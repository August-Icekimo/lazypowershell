#!/bin/bash

# 用檔案控制要同步的目錄清單
export fileslist="$(pwd)/flists.csv"

# 目錄清單轉為陣列元素
rsyncArr=()
while IFS= read -r line || [[ "$line" ]];
do
  rsyncArr+=("$line")
done < $fileslist

# 同步目錄的位移參數
export pathShift="/mnt/d"

# 將陣列內目錄名稱全部同步一遍
for folder in  "${rsyncArr[@]}"
do 
echo "開始同步 Syncing $folder"
rsync -zavh --stats --progress $pathShift"/"$folder "$folder" 
done

echo "同步完成 Syncing Completed."