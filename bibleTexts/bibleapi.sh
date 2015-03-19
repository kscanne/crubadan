#!/bin/bash

rm -f tempDirectories.txt
rm -f tempLanguages.txt

IFS=" "
ARG=`echo $1 | sed 's/\/$//g'` # Remove the trailing / (If there is one)
MISSING_LANGS="" # List of languages that do not have directories
declare -a MISSING_DAMS # List of bibles that are not in the corpus
DAM_COUNT=0

ls -a $ARG | cat | egrep '^[^\.]' > tempDirectories.txt # File with all directory names
perl getLanguages.pl > tempLanguages.txt # File with all language names

# Loop through languages
while read lang
do
    DBP=`echo $lang | egrep -o '^...'`
    ISO=`echo $lang | egrep -o '[a-z]{3}'`
    DAMS=`echo $lang | egrep -o '[^ ]{10}'`
    FOUND=false
    # Loop through directories
    while read dir
    do
        # CODE is the ISO ID in the directory. We compare it to the ISO from the API
        CODE=`cat $ARG/$dir/EOLAS | egrep -o '^ISO_639-3 .+$' | sed 's/ISO_639-3 //g'`
        if [ $CODE == $ISO ]
        then
            # Loop through DAM IDs
            for dam in $DAMS
            do
                FOUND_DAM=false
                # Loop through lines of the MANIFEST file
                while read line
                do
                    if [ `echo $line | egrep -o "$dam"` ]
                    then
                        FOUND_DAM=true
                    fi
                done < $ARG/$dir/MANIFEST
                # If the DAM ID was not in the manifest file, append it to $MISSING_DAMS
                if [ "$FOUND_DAM" = false ]
                then
                    MISSING_DAMS[$DAM_COUNT]="$dam"
                    DAM_COUNT=$(( $DAM_COUNT + 1 ))
                fi
            done
            FOUND=true
            break
        fi
    done < tempDirectories.txt
    # Append language onto MISSING_LANGS if it is not found in a directory
    if [ "$FOUND" = false ]
    then
        MISSING_LANGS="$MISSING_LANGS $ISO"
    fi
done < tempLanguages.txt

echo "-Missing Language(s):$MISSING_LANGS"
echo "-Missing Bible(s):"
for i in "${MISSING_DAMS[@]}"
do
    echo $i
done

rm -f tempDirectories.txt
rm -f tempLanguages.txt
