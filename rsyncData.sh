#!/bin/bash

# 用檔案控制要同步的目錄清單
# 使用方式可為Cgwin / WSL 內 rsync
# 須先建立目錄清單 flists.csv
if [ -f ./flists.csv ]
then
  export fileslist="$(pwd)/flists.csv"
else
  export fileslist="$1"
  echo "使用第1參數作為目錄清單 $fileslist"
fi

if [ -z $fileslist ]
then 
  echo "目錄清單不存在，請在第1個參數指定"
  exit 128 #Invalid argument to exit
fi

# 目錄清單轉為陣列元素
rsyncArr=()
# 逐行讀取轉為陣列元素
while IFS= read -r line || [[ "$line" ]];
do
  rsyncArr+=("$line")
  echo "新增同步目錄名稱 $line"
done < $fileslist

# 同步目錄的位移參數

export pathShift="/mnt/d"

# 將陣列內目錄名稱全部同步一遍
for folder in  "${rsyncArr[@]}"
do 
  echo "----開始同步 Syncing $folder"
  echo "RUN: rsync -zavuh --stats --progress $pathShift"/"$folder "$folder" "
  rsync -zavuh --stats --progress $pathShift"/"$folder "$folder" 
done

echo "----同步完成 Syncing Completed."
return 0