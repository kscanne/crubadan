#!/bin/bash

##############################################################
####################### INITIALIZATION #######################
##############################################################

rm -f tempDirectories.txt
rm -f tempISOs.txt
rm -f tempTrash.txt
rm -f tempTrash2.txt
rm -f DBP_Languages.txt
rm -f Crubadan_Info.txt

ARG=`echo $1 | sed 's/\/$//g'` # Remove the trailing / (If there is one)

##############################################################
###################### TEMP FILES ############################
##############################################################

# Create temporary files for the script
ls -a $ARG | egrep -v '\.' | cat -n > tempDirectories.txt # File with all directory names
while read dir
do
    DIR=`echo $dir | sed 's/ //g' | sed -r 's/^[0-9]+?//g'`
    cat $ARG/$DIR/EOLAS | egrep -o '^ISO_639-3 .+$' | sed 's/ISO_639-3 //g'
done < tempDirectories.txt > tempTrash.txt
cat -n tempTrash.txt > tempISOs.txt
join tempISOs.txt tempDirectories.txt > tempTrash2.txt
cat tempTrash2.txt | sed -r 's/^ +?[0-9]+? +?//g' > Crubadan_Info.txt
rm -f tempTrash2.txt
rm -f tempTrash.txt
rm -f tempISOs.txt
rm -f tempDirectories.txt
perl getLanguages.pl > DBP_Languages.txt # File with all language names

##############################################################
######################## FUNCTIONS ###########################
##############################################################

# Loops through all of the DAMS and loops for them in the MANIFEST file in the directory
# $1 = string containing DAMS, 1 per line
# $2 = path to the MANIFEST file
check_DAMS () {
    for dam in $1
    do
        FOUND_DAM=false
        # Loop through lines of the MANIFEST file
        while read line
        do
            if [ `echo $line | egrep -o "$dam"` ]
            then
                FOUND_DAM=true
                break
            fi
        done < $2/MANIFEST
        # If the DAM ID was not in the manifest file, append it to $MISSING_DAMS
        if [ "$FOUND_DAM" = false ]
        then
            echo "$dam: Bible on digitalbibleplatform.com but not in crubadan database"
        fi
    done
}

# Checks if the ISO codes match. If they do, it calls check_DAMS()
# $1 = string containing DAMS, 1 per line
# $2 = path to the MANIFEST file
# $3 = crubadan ISO code
# $4 = DBP ISO code
check_ISOs () {
    if [ $3 == $4 ]
    then
        check_DAMS "$1" "$2"
        FOUND=true
    fi  
}

##############################################################
#################### MAIN LOOP ###############################
##############################################################

# Loop through languages from the DBP API
while read lang # From DBP_Languages.txt
do
    DBP_ISO=`echo $lang | egrep -o '[a-z]{3}'`
    DAMS=`echo $lang | egrep -o '[^ ]{10}' | sed 's/ /\n/g'`
    FOUND=false
    # First check for a directory with the same name as the ISO code
    if [ -e "$ARG/$DBP_ISO/EOLAS" ]
    then
        CRUBADAN_ISO=`cat $ARG/$DBP_ISO/EOLAS | egrep 'ISO_639-3' | sed 's/ISO_639-3 //g'`
        if [ "$CRUBADAN_ISO" == "$DBP_ISO" ]
        then
            check_ISOs "$DAMS" "$ARG/$DBP_ISO" "$CRUBADAN_ISO" "$DBP_ISO"
        fi  
    fi
    # If not, then loop to find it
    if [ "$FOUND" = false ]
    then
        # Loop through crubadan info  (1 ISO and its corresponding directory per line)
        while read info # From Crubadan_Info.txt
        do
            # DIR is the name of the directory
            DIR=`echo $info | sed 's/... //g'`
            # CRUBADAN_ISO is the ISO ID in the directory. We compare it to the ISO from the API
            CRUBADAN_ISO=`echo $info | egrep -o '^.{3}'`
            check_ISOs "$DAMS" "$ARG/$DIR" "$CRUBADAN_ISO" "$DBP_ISO"
            if [ "$FOUND" = true ]
            then
                break
            fi
        done < Crubadan_Info.txt
    fi
    # Append language onto MISSING_LANGS if it is not found in a directory
    if [ "$FOUND" = false ]
    then
        echo "$DBP_ISO: Language on digitalbibleplatform.com but not in crubadan database"
    fi
done < DBP_Languages.txt

##############################################################
######################### CLEAN-UP ###########################
##############################################################

rm -f DBP_Languages.txt
rm -f Crubadan_Info.txt
