/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.buffer;

import std.exception;
import std.stdio;
import std.typecons;

import dgl.attribute;
import dgl.loader;
import dgl.util;

/// All possible OpenGL usage hints
enum UsageHint
{
    /// sentinel
    invalid,

    ///
    staticDraw = GL_STATIC_DRAW,

    ///
    dynamicDraw = GL_DYNAMIC_DRAW,

    ///
    streamDraw = GL_STREAM_DRAW,
}

/**
    The OpenGL buffer type.

    The $(D release) method should be called for manual release of OpenGL resources.
*/
class GLBuffer
{
    /**
        Create and initialize an OpenGL buffer with the
        contents of $(D buffer) and the buffer hint $(D usageHint).
    */
    this(T)(T[] buffer, UsageHint usageHint)
    {
        _data = Data(buffer, usageHint);
    }

    /**
        Write the $(D buffer) data to this buffer, at byte offset $(D byteOffset).
        This will overwrite the data that was already in the buffer.
    */
    void write(T)(T[] buffer, ptrdiff_t byteOffset = 0)
    {
        _data.write(buffer, byteOffset);
    }

    /** Bind this buffer to an attribute. */
    void bind(Attribute attribute, int size, GLenum type, bool normalized, int stride, int offset)
    {
        _data.bind(attribute, size, type, cast(GLboolean)normalized, stride, offset);
    }

    /** Unbind this buffer. */
    void unbind()
    {
        _data.unbind();
    }

    /** Explicitly delete the OpenGL buffer. */
    void release()
    {
        _data.release();
    }

    ///
    @property GLuint ID() { return _data._bufferID; }

private:

    alias Data = GLBufferImpl;
    Data _data;
}

private struct GLBufferImpl
{
    this(T)(T[] buffer, UsageHint usageHint)
    {
        enforce(usageHint != UsageHint.invalid, "Usage hint is uninitialized.");

        glGenBuffers(bufferCount, &_bufferID);
        glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
        glBufferData(GL_ARRAY_BUFFER, buffer.memSizeOf, buffer.ptr, cast(GLenum)usageHint);
        glBindBuffer(GL_ARRAY_BUFFER, nullBufferID);
    }

    void write(T)(T[] buffer, ptrdiff_t byteOffset)
    {
        glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
        glBufferSubData(GL_ARRAY_BUFFER, byteOffset, buffer.memSizeOf, buffer.ptr);
        glBindBuffer(GL_ARRAY_BUFFER, nullBufferID);
    }

    void bind(Attribute attribute, GLint size, GLenum type, GLboolean normalized, GLsizei stride, GLsizei offset)
    {
        glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
        glVertexAttribPointer(attribute._attributeID, size, type, normalized, stride, cast(void*)offset);
    }

    void unbind()
    {
        glBindBuffer(GL_ARRAY_BUFFER, nullBufferID);
    }

    void release()
    {
        if (_bufferID != invalidBufferID)
        {
            glDeleteBuffers(bufferCount, &_bufferID);
            _bufferID = invalidBufferID;
        }
    }

    debug ~this()
    {
        if (_bufferID != invalidBufferID)
            stderr.writefln("%s(%s): OpenGL: Buffer resources not released.", __FILE__, __LINE__);
    }

    /* Buffer data. */
    GLuint _bufferID = invalidBufferID;

    private enum bufferCount = 1;

    // sentinel
    private enum invalidBufferID = -1;

    // used for unbinding
    private enum nullBufferID = 0;
}
