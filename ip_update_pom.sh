#!/bin/bash

FILE="pom.xml" # To be replaced it with something dynamic
NEXUS_SERVER="Nexus-Server"

# Check if the file exists

# Check if the correct number of arguments is provided (just one argument: the file full path)

if [ -e "$FILE" ]; then

    echo -e "\nThe File $FILE exists."

	# Retrieve public IP addresses and instance IDs for running instances
	NEW_IP=`aws ec2 describe-instances --filters "Name=tag:Name,Values=$NEXUS_SERVER" --query "Reservations[*].Instances[?State.Name=='running'].PublicIpAddress" --output text`
	NEXUS_SERVER_ID=`aws ec2 describe-instances --filters "Name=tag:Name,Values=$NEXUS_SERVER" --query "Reservations[*].Instances[?State.Name=='running'].InstanceId" --output text`

	# Check if instances_info is empty
	if [[ -z "$NEW_IP" ]]; then
		echo -e "\nNo running instances found with the name $NEXUS_SERVER."
		echo -e "\n"
		exit 1
	else 	
		
		# IP extraction
		OLD_IP=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$FILE")
		
		if [ -n "$OLD_IP" ]; then

			# Display results
			echo -e "\n#################### INSTANCE INFORMATION ################"
			echo "Nexus InstanceId: $NEXUS_SERVER_ID"
			echo "Old Nexus Server IP Address: $OLD_IP"
			echo "New Nexus Server IP Address: $NEW_IP"
			
			# Change the OLD_IP by the NEW_IP
			#sudo sed -i "s/$OLD_URL/$NEW_URL/g" "$FILE"
			
			grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$FILE" | while read -r ip; do 
				sed -i "s/$ip/$NEW_IP/g" "$FILE" 
			done
			
			# Display the new file updated
			echo -e "\n#################### New version of the file #####################"
			cat $FILE
			echo ""
			
						# Restart the service
			echo -e "\n#################### Restarting Nexus Server #####################"
			echo "Restart Nexus Service, please wait a moment ...."
			sudo systemctl restart nexus.service
			sleep 5 
			sudo systemctl status nexus | grep running
			echo -e "\nDone...................."
			echo -e "\n"
		
		else
			echo "No IP address found in the file $FILE."
			exit 1
		fi
		
	fi
else
    echo -e "\nThe file $FILE does not exist."
fi