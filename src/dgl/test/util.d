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
import std.stdio;
import std.string;
import std.traits;

import minilib.core.test;

import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.opengl3.deprecatedConstants;
import derelict.opengl3.constants;

import deimos.glfw.glfw3;

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

        // Create a windowed mode window and its OpenGL context
        auto window = require(glfwCreateWindow(100, 100, "Hello World", null, null),
                "glfwCreateWindow call failed.");

        // minimize it during testing
        glfwIconifyWindow(window);

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

    const string vertexShader1 = "shader.glsl";
    const string badVertexShader1 = "shader_bad.glsl";

    private void writeTestShaders()
    {
        vertexShader1.writeFile(q{
            #version 330

            in vec2 position;
            out vec2 texcoord;

            void main()
            {
                gl_Position = vec4(position, 0.0, 1.0);
                texcoord = position * vec2(0.5, -0.5) + vec2(0.5);
            }
        });

        badVertexShader1.writeFile(q{
            #version 330

            in vec2 position;
            out vec2 texcoord;

            asdf

            void main()
            {
                gl_Position = vec4(position, 0.0, 1.0);
                texcoord = position * vec2(0.5, -0.5) + vec2(0.5);
            }
        });
    }

    private void removeTestShaders()
    {
        foreach (file; [vertexShader1, badVertexShader1])
            if (file.exists) remove(file);
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
        stderr.writefln("%s(%s): %s(%s) failed with: %s",
            __traits(identifier, func), text(args), lastError.toString());
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
