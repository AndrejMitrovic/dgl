@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dglRoot=%thisPath%\..
set binPath=%dglRoot%\bin
cd %thisPath%\..\src

set "files="
for /r %%i in (*.d) do set files=!files! %%i

set "LIBS_ROOT=%CD%\..\..
IF NOT EXIST %DERELICT_GL_HOME% do set DERELICT_GL_HOME=%LIBS_ROOT%\DerelictGL3
IF NOT EXIST %DERELICT_UTIL_HOME% do set DERELICT_UTIL_HOME=%LIBS_ROOT%\DerelictUtil
IF NOT EXIST %DEIMOS_GLFW% do set DEIMOS_GLFW=%LIBS_ROOT%\glfw
IF NOT EXIST %GLAD_HOME% do set GLAD_HOME=%LIBS_ROOT%\glad

set includes=-I%DERELICT_GL_HOME%\source -I%DERELICT_UTIL_HOME%\source -I%DEIMOS_GLFW% -I%GLAD_HOME%\build
set implibs=%dglRoot%\lib\glfw3_implib.lib

rem set versions=-version=dgl_use_derelict
set versions=-version=dgl_use_glad

set flags=%includes% %implibs% %versions%

set compiler=dmd.exe
rem set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set dtest=rdmd -of%binPath%\dgl_test.exe --main -unittest -g --force --compiler=%compiler% %flags% dgl\package.d

%dtest% && echo Success: dgl tested. && %compiler% -g -of%binPath%\dgl.lib -lib %flags% %files% && echo Success: dgl built.
