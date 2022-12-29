@ECHO OFF
TITLE "Remove Oracle Java, 8"
ECHO Cleanup Running Java Update process
ECHO "開始清除Oracle Java 8"
ECHO "首先停止背景更新程式"
wmic process where "name like 'jucheck%%.exe'" delete /nointeractive
wmic process where "name like 'jusched%%.exe'" delete /nointeractive
ECHO Cleanup Runing Java instance, like java, javaw ...
ECHO "停止Java程式"
wmic process where "name like 'java%%'" delete /nointeractive
ECHO "等所有java程式終止，後續將移除Oracle Java 8 所有版本"
ECHO "Wait 10 seconds to remove Oracle Java 8." & TIMEOUT /T 10 /NOBREAK 
REM Uninstall Oracle Java 8 by select product registry name.
wmic product where "name like 'Java 8%%'" call uninstall /nointeractive
ECHO "完成移除工作"