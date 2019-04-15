#!/usr/bin/env bash

LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
echo "$LOGTIME: ******  START deletefeed  ******"

# Log Location on Server.
LOG_LOCATION=/rl/data/logs/facebook-delete-feed/
CURRENTDATE=`date "+%Y-%m-%d"`

log=$LOG_LOCATION/deletefeed_$CURRENTDATE.log

#global variables
#monitoring 3 dirs:
vautoDir=/home/vautoreachlocal/catalog
homenetDir=/home/homenetautoreachlocal/catalog
autouplinkDir=/home/autouplinktechreachlocal/catalog

LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`

echo "$LOGTIME: ******  START : Cleaning up 60 days before feed files from $vautoDir  ******" >> $log
find $vautoDir -mindepth 0 -type f -mtime +60 -print | xargs rm -v >> $log
echo "$LOGTIME: ******  END : Cleaning up 60 days before feed files from $vautoDir  ******" >> $log

echo "$LOGTIME: ******  START : Cleaning up 60 days before feed files from $homenetDir  ******" >> $log
find $homenetDir -mindepth 0 -type f -mtime +60 -print | xargs rm -v >> $log
echo "$LOGTIME: ******  END : Cleaning up 60 days before feed files from $homenetDir  ******" >> $log

echo "$LOGTIME: ******  START : Cleaning up 60 days before feed files from $autouplinkDir  ******" >> $log
find $autouplinkDir -mindepth 0 -type f -mtime +60 -print | xargs rm -v >> $log
echo "$LOGTIME: ******  END : Cleaning up 60 days before feed files from $autouplinkDir  ******" >> $log

echo "$LOGTIME: ******  END deletefeed  ******"