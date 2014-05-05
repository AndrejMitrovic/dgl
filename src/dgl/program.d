/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.program;

import std.array;
import std.exception;
import std.stdio;
import std.string;
import std.typecons;

import dgl.attribute;
import dgl.loader;
import dgl.shader;
import dgl.uniform;

///
/+ class ProgramException : Exception
{
    this(in char[] log)
    {
        string error = format("Failed to link shaders:\n%s", log);
        super(error);
    }
} +/

//
/+ private enum isSupported(alias symbol, T = typeof(symbol))
    = is(T == Attribute) || is(T == Uniform); +/

/** A generic getter for uniforms and attributes in a program. */
/+ @property typeof(symbol) get(alias symbol)(Program program)
    if (isSupported!symbol)
{
    return get!(symbol, __traits(identifier, symbol))(program);
} +/

/**
    Ditto, but supports using a custom name in the shader
    that doesn't match the symbol name.
*/
/+ @property typeof(symbol) get(alias symbol, string name)(Program program)
    if (isSupported!symbol)
{
    return get!symbol(program, name);
} +/

/** Ditto, but the custom shader field name is a runtime value. */
/+ @property typeof(symbol) get(alias symbol)(Program program, string name)
    if (isSupported!symbol)
{
    alias Type = typeof(symbol);

    static if (is(Type == Attribute))
        return symbol = program.getAttribute(name);
    else
    static if (is(Type == Uniform))
        return symbol = program.getUniform(name);
    else
    static assert(0);
} +/

/** A generic setter for uniforms and attributes in a program. */
/+ void set(alias symbol, Args...)(Program program, Args args)
    if (isSupported!symbol)
{
    alias Type = typeof(symbol);

    static if (is(Type == Attribute))
        program.setAttribute(symbol, args);
    else
    static if (is(Type == Uniform))
        program.setUniform(symbol, args);
    else
    static assert(0);
} +/

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
    void setUniform(Uniform uniform, float value)
    {
        _data.setUniform1f(uniform, value);
    }

    /// ditto
    void setUniform1i(Uniform uniform, int value)
    {
        _data.setUniform1i(uniform, value);
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

    void setUniform2i(Uniform uniform, int value1, int value2)
    {
        _data.setUniform2i(uniform, value1, value2);
    }

private:
    alias Data = ProgramImpl;
    Data _data;
}

private struct ProgramImpl
{
    this(Shader[] shaders...)
    {
        _programID = glCreateProgram();

        foreach (shader; shaders)
            glAttachShader(_programID, shader.shaderID);

        this.link();

        foreach (shader; shaders)
            glDetachShader(_programID, shader.shaderID);
    }

    private void link()
    {
        glLinkProgram(_programID);

        GLint status;
        glGetProgramiv(_programID, GL_LINK_STATUS, &status);
        if (status == GL_TRUE)
            return;

        // todo: need to figure out why this path is continued even when
        // dgl_error_callback throws.

        /+ /* read the error log and throw */
        GLint logLength;
        glGetProgramiv(_programID, GL_INFO_LOG_LENGTH, &logLength);

        GLchar[] logBuff = new GLchar[logLength];
        glGetProgramInfoLog(_programID, logLength, null, logBuff.ptr);

        auto log = logBuff[0 .. logLength - 1];
        throw new ProgramException(log); +/
    }

    private void bind()
    {
        glUseProgram(_programID);
    }

    private void unbind()
    {
        glUseProgram(nullProgramID);
    }

    private Attribute getAttribute(string attributeName)
    {
        auto attributeLocation = glGetAttribLocation(_programID, attributeName.toStringz);
        enforce(attributeLocation >= 0,
                format("glGetAttribLocation returned '%s' for location: '%s'",
                       attributeLocation, attributeName));
        return Attribute(attributeLocation);
    }

    private Uniform getUniform(string uniformName)
    {
        auto uniformLocation = glGetUniformLocation(_programID, uniformName.toStringz);
        enforce(uniformLocation >= 0,
                format("glGetUniformLocation returned '%s' for location: '%s'",
                       uniformLocation, uniformName));
        return Uniform(uniformLocation);
    }

    private void setUniform1i(Uniform uniform, int value)
    {
        glUniform1i(uniform._uniformID, value);
    }

    private void setUniform1f(Uniform uniform, float value)
    {
        glUniform1f(uniform._uniformID, value);
    }

    private void setUniform2i(Uniform uniform, int value1, int value2)
    {
        glUniform2i(uniform._uniformID, value1, value2);
    }

    private void setUniform2f(Uniform uniform, float value1, float value2)
    {
        glUniform2f(uniform._uniformID, value1, value2);
    }

    private void setUniform4f(Uniform uniform, float value1, float value2, float value3, float value4)
    {
        glUniform4f(uniform._uniformID, value1, value2, value3, value4);
    }

    private void release()
    {
        if (_programID != invalidProgramID)
        {
            glDeleteProgram(_programID);
            _programID = invalidProgramID;
        }
    }

    debug ~this()
    {
        if (_programID != invalidProgramID)
            stderr.writefln("%s(%s): OpenGL: Program resources not released.", __FILE__, __LINE__);
    }

    // data
    GLuint _programID = invalidProgramID;

    // sentinel
    private enum invalidProgramID = -1;

    // unbind
    private enum nullProgramID = 0;
}
