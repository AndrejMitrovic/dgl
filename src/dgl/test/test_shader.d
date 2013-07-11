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
import std.file;
import std.path;

import minilib.core.test;

import derelict.opengl3.gl3;

import dgl.shader;
import dgl.test.util;

unittest
{
    // throw on no file
    Shader(ShaderType.vertex, "no.file").assertErrorsWith("Shader file 'no.file' does not exist.");

    // throw on no shader type
    Shader(ShaderType.invalid, testShaders[0].vertex).assertErrorsWith("Shader type is uninitialized.");

    // throw on bad shader from file
    auto exc1 = Shader(ShaderType.vertex, badShaders[0].vertex).getException!ShaderException;
    exc1.shaderName.assertEqual(badShaders[0].vertex.baseName);
    exc1.shaderFile.assertEqual(badShaders[0].vertex);

    // throw on bad shader from memory
    auto exc2 = Shader(ShaderType.vertex, "badShader", readText(badShaders[0].vertex)).getException!ShaderException;
    exc2.shaderName.assertEqual("badShader");
    exc2.shaderFile.assertEmpty();

    // throw when using file constructor instead of in-memory buffer constructor
    assertThrown(Shader(ShaderType.vertex,
    q{
        #version 330

        in vec4 position;

        void main()
        {
            gl_Position = position;
        }
    }));

    // check init and copying from file
    auto shader1 = Shader(ShaderType.vertex, testShaders[0].vertex);
    shader1 = Shader(ShaderType.vertex, testShaders[0].vertex);

    // check init and copying from memory
    auto shader2 = Shader(ShaderType.vertex, testShaders[0].vertex, readText(testShaders[0].vertex));
    shader2 = Shader(ShaderType.vertex, testShaders[0].vertex, readText(testShaders[0].vertex));
}
