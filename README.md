

<div align="center">

# LibFPrint

*LibFPrint is part of the **[FPrint][Website]** project.*

<br/>

[![Button Website]][Website]
[![Button Documentation]][Documentation]

[![Button Supported]][Supported]
[![Button Unsupported]][Unsupported]

[![Button Contribute]][Contribute]
[![Button Contributors]][Contributors]

</div>

> **About this fork.** This is a fork of [libfprint](https://gitlab.freedesktop.org/libfprint/libfprint)
> with a driver for the FocalTech FT9366 fingerprint sensor (`2808:a658`). The driver was written by
> **V8V88V8V88** and **Tattwamashi Nayak**; see [.github/README.md](./.github/README.md) for the
> driver's status, install steps and full credits. This fork is maintained by
> [Anish-0211](https://github.com/Anish-0211) and is not affiliated with the upstream libfprint project.

## History

**LibFPrint** was originally developed as part of an
academic project at the **[University Of Manchester]**.

It aimed to hide the differences between consumer
fingerprint scanners and provide a single uniform
API to application developers.

## Goal

The ultimate goal of the **FPrint** project is to make
fingerprint scanners widely and easily usable under
common Linux environments.

## License

This project is licensed under the **GNU Lesser General Public License,
version 2.1 or (at your option) any later version** (`LGPL-2.1-or-later`).
The full text is in [COPYING](./COPYING).

In short, you are free to use, study, modify and redistribute this library,
including in proprietary software, provided that you:

 - keep the copyright notices and the license text with the code;
 - release any modifications you make to the library itself under the LGPL;
 - allow users of your software to replace the library with a modified
   version (for example by linking it dynamically);
 - clearly mark your changes.

The library comes with **no warranty**. See [COPYING](./COPYING) for details.

Copyright remains with the original authors listed in [AUTHORS](./AUTHORS) and
in the headers of each source file, including the authors of the FT9366 driver
(`libfprint/drivers/ft9366*`). Forking does not change the copyright holders.

`Section 6` of the license states that for compiled works that use
this library, such works must include **LibFPrint** copyright notices
alongside the copyright notices for the other parts of the work.

**LibFPrint** includes code from **NIST's** **[NBIS]** software distribution.

We include **Bozorth3** from the **[US Export Controlled]**
distribution, which we have determined to be fine
being shipped in an open source project.

## Development

A `Makefile` wraps the project's build, test, formatting and analysis tools:

| Command | What it does | Needs |
|---|---|---|
| `make` / `make build` | Configure with Meson and build with Ninja into `build/` | `meson`, `ninja` |
| `make test` | Run the Meson test suite | `meson` |
| `make format` | Format all C sources with the project's `uncrustify` config | `uncrustify` |
| `make format-check` | Check formatting without changing files | `uncrustify` |
| `make lint` | Run `cppcheck` on the FT9366 driver files | `cppcheck` |
| `make scan` | Run clang's static analyzer (`scan-build`) in `build-scan/` | `clang-tools` |
| `make asan` | Build and test with AddressSanitizer and UBSan in `build-asan/` | `meson`, `gcc` or `clang` |
| `make valgrind` | Run the tests under `valgrind` with the project's suppressions | `valgrind` |
| `make check` | `format-check`, `lint` and `test` together | all of the above |
| `make clean` | Remove the build directories | |

On Ubuntu, install the extra tools with:

```sh
sudo apt install uncrustify cppcheck valgrind clang-tools
```

Please run `make format` and `make check` before sending changes. See
[HACKING.md](./HACKING.md) for the full contribution guide.

## Get in *touch*

 - [IRC] - `#fprint` @ `irc.oftc.net`
 - [Matrix] - `#fprint:matrix.org` bridged to the IRC channel
 - [MailingList] - low traffic, not much used these days

<br/>

<div align="right">

[![Badge License]][License]

</div>


<!----------------------------------------------------------------------------->

[Documentation]: https://fprint.freedesktop.org/libfprint-dev/
[Contributors]: https://gitlab.freedesktop.org/libfprint/libfprint/-/graphs/master
[Unsupported]: https://gitlab.freedesktop.org/libfprint/wiki/-/wikis/Unsupported-Devices
[Supported]: https://fprint.freedesktop.org/supported-devices.html
[Website]: https://fprint.freedesktop.org/
[MailingList]: https://lists.freedesktop.org/mailman/listinfo/fprint
[IRC]: ircs://irc.oftc.net:6697/#fprint
[Matrix]: https://matrix.to/#/#fprint:matrix.org

[Contribute]: ./HACKING.md
[License]: ./COPYING

[University Of Manchester]: https://www.manchester.ac.uk/
[US Export Controlled]: https://fprint.freedesktop.org/us-export-control.html
[NBIS]: http://fingerprint.nist.gov/NBIS/index.html


<!---------------------------------[ Badges ]---------------------------------->

[Badge License]: https://img.shields.io/badge/License-LGPL2.1-015d93.svg?style=for-the-badge&labelColor=blue


<!---------------------------------[ Buttons ]--------------------------------->

[Button Documentation]: https://img.shields.io/badge/Documentation-04ACE6?style=for-the-badge&logoColor=white&logo=BookStack
[Button Contributors]: https://img.shields.io/badge/Contributors-FF4F8B?style=for-the-badge&logoColor=white&logo=ActiGraph
[Button Unsupported]: https://img.shields.io/badge/Unsupported_Devices-EF2D5E?style=for-the-badge&logoColor=white&logo=AdBlock
[Button Contribute]: https://img.shields.io/badge/Contribute-66459B?style=for-the-badge&logoColor=white&logo=Git
[Button Supported]: https://img.shields.io/badge/Supported_Devices-428813?style=for-the-badge&logoColor=white&logo=AdGuard
[Button Website]: https://img.shields.io/badge/Homepage-3B80AE?style=for-the-badge&logoColor=white&logo=freedesktopDotOrg
