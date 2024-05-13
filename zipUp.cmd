REM cd "C:\Program Files\7-Zip\"

REM 取得今天的年、月、日 (自動補零) :THE Will Will Web:
SET TodayYear=%date:~0,4%
SET TodayMonthP0=%date:~5,2%
SET TodayDayP0=%date:~8,2%

REM 取得今天的年、月、日 (純數字)
REM 2010/08/03 更新：以下是為了修正 Batch 遇到 08, 09 會視為八進位的問題
IF %TodayMonthP0:~0,1% == 0 (
	SET /A TodayMonth=%TodayMonthP0:~1,1%+0
) ELSE (
	SET /A TodayMonth=TodayMonthP0+0
)

IF %TodayMonthP0:~0,1% == 0 (
	SET /A TodayDay=%TodayDayP0:~1,1%+0
) ELSE (
	SET /A TodayDay=TodayDayP0+0
)

REM 日期1 %TodayYear%/%TodayMonth%/%TodayDay%
REM 日期2 %TodayYear%/%TodayMonthP0%/%TodayDayP0%

"C:\Program Files\7-Zip\7z.exe" a -mx=9 -t7z -x!.git Z:\CEPP-HRM_%TodayYear%%TodayMonthP0%%TodayDayP0%.7z D:\CEPP-HRM\HRM