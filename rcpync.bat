SET LOGPATH=%cd%\log
SET SOURCE="C:\USER\%id%\Documents"
SET DESTINATION="%cd%\bak"
robocopy.exe /R:0 /W:0 "%SOURCE%" "%DESTNATION%" /E /Z /XA:SH /XJ /UNICODE /ETA /COPY:DT /MIR /MT:32 /LOG+".\backup.log" /TEE
PAUSE