#!/bin/bash

function showPlugins {
	plugins=$1
		counter=1;
	for plugin in "${plugins[@]}"
	do
	  echo "$counter. ${plugin}"
	  counter=$((counter+1))
	done
} 

function loadPlugins {
	IFS=""
		
	liferay_path=$1
	version=$2 
	instance_path=$3

	userInput "Do you want to include any plugin? (y/n)" addPlugins

	if [ "$addPlugins" == "y" ];then

		declare -a selected_plugins
		shopt -u sourcepath 
	    cd $liferay_path/plugins/$version
		
		plugins=(*)

		printMenu "Available plugins for $version" `showPlugins ${plugins[@]}`

		userInput "Select the plugins to add (0 to end): "  input_plugin

		while [ "$input_plugin" != "0" ]; do
		  	plugins_to_deploy+=(${plugins[$input_plugin]})
			read  input_plugin
		done
		
		printAction `
			for plugin in "${plugins_to_deploy[@]}"
		    do
		      echo "Coping plugin " $plugin

		      cp $liferay_path/plugins/$version/$plugin $instance_path/portal_files/deploy 
		    done
		`
	fi
}
