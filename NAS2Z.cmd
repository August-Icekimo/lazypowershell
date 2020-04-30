@ECHO OFF
ECHO Delete Z: link First
net use * /d /YES
ECHO Linking to Z: again...
NET USE Z: \\192.168.1.139\文件 /user:icekimo PahoIsi
ECHO Done ! Now push new files to NAS
WSL -u root /home/icekimo/syncup.sh