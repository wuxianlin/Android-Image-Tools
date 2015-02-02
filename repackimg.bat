@echo off
color 0a
title Android Image 工具箱
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.I                                                                             I
echo.I                         Android Image 工具箱-打包                           I
echo.I                                                                by wuxianlin I
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.
if "%~1" == "" goto noargs
set folder=%~nx1
if not exist %folder%\nul goto nofiles
if not exist %folder%\ramdisk\nul goto nofiles
set bin=.\bin
set "args=%2"

if exist %~nx1-new.img del /f/a/q %~nx1-new.img

del /f/a/q %folder%\ramdisk-new.cpio* 2>nul

for /f "delims=" %%a in ('dir /b %folder%\*-ramdisk.cpio*') do @set ramdisk=%%a
::if "%args%" == "--original" echo ramdisk = %ramdisk% & set "ramdisk=--ramdisk "%folder%\%ramdisk%""
if "%args%" == "--original" echo 使用原始ramdisk... & echo ramdisk = %ramdisk% & set "ramdisk=%ramdisk%" & goto skipramdisk

echo 打包 ramdisk . . .
echo.
for /f "delims=" %%a in ('dir /b %folder%\*-ramdiskcomp') do @set ramdiskcname=%%a
for /f "delims=" %%a in ('type "%folder%\%ramdiskcname%"') do @set ramdiskcomp=%%a
echo 压缩格式: %ramdiskcomp%
if "%ramdiskcomp%" == "gzip" set "repackcmd=gzip" & set "compext=gz"
if "%ramdiskcomp%" == "lzop" set "repackcmd=lzop" & set "compext=lzo"
if "%ramdiskcomp%" == "lzma" set "repackcmd=xz -Flzma" & set "compext=lzma"
if "%ramdiskcomp%" == "xz" set "repackcmd=xz -1 -Ccrc32" & set "compext=xz"
if "%ramdiskcomp%" == "bzip2" set "repackcmd=bzip2" & set "compext=bz2"
if "%ramdiskcomp%" == "lz4" set "repackcmd=lz4 stdin stdout 2>nul" & set "compext=lz4"
%bin%\mkbootfs %folder%\ramdisk | %bin%\%repackcmd% > %folder%\ramdisk-new.cpio.%compext%
if errorlevel == 1 goto error

::set "ramdisk=--ramdisk %folder%\ramdisk-new.cpio.%compext%"
echo ramdisk = ramdisk-new.cpio.%compext%
set "ramdisk=ramdisk-new.cpio.%compext%"

:skipramdisk
echo.

echo 获取镜像生成信息...
echo.
for /f "delims=" %%a in ('dir /b %folder%\*-zImage') do @set kernel=%%a
echo kernel = %kernel%

for /f "delims=" %%a in ('dir /b %folder%\*-cmdline') do @set cmdname=%%a
for /f "delims=" %%a in ('type "%folder%\%cmdname%"') do @set cmdline=%%a
echo cmdline = %cmdline%

for /f "delims=" %%a in ('dir /b %folder%\*-board') do @set boardname=%%a
for /f "delims=" %%a in ('type "%folder%\%boardname%"') do @set board=%%a
echo board = %board%

for /f "delims=" %%a in ('dir /b %folder%\*-base') do @set basename=%%a
for /f "delims=" %%a in ('type "%folder%\%basename%"') do @set base=%%a
echo base = %base%

for /f "delims=" %%a in ('dir /b %folder%\*-pagesize') do @set pagename=%%a
for /f "delims=" %%a in ('type "%folder%\%pagename%"') do @set pagesize=%%a
echo pagesize = %pagesize%

for /f "delims=" %%a in ('dir /b %folder%\*-kerneloff') do @set koffname=%%a
for /f "delims=" %%a in ('type "%folder%\%koffname%"') do @set kerneloff=%%a
echo kernel_offset = %kerneloff%

for /f "delims=" %%a in ('dir /b %folder%\*-ramdiskoff') do @set roffname=%%a
for /f "delims=" %%a in ('type "%folder%\%roffname%"') do @set ramdiskoff=%%a
echo ramdisk_offset = %ramdiskoff%

for /f "delims=" %%a in ('dir /b %folder%\*-tagsoff') do @set toffname=%%a
for /f "delims=" %%a in ('type "%folder%\%toffname%"') do @set tagsoff=%%a
echo tags_offset = %tagsoff%

if not exist "%folder%\*-mtk" goto skipmtk
for /f "delims=" %%a in ('dir /b %folder%\*-mtk') do @set mtkname=%%a
for /f "delims=" %%a in ('type "%folder%\%mtkname%"') do @set mtk=%%a
echo mtk = %mtk% & set "mtk=--mtk %mtk%"

:skipmtk
if not exist "%folder%\*-second" goto skipsecond
for /f "delims=" %%a in ('dir /b %folder%\*-second') do @set second=%%a
echo second = %second% & set "second=--second "%folder%/%second%""

for /f "delims=" %%a in ('dir /b %folder%\*-secondoff') do @set soffname=%%a
for /f "delims=" %%a in ('type "%folder%\%soffname%"') do @set secondoff=%%a
echo second_offset = %secondoff% & set "second_offset=--second_offset %secondoff%"
:skipsecond
if not exist "%folder%\*-dtb" goto skipdtb
for /f "delims=" %%a in ('dir /b %folder%\*-dtb') do @set dtb=%%a
echo dtb = %dtb% & set "dtb=--dt "%folder%\%dtb%""
:skipdtb
echo.

echo 生成镜像%~nx1-new.img...
echo.
%bin%\mkbootimg --kernel "%folder%\%kernel%" --ramdisk "%folder%\%ramdisk%" %second% --cmdline "%cmdline%" --board "%board%" --base %base% --pagesize %pagesize% --kernel_offset %kerneloff% --ramdisk_offset %ramdiskoff% %second_offset% --tags_offset %tagsoff% %dtb% %mtk% -o %~nx1-new.img
if errorlevel == 1 goto error

echo 完成!
goto end

:noargs
echo 未提供用于打包的相关文件.
goto end

:nofiles
echo 未发现用于打包的相关文件.
goto end

:error
echo 错误!
goto end

:end
echo.
pause
