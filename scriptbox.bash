# Copyright (c) 2011 Timo Lotterbach
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/bin/bash

SCRIPTBOX_TITLE="ScriptBox"
SCRIPTBOX_VERSION=0.5.5

echo "Enabled $SCRIPTBOX_TITLE $SCRIPTBOX_VERSION shell extension."

# if there are command line arguments, use them as direct input
SB_QUEUE="$1"

SB_RED_BOLD='\E[37;31m''\033[1m'
SB_GREEN='\e[0;32m'
SB_YELLOW='\e[0;33m'
SB_BLUE='\e[0;34m'
SB_NORM='\033[0m'

menu_running()
{
	if [ "${SB_QUEUE:0:1}" != "x" ]
	then
		echo "continue"
	fi
}

menu_delimiter()
{
	printf "${SB_BLUE}----------------------------------------------------------${SB_NORM}\n"
}

menu_delimiter_inline_start()
{
	printf "${SB_YELLOW}----------------------------------------------------------\n"
}

menu_delimiter_inline_stop()
{
	printf "\0----------------------------------------------------------${SB_NORM}\n"
}

menu_delimiter_bold()
{
	printf "${SB_BLUE}==========================================================${SB_NORM}\n"
}

menu_headline()
{
	clear
	menu_delimiter_bold
	printf " $SCRIPTBOX_TITLE $SCRIPTBOX_VERSION | `basename $0` \n"
	menu_delimiter_bold
}

execute_local()
{
	SB_COMMAND=$1
	SB_MODE=$2
	SB_TEXT=$3

	case $SB_MODE in
		"silent" )
			sh -c "$SB_COMMAND" > /dev/null;;
		"inline" )
			menu_delimiter_inline_start
			sh -c "$SB_COMMAND"
			menu_delimiter_inline_stop;;
		"window" )
			(xterm -T "[$SB_TARGET] $SB_TEXT" -e "$SB_COMMAND") & ;;
	esac
}

execute_remote()
{
	SB_COMMAND=$1
	SB_TARGET=$2
	SB_MODE=$3
	SB_TEXT=$4

	eval SB_IP="\$${SB_TARGET}_IP"
	eval SB_USER="\$${SB_TARGET}_USER"
	
	case $SB_MODE in
		"silent" )
			(ssh $SB_USER@$SB_IP "$SB_COMMAND") &> /dev/null;;
		"inline" )
			menu_delimiter_inline_start
			ssh $SB_USER@$SB_IP "$SB_COMMAND"
			menu_delimiter_inline_stop;;
		"window" )
			(xterm -T "[$SB_TARGET] $SB_TEXT" -e ssh $SB_USER@$SB_IP "$SB_COMMAND") & ;;
	esac
	
}

menu_entry()
{
	SB_KEY=$1
	SB_TEXT=$2
	SB_TARGET=$3
	SB_COMMAND=$4
	SB_MODE=$5

	if [ "$SB_MODE" == "" ]; then
		SB_MODE=inline
	fi
	
	case $SB_TARGET in
		"script" ) printf " ${SB_RED_BOLD}$SB_KEY${SB_NORM} $SB_TEXT ${SB_GREEN}[script:$SB_COMMAND]${SB_NORM}\n";;
		*        ) printf " ${SB_RED_BOLD}$SB_KEY${SB_NORM} $SB_TEXT ${SB_GREEN}[$SB_TARGET][${SB_MODE:0:1}]${SB_NORM}\n";;
	esac

	if [ "$SB_MODE" == "blocking_window" ]; then
		SB_MODE=window
		SB_COMMAND="$SB_COMMAND;echo;echo '[Finished - Press ENTER to close window]';read"
	fi

	if [ "${SB_QUEUE:0:1}" == "$SB_KEY" ]; then
		case $SB_TARGET in
			"script" ) SB_QUEUE=" $SB_COMMAND${SB_QUEUE:1}";;
			"local"  ) execute_local "$SB_COMMAND" "$SB_MODE" "$SB_TEXT";;
			*        ) execute_remote "$SB_COMMAND" "$SB_TARGET" "$SB_MODE" "$SB_TEXT";;
		esac
	fi
}

menu_wait_for_user_input()
{
	menu_delimiter

	menu_entry "-" "pause (1 Sec)" local "sleep 1" silent
	menu_entry "x" "exit" local "" silent

	menu_delimiter_bold

	SB_QUEUE=${SB_QUEUE:1}

	if [ "$SB_QUEUE" == "" ]; then
		read -p " Command(list): " SB_QUEUE
	fi
	
	echo
}
