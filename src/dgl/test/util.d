/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.test.util;

import core.exception;
import std.conv;
import std.exception;
import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string;
import std.traits;

import minilib.core.test;

import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.opengl3.deprecatedConstants;
import derelict.opengl3.constants;

import deimos.glfw.glfw3;

import dgl.shader;

///
public alias writeFile = std.file.write;

version(unittest)
{
    shared static this()
    {
        createContext();
        writeTestShaders();
    }

    shared static ~this()
    {
        destroyContext();
        removeTestShaders();
    }

    /** Initialize GLWF, an OpenGL context, and load Derelict3 function pointers. */
    private void createContext()
    {
        // initialize derelict
        DerelictGL.load();

        // initialize glwf
        auto res = glfwInit();
        require(res, "glfwInit call failed with return code: '%s'", res);
        scope(failure)
            glfwTerminate();

        // set the window to inivisible since it will only briefly appear during testing
        glfwWindowHint(GLFW_VISIBLE, 0);

        // Create a windowed mode window and its OpenGL context
        auto window = require(glfwCreateWindow(640, 480, "Hello World", null, null),
                "glfwCreateWindow call failed.");

        // Make the window's context current
        glfwMakeContextCurrent(window);

        // load all derelict function pointers
        DerelictGL.reload();
    }

    /** Deinitialize GLWF and other contexts. */
    private void destroyContext()
    {
        glfwTerminate();
    }

    // 10612 regression workaround:
    // http://d.puremagic.com/issues/show_bug.cgi?id=10612
    // string[ShaderType][] testShaders;

    /**
        Group of of shader file names, each such group is
        compatible with each other and can be linked in an OpenGL program
    */
    private struct ShaderGroup
    {
        string vertex;
        string geometry;
        string fragment;

        void remove()
        {
            if (vertex.exists) .remove(vertex);
            if (geometry.exists) .remove(geometry);
            if (fragment.exists) .remove(fragment);
        }
    }

    ShaderGroup[] testShaders;
    ShaderGroup[] badShaders;

    private void writeTestShaders()
    {
        writeGoodShaders();
        writeBadShaders();
    }

    private void writeGoodShaders()
    {
        ShaderGroup shaderGroup;

        string vertexFile = "good_vertex_1";
        vertexFile.writeFile(q{
            #version 330

            layout(location = 0) in vec4 position;
            uniform vec2 offset;

            void main()
            {
                vec4 totalOffset = vec4(offset.x, offset.y, 0.0, 0.0);
                gl_Position = position + totalOffset;
            }
        });
        shaderGroup.vertex = vertexFile;

        string fragmentFile = "good_fragment_1";
        fragmentFile.writeFile(q{
            #version 330

            out vec4 fragColor;

            void main()
            {
                fragColor = vec4(1.0, 1.0, 1.0, 1.0);
            }
        });
        shaderGroup.fragment = fragmentFile;

        testShaders ~= shaderGroup;
    }

    private void writeBadShaders()
    {
        ShaderGroup shaderGroup;

        string vertexFile = "bad_vertex_1";
        vertexFile.writeFile(q{
            asdf
        });
        shaderGroup.vertex = vertexFile;

        string fragmentFile = "bad_fragment_1";
        fragmentFile.writeFile(q{
            asdf
        });
        shaderGroup.fragment = fragmentFile;

        badShaders ~= shaderGroup;
    }

    private void removeTestShaders()
    {
        foreach (group; chain(testShaders, badShaders))
            group.remove();
    }
}

///
auto verify(alias func, string file = __FILE__, size_t line = __LINE__, Args...)(Args args)
{
    require(func !is null, "Function pointer '%s' is not loaded. Please verify that 'DerelictGL.load()' and 'DerelictGL.reload()' were called first.", __traits(identifier, func));

    static if (is(ReturnType!(typeof(func)) == void))
        func(args);
    else
        auto result = func(args);

    GLenum lastError = glGetError();
    if (lastError != GL_NO_ERROR)
    {
        string argsStr = format("%s".repeat(Args.length).join(", "), args);
        stderr.writefln("%s(%s): %s(%s) failed with: %s",
            file, line, __traits(identifier, func), argsStr, lastError.toString());
    }

    static if (!is(ReturnType!func == void))
        return result;
}

/// Converts an OpenGL errorenum to a string
string toString(GLenum error)
{
    switch (error)
    {
        case GL_INVALID_ENUM:
            return "An unacceptable value is specified for an enumerated argument.";

        case GL_INVALID_VALUE:
            return "A numeric argument is out of range.";

        case GL_INVALID_OPERATION:
            return "The specified operation is not allowed in the current state.";

        case GL_INVALID_FRAMEBUFFER_OPERATION:
            return "The framebuffer object is not complete.";

        case GL_OUT_OF_MEMORY:
            return "There is not enough memory left to execute the command. WARNING: GL operation is undefined.";

        case GL_STACK_UNDERFLOW:
            return "An attempt has been made to perform an operation that would cause an internal stack to underflow.";

        case GL_STACK_OVERFLOW:
            return "An attempt has been made to perform an operation that would cause an internal stack to overflow.";

        default:
            assert(0, format("Unhandled GLenum error state: '%s'", error));
    }
}
