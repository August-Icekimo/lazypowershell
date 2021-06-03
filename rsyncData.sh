#!/bin/bash
# 變數宣告
export fileslist=""
export pathShift=""
reverseDir=""
_debug=""
_dryrun=""


# 前段函式宣告
_printHelp()
{
  #印出Debug說明或是幫助文字
  if [ "$1" == "help" ];
  then
    echo ""
    echo "使用-f 傳入目錄清單參數"
    # 用檔案控制要同步的目錄清單
    # 使用方式可為Cgwin / WSL 內 rsync
    # 須先建立目錄清單 flists.csv
    echo "使用-p 同步目錄的位置參數"
    # 同步目錄的位置參數
    # export pathShift="/mnt/d"
  fi
  if [ "$1" == "debug" ];
  then
  echo "反轉同步方向: $reverseDir";
  echo "同步目錄清單: $fileslist";
  echo "同步目錄位置: $pathShift";
  fi
}

# 前期傳入參數處理
while [ ${#} -gt 0 ];
  do 
    case ${1} in
    -r | --reverse )
      reverseDir="TRUE"
    ;;
    -f | --folder )
      fileslist="$2"
      shift
    ;;
    -p | --path )
      pathShift="$2"
      shift
    ;;
    -d | --debug )
      _debug="TRUE"
    ;;
    --dry-run )
    _dryrun="--dry-run"
    ;;
    -h | --help )
      _printHelp "help"
      _printHelp "debug"
      exit
    ;;
    *) 
        ;;
    esac
    shift 1
  done

_fileList()
{
  if [ -z $1 ];
  then 
    if [ -r $(pwd)/flists.csv ];
    then
      export fileslist="$(pwd)/flists.csv"
    fi
  else
    if [ -r $1 ];
    then
      echo "目錄清單不存在，請在-f後指定正確清單"
      exit 128 #Invalid argument to exit
    fi
  fi
}

# 處理要不要用內建的目錄清單
_fileList $fileslist

# 偵錯用列印函式
if [ -n $_debug ];
then 
  _printHelp "debug"
fi


# 目錄清單轉為單次指令稿
scriptname="/tmp/runRsyncOnce$(date +%s).sh"

# 逐行讀取轉入指令稿
while IFS= read -r line || [[ "$line" ]];
do
    # echo "/usr/bin/rsync -zavuh --stats --progress $pathShift/$line $line $_dryrun" >> $scriptname
    if [ -n $_debug ];
    then
      echo "新增同步目錄指令:"
      echo "/usr/bin/rsync -zavuh --stats --progress \"$pathShift/$line\" \"$line\" $_dryrun"
    fi
done < $fileslist


echo "----同步完成 Syncing Completed."