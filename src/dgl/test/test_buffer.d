/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.test_buffer;

/**
    Test dgl.buffer.
*/

import core.exception;
import std.exception;
import std.file;

import minilib.core.test;

import derelict.opengl3.gl3;

import dgl.buffer;
import dgl.program;
import dgl.shader;
import dgl.test.util;

unittest
{
    // throw on invalid hint type
    GLBuffer([1, 2], UsageHint.init).assertErrorsWith("Draw hint is uninitialized.");

    //
    GLBuffer([1, 2], UsageHint.staticDraw);
}
