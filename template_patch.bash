#!/bin/bash

# Name of the patch
# It is nameOfPatch-Date with date in format ddmmyy
PATCHNAME=
# ISROOTNEEDED
RUNASROOT=

#
# infosPatch contain all informations about what
# the patch will do.
#

function infosPatch
{
  #FIXME Enter informations about this patch
  echo "This patch will do nothing."
  echo "You should not install it."
}

#
# actionsPerformed will reunite all the actions performed by the patch
# You should only modify this function for your patch
#

function actionsPerformed
{
  #FIXME Edit what the patch will do
  echo "FIXME"
}


###################################################
### Editing the following functions for you patch #
### may corrupt your patch. #######################
###################################################

#
# THIS AFFECT PERMANENTLY THE ENV VAR
# addEnvironmentVar: Create new environment variable
# ONLY if it does not exist. If you want to update
# a variable that might already exist, please use
# the function 'updateEnvironmentVar'
#

function addEnvironmentVar
{
  if [ $# -ne 2 ]; then
    echo "ERROR: Bad usage of addEnvironmentVar"
    echo "Usage: addEnvironmentVar \"newEnvVar\" \"newEnvValue\""
    exit 1
  fi
  local _newEnvVar=$1
  local _newEnvValue=$2

  if ! cat /etc/environment | grep "$_newEnvVar=" &> /dev/null; then
    echo "$_newEnvVar=$_newEnvValue" >> /etc/environment
    echoInfo "Variable environment $_newEnvVar set to $_newEnvValue"
  else
    local _varContent="echo \${$_newEnvVar}"
    _varContent=$(eval $_varContent)
    echoWarning "Variable environment '$_newEnvVar' already exists."
    echoWarning "  The current value: '$_varContent' DIDN'T change."
    echoWarning "  The patch should have set it to '$_newEnvValue'"
  fi
}

#
# THIS AFFECT PERMANENTLY THE ENV VAR
# updateEnvironmentVar: Update or create
# the given environment variable.
#

function updateEnvironmentVar
{
  if [ $# -ne 2 ]; then
    echo "ERROR: Bad usage of updateEnvironmentVar"
    echo "Usage: updateEnvironmentVar \"envVar\" \"newEnvValue\""
    exit 1
  fi
  local _newEnvVar=$1
  local _newEnvValue=$2

  if ! cat /etc/environment | grep $_newEnvVar= &> /dev/null; then
    echo "$_newEnvVar=$_newEnvValue" >> /etc/environment
  else
    sed -i 's/'"$_newEnvVar"'=.*$/'"$_newEnvVar"'='"$_newEnvValue"'/' /etc/environment 
  fi
  echoInfo "Variable environment $_newEnvVar set to $_newEnvValue"
}

function installPackage
{
  if [ $# -ne 1 ]; then
    echoError "Bad usage of installPackage"
    echo "Usage: installPackage \"newPackage\""
    exit 1
  fi

  local _newPackage=$1

  echoInfo "Installing $_newPackage..."
  if apt -y install $_newPackage; then
    echoInfo "Package $_newPackage installed"
  else
    echoError "Installation of package $_newPackage failed"
    echoError "Try to run 'sudo apt install $_newPackage'"
    exit 1
  fi
}

function removePackage
{
  if [ $# -ne 1 ]; then
    echoError "Bad usage of removePackage"
    echo "Usage: removePackage \"packageToDelete\""
    exit 1
  fi

  local _old=$1

  echoInfo "Installing $_newPackage..."
  if apt -y remove $_newPackage && apt -y autoremove; then
    echoInfo "Package $_newPackage removed successfully"
  else
    echoError "Removing of package $_newPackage failed"
    echoError "Try to run 'sudo apt remove $_newPackage && sudo apt autoremove'"
    exit 1
  fi
}

function mendatoryCmd
{
  if [ $# -ne 1 ]; then
    echoError "Bad usage of mendatoryCmd"
    echo "Usage: mendatoryCmd \"cmd\""
    exit 1
  fi
  local _cmd=$1
  if $_cmd; then
    echoSuccess "$_cmd"
  else
    echoError "$_cmd failed. Script aborted"
  fi
}

# Check that a given patch is already install on that VM
function checkPatchInstalled
{
  if [ $# -ne 1 ]; then
    echoError "Bad usage of checkPatchInstalled"
    echo "Usage: checkPatchInstalled \"patchName\""
    exit 1
  fi
  local _patchName=$1
  if cat ~/.PATCHLIST | grep $_patchName; then
    return 0
  fi
  return 1
}

function checkRequirements
{
  if [ ! -f ~/.PATCHLIST ]; then
    if [ ! "$EUID" -ne 0 ]; then
      echoError "You need to create ~/.PATCHLIST file with your user account"
      echoError "You can create it with the following command: 'touch ~/.PATCHLIST'"
      exit 1
    else
      echo "~/.PATCHLIST does not exist. This run will create it for you."
      touch ~/.PATCHLIST
    fi
  fi
}

function isPatchAlreadyInstalled
{
  if cat ~/.PATCHLIST | grep $PATCHNAME; then
    return 0
  fi
  return 1
}

function addPatchToList
{
  if ! isPatchAlreadyInstalled; then
    echo "$PATCHNAME" >> ~/.PATCHLIST
  fi
}

function downloadFile
{
  if [ $# -ne 1 ]; then
    echoError "Bad usage of downloadFile"
    echo "Usage: downloadFile \"url\" [\"path\"]"
    echo "By default, the path is the current directory"
    exit 1
  fi
  local _url=$1
  echoInfo "Downloading $_url"
  wget $_url
}

function confirmPatch
{
  if ! isPatchAlreadyInstalled; then
    read -p "Do you want to apply this patch? (y/n) " -n 1 -r
  else
    echoWarning "Patch $PATCHNAME already present in this VM"
    read -p "Do you really want to reinstall this patch? (y/n) " -n 1 -r
  fi
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echoError "Patch $PATCHNAME aborted."
    exit 2
  fi
}

function createFile
{
  if [ $# -ne 1 ]; then
    echoError "Bad usage of createFile"
    echo "Usage: createFile \"filename\" \"[content]\""
    exit 1
  fi
  local _file=$1
  local _content=$2
  if [ -f "$_file" ]; then
    echoWarning "File $_file already exists. Do you want to replace it?"
  fi
}

function checkUserIsRoot
{
  if [ "$EUID" -ne 0 ]; then
    echoError "Please run this patch as root."
    echoError "Patch $PATCHNAME aborted."
    exit 3
  fi
  return 0
}

