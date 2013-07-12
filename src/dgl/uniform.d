/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.uniform;

import derelict.opengl3.gl3;

/** An OpenGL uniform location. */
struct Uniform
{
    /**
        Construct the Uniform.

        A valid uniform can only be constructed from
        within the library, since it has to be
        queried for in the OpenGL program.
    */
    package this(GLuint uniformLocation)
    {
        _uniformID = uniformLocation;
    }

package:
    GLuint _uniformID = invalidUniformID;

    private enum invalidUniformID = -1;
}
