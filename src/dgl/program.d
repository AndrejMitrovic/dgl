/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.program;

import std.array;
import std.string;
import std.typecons;

import derelict.opengl3.gl3;

import dgl.shader;

import dgl.test.util;

///
class ProgramException : Exception
{
    this(in char[] log)
    {
        string error = format("Failed to link shaders:\n%s", log);
        super(error);
    }

    /// The file the shader was read from.
    const(char)[] fileName;
}

/**
    The OpenGL program type.
    This is a refcounted type which can be freely copied around.
    Once the reference count reaches 0 the underlying program
    and all shaders it references will be deleted.
*/
struct Program
{
    /**
        Initialize the program with a list of shaders.
    */
    this(Shader[] shaders...)
    {
        _data = Data(shaders);
    }

    /** Explicitly delete the OpenGL program. */
    void remove()
    {
        _data.remove();
    }

private:
    alias Data = RefCounted!(ProgramImpl, RefCountedAutoInitialize.no);
    Data _data;
}

private struct ProgramImpl
{
    this(Shader[] shaders...)
    {
        _programID = verify!glCreateProgram();

        _shaders.reserve(shaders.length);

        foreach (shader; shaders)
        {
            verify!glAttachShader(_programID, shader.shaderID);
            _shaders ~= shader;
        }

        link();
    }

    private void link()
    {
        verify!glLinkProgram(_programID);

        GLint status;
        verify!glGetProgramiv(_programID, GL_LINK_STATUS, &status);
        if (status == GL_TRUE)
            return;

        /* read the error log and throw */
        GLint logLength;
        verify!glGetProgramiv(_programID, GL_INFO_LOG_LENGTH, &logLength);

        GLchar[] logBuff = new GLchar[logLength];
        verify!glGetProgramInfoLog(_programID, logLength, null, logBuff.ptr);

        assert(0, logBuff);

        auto log = logBuff[0 .. logLength - 1];
        throw new ProgramException(log);
    }

    ~this()
    {
        remove();
    }

    private void remove()
    {
        if (_programID != invalidProgramID)
        {
            verify!glDeleteProgram(_programID);
            _programID = invalidProgramID;
        }
    }

    /// Should never perform copy
    @disable this(this);

    /// Should never perform assign
    @disable void opAssign(typeof(this));

    // data
    GLuint _programID = invalidProgramID;

    /// list of all shaders
    Shader[] _shaders;

    // sentinel
    private enum invalidProgramID = GLuint.max;
}
