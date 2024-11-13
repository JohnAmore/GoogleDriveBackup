#!/bin/bash
# Compress all files in ~/Documents directory
function zip_all(){
	#Edge Case– A zip file already exists in the PWD.
	rm *.tar
	filename="$(get_zip_format).tar"
	tar cvf "${filename}" ~/Documents/*
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
	if [ $count -gt 1 ]
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
			rclone delete "gdrive:/Backups/$file"
		done

	fi
}

file=$(zip_all)
echo "File to move: $file"
rclone move "$file" gdrive:/Backups/
countAndRemoveExtras
