#!/bin/bash
set -x
#Initialize where the .tar.gz files will go if not already initialized.
check_for_local_backups_folder (){
	path_to_backups_folder="/Users/danielbennett/.googleDriveBackups/"

	if [ -d "$path_to_backups_folder" ];
	then
		continue
	else
		mkdir "${path_to_backups_folder}"
	fi
}

get_most_recent_file(){
	count=$(rclone lsf gdrive:/Backups | wc -l)
	filenames=()
	for file in  $(rclone lsf "gdrive:/Backups"); do
		filenames+=($(($(echo "$file" | sed 's/\..*//'))))
	done
	if [ $count -lt 1 ] 
	then
		echo "ERROR: No backup files detected."
		exit 1
	fi
	#Because the backup.sh script limits backups to 2, we only need to check 
	#for 2 or 1.
	if [ $count -gt 1 ]
		then
		if [ $((filenames[0])) -lt $((filenames[1])) ]
		then
			most_recent="${filenames[1]}.tar.gz"
		else
			most_recent="${filenames[0]}.tar.gz"
		fi
	else
		most_recent="${filenames[0]}.tar.gz"
	fi

	echo "${most_recent}"
}
#Lengthy. Extracts the .tar.gz file. Then, proceed to Documents directory.
#After getting into the tar's Documents directory, move those files into ~/Documents/
extract_backup(){
	#Pre-known locations
	filepath_tar="/Users/danielbennett/.googleDriveBackups/Users/danielbennett/Documents/"
	filepath_pc="/Users/danielbennett/Documents"
	#Extract
	cd /Users/danielbennett/.googleDriveBackups/
	tar -xzf "$1"
	cd $filepath_tar
	#Now that we made it into the location with all the backed-up files,
	#We can move it into the PC.
	mv ./* $filepath_pc
	cd /Users/danielbennett/.googleDriveBackups/
	rm -rf /Users/danielbennett/.googleDriveBackups/*
}

check_for_local_backups_folder
file=$(get_most_recent_file)
rclone move "gdrive:/Backups/${file}" /Users/danielbennett/.googleDriveBackups/
extract_backup $file
