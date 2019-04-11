#!/bin/bash

LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
echo "$LOGTIME: Pinging copyfeed .. "

# Log Location on Server.
LOG_LOCATION=/rl/data/logs/facebook-auto-feed/
CURRENTDATE=`date "+%Y-%m-%d"`
exec >> $LOG_LOCATION/copyfeed_$CURRENTDATE.log 2>&1

#global variables
#monitoring 3 dirs:
vautoDir=/home/vautoreachlocal/catalog
homenetDir=/home/homenetautoreachlocal/catalog
autouplinkDir=/home/autouplinktechreachlocal/catalog
yyyymmdd=""

#To extract date from filename
getDateFromFilename() {

  LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
  echo "$LOGTIME: fileName : $1"

  fileNameDate=$(expr "$1" : '.*/\([^/]*\).*' | cut -f 2 -d "_")
  echo "$LOGTIME: fileNameDate : $fileNameDate"

  if [ ${#fileNameDate} -ne 10 ]; then
      echo "$LOGTIME: ERROR Incorrect length of fileNameDate : ${fileNameDate}" >&2
      yyyymmdd=""
      return
  fi

  #To convert date format if needed
  #yyyymmdd="${file_name_date:6:4}-${file_name_date:0:2}-${file_name_date:3:2}"

  yyyymmdd=${fileNameDate}

  if [ ! -d "/rl/data/feed/$yyyymmdd" ]; then ###Checking if current date directory exists
      mkdir -p /rl/data/feed/$yyyymmdd
      echo "$LOGTIME: Made dir /rl/data/feed/$yyyymmdd"
  else
      echo "$LOGTIME: Dir /rl/data/feed/$yyyymmdd  already exists"
  fi

}

#To copy file from homeDir to dateDir
copyFileToDateDirectory() {
    if cp $1 $2; then
        echo "$LOGTIME: ******* Copy Code: $? - SUCCESS Copying $1 to $2  *******"
    else
        echo "$LOGTIME: ******* Copy Code: $? - FAILED Copying $1 to $2   *******" >&2
    fi
}

echo "$LOGTIME: Pinging copyfeed process .. "
PROCESS_ID=$(ps -ef | grep inotifywait | grep -v grep | grep -v \<defunct\> | awk '{print $2}')
echo "PROCESS_ID : $PROCESS_ID"
if [[ ! -z "$PROCESS_ID" ]]; then
    echo "$LOGTIME: copyfeed process already running"
else
    echo "$LOGTIME: copyfeed process NOT running.  Initating a new one"
    echo "Looking for files created/modified in last 2 mins"
    for fileName in  $(find $vautoDir $homenetDir $autouplinkDir -mtime -2m -type f ); do
        echo "$LOGTIME: Found files modified in last 2 mins"
        getDateFromFilename "$fileName"
        if [[ $yyyymmdd != "" ]]; then
            #echo " dateDirectory for $fileName : $yyyymmdd"
            copyFileToDateDirectory "$fileName" "/rl/data/feed/$yyyymmdd/"
        fi
    done

    inotifywait -m $vautoDir $homenetDir $autouplinkDir -e create -e modify |

    while read path action file;
       do
          LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
          echo "$LOGTIME: The file '$file' appeared in directory '$path' via '$action'"

          #fileName="/home/testuser/catalog/Dealer123_2018-11-10_15:21:20.csv"
          fileName="$path$file" #Should be injected by the inotify listener

          echo "$LOGTIME: fileName : $fileName"

          getDateFromFilename "$fileName"
          if [[ $yyyymmdd != "" ]]; then
            #echo " dateDirectory for $fileName : $yyyymmdd"
            copyFileToDateDirectory "$fileName" "/rl/data/feed/$yyyymmdd/"
          fi
    done

fi