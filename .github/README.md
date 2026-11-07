# libfprint + FocalTech FT9366 driver

[![CI](https://github.com/Anish-0211/libfprint-fork/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Anish-0211/libfprint-fork/actions/workflows/ci.yml)

An open-source [libfprint](https://gitlab.freedesktop.org/libfprint/libfprint) driver for the
**FocalTech FT9366 fingerprint sensor behind a Realtek RTS5811 USB bridge (`2808:a658`)**, found
in ASUS VivoBook laptops and others:

```
ID 2808:a658 Realtek USB2.0 Finger Print Bridge FocalTech Fingerprint Device
```

Until now the only way to use this sensor on Linux was FocalTech's closed-source libfprint
build, which is stuck at libfprint 1.94.4 and needs binary patching on current distributions.
This driver is written from scratch, contains no vendor code, and works with current libfprint
and fprintd.

The driver is in `libfprint/drivers/ft9366.c` (USB protocol, finger detection, capture) and
`libfprint/drivers/ft9366-match.{c,h}` (image processing and matching). Everything else is
upstream libfprint. Branch `ft9366` is upstream `master` plus the driver commits.

## Status

Enroll, verify and identify work through fprintd, including `sudo` via `pam_fprintd`.

| | Result |
|---|---|
| Enrolled finger, live | 20/20 and 18/20 accepted in two test sessions |
| Other fingers, live | 0/45 accepted |
| Recorded touches, across sessions | 82 % accepted, 0 of 1,764 other-finger comparisons accepted |

This is new code tested on one laptop. Keep a password fallback (`pam_fprintd` as
`sufficient`) and treat it as convenience, not as a security boundary, until it has seen more
hardware and more people. Reports from other `2808:a658` machines are very welcome.

How it works:

- **Capture**: waits for the finger to settle, keeps the best of up to 4 frames, rejects empty
  frames, and recalibrates the sensor if its finger-detect baseline was taken with a finger on it.
- **Matching**: the sensor sees only ~3×4 mm of finger, too little for libfprint's minutiae
  matcher. Instead: SIFT-style keypoints and descriptors, a pose found by keypoint pairs that
  agree in position and orientation, then a check that the ridges actually line up.
- **Enrollment**: 20 touches, near-duplicates rejected, registered into one template so a later
  touch can match across several enrolled touches.

## Install

### Arch Linux

```sh
git clone https://github.com/tattwamashi/libfprint-ft9366-pkg
cd libfprint-ft9366-pkg
makepkg -si
```

It builds the official libfprint 1.94.100 release with this driver as a patch, with Arch's build
options and every upstream driver, and replaces the `libfprint` package. Prebuilt packages are
on that repository's [releases](https://github.com/tattwamashi/libfprint-ft9366-pkg/releases).
An AUR package (`libfprint-ft9366`) will follow once AUR registration reopens.

Then:

```sh
fprintd-enroll          # 20 touches; place the finger as you would to unlock
fprintd-verify
```

Fingerprint for `sudo`, with the password as fallback:

```sh
sudo sed -i '1a auth\t\tsufficient\tpam_fprintd.so max-tries=3 timeout=10' /etc/pam.d/sudo
```

### From source

```sh
meson setup build -Ddrivers=ft9366 -Ddoc=false -Dgtk-examples=false -Dintrospection=false
ninja -C build
```

## Tips

- The sensor often sits on the power button. A light touch is enough, and a firm press may
  power the laptop off.
- The sensor is tiny: enroll with the finger placed the way you will actually touch it, shifting
  a millimetre or two between touches.
- If a scan fails, lift the finger completely before trying again.

## Notes from this fork

This fork ([Anish-0211](https://github.com/Anish-0211)) builds on the driver above and adds
tuning, speed and tooling changes. The driver itself is the original authors' work (see
Credits). The results below are from **one unit** and are separate from the test numbers in
Status.

**Tested on:** ASUS VivoBook K3502ZA, Ubuntu 26.10 (kernel 7.3), fprintd 1.94.5 with this
fork's libfprint installed under `/usr/local`.

**What did not work out of the box.** On this unit every touch was rejected as "finger not
centered". The raw frames showed why: 96.9 % of pixels sat at 4092, the top of the 12-bit range, both
with and without a finger, so the image carried no signal. The reported 25 % "coverage" was
only noise in the two edge columns. The imaging DAC default (`0x3b`) was just outside this
unit's usable window.

**What changed:**

- **Imaging DAC default `0x3b` to `0x36`.** A sweep of the DAC found the usable window at
  `0x34` to `0x38`; `0x36` is its middle. From `0x20` to `0x31` the frames were all zero, from
  `0x3b` up all saturated, and `0x00` and `0x10` made the sensor time out.

  | `FT9366_IMG_DAC` | Mid-scale pixels |
  |---|---|
  | `0x31` | 0 % |
  | `0x33` | 28 % |
  | `0x34` | 96 % |
  | `0x35` to `0x38` | 99 to 100 % |
  | `0x39` | 62 % |
  | `0x3a` | 2 % |
  | `0x3b` | 0 % (saturated) |

- **Verify and identify no longer wait for the finger to lift.** Enroll still does. The
  match arrives about 0.5 s after the finger lands instead of about 0.9 s.
- **Overrides for tuning your own unit:** `FT9366_IMG_DAC` and `FT9366_INTEGRATION` change the
  imaging DAC and the bridge integration byte at runtime (for example `FT9366_IMG_DAC=0x35`),
  and `FT9366_DUMP=<dir>` writes every capture, raw frame and background as image files.
  Frame dumps are biometric data: keep them out of version control.
- **Tooling:** `make setup`, `make check` (format check, strict `cppcheck` lint, build and
  tests) and CI. See the Development section of the root
  [README.md](../README.md).

**Measured on this unit** (single runs, not a benchmark):

| | Before | After |
|---|---|---|
| Touch coverage reported by the driver | 25 % | 97 % |
| Enroll | 0 of 20 stages | 20 of 20 |
| Finger down to match | about 930 ms | about 476 ms |

Enroll, verify, `sudo` through `pam_fprintd`, GNOME lock screen unlock, suspend/resume and
reboot all work, and fingers other than the enrolled one were rejected. **Not yet verified:**
any other `2808:a658` unit.

**Tuning another unit:** if touches are rejected with coverage stuck near 25 %, run with
`FT9366_DUMP` set and check whether the frames are saturated. If they are, try other
`FT9366_IMG_DAC` values around `0x30` to `0x40` and look for frames that use the middle of the
range.

## Credits

- **V8V88V8V88**: the original FT9366 driver this work builds on (USB protocol, finger detection,
  capture), and the [ft9366-rek](https://github.com/V8V88V8V88/ft9366-rek) protocol notes.
- **Tattwamashi Nayak**: capture reliability, the matcher, enrollment, packaging.
- The **libfprint** project.

License: LGPL-2.1-or-later, as libfprint.
