/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.shader;

import std.file;
import std.exception;
import std.string;

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
struct Shader
{
    /** Read the shader of type $(D shaderType) from the file $(D fileName). */
    this(in char[] fileName, ShaderType shaderType)
    {
        require(fileName.exists, format("Shader file '%s' does not exist.", fileName));
        require(shaderType.isValidEnum, "Shader type is uninitialized.");

        string shaderText = fileName.readText();
    }

    invariant()
    {
        assert(_shaderID != GLuint.max, "Shader was left uninitialized.");
    }

    // todo: remove later
    void _testInvariant() { }

private:
    GLuint _shaderID = GLuint.max;
}
