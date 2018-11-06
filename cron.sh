#!/bin/bash

modified_file_name_path="$@" #Should be injected by the inotify listener

#Sample file path
#modified_file_name_path="/home/testuser/catalog/Dealer123_USA_11-01-2018_15_21_20.csv"

file_name_date=$(expr "$modified_file_name_path" : '.*/\([^/]*\).*' | cut -f 3 -d "_")
echo $file_name_date

user_dir=$(echo "$modified_file_name_path" | cut -f 3 -d "/")
echo $user_dir

 if [ ! -d "/home/$user_dir/catalog/$file_name_date" ]; then ###Checking if current date directory exists
      mkdir -p /home/$user_dir/catalog/$file_name_date
 fi

cp $modified_file_name_path /home/$user_dir/catalog/$file_name_date/
