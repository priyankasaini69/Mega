#!/bin/bash

# Set the VM name and resource group
VM_NAME="example-machine"
RESOURCE_GROUP="myResourceGroup"  # Use the resource group you created in Central India

# Retrieve the public IP address of the specified Azure VM
ipv4_address=$(az vm list-ip-addresses --name $VM_NAME --resource-group $RESOURCE_GROUP --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)

# Path to the .env file
file_to_find="../frontend/.env.docker"

# Check the current VITE_API_PATH in the .env file
current_url=$(cat $file_to_find)

# Update the .env file if the IP address has changed
if [[ "$current_url" != "VITE_API_PATH=\"http://${ipv4_address}:31100\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|VITE_API_PATH.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|g" $file_to_find
    else
        echo "ERROR: File not found."
    fi
fi
