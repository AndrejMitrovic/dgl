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
    this(ShaderType shaderType, in char[] log)
    {
        string error = format("Failed to compile shader of type '%s':\n%s", shaderType, log);
        super(error);
    }
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
        Create a shader of type $(D shaderType) from
        the shader code in $(D shaderText).
    */
    this(ShaderType shaderType, in char[] shaderText)
    {
        require(!shaderText.exists, "Attempted to pass a shader file '%s' instead of the shader code. Use 'Shader.fromFile' to load a shader from disk.", shaderText);
        _data = Data(shaderType, shaderText);
    }

    /**
        Create a shader of type $(D shaderType) from
        the file $(D shaderFile) and return it.
    */
    static Shader fromFile(ShaderType shaderType, in char[] shaderFile)
    {
        require(shaderFile.exists, "Shader file '%s' does not exist.", shaderFile);
        string shaderText = shaderFile.readText();
        return Shader(shaderType, shaderText);
    }

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
    this(ShaderType shaderType, in char[] shaderText)
    {
        require(shaderType.isValidEnum, "Shader type is uninitialized.");

        _shaderType = shaderType;
        _shaderID = verify!glCreateShader(cast(GLenum)shaderType);

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
        throw new ShaderException(_shaderType, log);
    }

    ~this()
    {
        remove();
    }

    private void remove()
    {
        if (_shaderID != nullShaderID)
        {
            verify!glDeleteShader(_shaderID);
            _shaderID = nullShaderID;
        }
    }

    /// Should never perform copy
    @disable this(this);

    /// Should never perform assign
    @disable void opAssign(typeof(this));

    /* Shader data. */
    GLuint _shaderID = nullShaderID;
    ShaderType _shaderType;

    // sentinel
    private enum nullShaderID = 0;
}
