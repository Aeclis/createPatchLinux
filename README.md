# createPatchLinux

This project aims to ease the patches on VM and keep track of what is done in them.

It was created in order to keep the same VM updated for multiple user who wants to have the same behavior.

Behavior with Bash before V4 is not tested.

# How it works
  - Generate your new patch with generate_new_patch.bash script.
  - Enter the patch name in one word
  - Choose if the patch needs a root execution
  - Open "patch-NAMEPATCH.bash" and edit the 2 followings files:
    - infosPatch will be where you enter all information of what you patch do
    - actionsPerformed is where you create your patch

# Logs functions
echoInfo "Text message"
- Display a blue message in the following format:    "[INFO]    Text message"
echoSuccess "Text message"
- Display a green message in the following format:   "[SUCCESS] Text message"
echoWarning "Text message"
- Display a warning message in the following format: "[WARNING] Text message"
echoError "Text message"
- Display a red message in the following format:     "[ERROR]   Text message"

# Commands functions
runCmd "command"
- Display and execute the command.
mendatoryCmd "command"
- Display and execute the command. Script ends upon error on the command and abort the patch.

# Patch functions
addEnvironmentVar "envVarName" "valueEnvVar"
- AFFECTS PERMANENTLY THE ENV VAR. Create new environment variable ONLY if it does not exist. If you want to update a variable that might already exist, please use the function 'updateEnvironmentVar'
updateEnvironmentVar "envVarName" "newValueEnvVar"
- AFFECTS PERMANENTLY THE ENV VAR. Update or create the given environment variable.
installPackage "package name"
- Install the package name (from repository). Uses "apt install"
removePackage "package name"
- Remove the package name (from repository). Uses "apt remove"
checkPatchInstalled patchName
- Check that the given patchName is installed on this VM.
downloadFile "URL"
- Download the file of the given URL. Uses "wget"
