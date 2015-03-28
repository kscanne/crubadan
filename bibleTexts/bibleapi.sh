#!/bin/bash

##############################################################
####################### INITIALIZATION #######################
##############################################################

rm -f DBP_Languages.txt
rm -f Crubadan_Info.txt

ARG=`echo $1 | sed 's/\/$//g'` # Remove the trailing "/" (If there is one) from the argument

##############################################################
###################### TEMP FILES ############################
##############################################################

# Create temporary files for the script
ls -a $ARG | egrep -v '^\.' |
while read dir
do
    ISO=`cat $ARG/$dir/EOLAS | egrep -o '^ISO_639-3 .+$' | sed 's/ISO_639-3 //g'`
    echo $dir | sed "s/^/$ISO /g"
done > Crubadan_Info.txt # File with 1 ISO code and 1 directory name per line
perl getLanguages.pl > DBP_Languages.txt # File with all language names from the DBP API

##############################################################
######################## FUNCTIONS ###########################
##############################################################

# Checks if the ISO codes match. If they do, it searches for the DAMs in the MANIFEST file
# $1 = string containing DAMS, 1 per line
# $2 = path to the directories
# $3 = directory name
# $4 = crubadan ISO code
# $5 = DBP ISO code
check_ISOs () {
    if [ "$4" == "$5" ]
    then
        for dam in $1
        do
            GREP_DAM=`egrep -m 1 "$dam" $2/$3/MANIFEST`
            if [ -z "$GREP_DAM" ] # if the DAM is not found in the MANIFEST file
            then
                echo "$dam: Bible on digitalbibleplatform.com but not in crubadan database"
            fi
        done
        FOUND=true
    fi  
}

##############################################################
#################### MAIN LOOP ###############################
##############################################################

# Loop through languages from the DBP API
while read lang # From DBP_Languages.txt
do
    DBP_ISO=`echo $lang | egrep -o '[a-z]{3}'` # String of the ISO code for the language
    DAMS=`echo $lang | egrep -o '[^ ]{10}' | sed 's/ /\n/g'` # String of the language's DAMS, 1 per line
    FOUND=false
    # First check for a directory with the same name as the ISO code
    if [ -e "$ARG/$DBP_ISO/EOLAS" ]
    then
        CRUBADAN_ISO=`cat $ARG/$DBP_ISO/EOLAS | egrep 'ISO_639-3' | sed 's/ISO_639-3 //g'`
        check_ISOs "$DAMS" "$ARG" "$DBP_ISO" "$CRUBADAN_ISO" "$DBP_ISO"
    fi
    # If the directory doesn't exist or the ISOs don't match, then loop to find the correct directory
    if [ "$FOUND" = false ]
    then
        # Grep Crubadan_Info.txt for the ISO
        CRUBADAN_ISO=`egrep -m 1 "^$DBP_ISO" Crubadan_Info.txt`
        if [ -n "$CRUBADAN_ISO" ] # If the ISO is found in Crubadan_Info.txt
        then
            DIR=`echo $GREP_ISO | sed 's/... //g'`
            check_ISOs "$DAMS" "$ARG" "$DIR" "$CRUBADAN_ISO" "$DBP_ISO"
            if [ "$FOUND" = true ]
            then
                break
            fi

        fi
    fi
    # If DBP_ISO is not found in any of the directories
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
