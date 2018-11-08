#!/bin/bash
# Log Location on Server.
LOG_LOCATION=/rl/data/logs/facebook-auto-feed/
exec >> $LOG_LOCATION/copyfeed.log 2>&1

echo "*******  Start of copyfeed.sh script *******"

inotifywait -m /home/testuser/catalog/ -e create -e modify |

while read path action file;

   do
      LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
      echo $LOGTIME": The file '$file' appeared in directory '$path' via '$action'"


      sourceFilePath="$path$file" #Should be injected by the inotify listener

      echo "sourceFilePath : $sourceFilePath"
      #Sample file path
      #sourceFilePath="/home/testuser/catalog/Dealer123_USA_11-01-2018_15_21_20.csv"

      dateInSourceFilePath=$(expr "$sourceFilePath" : '.*/\([^/]*\).*' | cut -f 3 -d "_")
      echo "dateInSourceFilePath : $dateInSourceFilePath"

      #Format date to yyyy-mm-dd
      IFS='-' mmddyyyy=(${dateInSourceFilePath})
      yyyymmdd="${mmddyyyy[2]}-${mmddyyyy[0]}-${mmddyyyy[1]}"
      echo "yyyymmdd : $yyyymmdd"

     user_dir=$(echo "$sourceFilePath" | cut -f 3 -d "/")
     echo "user_dir : $user_dir"

     targetDir="/rl/data/autofeed/$yyyymmdd"

     if [ ! -d $targetDir ]; then ###Checking if current date directory exists
       mkdir -p $targetDir
     fi

     cp $sourceFilePath $targetDir
     echo "***** SUCCESS : Copied $sourceFilePath to $targetDir *****"

done
