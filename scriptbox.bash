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
SCRIPTBOX_VERSION=0.5.3

echo "Enabled $SCRIPTBOX_TITLE $SCRIPTBOX_VERSION shell extension."

# if there are command line arguments, use them as direct input
QUEUE="$1"

RED_BOLD='\E[37;31m''\033[1m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
BLUE='\e[0;34m'
NORM='\033[0m'

menu_delimiter()
{
	printf "${BLUE}----------------------------------------------------------${NORM}\n"
}

menu_delimiter_inline_start()
{
	printf "${YELLOW}----------------------------------------------------------\n"
}

menu_delimiter_inline_stop()
{
	printf "\0----------------------------------------------------------${NORM}\n"
}

menu_delimiter_bold()
{
	printf "${BLUE}==========================================================${NORM}\n"
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
	COMMAND=$1
	MODE=$2
	TEXT=$3

	case $MODE in
		"silent" )
			sh -c "$COMMAND" > /dev/null;;
		"inline" )
			menu_delimiter_inline_start
			sh -c "$COMMAND"
			menu_delimiter_inline_stop;;
		"window" )
			(xterm -T "[$TARGET] $TEXT" -e "$COMMAND") & ;;
	esac
}

execute_remote()
{
	COMMAND=$1
	TARGET=$2
	MODE=$3
	TEXT=$4

	eval IP="\$${TARGET}_IP"
	eval USER="\$${TARGET}_USER"
	
	case $MODE in
		"silent" )
			(ssh $USER@$IP "$COMMAND") &> /dev/null;;
		"inline" )
			menu_delimiter_inline_start
			ssh $USER@$IP "$COMMAND"
			menu_delimiter_inline_stop;;
		"window" )
			(xterm -T "[$TARGET] $TEXT" -e ssh $USER@$IP "$COMMAND") & ;;
	esac
	
}

menu_entry()
{
	KEY=$1
	TEXT=$2
	TARGET=$3
	COMMAND=$4
	MODE=$5

	if [ "$MODE" == "" ]; then
		MODE=inline
	fi
	
	case $TARGET in
		"script" ) printf " ${RED_BOLD}$KEY${NORM} $TEXT ${GREEN}[script:$COMMAND]${NORM}\n";;
		*        ) printf " ${RED_BOLD}$KEY${NORM} $TEXT ${GREEN}[$TARGET][${MODE:0:1}]${NORM}\n";;
	esac

	if [ "$MODE" == "blocking_window" ]; then
		MODE=window
		COMMAND="$COMMAND;echo;echo '[Finished - Press ENTER to close window]';read"
	fi

	if [ "${QUEUE:0:1}" == "$KEY" ]; then
		case $TARGET in
			"script" ) QUEUE=" $COMMAND${QUEUE:1}";;
			"local"  ) execute_local "$COMMAND" "$MODE" "$TEXT";;
			*        ) execute_remote "$COMMAND" "$TARGET" "$MODE" "$TEXT";;
		esac
	fi
}

menu_wait_for_user_input()
{
	menu_delimiter

	menu_entry "-" "pause (1 Sec)" local "sleep 1" silent
	menu_entry "x" "exit" local "" silent

	menu_delimiter_bold

	QUEUE=${QUEUE:1}

	if [ "$QUEUE" == "" ]; then
		read -p " Command(list): " QUEUE
	fi
	
	echo
}
