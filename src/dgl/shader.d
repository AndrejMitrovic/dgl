/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.shader;

import std.file;
import std.exception;
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
    this(in char[] fileName, in char[] log)
    {
        this.fileName = fileName;
        string error = format("Failed to compileShader shader in file '%s':\n%s", fileName, log);
        super(error);
    }

    /// The file the shader was read from.
    const(char)[] fileName;
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
    */
    this(ShaderType shaderType, in char[] fileName)
    {
        _data = Data(shaderType, fileName);
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
    this(ShaderType shaderType, in char[] fileName)
    {
        require(shaderType.isValidEnum, "Shader type is uninitialized.");
        require(fileName.exists, "Shader file '%s' does not exist.", fileName);

        _fileName = fileName;
        _shaderID = verify!glCreateShader(cast(GLenum)shaderType);

        string shaderText = fileName.readText();

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
        throw new ShaderException(_fileName, log);
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

    // data
    GLuint _shaderID = invalidShaderID;
    const(char)[] _fileName;

    // sentinel
    private enum invalidShaderID = GLuint.max;
}
