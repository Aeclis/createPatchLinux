function echoError
{
  local _text=$1
  echo -e "\e[91m[ERROR]   $_text\e[0m"
}

function echoWarning
{
  local _text=$1
  echo -e "\e[93m[WARNING] $_text\e[0m"
}

function echoSuccess
{
  local _text=$1
  echo -e "\e[92m[SUCCESS] $_text\e[0m"
}

function echoInfo
{
  local _text=$1
  echo -e "\e[96m[INFO]    $_text\e[0m"
}

function runCmd
{
	local _cmd=$1
	echoInfo "$_cmd"
	$_cmd
}
