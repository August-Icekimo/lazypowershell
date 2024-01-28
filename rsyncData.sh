#!/bin/sh
# 產生逐行的rsync指令行，供排程使用。
# 因為rsync特性，所以建議加大排程時間，盡量不需要做執行個體檢查控制
# Define variables 變數宣告
# check if fileslist variable is set or default valuees "flists.csv"
export fileslist==${PORTAINER_DATA:-flists.csv}
# check if pathShift variable is set or default valuees "$pwd"
export pathShift==${PORTAINER_DATA:-$pwd}
# check if _reverseDir variable is set or default valuees "FALSE"
export _reverseDir==${PORTAINER_DATA:-FALSE}
# check if _debug variable is set or default valuees "FALSE"
export _debug==${PORTAINER_DATA:-FALSE}
# check if _dryrun variable is set or default valuees "FALSE"
export _dryrun==${PORTAINER_DATA:-FALSE}

# rsync -zavH --exclude="**/@eaDir" --exclude="**/*recycle*" --exclude="**/.sync*" --stats --progress -e "ssh -p6622" /volume1/文件/_PMO各年度教育訓練教材 iceicebaby.duckdns.org:/volume1/MOI_Sync/ --dry-run

# 前段函式宣告
_printHelp()
{
  # 印出Debug說明或是幫助文字
  if [ "$1" == "help" ];
  then
    echo "使用-r | --reverse 轉換同步檔案的方向"
    echo "使用-f | --folder 傳入目錄清單參數"
    # 用檔案控制要同步的目錄清單
    # 使用方式可為Cgwin / WSL 內 rsync
    # 須先建立目錄清單 flists.csv
    echo "使用-p | --path 同步目錄的位置參數,可以加user@IP:"
    # 同步目錄的位置參數
    # export pathShift="/mnt/d"
    echo "使用-d | --debug 打開偵錯參數"
    echo "使用--dry-run 僅進行暖身，不會真的執行"
  fi
  if [ "$1" == "debug" ];
  then
  echo "反轉同步方向: $_reverseDir";
  echo "同步目錄清單(.csv): $fileslist";
  echo "同步目錄位置(URL): $pathShift";
  fi
}

# 前期傳入參數處理
while [ ${#} -gt 0 ];
  do 
    case ${1} in
    -r | --reverse )
      _reverseDir="TRUE"
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
  # 處理要不要用內建的目錄清單的函式
  if [ -z $1 ];
  then 
    if [ -r $(pwd)/flists.csv ];
    then
      export fileslist="$(pwd)/flists.csv"
    fi
  else
    if [ ! -r $(pwd)/$1 ];
    then
      echo "目錄清單不存在，請在-f後指定正確清單"
      exit 128 #Invalid argument to exit
    fi
  fi
}

# 處理要不要用內建的目錄清單
_fileList $fileslist

# 偵錯用列印函式
if [ "$_debug" = "TRUE" ];
then 
  _printHelp "debug"
fi


# 目錄清單轉為單次指令稿
scriptname="/tmp/runRsyncOnce$(date +%s).sh"
touch $scriptname && chmod +x $scriptname
echo "#!/bin/sh" > $scriptname

# 逐行讀取轉入指令稿
if [ "$_reverseDir" = "TRUE" ];
# 取得同步方向
then
  while IFS= read -r line || [[ "$line" ]];
  do
       echo "/usr/bin/rsync -zavuh --stats --progress \"$line\" \"$pathShift/$line\" $_dryrun" >> $scriptname
      if [ "$_debug" = "TRUE" ];
      then
        echo "新增同步目錄指令:"
        echo "/usr/bin/rsync -zavuh --stats --progress \"$line\" \"$pathShift/$line\" $_dryrun"
      fi
  done < $fileslist 
else
  while IFS= read -r line || [[ "$line" ]];
  do
        echo "/usr/bin/rsync -zavuh --stats --progress \"$pathShift/$line\" \"$line\" $_dryrun" >> $scriptname
      if [ "$_debug" = "TRUE" ];
      then
        echo "新增同步目錄指令:"
        echo "/usr/bin/rsync -zavuh --stats --progress \"$pathShift/$line\" \"$line\" $_dryrun"
      fi
  done < $fileslist
fi
# 開始正式執行腳本
echo "----開始執行同步 RSyncing ....."
sh $scriptname
if  [ $? = 0 ] ; 
then 
  echo "----同步完成 RSync Completed."
  rm $scriptname
else
  echo "----同步有問題，請檢查$scriptname ."
  exit 1
fi