# Created by BitSys Technologies AB
# Tweet @BitSysAB
# This is something every company needs to manage local admin passwords
# Script will create the local admin account and send password to Azure Tables
# This is quite advance as compared to macOS script in this repo. This will write device name, serial number & password on AZ tables.

# Import the required modules
Import-Module Azure.Storage

# Set the Azure storage account and table name
$accountName = 'mystorageaccount'
$tableName = 'mytablename'

# Generate a random password
$password = [System.Web.Security.Membership]::GeneratePassword(12, 2)

# Create the local admin account
$username = 'admin'
$fullName = 'Local Admin'
$description = 'Local administrator account'
New-LocalUser -Name $username -Password $password -FullName $fullName -Description $description -PasswordNeverExpires

# Add the local admin account to the local administrators group
Add-LocalGroupMember -Group 'Administrators' -Member $username

# Get the computer name and serial number
$computerName = $env:COMPUTERNAME
$serialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber

# Connect to the Azure storage account
$accountKey = (Get-AzStorageAccountKey -Name $accountName).Value[0]
$context = New-AzStorageContext -AccountName $accountName -AccountKey $accountKey

# Create the Azure table if it does not exist
if (-not (Get-AzStorageTable -Name $tableName -Context $context)) {
    New-AzStorageTable -Name $tableName -Context $context
}

# Create a new entity to store the computer name, serial number, and password
$properties = @{
    PartitionKey = 'computer'
    RowKey = $computerName
    SerialNumber = $serialNumber
    Password = $password
}
$entity = New-Object -TypeName Microsoft.Azure.Cosmos.Table.DynamicTableEntity -ArgumentList $properties

# Insert the entity into the Azure table
Add-AzTableRow -Entity $entity -Table $tableName -Context $context
