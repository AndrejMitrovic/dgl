# dgl

This is a personal D OpenGL API wrapper library, and a work in progress. It uses [Derelict3] to dynamically load the OpenGL shared libraries, and uses [glfw] in its test-suite for window management.

[Derelict3]: https://github.com/aldacron/Derelict3
[glfw]: https://github.com/D-Programming-Deimos/glfw

This is a personal library and does not have any feature list / plans / or any guarantees that it will work for you.

Currently it's only tested on Windows 7.

## Building

Make sure you're using the latest compiler. Sometimes that even means using the latest git-head version
(sorry about that).

Make sure the dependencies can be found either in these environment variables:

- `MINLIB_HOME`
- `DERELICT3_HOME`
- `DEIMOS_GLFW`

Or put the dependencies alongside `dgl`, so the directory structure becomes:

- `dir/dgl`
- `dir/minilib`
- `dir/Derelict3`
- `dir/glfw`

Run the `build.bat` file to both run the unittests and generate a static library in the `bin` subfolder.

## Dependencies

- [minilib](https://github.com/AndrejMitrovic/minilib)
- [Derelict3](https://github.com/aldacron/Derelict3)
- [glwf](https://github.com/D-Programming-Deimos/glfw)

## License

Distributed under the Boost Software License, Version 1.0.
See accompanying file LICENSE_1_0.txt or copy [here][BoostLicense].

[BoostLicense]: http://www.boost.org/LICENSE_1_0.txt
