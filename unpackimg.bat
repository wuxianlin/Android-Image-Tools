@echo off
color 0a
title Android Image 工具箱
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.I                                                                             I
echo.I                        Android Image 工具箱-解包                            I
echo.I                                                                by wuxianlin I
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.
if "%~1" == "" goto noargs
set "file=%~f1"
set bin=%~dp0bin

echo 待解包镜像: %~nx1
echo.

set "folder=%~n1"
if exist %folder% rd /s/q %folder%
md %folder%

echo 解包镜像到：%folder% 目录...
echo.

cd %folder%
set tools=..\bin

%tools%\unpackbootimg -i "%file%"
echo.
%tools%\file -m %tools%\magic *-ramdisk.gz | %tools%\cut -d: -f2 | %tools%\cut -d" " -f2 > "%~nx1-ramdiskcomp"
for /f "delims=" %%a in ('type "%~nx1-ramdiskcomp"') do @set ramdiskcomp=%%a
if "%ramdiskcomp%" == "gzip" set "unpackcmd=gzip -dc" & set "compext=gz"
if "%ramdiskcomp%" == "lzop" set "unpackcmd=lzop -dc" & set "compext=lzo"
if "%ramdiskcomp%" == "lzma" set "unpackcmd=xz -dc" & set "compext=lzma"
if "%ramdiskcomp%" == "xz" set "unpackcmd=xz -dc" & set "compext=xz"
if "%ramdiskcomp%" == "bzip2" set "unpackcmd=bzip2 -dc" & set "compext=bz2"
if "%ramdiskcomp%" == "lz4" ( set "unpackcmd=lz4" & set "extra=stdout 2>nul" & set "compext=lz4"  ) else ( set "extra= " )
ren *ramdisk.gz *ramdisk.cpio.%compext%

md ramdisk
cd ramdisk

set tools=..\..\bin
echo 解压ramdisk到：%folder%\ramdisk 目录...
echo.
echo 压缩方式: %ramdiskcomp%
if "%compext%" == "" goto error
%tools%\%unpackcmd% "../%~nx1-ramdisk.cpio.%compext%" %extra% | %tools%\cpio -i
if errorlevel == 1 goto error
echo.
cd ../../

echo 完成!
goto end

:noargs
echo 未提供镜像文件.
goto end

:error
echo 错误!

:end
echo.
pause
