#!/bin/bash

# Set the string length
length=8

# Generate a random string using openssl
randomString=$(openssl rand -base64 $length)

#########
# Here, use sysadminctl to create the user account and feed the password directly.
# Next, send the same password to Azure Tables

# Import the required modules
source azure-functions-core-tools@3

# Set the account name and password length
accountName="admin"
passwordLength=16

# Generate a random password using OpenSSL
password=$(openssl rand -base64 $passwordLength)
randomString=$(password)
# Create the local admin account with the random password
dscl . -create /Users/$accountName
dscl . -create /Users/$accountName UserShell /bin/bash
dscl . -create /Users/$accountName RealName "Local Admin"
dscl . -passwd /Users/$accountName $password
dscl . -append /Groups/admin GroupMembership $accountName
#########

# Set your Azure storage account name and key
accountName='<YOUR_STORAGE_ACCOUNT_NAME>'
accountKey='<YOUR_STORAGE_ACCOUNT_KEY>'

# Set the name of the table to write to
tableName='<YOUR_TABLE_NAME>'

# Set the entity properties to write to the table
partitionKey='<PARTITION_KEY>'
rowKey='<ROW_KEY>'
propertyName='RandomString'
propertyValue=$randomString

# Authenticate to your Azure storage account
sasToken=$(printf $accountKey | base64)
storageAccountUrl="https://$accountName.table.core.windows.net/"

# Get a reference to the table
tableUrl="$storageAccountUrl$tableName"

# Create the entity to insert into the table
entity='{"PartitionKey": "'$partitionKey'", "RowKey": "'$rowKey'", "'$propertyName'": "'$propertyValue'"}'

# Insert the entity into the table
curl -X POST $tableUrl -H "Authorization: SharedAccessSignature $sasToken" -H "Content-Type: application/json" -d $entity
