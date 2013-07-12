/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.attribute;

import derelict.opengl3.gl3;

import dgl.test.util;

/** An OpenGL attribute location. */
struct Attribute
{
    /** Construct an attribute with the given $(D attributeID). */
    this(int attributeID)
    {
        _attributeID = attributeID;
    }

    /**
        Enable this attribute.

        $(BLUE Note:) An attribute must be enabled before rendering.
    */
    void enable()
    {
        verify!glEnableVertexAttribArray(cast(GLint)_attributeID);
    }

    /**
        Disable this attribute.
    */
    void disable()
    {
        verify!glDisableVertexAttribArray(cast(GLint)_attributeID);
    }

package:
    // location
    GLint _attributeID = invalidAttributeID;

    // sentinel
    private enum invalidAttributeID = -1;
}
