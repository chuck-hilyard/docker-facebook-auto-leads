#!/bin/bash

current_date=$(date +%m-%d-%Y)
echo "current date - $current_date"

users=( "testuser" "testuser2" )

for user in "${users[@]}"
do
   echo "user - $user"
   if [ ! -d "/home/$user/catalog/$current_date" ]; then ###Checking if current date directory exists
      mkdir -p /home/$user/catalog/$current_date
   fi

   for feed_file in /home/$user/catalog/*$current_date*.csv
    do
        echo "feed file - $feed_file"
        cp $feed_file /home/$user/catalog/$current_date/
    done
done
