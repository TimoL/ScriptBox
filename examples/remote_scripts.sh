#!/bin/bash -l

# it is highly recommended to add your public ssh key to the list of
# allowed keys of all used targets before using scriptbox with remote
# targets. Otherwise you will have to provide the user password all
# the time.

# configure remote targets, you can have as many targets as you like
# to define target MYTARGET, you have to define MYTARGET_IP and MYTARGET_USER
TARGET1_IP=192.168.0.2
TARGET1_USER=root

# menu_entry syntax
# menu_entry <key> <description> <location> <command> [mode]

while [ $(menu_running) ]
do
	menu_headline

	# simple menu entries, their output is displayed inline
	
	menu_entry "a" "print system information" TARGET1 "uname -a"
			
	menu_entry "b" "print content of home folder" TARGET1 "ls ~"

	menu_delimiter

	# execute script, but suppress all output

	menu_entry "e" "print content of home folder, no output" TARGET1 "ls ~" silent

	menu_delimiter

	# execute more than one command

	menu_entry "h" "create, print and delete file" TARGET1 \
	               "cd ~; \
	                echo 'scriptbox demo' >> scriptbox_demo.txt; \
	                cat scriptbox_demo.txt; \
	                rm scriptbox_demo.txt"

	menu_delimiter

	# execute command asynchronously in window
	# window will close after command is finished
	
	menu_entry "k" "input in external window" TARGET1 \
	               "read -p 'input in external window: ' tmp" \
	               window
			
	# execute command asynchronously in window
	# window will stay open after command is finished
	
	menu_entry "l" "input in external blocking window" TARGET1 \
	               "read -p 'input in external window: ' tmp" \
	               blocking_window

	menu_delimiter

	# script support, command is interpreted as a series of user inputs
	
	menu_entry "1" "script calling menu_entries" script "abehkl"
			
	menu_entry "2" "script calling other script" script "1-1"
			
	menu_wait_for_user_input

done
