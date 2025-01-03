#!/bin/bash

# Check if the user is root
if [ "$(id -u)" -ne "0" ]; then
  echo "This script must be run as root."
  exit 1  # Exit with an error code
fi

# Check previous binary exist or not, if exist then remove old binary
if [ -f "/bin/ovlc" ] ; then
   rm /bin/ovlc /bin/parseimages /bin/utils 
fi

# Check lab list exist or not

if [ -f "/bin/doclist.csv" ] ; then
    	old_list="/bin/doclist.csv"
    	new_list="./doclist.csv"
	lab_count=$(wc -l < doclist.csv)
	
	# Calculate checksums (you can replace md5sum with your preferred tool)
	checksum1=$(md5sum "$old_list" | awk '{print $1}')
	checksum2=$(md5sum "$new_list" | awk '{print $1}')

	if [ "$checksum1" == "$checksum2" ]; then
    		echo "Lab list is updated. list having $((lab_count - 1)) Labs."
	else
    		read -p "Do you want to update existing doclist.csv file with new list? (Y/N): " choice
    		# Convert the choice to lowercase for easier comparison
    		choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') 
    
    		if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    			cp ./doclist.csv /bin/doclist.csv
    			echo "Lab list is updated. list having $((lab_count - 1)) Labs."
    		fi
	fi
 else
cp ./doclist.csv /bin/doclist.csv
fi

cp ./utils /bin/utils  
cp ./ovlc  /bin/ovlc 
cp ./parseimages /bin/parseimages

chmod +x /bin/ovlc /bin/parseimages /bin/utils

source /bin/utils

read -p "Do you want to add aditional swap memory? (Y/N): " choice
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') 
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	swap_add
fi

read -p "Do you want to UPDATE/UPGRADE OS packages? (Y/N): " choice
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') 
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	update_upgrade
fi

#Install Required Tools
install_tool

echo "Setup completed. use ovlc command to start the lab."
