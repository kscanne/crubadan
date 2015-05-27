#!/bin/bash
# Author: Matthew Meyer

ALL_LEX=( amharic 
          arabic
          armenian
          assamese
          bengali
          bopomofo
          canadian_aboriginal
          cherokee
          cjk
          coptic
          cyrillic
          devanagari
          ethiopic 
          georgian 
          greek 
          hebrew 
          hiragana 
          indic 
          japanese 
          all
          katakana 
          khmer 
          latin
          mongolian 
          myanmar 
          ogham 
          runic 
          syriac 
          thaana 
          thai
          )
# ALL_LEX is the scripts we have rules for
PREF=.user_pref.trans    # const file name for storing preferences
RULES=~/.transliterate/  # const directory name for easy rule lookup

# Doc stuff
USAGE() {
  echo "If no file is given for input or output, stdin and stdout will be used. "
  echo "Usage: $0 {IN_FILE_NAME} {FLAGS}"
  echo ""
  echo "Flags to use with the tool: "
  echo "       -h | --help"
  echo "           This will show usage and terminate successfully"
  echo "       -L | --lex"
  echo "           This will show the available lexicographical options"
  echo "       -f | --from {LEX}"
  echo "           This is the lexicographic script from the transliterating file"
  echo "           If this flag is not used, the default script of the user preferences"
  echo "           will be used."
  echo "       -t | --to {LEX}"
  echo "           This is the lexicographic script that you want to transliterate to"
  echo "           If this flag is not used, the default script of the user preferences"
  echo "           will be used."
  echo "       -o | --out {FILE_NAME}"
  echo "           This is the file that the output is sent to"
  echo "           The default file name is IN_FILE_NAME.out"
  echo "       -l | --lang {LANG_CODE}"
  echo "           This code will be used for lnaguage specific transliterations. If no"
  echo "           code is given, the generic transliteration will be used."
  echo ""
  echo "Flags to change the local (directories) settings in `pwd`/.tranliterate/user_pref"
  echo "       --set-from {PREF}"
  echo "       --set-to {PREF}"
  echo "       --set-lang {PREF}"
  echo "Flags to change the global setting in ~/.tranliterate/user_pref"
  echo "       --set-global-from {PREF}"
  echo "       --set-global-to {PREF}"
  echo "       --set-global-lang {PREF}"
  echo "Flag to see settings"
  echo "       --pref"
}

# Check to see if the script is able to be used
CHECK_SCRIPT() {
  local bool=1
  for i in "${ALL_LEX[@]}"
  do
    if [ "$i" == $1 ]
    then 
      bool=0
    fi
  done
  return $bool
}

# Finds the preferences from the most local directory, 
# It jumps to parents until in the home directory where install.sh
# has placed a preference
FIND() {
  local P=`pwd`
  P+=/
  local F=
  local LOCAL=$PREF
  while [ -z $F ]
  do
    if [ ! -f $P/$LOCAL ]
    then 
      P+=../
    else
      F=`egrep "$1" $P$LOCAL | sed "s/$1: *//"`
    fi
  done
  echo "$F"
}

# This makes sure that all info is valid before transliterating. 
# If anything is wrong, it will print out what is wrong and exit
CHECK() {
  BAD=       # <-- error info
  # Check from script
  if [ ${FROM:+1} ]
  then # user gave flag
    CHECK_SCRIPT $FROM || BAD+="\*\*\*\* Invalid lex code from -f flag \*\*\*\*\n"
  else # no flag given
    FROM=$(FIND F)
  fi
  
  # check to script
  if [ ${TO:+1} ]
  then #user gave flag
    CHECK_SCRIPT $TO || BAD+="\*\*\*\* Invalid lex code from -t flag \*\*\*\*\n"
  else # no flag
    TO=$(FIND T)
  fi

  # not going to bother checking language for now
  if [ -z "$LANG_CODE" ]
  then
    LANG_CODE=$(FIND L)
  fi

  # check for and the existence of input file
  if [ ! -z "$IN" ]
  then
    if [ ! -f $IN ]
    then
      BAD+="\*\*\*\* Input file $IN not found \*\*\*\*"
    fi
  fi

  # check for errors
  if [ "$BAD" != "" ]
  then 
    echo -e $BAD
    exit 1
  fi

  # Set RULES
  RULES+="$FROM-to-$TO.rules"

}

# File to File
TRANS() {
  SED=
  PIPE=`cat $RULES | sed 's/#.*$//' | sed 's/ +$//' | sed '/^$/d' | (
  while read x # comments and empty lines already removed from sed commands
  do
    if [[ $x =~ ^LANG.* ]]
    then
      [[ $x =~ .*$LANG_CODE.* ]] || [[ $x =~ .*all.* ]] && SWITCH=true || SWITCH=false
    else
      # search and replace to transliterate
      if [ "$SWITCH" = true ]
      then
        x+="g;"
        SED+=$x
      fi
    fi
  done
  echo $SED
  )`

  while read line
  do
    line=`echo $line | sed "$PIPE"`
    echo $line >> ${OUT:-/dev/stdout}
  done < ${IN:-/dev/stdin}
}

# update local or global user preferences
USER_PREF() {
  if [ $3 ]
  then
    FILE=~/$PREF
  else
    FILE=`pwd`/$PREF
  fi
  
  if [ ! -f $FILE ]
  then
    touch $FILE
    echo "F:latin" >> $FILE
    echo "T:latin" >> $FILE
    echo "L:all" >> $FILE
  fi
  sed -i "s/^$2.*$/$2:$1/" $FILE
}


# MAIN
# handle flags, tons of flags
while [ $# -ge 1 ]
do
  case "$1" in
    -h | --help )
      USAGE
      exit 0
      ;;
    -L | --lex )
      LEX=`echo $0 | sed 's/trans.sh/available.sh/'`
      bash $LEX
      exit 0
      ;;
    -f | --from )
      shift
      FROM=$1
      ;;
    -t | --to )
      shift
      TO=$1
    ;;
    -o | --out )
      shift
      OUT=$1
      ;;
    -l | --lang )
      shift 
      LANG_CODE=$1
      ;;
    --set-from )
      shift 
      USER_PREF $1 F
      exit 0
      ;;
    --set-to )
      shift 
      USER_PREF $1 T
      exit 0
      ;;
    --set-lang )
      shift 
      USER_PREF $1 L
      exit 0
      ;;
    --set-global-from )
      shift 
      USER_PREF $1 F G
      exit 0
      ;;
    --set-global-to )
      shift 
      USER_PREF $1 T G
      exit 0
      ;;
    --set-global-lang )
      shift 
      USER_PREF $1 L G
      exit 0
      ;; 
    --pref )
      echo "LOCAL:"
      cat `pwd`/$PREF
      
      echo "GLOBAL:"
      cat ~/$PREF
      exit 0
      ;;
    * )
      IN=$1
      ;;

  esac
  shift
done
# if CHECK fails below, TRANS is skipped and we exit unsuccessfully
CHECK && TRANS || exit 1 # Output telling them what the bother is above
exit 0
