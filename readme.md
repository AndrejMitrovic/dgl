# dgl

This is a personal and minimal D OpenGL wrapper library.
It uses either [Derelict3] or [glad] to load the OpenGL function pointers.

Only tested on Windows 7.

## Building

Use [dub] to add `dgl` as a dependency to your projects.

Use one of the two configuration, depending on whether you want to use
[Derelict3] or [glad] for loading the function pointers:

```
dub --config=dgl-derelict

dub --config=dgl-glad
```

## License

Distributed under the [Boost Software License][BoostLicense], Version 1.0.

See the accompanying file [license.txt](https://raw.github.com/AndrejMitrovic/dtk/master/license.txt) or an online copy [here][BoostLicense].

[dub]: http://code.dlang.org/download
[BoostLicense]: http://www.boost.org/LICENSE_1_0.txt
[Derelict3]: https://github.com/aldacron/Derelict3
[glad]: https://github.com/Dav1dde/glad
