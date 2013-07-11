/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.buffer;

import std.stdio;
import std.typecons;

import minilib.core.array;
import minilib.core.test;

import derelict.opengl3.gl3;

import dgl.test.util;

/// All possible OpenGL usage hints
enum UsageHint
{
    /// sentinel
    invalid,

    ///
    staticDraw = GL_STATIC_DRAW,
}

/**
    The OpenGL buffer type.
    This is a refcounted type which can be freely copied around.
    Once the reference count reaches 0 the underlying OpenGL buffer
    will be deleted.
*/
struct GLBuffer
{
    /**
        Create and initialize an OpenGL buffer with the
        contents of $(D buffer) and the buffer hint $(D bufferHint).
    */
    this(T)(T[] buffer, UsageHint bufferHint)
    {
        _data = Data(buffer, bufferHint);
    }

    /** Explicitly delete the OpenGL buffer. */
    void remove()
    {
        _data.remove();
    }

private:

    alias Data = RefCounted!(GLBufferImpl, RefCountedAutoInitialize.no);
    Data _data;
}

private struct GLBufferImpl
{
    this(T)(T[] buffer, UsageHint bufferHint)
    {
        require(bufferHint.isValidEnum, "Draw hint is uninitialized.");

        verify!glGenBuffers(magicGenBuffIndex, &_bufferID);
        verify!glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
        verify!glBufferData(GL_ARRAY_BUFFER, buffer.memSizeOf, buffer.ptr, cast(GLenum)bufferHint);
        verify!glBindBuffer(GL_ARRAY_BUFFER, nullBufferID);
    }

    ~this()
    {
        remove();
    }

    private void remove()
    {
        if (_bufferID != nullBufferID)
        {
            verify!glDeleteBuffers(magicDeleteIndex, &_bufferID);
            _bufferID = nullBufferID;
        }
    }

    /// Should never perform copy
    @disable this(this);

    /// Should never perform assign
    @disable void opAssign(typeof(this));

    /* Buffer data. */
    GLuint _bufferID = nullBufferID;

    /* todo: figure out why it's a '1' here for both enums. */
    private enum magicDeleteIndex = 1;
    private enum magicGenBuffIndex = 1;

    // sentinel
    private enum nullBufferID = 0;
}
