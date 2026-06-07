#!/bin/sh
## This script executes the backup of the teamspeak-6-beta application folder and underlying files.
## For use in regular maintenance, data restore, and other DR exercises.
##
## Requires pigz.
##
#
#set -x # to turn on verbose mode, useful for debuggin

RUNDATE=$(date +%Y-%m-%d)
RUNTIME=$(date +%Y-%m-%d_%H%M)
SOURCEDIR=/app/ts6server-beta/amd64                       ## scratched TO-DO: modify to non-hardcoded dir
#SOURCEDIR="$( cd "$( dirname "$0" )" && pwd )"           ## Automatically grabs current working directory (no more hard coded values!)
                                                          ##  DEV NOTE: After testing, I realized this methodology is not intuitive.
                                                          ##            I elected to leave both values in for function and documentation purposes.
TARGETDIR=/archive/level1/backups/ts6server-beta
COUNT=$(ls ${TARGETDIR} | grep -c $(date +%Y-%m-%d'\.'))
VAR_NUM=$(ls ${TARGETDIR} | grep -cv '.gz\|.txt')
FILE_CNT=$((COUNT+1))
FILE_NAME=ts6server-beta_${RUNDATE}.${FILE_CNT}.tar
JOB_LOG=${SOURCEDIR}/logs/ts6server-beta_backup_${RUNTIME}.log

#################
fn_debug() {
##-- Used for testing
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | ===================================== "   >  ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Run Date   = " "${RUNDATE}"               >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Targ. Dir  = " "${TARGETDIR}"              >> ${JOB_LOG}
echo $(date +%Y-%m-%d" "%H:%M:%S)" | DEBUG | Targ File  = " "${TARGETDIR}/${FILE_NAME}" >> ${JOB_LOG}
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
## Delete data & files older than x days
DAYS=9
find ${TARGETDIR} -mtime +${DAYS} -name '*.gz' -delete
find ${TARGETDIR} -mtime +${DAYS} -name '*.gz' -delete                >> ${JOB_LOG}

find ${TARGETDIR} -mtime +${DAYS} -name '*.txt' -delete
find ${TARGETDIR} -mtime +${DAYS} -name '*.txt' -delete               >> ${JOB_LOG}

find ${SOURCEDIR}/logs -mtime +${DAYS} -name '*.log' -delete
find ${SOURCEDIR}/logs -mtime +${DAYS} -name '*.log' -delete         >> ${JOB_LOG}

}
#################

#################
fn_backup() {
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backing up server... please wait..." 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backing up server... please wait..."     >> ${JOB_LOG}

tar -cpf ${TARGETDIR}/"${FILE_NAME}" ${SOURCEDIR}

echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backup complete & located at: ${TARGETDIR}/${FILE_NAME}" 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Backup complete & located at: ${TARGETDIR}/${FILE_NAME}"  >> ${JOB_LOG}
}

##################
fn_pigz (){
#set -x
if [ "$VAR_NUM" = 0 ] ;  then
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | No Files to gzip, so skipping." 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | No Files to gzip, so skipping."    >> ${JOB_LOG}
        else 
    while [ "${VAR_NUM}" -gt 0 ] 
        do
        GZIP_FILE=$(ls -t ${TARGETDIR}| grep tar | grep -v '.tar.gz' | tail -n1 | awk '{print $1 }') 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation started for file ${GZIP_FILE}" 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation started for file ${GZIP_FILE}"   >> ${JOB_LOG}
## Comment out next line when debugging/testing and not want to actually perform the pigz operation
        pigz -9 ${TARGETDIR}/"${GZIP_FILE}"
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation finishd for file ${GZIP_FILE}" 
        echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation finishd for file ${GZIP_FILE}" >> ${JOB_LOG}
        VAR_NUM=$((VAR_NUM-1))
        done
    echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation finished for all files in directory." 
    echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | PIGZ operation finished for all files in directory." >> ${JOB_LOG}
fi
#set +x
}
##################


##################
fn_outputDirSize () {
ARCHIVE_UTIL=$(ls -lh ${TARGETDIR} | head -n1 | awk '{print $2}')
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Archive Size Dir written to temp file" 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Archive Size Dir written to temp file" >> ${JOB_LOG}
$(touch ${TARGETDIR}/${RUNTIME}_dir_size_is_${ARCHIVE_UTIL}.txt)
}
##################

### MAIN SCRIPT ###

echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Main Process Started!" 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Main Process Started!"   >> ${JOB_LOG}

fn_debug
fn_findAndDelete
fn_pigz
fn_backup
fn_outputDirSize


echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Process complete! Now exiting." 
echo $(date +%Y-%m-%d" "%H:%M:%S)" | INFO | Process complete! Now exiting."   >> ${JOB_LOG}

sleep 1
## End of script

