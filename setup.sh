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
    
    		if [[ "$choice" == "y" ]]; then
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
if [[ "$choice" == "y" ]]; then
	swap_add
fi

read -p "Do you want to UPDATE/UPGRADE OS packages? (Y/N): " choice
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') 
if [[ "$choice" == "y" ]]; then
	update_upgrade
fi

#Install Required Tools
install_tool

declare -a descs cmd_fresh cmd_start cmd_stop cmd_remove

DOCLIST="/bin/doclist.csv"

log "[+] Parsing ${DOCLIST}"

read -p "Do you want to remove all older containers if any? (Y/N): " choice
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') 
if [[ "$choice" == "y" ]]; then
	# All docker containers stop and remove 
	all_docker_remove
fi

count=0
while IFS=',' read REPO TAG NAME APP_NAME ADD_OPTIONS PORT_ARGS POST_DOC_CMD POST_CMD REF
do
   if [ "$REPO" != "" ]
   then
     
      free_ram_gb=`free --giga | grep -i mem | awk '{print $4}'`
      run_dock=`docker ps | wc -l`
      
      log "docker pull $REPO:$TAG # Free RAM $free_ram_gb GB"
      echo "docker pull $REPO:$TAG # Free RAM $free_ram_gb GB"
      docker pull $REPO:$TAG
      log "docker run $ADD_OPTIONS --rm --name $NAME $PORT_ARGS $REPO:$TAG $POST_DOC_CMD # Free RAM $free_ram_gb GB"
      echo "docker run $ADD_OPTIONS --rm --name $NAME $PORT_ARGS $REPO:$TAG $POST_DOC_CMD # Free RAM $free_ram_gb GB"
      docker run $ADD_OPTIONS --rm --name $NAME $PORT_ARGS $REPO:$TAG $POST_DOC_CMD
      
       if [[ -n ${POST_CMD} ]]
       then
         log "Post Command Executed. $POST_CMD"
         sleep 20 
         $($POST_CMD)
       fi
    fi

   if [ $(( $free_ram_gb )) -lt 1 ]
   then
	log "Free RAM size is lessthen 1 GB, stop all docker."    
      	sync; echo 1 > /proc/sys/vm/drop_caches
	sync; echo 2 > /proc/sys/vm/drop_caches
	sync; echo 3 > /proc/sys/vm/drop_caches
   fi
    
docker stop $NAME 
    
count=$((count + 1))
done <<< "$(cat "${DOCLIST}" | sed -e 's/#.*//g')"

all_docker_stop

echo "Setup completed. use ovlc command to start the lab."
