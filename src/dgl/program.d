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

import dgl.attribute;
import dgl.loader;
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
}

/**
    The OpenGL program type.

    The $(D release) method should be called for manual release of OpenGL resources.

    $(B Note:) The program will not call the shaders' $(B release()) method after construction.
*/
class Program
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
    void release()
    {
        _data.release();
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
        Get the attribute of name $(D attributeName) in the program.
        Note that if the attribute is not used in the shader program
        by any of its code, an invalid $(D Attribute) will be returned,
        and a message will be written to $(D stderr).
    */
    Attribute getAttribute(string attributeName)
    {
        return _data.getAttribute(attributeName);
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

    // todo: add getFragment: glGetFragDataLocation

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
    alias Data = ProgramImpl;
    Data _data;
}

private struct ProgramImpl
{
    this(Shader[] shaders...)
    {
        _programID = verify!glCreateProgram();

        foreach (shader; shaders)
            verify!glAttachShader(_programID, shader.shaderID);

        this.link();

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

    private Attribute getAttribute(string attributeName)
    {
        auto attributeLocation = verify!glGetAttribLocation(_programID, attributeName.toStringz);

        if (attributeLocation < 0)
            stderr.writefln("Warning: 'glGetAttribLocation' returned '%s' for location: '%s'",
                            attributeLocation, attributeName);

        return Attribute(attributeLocation);
    }

    private Uniform getUniform(string uniformName)
    {
        auto uniformLocation = verify!glGetUniformLocation(_programID, uniformName.toStringz);

        if (uniformLocation < 0)
            stderr.writefln("Warning: 'glGetUniformLocation' returned '%s' for location: '%s'",
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

    private void release()
    {
        if (_programID != invalidProgramID)
        {
            verify!glDeleteProgram(_programID);
            _programID = invalidProgramID;
        }
    }

    debug ~this()
    {
        if (_programID != invalidProgramID)
            stderr.writeln("OpenGL: Program resources not released.");
    }

    // data
    GLuint _programID = invalidProgramID;

    // sentinel
    private enum invalidProgramID = -1;

    // unbind
    private enum nullProgramID = 0;
}
