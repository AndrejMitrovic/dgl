@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
cd %thisPath%\..

dub

