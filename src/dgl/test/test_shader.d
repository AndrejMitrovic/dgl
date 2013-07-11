/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.test_shader;

/**
    Test dgl.shader.
*/

import core.exception;
import std.exception;

import minilib.core.test;

import derelict.opengl3.gl3;

import dgl.shader;
import dgl.test.util;

unittest
{
    // throw on no file
    Shader("no.file", ShaderType.vertex).assertErrorsWith("Shader file 'no.file' does not exist.");

    // throw on no shader type
    Shader(vertexShader1, ShaderType.invalid).assertErrorsWith("Shader type is uninitialized.");

    // throw on invalid shader source
    Shader(badVertexShader1, ShaderType.vertex)
        .getException!ShaderException.fileName.assertEqual(badVertexShader1);

    // check init and copying
    auto shader1 = Shader(vertexShader1, ShaderType.vertex);
    shader1 = Shader(vertexShader1, ShaderType.vertex);
}
