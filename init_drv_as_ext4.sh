#!/bin/sh
#
# This program will initialize, format, and create a disk (dev/sd[a-z] | dev/nvmen[0-9]p[0-9] ) in EXT4 file system.
# 
# You will need to supply the DISK manually (maybe later I will enhnace so it is a READ-in vs hard-coded variable)
#
# I MBROUIL3 AM NOT RESPONSIBLE FOR ANY DAMAGE OR ISSUES CAUSED TO YOUR DATA AND DISKS FROM THIS SCRIPT!!
# BACK UP YOUR IMPORTANT DATA BEFORE PROCEEDING!!!
# IT IS YOUR RESPONSIBILITY TO DOUBLE & TRIPLE CHECK THE DRIVE(s) YOU ARE INTENDING TO FORMAT!
#
#
#set -x
#
# Set variables: 
# (this will be replaced in the future with a $READ variable :) ) 
DISK=/dev/sdf
DISK1=${DISK}1
BLOCK=`awk -v var=$DISK 'BEGIN {print substr(var,6)}'`

###############
# Declare functions
###############

fn_sleep () {
echo "sleeping for 5 sec" && sleep 5 && echo ""
}

fn_lsblk () {
# print basic lsblk info:
echo "==============================================================================================="
echo "Displaying LSBLK info of ${DISK}"
echo "==============================================================================================="
lsblk -fs | head -n1 ; lsblk -fs | grep $BLOCK && echo ""
sleep 1
}

# Print variables:
echo ""
echo "=================="
echo "Printing Variables"
echo "=================="
echo "DISK  = ${DISK}"
echo "DISK1 = ${DISK1}"
echo ""

fn_lsblk

echo "Verify your disks NOW...you have 10 sec to cancel (ctrl+c) if needed"
sleep 5
echo "Press CONTROL C in the next 5 seconds to cancel NOW!"
sleep 1
echo "Press CONTROL C in the next 4 seconds to cancel NOW!"
sleep 1
echo "Press CONTROL C in the next 3 seconds to cancel NOW!"
sleep 1
echo "Press CONTROL C in the next 2 seconds to cancel NOW!"
sleep 1
echo "Press CONTROL C in the next 1 seconds to cancel NOW!"
sleep 1

echo "Proceeding with remainder of script! "
sleep 1


# Set partition table as GPT
echo "sudo parted ${DISK}  mklabel gpt && echo """
sleep 2
sudo parted ${DISK}  mklabel gpt && echo ""

fn_lsblk

# Make partition 1 as EXT4, extend to ENTIRE disk 
echo "sudo parted -a opt ${DISK} mkpart primary ext4 0% 100%"
sudo parted -a opt ${DISK} mkpart primary ext4 0% 100%
fn_lsblk


# Initialize ext4 partition & give it a human-reable name
echo "sudo mkfs.ext4 -L datapartition ${DISK1} && echo """
sudo mkfs.ext4 -L datapartition ${DISK1} && echo ""
fn_lsblk

echo "Process complete! Now exiting."
sleep 1
