/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.program;

import std.array;
import std.stdio;
import std.string;
import std.typecons;

import derelict.opengl3.gl3;

import dgl.shader;
import dgl.uniform;

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

    /**
        Get the uniform of name $(D uniformName) in the program.
        Note that if the uniform is not used in the shader program
        by any of its code, an invalid $(D Uniform) will be returned,
        and a message will be written to $(D stderr).
    */
    Uniform getUniform(string uniformName)
    {
        return _data.getUniform(uniformName);
    }

    /** Set the $(D uniform) value in this program. */
    void setUniform1f(Uniform uniform, float value)
    {
        _data.setUniform1f(uniform, value);
    }

    /// ditto
    void setUniform2f(Uniform uniform, float value1, float value2)
    {
        _data.setUniform2f(uniform, value1, value2);
    }

    /// ditto
    void setUniform4f(Uniform uniform, float value1, float value2, float value3, float value4)
    {
        _data.setUniform4f(uniform, value1, value2, value3, value4);
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

    private Uniform getUniform(string uniformName)
    {
        auto uniformLocation = verify!glGetUniformLocation(_programID, uniformName.toStringz);

        if (uniformLocation < 0)
            stderr.writefln("Warning: 'glGetAttribLocation' returned '%s' for location: '%s'",
                            uniformLocation, uniformName);

        return Uniform(uniformLocation);
    }

    private void setUniform1f(Uniform uniform, float value)
    {
        verify!glUniform1f(uniform._uniformID, value);
    }

    private void setUniform2f(Uniform uniform, float value1, float value2)
    {
        verify!glUniform2f(uniform._uniformID, value1, value2);
    }

    private void setUniform4f(Uniform uniform, float value1, float value2, float value3, float value4)
    {
        verify!glUniform4f(uniform._uniformID, value1, value2, value3, value4);
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

    // sentinel
    private enum invalidProgramID = -1;

    // unbind
    private enum nullProgramID = 0;
}
