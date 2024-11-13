#!/bin/bash
# Compress all files in ~/Documents directory
function zip_all(){
	#Edge Case– A zip file already exists in the PWD.
	rm *.zip
	filename="$(get_zip_format).zip"
	zip -r ${filename} ~/Documents/*
	echo "$filename"
}
#Returns the date format of the intended zip file.
function get_zip_format(){
	echo "$(date +"%Y%m%d")"
}

#Looks to see if there are more than 3 backups in the folder
function countAndRemoveExtras(){
	filenames=()
	count=$(rclone lsf gdrive:/Backups | wc -l)
	if [ $count -gt 3 ]
	then
		for file in $(rclone lsf "gdrive:/Backups"); 
		do
			filenames+=("$file")
		done
		oldest=$((${filenames[0]::-4}))
		for file in filenames;
		do
			fileSub=${file::-4}
			if [ $((fileSub)) -gt oldest ]
			then
				oldest=file
			fi
			rclone rm "gdrive:/Backups/$file"
		done

	fi
}

#Take the zip file and move it into the Google Drive Backups directory.
function moveToGDrive(){
	#BUG: The zip file is not found when attempting to move it to the Backups directory in Google Drive.
	rclone move "./*.zip" gdrive:/Backups/
	echo "Backup added!"
}
	

file=$(zip_all)
echo $file
# moveToGDrive $file
# countAndRemoveExtras

