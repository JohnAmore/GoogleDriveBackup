#!/bin/bash
# Compress all files in ~/Documents directory
function zip_all(){
	#Edge Case– A zip file already exists in the PWD.
	rm *.tar.gz
	filename="$(get_zip_format).tar.gz"
	tar cvfz "${filename}" ~/Documents/*
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
	if [ $count -gt 2 ]
	then
		for file in $(rclone lsf "gdrive:/Backups"); 
		do
			filenames+=("$file")
		done
		oldest=$(echo "$filenames[0]" | sed 's/\..*//')
		oldest=$(($oldest))

		for file in filenames;
		do
			fileSub=$(echo "$file" | sed 's/\..*//')
			if [ $((fileSub)) -gt oldest ]
			then
				oldest=file
			fi
		done
			rclone delete "gdrive:/Backups/$file"
	fi
}

file=$(zip_all)
rclone move "$file" gdrive:/Backups/
#Check for more than 2 files and remove the oldest file.
countAndRemoveExtras
