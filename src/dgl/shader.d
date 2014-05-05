/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.shader;

import std.algorithm;
import std.file;
import std.exception;
import std.path;
import std.stdio;
import std.string;
import std.typecons;

import dgl.loader;

///
/+ class ShaderException : Exception
{
    this(ShaderType shaderType, in char[] log)
    {
        string error = format("Failed to compile shader of type '%s':\n%s", shaderType, log);
        super(error);
    }
} +/

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

/**
    The OpenGL shader type.

    The $(D release) method should be called for manual release of OpenGL resources.
*/
class Shader
{
    /**
        Create a shader of type $(D shaderType) from
        the shader code in $(D shaderText).
    */
    static Shader fromText(ShaderType shaderType, in char[] shaderText)
    {
        return new Shader(shaderType, shaderText);
    }

    /**
        Create a shader of type $(D shaderType) from
        the file $(D shaderFile) and return it.
    */
    static Shader fromFile(ShaderType shaderType, in char[] shaderFile)
    {
        enforce(shaderFile.exists, "Shader file '%s' does not exist.".format(shaderFile));
        string shaderText = shaderFile.readText();
        return fromText(shaderType, shaderText);
    }

    // Use $(D fromText) or $(D fromFile).
    private this(ShaderType shaderType, in char[] shaderText)
    {
        _data = Data(shaderType, shaderText);
    }

    /** Explicitly release the OpenGL shader. */
    void release()
    {
        _data.release();
    }

    /** Return the shader type of this shader. */
    @property ShaderType shaderType()
    {
        return _data._shaderType;
    }

    // internal API
    package GLuint shaderID()
    {
        return _data._shaderID;
    }

private:
    alias Data = ShaderImpl;
    Data _data;
}

private struct ShaderImpl
{
    this(ShaderType shaderType, in char[] shaderText)
    {
        enforce(shaderType != ShaderType.invalid, "Shader type is uninitialized.");

        _shaderType = shaderType;
        _shaderID = glCreateShader(cast(GLenum)shaderType);

        auto shaderPtr = shaderText.ptr;
        auto shaderLen = cast(int)shaderText.length;
        enum elemCount = 1;

        glShaderSource(_shaderID, elemCount, &shaderPtr, &shaderLen);
        this.compileShader();
    }

    private void compileShader()
    {
        glCompileShader(_shaderID);

        GLint status;
        glGetShaderiv(_shaderID, GL_COMPILE_STATUS, &status);
        if (status == GL_TRUE)
            return;
    }

    void release()
    {
        if (_shaderID != invalidShaderID)
        {
            glDeleteShader(_shaderID);
            _shaderID = invalidShaderID;
        }
    }

    debug ~this()
    {
        if (_shaderID != invalidShaderID)
            stderr.writefln("%s(%s): OpenGL: Shader resources not released.", __FILE__, __LINE__);
    }

    /* Shader data. */
    GLuint _shaderID = invalidShaderID;
    ShaderType _shaderType;

    // sentinel
    private enum invalidShaderID = -1;
}
