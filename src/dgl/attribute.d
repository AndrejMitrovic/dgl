/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.attribute;

import derelict.opengl3.gl3;

import dgl.test.util;

/** An OpenGL attribute. */
struct Attribute
{
    GLint location = invalidAttributeID;
    alias location this;

    /**
        Enable this attribute.

        $(BLUE Note:) An attribute must be enabled before rendering.
    */
    void enable()
    {
        verify!glEnableVertexAttribArray(cast(GLint)location);
    }

    /**
        Disable this attribute.
    */
    void disable()
    {
        verify!glDisableVertexAttribArray(cast(GLint)location);
    }

    // sentinel
    private enum invalidAttributeID = -1;
}
