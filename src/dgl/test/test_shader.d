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
import std.string;

import minilib.core.test;

import dgl.loader;
import dgl.shader;
import dgl.test.util;

unittest
{
    // throw on no file
    Shader.fromFile(ShaderType.vertex, "no.file").assertErrorsWith("Shader file 'no.file' does not exist.");

    // throw on invalid shader type
    Shader.fromFile(ShaderType.invalid, testShaders[0].vertex).assertErrorsWith("Shader type is uninitialized.");

    // throw on trying to pass a file name instead of a buffer
    new Shader(ShaderType.invalid, testShaders[0].vertex)
        .assertErrorsWith("Attempted to pass a shader file '%s' instead of the shader code. Use 'Shader.fromFile' to load a shader from disk.".format(testShaders[0].vertex));

    // throw on bad shader from file
    assertThrown!ShaderException(Shader.fromFile(ShaderType.vertex, badShaders[0].vertex));

    // throw on bad shader from memory
    assertThrown!ShaderException(new Shader(ShaderType.vertex, readText(badShaders[0].vertex)));

    auto shader1 = Shader.fromFile(ShaderType.vertex, testShaders[0].vertex);
    shader1.release();

    shader1 = new Shader(ShaderType.vertex, readText(testShaders[0].vertex));
    shader1.release();

    auto shader2 = new Shader(ShaderType.vertex, readText(testShaders[0].vertex));
    shader2.release();

    shader2 = new Shader(ShaderType.vertex, readText(testShaders[0].vertex));
    shader2.release();
}
