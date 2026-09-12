#!/bin/sh
## This is a script to backup the /app/arkserver/arkgameserver directory for maintenance and DR purposes.
##   Execute every x hours thru crontab. Helps save server cluster from corruption, bugs, etc. 
##
## TLDR: 
##   pigz {all-previous-archive-tars} 
##   tar -cpf /archive/level1/backups/arkserver/arkgameserver_YYYY-MM-DD.X.tar arkgameserver/
##

#set -x

## Declare and init variables
## Modify SOURCEDIR and TARG_DIR accordingly to match your system's installation & file structure
#
RUNDATE=$(date +%Y-%m-%d)
RUNTIME=$(date +%Y-%m-%d_%H%M)
SOURCEDIR=/app/arkserver/arkgameserver/ShooterGame
TARG_DIR=/archive/level1/backups/arkserver
COUNT=$(ls ${TARG_DIR} | grep -c $(date +%Y-%m-%d'\.'))
VAR_NUM=$(ls ${TARG_DIR} | grep -cv '.gz\|.txt')
FILE_CNT=$((COUNT+1))
FILE_NAME=arkserverdata_${RUNDATE}.${FILE_CNT}.tar
JOB_LOG=/app/arkserver/logs.d/backup_${RUNTIME}.log

#################
fn_debug() {
##-- Used for testing
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | ===================================== "   >  ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Run Date   = " "${RUNDATE}"               >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | SourceDir  = " "${SOURCEDIR}/Saved"       >> ${JOB_LOG} 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Targ File  = " "${TARG_DIR}/${FILE_NAME}" >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Targ. Dir  = " "${TARG_DIR}"              >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Count      = " "${COUNT}"                 >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Var Num    = " "${VAR_NUM}"               >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | File Count = " "${FILE_CNT}"              >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | File NAME  = " "${FILE_NAME}"             >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | ===================================== "   >> ${JOB_LOG}
##-- Used for testing
}
#################


#################
fn_findAndDelete() {
## Delete data older than the established retention
#
## Set retention  (in days)
DAYS=15

find ${TARG_DIR} -mtime +${DAYS} -name '*.gz' -delete
find ${TARG_DIR} -mtime +${DAYS} -name '*.gz' -delete                >> ${JOB_LOG}

find ${TARG_DIR} -mtime +${DAYS} -name '*.txt' -delete
find ${TARG_DIR} -mtime +${DAYS} -name '*.txt' -delete               >> ${JOB_LOG}

find ${SOURCEDIR}/Saved/Logs -mtime +${DAYS} -name '*.log' -delete
find ${SOURCEDIR}/Saved/Logs -mtime +${DAYS} -name '*.log' -delete   >> ${JOB_LOG}

find /app/arkserver/logs.d -mtime +${DAYS} -name 'backup_*' -delete
find /app/arkserver/logs.d -mtime +${DAYS} -name 'backup_*' -delete  >> ${JOB_LOG}
}
#################

#################
fn_backup() {
## Function to backup the ARK server data with tar
#
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backing up ARK Server... please wait..." 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backing up ARK Server... please wait..."     >> ${JOB_LOG}

## Exclude following mods to save space & time (we dont need them archived):
##    111111111       = Primitive Plus
##    FjordurOfficial = WildCard converted Fjordur Map (NOT the original community map)
##    Ragnarok        = WildCard converted Ranarok Map (NOT the original community map)
##    TheCenter       = The Center Map
##    Valguero        = Map
##    LostIsland      = Map
tar --exclude="${SOURCEDIR}/Content/Mods/111111111" --exclude="${SOURCEDIR}/Content/Mods/FjordurOfficial" --exclude="${SOURCEDIR}/Content/Mods/Ragnarok" --exclude="${SOURCEDIR}/Content/Mods/TheCenter" --exclude="${SOURCEDIR}/Content/Mods/Valguero" --exclude="${SOURCEDIR}/Content/Mods/LostIsland" -cpf ${TARG_DIR}/"${FILE_NAME}" ${SOURCEDIR}/Content/Mods ${SOURCEDIR}/Saved

echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backup complete & located at: ${TARG_DIR}/${FILE_NAME}" 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backup complete & located at: ${TARG_DIR}/${FILE_NAME}"  >> ${JOB_LOG}
}

##################
fn_pigz (){
## Function to compress existing .tar files with pigz (parallel implementation of GZ)
#
if [ "$VAR_NUM" = 0 ] ;  then
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | No Files to gzip, so skipping." 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | No Files to gzip, so skipping."    >> ${JOB_LOG}
        else 
    while [ "${VAR_NUM}" -gt 0 ] 
        do
        GZIP_FILE=$(ls -t ${TARG_DIR}| grep tar | grep -v 'tar.gz' | tail -n50 | awk '{print $1 }')
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation started for file ${GZIP_FILE}" 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation started for file ${GZIP_FILE}"   >> ${JOB_LOG}
        pigz -9 ${TARG_DIR}/"${GZIP_FILE}"
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation completed for file ${GZIP_FILE}" 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation completed for file ${GZIP_FILE}" >> ${JOB_LOG}
        VAR_NUM=$((VAR_NUM-1))
        done
    echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation completed for all files in directory." 
    echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation completed for all files in directory." >> ${JOB_LOG}
fi
#set +x
}
##################


##################
fn_outputDirSize () {
## Function to place a file in TARG_DIR explaining archive size as of the backup datestamp
## Useful for checking TARG_DIR size over time 
#
## Example: 2025-12-21_2300_dir_size_is_72G.txt
#
ARCHIVE_UTIL=$(ls -lh ${TARG_DIR} | head -n1 | awk '{print $2}')
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Archive Size Dir written to temp file" 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Archive Size Dir written to temp file" >> ${JOB_LOG}
$(touch ${TARG_DIR}/${RUNTIME}_dir_size_is_${ARCHIVE_UTIL}.txt)
}
##################


fn_debug
fn_findAndDelete
fn_pigz
fn_backup
fn_outputDirSize


echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Process complete! Now exiting." 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Process complete! Now exiting."   >> ${JOB_LOG}

sleep 1
## End of script
