#!/bin/bash

echo "*******  Start of copyfeed.sh script *******"

# Log Location on Server.
LOG_LOCATION=/rl/data/logs/facebook-auto-feed/
LOGFILE=`date "+%Y-%m-%d"`
exec >> $LOG_LOCATION/copyfeed_$LOGFILE.log 2>&1

inotifywait -m /home/testuser/catalog/ -e create -e modify |

while read path action file;

   do
      LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
      echo "$LOGTIME: The file $file appeared in directory $path via $action"


      modified_file_name_path="$path$file" #Should be injected by the inotify listener

      echo "modified_file_name_path : $modified_file_name_path"
      #Sample file path
      #modified_file_name_path="/home/testuser/catalog/Dealer123_USA_11-01-2018_15_21_20.csv"

      file_name_date=$(expr "$modified_file_name_path" : '.*/\([^/]*\).*' | cut -f 3 -d "_")
      echo "file_name_date : $file_name_date"

      if [ ${#file_name_date} -ne 10 ]; then
              echo "Incorrect length of file_name_date : ${file_name_date}"
              exit 1
      fi


      yyyymmdd="${file_name_date:6:4}-${file_name_date:0:2}-${file_name_date:3:2}"

      user_dir=$(echo "$modified_file_name_path" | cut -f 3 -d "/")
      echo "user_dir : $user_dir"

      if [ ! -d "/rl/data/feed/$yyyymmdd" ]; then ###Checking if current date directory exists
          mkdir -p /rl/data/feed/$yyyymmdd
          echo "Made dir /rl/data/feed/$yyyymmdd"
      else
          echo "Dir /rl/data/feed/$yyyymmdd  already exists"
      fi

      if cp $modified_file_name_path /rl/data/feed/$yyyymmdd/; then
          echo "******* Copy Code: $? - Success Copying $modified_file_name_path to /rl/data/feed/$yyyymmdd/  *******"
      else
          echo "******* Copy Code: $? - Failed Copying $modified_file_name_path to /rl/data/feed/$yyyymmdd/   *******"
      fi

done
