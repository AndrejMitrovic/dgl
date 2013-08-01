/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.loader;

import std.exception;

import dgl.versions;

static if (DGL_Versions.use_derelict)
{
    public
    {
        import derelict.opengl3.gl3;
        import derelict.opengl3.gl;
        import derelict.opengl3.gl3;
        import derelict.opengl3.deprecatedConstants;
        import derelict.opengl3.constants;
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
        enforce(DerelictGL.reload());
    }
}
else
static if (DGL_Versions.use_glad)
{
    public
    {
        import glad.gl;
    }

    import glad.loader;

    /// Initialize GL
    void initGL()
    {
        // initialize glad
        enforce(gladInit());
    }

    /// Load GL
    void loadGL()
    {
        // load all glad function pointers
        enforce(gladLoadGL());
    }
}
