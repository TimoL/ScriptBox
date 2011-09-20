#!/bin/bash -l

#menu_entry syntax
# menu_entry <key> <description> <location> <command> [mode]

while [ $(menu_running) ]
do
	menu_headline

	# simple menu entries, their output is displayed inline
	
	menu_entry "a" "print system information" local "uname -a"
			
	menu_entry "b" "print content of home folder" local "ls ~"

	menu_delimiter

	# execute script, but suppress all output

	menu_entry "e" "print content of home folder, no output" local "ls ~" silent

	menu_delimiter

	# execute more than one command

	menu_entry "h" "create, print and delete file" local \
	               "cd ~; \
	                echo 'scriptbox demo' >> scriptbox_demo.txt; \
	                cat scriptbox_demo.txt; \
	                rm scriptbox_demo.txt"

	menu_delimiter

	# execute command asynchronously in window
	# window will close after command is finished
	
	menu_entry "k" "input in external window" local \
	               "read -p 'input in external window: ' tmp" \
	               window
			
	# execute command asynchronously in window
	# window will close after command is finished
	
	menu_entry "l" "input in external blocking window" local \
	               "read -p 'input in external window: ' tmp" \
	               blocking_window

	menu_delimiter

	# script support, command is interpreted as a series of user inputs
	
	menu_entry "1" "script calling menu_entries" script "abehkl"
			
	menu_entry "2" "script calling other script" script "1-1"
			
	menu_wait_for_user_input

done
