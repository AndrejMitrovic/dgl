@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dglRoot=%thisPath%\..
set binPath=%dglRoot%\bin
cd %thisPath%\..\src

set "files="
for /r %%i in (*.d) do set files=!files! %%i

set "LIBS_ROOT=%CD%\..\..
IF NOT EXIST %MINILIB_HOME% do set MINILIB_HOME=%LIBS_ROOT%\minilib
IF NOT EXIST %DERELICT3_HOME% do set DERELICT3_HOME=%LIBS_ROOT%\Derelict3
IF NOT EXIST %DEIMOS_GLFW% do set DEIMOS_GLFW=%LIBS_ROOT%\glfw

set includes=-I%MINILIB_HOME%\src -I%DERELICT3_HOME%\import -I%DEIMOS_GLFW%
set implibs=%dglRoot%\lib\glfw3_implib.lib
set flags=%includes% %implibs% -debug

rem set compiler=dmd.exe
set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set dtest=rdmd -of%binPath%\dgl_test.exe --main -unittest -g --force --compiler=%compiler% %flags% dgl\package.d

%dtest% && echo Success: dgl tested. && %compiler% -g -of%binPath%\dgl.lib -lib %flags% %files% && echo Success: dgl built ok.
