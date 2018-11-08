#!/bin/bash
# Log Location on Server.
currentdate=`date "+%Y-%m-%d %H:%M:%S"`

LOG_LOCATION=/rl/data/logs/facebook-auto-feed/
exec >> $LOG_LOCATION/copyfeed-$currentdate.log 2>&1

echo "*******  Start of copyfeed.sh script *******"

inotifywait -m /home/testuser/catalog/ -e create -e modify |

while read path action file;

   do
      timestamp=`date "+%Y-%m-%d %H:%M:%S"`
      echo "$timestamp: The file '$file' appeared in directory '$path' via '$action'"


      sourceFilePath="$path$file" #Should be injected by the inotify listener

      echo "$timestamp: sourceFilePath : $sourceFilePath"
      #Sample file path
      #sourceFilePath="/home/testuser/catalog/Dealer123_USA_11-01-2018_15_21_20.csv"

      dateInSourceFilePath=$(expr "$sourceFilePath" : '.*/\([^/]*\).*' | cut -f 3 -d "_")
      echo "$timestamp: dateInSourceFilePath : $dateInSourceFilePath"

      #Format date to yyyy-mm-dd
      IFS='-' mmddyyyy=(${dateInSourceFilePath})
      yyyymmdd="${mmddyyyy[2]}-${mmddyyyy[0]}-${mmddyyyy[1]}"
      echo "$timestamp: yyyymmdd : $yyyymmdd"

     user_dir=$(echo "$sourceFilePath" | cut -f 3 -d "/")
     echo "$timestamp: user_dir : $user_dir"

     targetDir="/rl/data/autofeed/$yyyymmdd"

     if [ ! -d $targetDir ]; then ###Checking if current date directory exists
       mkdir -p $targetDir
     fi

     cp $sourceFilePath $targetDir
     echo "$timestamp: ***** SUCCESS : Copied $sourceFilePath to $targetDir *****"

done
