Android Image Tools on Windows by wuxianlin
===========

说明
----------------

此处开源wuxianlin关于Android Image的工具
支持MTK、支持带有dt.img的boot.img/recovery.img


解包boot/recovery
----------------
方法一：将要解包的boot.img/recovery.img拖到unpackimg.bat，即会自动将其解包到boot/recovery目录
方法二：CMD命令行：unpackimg.bat <image_file> 

打包boot/recovery
----------------
方法一：将要打包的boot/recovery目录拖到repackimg.bat，即会自动将其打包到boot-new.img/recovery-new.img
方法二：CMD命令行：repackimg.bat <image_dir> [--original] 其中--original 为可选参数，若使用，则打包原始的ramdisk

注意事项
--------------------------------
注意工具的bin目录的完整性

感谢
--------
感谢omnirom开源项目的[mtk的打包工具](https://github.com/omnirom/android_device_oppo_r819/tree/android-4.4/mkmtkbootimg) 
感谢[osm0sis](http://forum.xda-developers.com/member.php?u=4544860)开源的[相关项目](https://github.com/osm0sishttps://github.com/osm0sis)及[Image Kitchen](http://forum.xda-developers.com/showthread.php?t=2073775)
