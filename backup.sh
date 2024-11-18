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

#Checks for more than 2 backups. If there is, remove the oldest.
function countAndRemoveExtras() {
    filenames=()
    count=$(rclone lsf "gdrive:/Backups" | wc -l)
    
    if [ $count -gt 2 ]; then
        # Add files to filenames array
        while read -r file; do
            filenames+=("$file")
        done < <(rclone lsf "gdrive:/Backups")

        # Find the oldest file
        oldest_file=""
        oldest_date=99999999 

        for file in "${filenames[@]}"; do
            # Extract the date
            file_date="${file:0:8}"
            
            if [[ $file_date =~ ^[0-9]{8}$ && $file_date -lt $oldest_date ]]; then
                oldest_date=$file_date
                oldest_file=$file
            fi
        done

        # Delete the oldest file 
        if [ -n "$oldest_file" ]; then
            echo "Deleting oldest file: $oldest_file"
            rclone delete "gdrive:/Backups/$oldest_file"
        else
            echo "No valid file to delete found."
        fi
    fi
}

file=$(zip_all)
rclone move "$file" gdrive:/Backups/
#Check for more than 2 files and remove the oldest file.
countAndRemoveExtras
