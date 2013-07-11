/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.shader;

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
    // Throw on uninitialized shader access
    Shader shader;
    assertThrown!AssertError(shader._testInvariant());
}

unittest
{
    // Throw on opening non-existing shader file
    Shader("foobar.shader", ShaderType.vertex).assertErrorsWith("Shader file 'foobar.shader' does not exist.");

    // Throw on invalid shader type
    Shader(shaderFile, ShaderType.invalid).assertErrorsWith("Shader type is uninitialized.");
}
