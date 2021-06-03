#!/bin/bash
# 變數宣告
fileslist=""
pathShift=""
reverseDir=""


# 前段函式宣告
_printHelp( )
{
  #印出Debug說明或是幫助文字
  if [ -z $1 ];
  then
    echo ""
    echo "使用-f 傳入目錄清單參數"
    echo "使用-p 同步目錄的位置參數"
  fi
  if [ "$1" == "debug"];
  then
  echo "reverse: $reverseDir";
  echo "fileslist: $fileslist";
  echo "pathShift: $pathShift";
  fi
}

# 前期傳入參數處理
while [ ${#} -gt 0 ];
  do 
    case ${1} in
    -r | --reverse)
      reverseDir="TRUE"
    ;;
    -f | --folder )
      fileslist="$2"
      # 用檔案控制要同步的目錄清單
      # 使用方式可為Cgwin / WSL 內 rsync
      # 須先建立目錄清單 flists.csv
      shift
    ;;
    -p | --path )
      pathShift="$2"
      # 同步目錄的位置參數
      # export pathShift="/mnt/d"
      shift
    ;;
    *) 

        ;;
    esac
    shift 1
  done

_fileList(){
if [ -f ./flists.csv ]
then
  export fileslist="$(pwd)/flists.csv"
else
  export fileslist="$1"
  echo "使用-f傳入目錄清單參數 $fileslist"
fi

if [ -z $fileslist ]
then 
  echo "目錄清單不存在，請在-f後指定"
  exit 128 #Invalid argument to exit
fi
}

# # 目錄清單轉為陣列元素
# rsyncArr=()
# # 逐行讀取轉為陣列元素
# while IFS= read -r line || [[ "$line" ]];
# do
#     rsyncArr+="${line@Q} "
#   echo "新增同步目錄名稱 ${line@Q}"
# done < $fileslist

# 將陣列內目錄名稱全部同步一遍
# for folder in ${rsyncArr[@]}
# do 
#   echo "----開始同步 Syncing $folder"
#   # 試著括號處理目錄中特殊字元
#   echo "RUN: rsync -zavuh --stats --progress $pathShift/$folder $folder"
#   # rsync -zavuh --stats --progress $pathShift/$folder "$folder" 
# done

echo "----同步完成 Syncing Completed."