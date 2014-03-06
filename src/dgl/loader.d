/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.loader;

import std.exception;

version (dgl_use_derelict)
{
    public
    {
        import derelict.opengl3.gl3;
        import derelict.opengl3.gl;
        import derelict.opengl3.gl3;
        import derelict.opengl3.deprecatedConstants;
        import derelict.opengl3.constants;
    }

    /// necessary aliases to match glad
    public import derelict.opengl3.arb :
        GL_ARB_debug_output = ARB_debug_output,
        GL_KHR_debug = KHR_debug;

    private import derelict.opengl3.types :
        DerelictGLVersion = GLVersion;

    /// compatibility with glad
    struct GLVersion
    {
    static:
        ///
        @property int major()
        {
            final switch (_derelictGLVersion) with (DerelictGLVersion)
            {
                case None:
                    assert(0);

                case GL11, GL12, GL13, GL14, GL15:
                    return 1;

                case GL20, GL21:
                    return 2;

                case GL30, GL31, GL32, GL33:
                    return 3;

                case GL40, GL41, GL42, GL43:
                    return 4;
            }
        }

        ///
        @property int minor()
        {
            final switch (_derelictGLVersion) with (DerelictGLVersion)
            {
                case None:
                    assert(0);

                case GL20, GL30, GL40:
                    return 0;

                case GL11, GL21, GL31, GL41:
                    return 1;

                case GL12, GL32, GL42:
                    return 2;

                case GL13, GL33, GL43:
                    return 3;

                case GL14:
                    return 4;

                case GL15:
                    return 5;
            }
        }
    }

    /// Initialize GL
    void initGL()
    {
        // initialize derelict
        DerelictGL.load();
    }

    /// Load GL
    void loadGL()
    {
        // load all derelict function pointers
        _derelictGLVersion = DerelictGL.reload();
    }

    private __gshared DerelictGLVersion _derelictGLVersion;
}
else
version (dgl_use_glad)
{
    public
    {
        import glad.gl.ext;
        import glad.gl.gl;
        import glad.gl.loader;
    }

    /// no-op: not required for glad.
    void initGL()
    {
    }

    /// Load GL
    void loadGL()
    {
        // load all glad function pointers
        enforce(gladLoadGL());
    }
}
