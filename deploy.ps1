# Azure Login
$applicationId =  ''
$securePasswordAz = ''
$tenantId = ''
$subscriptionID = ''
az login --allow-no-subscriptions --service-principal -u $applicationId --password $securePasswordAz --tenant $tenantId --subscription $subscriptionID
az account set --subscription $subscriptionID 

# Register for Image Builder / VM / Storage Features
az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview
az provider register -n Microsoft.VirtualMachineImages
az provider register -n Microsoft.Storage
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.Network
az provider register -n Microsoft.Compute

# Environment variables
# destination image resource group
$imageResourceGroup = 'AIB'

# location (eastus,eastus2,WestCentralUS,WestUS,WestUS2)
$location = 'eastus'

# password for test VM
$vmpassword = $securePasswordAz

# name of the image to be created
$imageName = 'aibCustomImgWin'

# image distribution metadata reference name
$runOutputName = 'aibCustWinRO'

# Create Resource group
az group create -n $imageResourceGroup -l $location

# To allow Azure VM Image Builder to distribute images to either the managed images or to a Shared Image Gallery, you will need to provide 'Contributor' permissions for the service "Azure Virtual Machine Image Builder" (app ID: cf32a0cc-373c-47c9-9156-0db11f6a6dfc) on the resource group.The --assignee value is the app registration ID for the Image Builder service.
az role assignment create `
    --assignee cf32a0cc-373c-47c9-9156-0db11f6a6dfc `
    --role Contributor `
    --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup

# download the VM Template and configure it with  variables
Invoke-WebRequest -UseBasicParsing `
    https://raw.githubusercontent.com/hanuravim/AIB/master/VMTemplate.json `
    -OutFile VMTemplate.json

sed -i -e "s/<subscriptionID>/$subscriptionID/g" VMTemplate.json
sed -i -e "s/<rgName>/$imageResourceGroup/g" VMTemplate.json
sed -i -e "s/<region>/$location/g" VMTemplate.json
sed -i -e "s/<imageName>/$imageName/g" VMTemplate.json
sed -i -e "s/<runOutputName>/$runOutputName/g" VMTemplate.json

# submit the image confiuration to the VM Image Builder Service
az resource create `
    --resource-group $imageResourceGroup `
    --properties '@VMTemplate.json' `
    --is-full-object `
    --resource-type Microsoft.VirtualMachineImages/imageTemplates `
    -n aibImage

# start the image build
az resource invoke-action `
     --resource-group $imageResourceGroup `
     --resource-type  Microsoft.VirtualMachineImages/imageTemplates `
     -n aibImage `
     --action Run 

# Create the VM
az vm create `
  --resource-group $imageResourceGroup `
  --name aibImage `
  --admin-username $applicationId `
  --admin-password $vmpassword `
  --image $imageName `
  --location $location
