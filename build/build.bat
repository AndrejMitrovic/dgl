@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set binPath=%thisPath%\..\bin
cd %thisPath%\..\src

set "files="
for /r %%i in (*.d) do set files=!files! %%i

set "LIBS_ROOT=%CD%\..\..
IF NOT EXIST %MINILIB_HOME% do set MINILIB_HOME=%LIBS_ROOT%\minilib
IF NOT EXIST %DERELICT3_HOME% do set DERELICT3_HOME=%LIBS_ROOT%\Derelict3

set includes=-I%MINILIB_HOME%\src -I%DERELICT3_HOME%\import
set flags=%includes%

rem set compiler=dmd.exe
set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set dtest=rdmd --main -unittest --force

%dtest% --compiler=%compiler% %flags% dgl\package.d && echo Success: dgl tested.
rem %compiler% -of%binPath%\dgl.lib -lib %flags% %files% && echo Success: dgl tested and built ok.
