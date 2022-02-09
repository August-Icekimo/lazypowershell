@ECHO OFF
TITLE "Remove Oracle Java, 8"
ECHO Cleanup Running Java Update process
wmic process where "name like 'jucheck%%.exe'" delete /nointeractive
wmic process where "name like 'jusched%%.exe'" delete /nointeractive
ECHO Cleanup Runing Java instance, like java, javaw ...
wmic process where "name like 'java%%'" delete /nointeractive
ECHO "Wait 10 seconds to remove Oracle Java 8." & TIMEOUT /T 10 /NOBREAK 
REM Uninstall Oracle Java 8 by select product registry name.
wmic product where "name like 'Java 8%%'" call uninstall /nointeractive