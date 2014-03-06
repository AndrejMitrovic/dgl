/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.uniform;

import dgl.loader;

/** An OpenGL uniform location. */
struct Uniform
{
    /** Construct a uniform with the given $(D uniformID). */
    this(GLint uniformID)
    {
        _uniformID = uniformID;
    }

    /// Temporary
    @property GLint ID()
    {
        return _uniformID;
    }

package:
    GLint _uniformID = invalidUniformID;

    private enum invalidUniformID = -1;
}
