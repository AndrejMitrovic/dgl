/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.shader;

import std.file;
import std.exception;
import std.path;
import std.stdio;
import std.string;
import std.typecons;

import minilib.core.test;

import derelict.opengl3.gl3;

import dgl.test.util;

/// All possible OpenGL shader types
enum ShaderType
{
    /// sentinel
    invalid,

    ///
    vertex = GL_VERTEX_SHADER,

    ///
    geometry = GL_GEOMETRY_SHADER,

    ///
    fragment = GL_FRAGMENT_SHADER,
}

///
class ShaderException : Exception
{
    this(ShaderType shaderType, in char[] shaderName, in char[] shaderFile, in char[] log)
    {
        this.shaderName = shaderName;
        this.shaderFile = shaderFile;

        string error =
            format("Failed to compile shader '%s' of type '%s'%s:\n%s",
                   shaderName, shaderType,
                   shaderFile !is null ? format(" from file '%s'", shaderFile) : "",
                   log);

        super(error);
    }

    /// The shader name. If shader was read from disk it is the base name of the file name.
    const(char)[] shaderName;

    /// The shader file. If the shader was read from memory it will be empty.
    const(char)[] shaderFile;
}

/**
    The OpenGL shader type.
    This is a refcounted type which can be freely copied around.
    Once the reference count reaches 0 the underlying shader
    will be deleted.
*/
struct Shader
{
    /**
        Read the shader of type $(D shaderType) from
        the file $(D fileName) and compile it.

        The shader name will be equal to $(D fileName).
    */
    this(ShaderType shaderType, in char[] fileName)
    {
        _data = Data(shaderType, fileName);
    }

    /**
        Read the shader of type $(D shaderType) from
        the shader code in $(D shaderText). The shader
        name will be set to $(D shaderName).

        This is the constructor version which doesn't
        read the shader code from disk, but from the
        in-memory buffer $(D shaderText).
    */
    //~ this(ShaderType shaderType, in char[] shaderName, in char[] shaderText)
    //~ {
        //~ _data = Data(shaderType, shaderName, shaderText);
    //~ }

    /** Explicitly delete the OpenGL shader. */
    void remove()
    {
        _data.remove();
    }

    // internal API
    package GLuint shaderID()
    {
        return _data._shaderID;
    }

private:

    alias Data = RefCounted!(ShaderImpl, RefCountedAutoInitialize.no);
    Data _data;
}

private struct ShaderImpl
{
    this(ShaderType shaderType, in char[] shaderFile)
    {
        require(shaderType.isValidEnum, "Shader type is uninitialized.");
        require(shaderFile.exists, "Shader file '%s' does not exist.", shaderFile);

        _shaderType = shaderType;
        _shaderName = shaderFile.baseName;
        _shaderID = verify!glCreateShader(cast(GLenum)shaderType);

        string shaderText = shaderFile.readText();

        auto shaderPtr = shaderText.ptr;
        auto shaderLen = cast(int)shaderText.length;
        enum elemCount = 1;

        verify!glShaderSource(_shaderID, elemCount, &shaderPtr, &shaderLen);
        this.compileShader();
    }

    private void compileShader()
    {
        verify!glCompileShader(_shaderID);

        GLint status;
        verify!glGetShaderiv(_shaderID, GL_COMPILE_STATUS, &status);
        if (status == GL_TRUE)
            return;

        /* read the error log and throw */
        GLint logLength;
        verify!glGetShaderiv(_shaderID, GL_INFO_LOG_LENGTH, &logLength);

        GLchar[] logBuff = new GLchar[logLength];
        verify!glGetShaderInfoLog(_shaderID, logLength, null, logBuff.ptr);

        auto log = logBuff[0 .. logLength - 1];
        throw new ShaderException(_shaderType, _shaderName, _shaderFile, log);
    }

    ~this()
    {
        remove();
    }

    private void remove()
    {
        if (_shaderID != invalidShaderID)
        {
            verify!glDeleteShader(_shaderID);
            _shaderID = invalidShaderID;
        }
    }

    /// Should never perform copy
    @disable this(this);

    /// Should never perform assign
    @disable void opAssign(typeof(this));

    /* Shader data. */
    GLuint _shaderID = invalidShaderID;
    ShaderType _shaderType;
    const(char)[] _shaderName;
    const(char)[] _shaderFile;

    // sentinel
    private enum invalidShaderID = GLuint.max;
}
