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
import minilib.core.typecons;

import deimos.glfw.glfw3;

import dgl.loader;
import dgl.shader;

///
public alias writeFile = std.file.write;

///
mixin NewException!"GLException";

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

    /**
        GL_ARB_debug_output or GL_KHR_debug callback.

        Throwing exceptions across language boundaries should be fine as
        long as $(B GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB) was enabled.

        This will emit proper stack traces.
    */
    extern (Windows)
    private void dgl_error_callback(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, in GLchar* message, GLvoid* userParam)
    {
        string msg = format("source: %s, type: %s, id: %s, severity: %s, length: %s, message: %s, userParam: %s",
                             source, type, id, severity, length, message.to!string, userParam);
        throw new GLException(msg);
    }

    /** Initialize GLWF, an OpenGL context, and load Derelict3 function pointers. */
    private void createContext()
    {
        // initialize GL
        initGL();

        // initialize glwf
        auto res = glfwInit();
        require(res, "glfwInit call failed with return code: '%s'", res);
        scope(failure)
            glfwTerminate();

        // set the window to inivisible since it will only briefly appear during testing
        glfwWindowHint(GLFW_VISIBLE, 0);

        // enable debugging
        glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, 1);

        // require GL 3.3x
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

        // require CORE profile, and forward compatible
        glfwWindowHint(GLFW_OPENGL_CORE_PROFILE, 1);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, 1);

        // Create a windowed mode window and its OpenGL context
        auto window = require(glfwCreateWindow(640, 480, "Hello World", null, null),
                              "glfwCreateWindow call failed.");

        // Make the window's context current
        glfwMakeContextCurrent(window);

        loadGL();

        // supporting only GL 3.3x+
        enforce(GLVersion.major > 3 || (GLVersion.major == 3 && GLVersion.minor == 3));

        // ensure the debug output extension is supported
        enforce(GL_ARB_debug_output || GL_KHR_debug);

        // cast: workaround for 'nothrow' propagation bug (haven't been able to reduce it)
        auto hookDebugCallback = GL_ARB_debug_output ? glDebugMessageCallbackARB
                                                     : cast(typeof(glDebugMessageCallbackARB))glDebugMessageCallback;


        // hook the debug callback
        // cast: derelict assumes its nothrow
        hookDebugCallback(cast(GLDEBUGPROCARB)&dgl_error_callback, null);

        // enable stack traces (otherwise we'd get random failures at runtime)
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);
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
            #version 130

            in vec4 position;
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
            #version 130

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
