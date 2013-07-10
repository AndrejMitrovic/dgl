# dgl

This is a personal D OpenGL API wrapper library, and a work in progress. It uses [Derelict3] to dynamically load the OpenGL shared libraries.

[Derelict3]: https://github.com/aldacron/Derelict3

This is a personal library and does not have any feature list / plans / or any guarantees that it will work for you.

Currently it's only tested on Windows 7.

## Building

Make sure you're using the latest compiler. Sometimes that even means using the latest git-head version
(sorry about that).

Either set the `DERELICT3_HOME` environment variable, or clone the dependency alongside `dgl`, so the `Derelict3` and `dgl` folders are alongside one another in the same directory.

Run the `build.bat` file to both run the unittests and generate a static library in the `bin` subfolder.

## Dependencies

- [Derelict3](https://github.com/aldacron/Derelict3)

## License

Distributed under the Boost Software License, Version 1.0.
See accompanying file LICENSE_1_0.txt or copy [here][BoostLicense].

[BoostLicense]: http://www.boost.org/LICENSE_1_0.txt
