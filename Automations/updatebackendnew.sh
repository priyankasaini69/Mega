#!/bin/bash

# Set the VM name and resource group
VM_NAME="example-machine"
RESOURCE_GROUP="myResourceGroup"

# Retrieve the public IP address of the specified Azure VM
ipv4_address=$(az vm list-ip-addresses --name $VM_NAME --resource-group $RESOURCE_GROUP --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)

# Path to the .env file
file_to_find="../backend/.env.docker"

# Check the current FRONTEND_URL in the .env file
current_url=$(sed -n "4p" $file_to_find)

# Update the .env file if the IP address has changed
if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:5173\"|g" $file_to_find
    else
        echo "ERROR: File not found."
    fi
fi
