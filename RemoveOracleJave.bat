@ECHO OFF
TITLE "Remove Oracle Java, 8"
ECHO Cleanup Running Java Update process
ECHO ==== 00 �}�l�M��Oracle Java 8 ====
ECHO ==== 01 ��������I����s�{��        ====
wmic process where "name like 'jucheck%%.exe'" delete /nointeractive
wmic process where "name like 'jusched%%.exe'" delete /nointeractive
ECHO Cleanup Runing Java instance, like java, javaw ...
ECHO ==== 02 ����Java�{��          ====
wmic process where "name like 'java%%'" delete /nointeractive
ECHO ==== 03 ��10��פ�Ҧ�java�{���A����N����Oracle Java 8 �Ҧ����� 
ECHO ==== 03 Wait 10 seconds to remove Oracle Java 8.  & TIMEOUT /T 10 /NOBREAK 
REM Uninstall Oracle Java 8 by select product registry name.
ECHO ==== 04 ����Java�{��          ====
wmic product where "name like 'Java 8%%'" call uninstall /nointeractive
ECHO ==== 05 ���������u�@            ====