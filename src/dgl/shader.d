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

///
class ShaderException : Exception
{
    this(in char[] fileName, in char[] log)
    {
        this.fileName = fileName;
        string error = format("Failed to compile shader in file '%s':\n%s", fileName, log);
        super(error);
    }

    /// The file the shader was read from.
    const(char)[] fileName;
}

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
struct Shader
{
    /** Read the shader of type $(D shaderType) from the file $(D fileName). */
    this(in char[] fileName, ShaderType shaderType)
    {
        _data = Data(fileName, shaderType);
    }

    /** Delete the OpenGL shader. */
    void remove()
    {
        _data.remove();
    }

private:

    /** Payload for the refcounted OpenGL shader object. */
    struct Payload
    {
        this(in char[] fileName, ShaderType shaderType)
        {
            require(fileName.exists, "Shader file '%s' does not exist.", fileName);
            require(shaderType.isValidEnum, "Shader type is uninitialized.");

            _fileName = fileName;
            _shaderID = verify!glCreateShader(cast(GLenum)shaderType);

            string shaderText = fileName.readText();

            auto shaderPtr = shaderText.ptr;
            auto shaderLen = cast(int)shaderText.length;
            enum elemCount = 1;

            verify!glShaderSource(_shaderID, elemCount, &shaderPtr, &shaderLen);
            compileShader();
        }

        void compileShader()
        {
            verify!glCompileShader(_shaderID);

            GLint status;
            verify!glGetShaderiv(_shaderID, GL_COMPILE_STATUS, &status);

            if (status == GL_FALSE)
            {
                GLint logLength;
                verify!glGetShaderiv(_shaderID, GL_INFO_LOG_LENGTH, &logLength);

                GLchar[] logBuff = new GLchar[logLength];
                verify!glGetShaderInfoLog(_shaderID, logLength, null, logBuff.ptr);

                string log = assumeUnique(logBuff[0 .. logLength - 1]);
                throw new ShaderException(_fileName, log);
            }
        }

        ~this()
        {
            remove();
        }

        void remove()
        {
            if (_shaderID != GLuint.max)
            {
                glDeleteShader(_shaderID);
            }
        }

        /// Should never perform copy
        @disable this(this);

        /// Should never perform assign
        @disable void opAssign(typeof(this));

        GLuint _shaderID = GLuint.max;
        const(char)[] _fileName;
    }

    alias RefCounted!(Payload, RefCountedAutoInitialize.no) Data;
    Data _data;
}
