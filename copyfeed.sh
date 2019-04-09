#!/bin/bash

LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
echo "$LOGTIME: Pinging copyfeed .. "

# Log Location on Server.
LOG_LOCATION=/rl/data/logs/facebook-auto-feed/
CURRENTDATE=`date "+%Y-%m-%d"`
exec >> $LOG_LOCATION/copyfeed_$CURRENTDATE.log 2>&1

echo "$LOGTIME: Pinging copyfeed process .. "
PROCESS_ID=$(ps -ef | grep inotifywait | grep -v grep | grep -v \<defunct\> | awk '{print $2}')
echo "PROCESS_ID : $PROCESS_ID"
if [[ ! -z "$PROCESS_ID" ]]; then
    echo "$LOGTIME: copyfeed process already running"
else
    echo "$LOGTIME: copyfeed process NOT running.  Initating a new one"
    # inotify monitoring 3 dirs:
    # /home/vautoreachlocal/catalog
    # /home/homenetautoreachlocal/catalog
    # /home/autouplinktechreachlocal/catalog
    inotifywait -m /home/vautoreachlocal/catalog/ /home/homenetautoreachlocal/catalog/ /home/autouplinktechreachlocal/catalog/ -e create -e modify |

    while read path action file;

       do
          LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
          echo "$LOGTIME: The file '$file' appeared in directory '$path' via '$action'"

          #Sample file path
          #modified_file_name_path="/home/testuser/catalog/Dealer123_2018-11-10_15:21:20.csv"
          modified_file_name_path="$path$file" #Should be injected by the inotify listener

          echo "$LOGTIME: modified_file_name_path : $modified_file_name_path"

          file_name_date=$(expr "$modified_file_name_path" : '.*/\([^/]*\).*' | cut -f 2 -d "_")
          echo "$LOGTIME: file_name_date : $file_name_date"

          if [ ${#file_name_date} -ne 10 ]; then
                  echo "$LOGTIME: Incorrect length of file_name_date : ${file_name_date}"
                  exit 1
          fi

          #To convert date format if needed
          #yyyymmdd="${file_name_date:6:4}-${file_name_date:0:2}-${file_name_date:3:2}"

          yyyymmdd=${file_name_date}

          if [ ! -d "/rl/data/feed/$yyyymmdd" ]; then ###Checking if current date directory exists
              mkdir -p /rl/data/feed/$yyyymmdd
              echo "$LOGTIME: Made dir /rl/data/feed/$yyyymmdd"
          else
              echo "$LOGTIME: Dir /rl/data/feed/$yyyymmdd  already exists"
          fi

#          if cp $modified_file_name_path /rl/data/feed/$yyyymmdd/; then
#              echo "$LOGTIME: ******* Copy Code: $? - SUCCESS Copying $modified_file_name_path to /rl/data/feed/$yyyymmdd/  *******"
#          else
#              echo "$LOGTIME: ******* Copy Code: $? - FAILED Copying $modified_file_name_path to /rl/data/feed/$yyyymmdd/   *******"
#          fi

          if rsync -av --include="*$yyyymmdd*" --exclude="*" $modified_file_name_path /rl/data/feed/$yyyymmdd/; then
              echo "$LOGTIME: ******* Copy Code: $? - SUCCESS Copying $modified_file_name_path to /rl/data/feed/$yyyymmdd/  *******"
          else
              echo "$LOGTIME: ******* Copy Code: $? - FAILED Copying $modified_file_name_path to /rl/data/feed/$yyyymmdd/   *******"
          fi

    done

fi