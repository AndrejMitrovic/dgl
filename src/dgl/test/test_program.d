/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.test_program;

/**
    Test dgl.program.
*/

import core.exception;
import std.exception;
import std.file;

import minilib.core.test;

import dgl.loader;
import dgl.program;
import dgl.shader;
import dgl.test.util;

unittest
{
    auto shader1 = new Shader(ShaderType.vertex, testShaders[0].vertex.readText);
    auto shader2 = new Shader(ShaderType.fragment, testShaders[0].fragment.readText);
    auto program = new Program(shader1, shader2);
    shader1.release();
    shader2.release();

    auto offset = program.getUniform("offset");

    program.bind();

    // the uniform can only be set while the program is in use
    program.setUniform2f(offset, 1.0, 2.0);

    program.unbind();
    program.release();
}
