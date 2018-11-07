#!/bin/bash

echo "*******  Start of copyfeed.sh script *******"

inotifywait -m /home/testuser/catalog/ -e create -e modify | 

while read path action file; 

   do 
      echo "The file '$file' appeared in directory '$path' via '$action'"  


      modified_file_name_path="$path$file" #Should be injected by the inotify listener

      echo "modified_file_name_path : $modified_file_name_path"
      #Sample file path
      #modified_file_name_path="/home/testuser/catalog/Dealer123_USA_11-01-2018_15_21_20.csv"

      file_name_date=$(expr "$modified_file_name_path" : '.*/\([^/]*\).*' | cut -f 3 -d "_")
      echo "file_name_date : $file_name_date"

     user_dir=$(echo "$modified_file_name_path" | cut -f 3 -d "/")
     echo "user_dir : $user_dir"

     if [ ! -d "/home/$user_dir/catalog/$file_name_date" ]; then ###Checking if current date directory exists
       mkdir -p /home/$user_dir/catalog/$file_name_date
     fi

     cp $modified_file_name_path /home/$user_dir/catalog/$file_name_date/
     echo "Copy Success"

done
