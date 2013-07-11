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
    is deleted.

    $(B Note:) The program will not call $(B remove()) on the
    shaders after linking, you have to do this manually.
*/
struct Program
{
    /**
        Initialize the program with a list of shaders,
        and create and link the program.
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

    /** Start using this OpenGL program. */
    void bind()
    {
        _data.bind();
    }

    /** Stop using this OpenGL program. */
    void unbind()
    {
        _data.unbind();
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

        foreach (shader; shaders)
            verify!glAttachShader(_programID, shader.shaderID);

        link();

        foreach (shader; shaders)
            verify!glDetachShader(_programID, shader.shaderID);
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

        auto log = logBuff[0 .. logLength - 1];
        throw new ProgramException(log);
    }

    private void bind()
    {
        verify!glUseProgram(_programID);
    }

    private void unbind()
    {
        verify!glUseProgram(nullProgramID);
    }

    ~this()
    {
        remove();
    }

    private void remove()
    {
        if (_programID != nullProgramID)
        {
            verify!glDeleteProgram(_programID);
            _programID = nullProgramID;
        }
    }

    /// Should never perform copy
    @disable this(this);

    /// Should never perform assign
    @disable void opAssign(typeof(this));

    // data
    GLuint _programID = nullProgramID;

    // sentinel
    private enum nullProgramID = 0;
}
