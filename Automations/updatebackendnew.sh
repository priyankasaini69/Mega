#!/bin/bash

# Set the VMSS name and resource group
VMSS_NAME="aks-system-17889271-vmss"  # Update this to your actual VMSS name
RESOURCE_GROUP="MC_myResourceGroup_wanderlust_centralindia"

# Retrieve the public IP address of the first instance in the VM scale set
ipv4_address=$(az vmss list-ip-addresses --resource-group $RESOURCE_GROUP --name $VMSS_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)

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
