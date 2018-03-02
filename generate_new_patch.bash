#!/bin/bash

# Here are all the imported files needed
IMPORTFILES="common.bash"
PATCHMAINFILE=template_patch.bash
PATCHNAME=
RUNASROOT=

function checkFiles
{
  for file in $IMPORTFILES; do
    if [ ! -f "$file" ]; then
      echo -e "\e[91m[ERROR] $file does not exist and is needed by $0\e[0m"
      exit 1
    fi
  done
}

function importFiles
{
  for file in $IMPORTFILES; do
    source "$file"
  done
}

function parseArgs
{
  while getopts "hr:p:" opt; do
    case "$opt" in
      h)
        echo "$0 helps you to generate patch scripts"
        echo "Usage: ./$0 [OPTION...]"
        echo "Options:"
        echo "  -h:"
        echo "    Display this information."
        echo "  -r (True|False):"
        echo "    Force the script to be launch as ROOT (True/False)"
        echo "  -p patchName:"
        echo "    Name of the generated patch"
        exit 0
        ;;
      p)
        PATCHNAME=$OPTARG
        ;;
      r)
        RUNASROOT=$OPTARG
        ;;
    esac
  done
}

#TODO
function unuse
{
  for file in $PATCHFILES; do
    if echo "$file" | grep template_; then
      newFileName=$(echo "$file" | sed 's|template_\(.*\)\.bash|\1-'"$PATCHNAME"'.bash|')
      if [ -e "$newFileName" ]; then
        echoError "$newFileName already exists"
        echoError "Script aborted"
        exit 1
      else
        runCmd "cp $file $newFileName"
      fi
    fi
  done
}

function configPatch
{
  if [ -z "$PATCHNAME" ]; then
    echo "Enter your patch name: (do not use space)"
    read -a PATCHNAME
  fi
  if [ -z "$RUNASROOT" ]; then
    read -p "Is your patch needs to be run as root? (y/n)" -r -n 1
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      RUNASROOT=True
    else
      RUNASROOT=False
    fi
  fi
}

function createMainFile
{
  local _file=patch-$PATCHNAME.bash
  local _date=$(date +"%d%m%y")
  if [ -f "$_file" ]; then
    echoError "$_file already exists"
    echoError "Script aborted"
    exit 1
  fi
  echoInfo "Preparing $_file"
  touch $_file
  cat template_patch.bash >> $_file
  cat common.bash >> $_file
  cat template_running.patch >> $_file
  echo "" >> $_file
  sed -i 's/^PATCHNAME=$/PATCHNAME='"$PATCHNAME-$_date"'/' $_file
  sed -i 's/^RUNASROOT=$/RUNASROOT='"$RUNASROOT"'/' $_file
  runCmd "chmod 755 $_file"
  printConfiguration
  echoInfo "$_file generated."
}

function printConfiguration
{
  local _LINEOFFSET='......................................'
  printf "============================================================\n"
  printf "=== PATCH CONFIGURATION ====================================\n"
  printf "============================================================\n"
  printf "== %.30s %s\n" "PATCHNAME $_LINEOFFSET" "$PATCHNAME"
  printf "== %.30s %s\n" "RUNASROOT $_LINEOFFSET" "$RUNASROOT"
  printf "============================================================\n"
  printf "============================================================\n"
}

checkFiles
importFiles
parseArgs $@
configPatch
createMainFile
