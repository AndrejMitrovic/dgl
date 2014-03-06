/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.test_exceptions;

import core.exception;
import std.exception;
import std.file;

import minilib.core.test;

import dgl.buffer;
import dgl.loader;
import dgl.program;
import dgl.shader;
import dgl.test.util;

unittest
{
    // example failing code
    assertThrown!GLException(glEnable(GL_TEXTURE));
}
