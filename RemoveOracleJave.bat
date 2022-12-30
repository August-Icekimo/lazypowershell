@ECHO OFF
TITLE "Remove Oracle Java, 8"
ECHO Cleanup Running Java Update process
ECHO ==== 00 開始清除Oracle Java 8 ====
ECHO ==== 01 首先停止背景更新程式        ====
wmic process where "name like 'jucheck%%.exe'" delete /nointeractive
wmic process where "name like 'jusched%%.exe'" delete /nointeractive
ECHO Cleanup Runing Java instance, like java, javaw ...
ECHO ==== 02 停止Java程式          ====
wmic process where "name like 'java%%'" delete /nointeractive
ECHO ==== 03 等10秒終止所有java程式，後續將移除Oracle Java 8 所有版本 
ECHO ==== 03 Wait 10 seconds to remove Oracle Java 8.  & TIMEOUT /T 10 /NOBREAK 
REM Uninstall Oracle Java 8 by select product registry name.
ECHO ==== 04 移除Java程式          ====
wmic product where "name like 'Java 8%%'" call uninstall /nointeractive
ECHO ==== 05 完成移除工作            ====