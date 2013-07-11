/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.util;

import std.conv;
import std.exception;
import std.file;
import std.path;
import std.stdio;
import std.string;

///
const string shaderFile = "shader.glsl";

///
public alias writeFile = std.file.write;

// Write the shader test-files
version(unittest)
{
    shared static this()
    {
        shaderFile.writeFile(
        q{
            #version 330

            in vec2 position;
            out vec2 texcoord;

            void main()
            {
                gl_Position = vec4(position, 0.0, 1.0);
                texcoord = position * vec2(0.5, -0.5) + vec2(0.5);
            }
        });
    }

    shared static ~this()
    {
        if (shaderFile.exists)
            remove(shaderFile);
    }
}
