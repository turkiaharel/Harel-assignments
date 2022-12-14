
# Assignment 1: PowerShell script that interacts with Azure Active directory. Created By Harel Turkia


function CreateUser ([String]$D_Name,[String]$U_Name,[String]$UPN)
{
	$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
	$PasswordProfile.Password = "<Password>"

	New-AzureADUser -DisplayName $D_Name -UserPrincipalName $UPN -MailNickName $U_Name  -AccountEnabled $true -PasswordProfile $PasswordProfile
	$UserID = Get-AzureADUser -SearchString $UPN | Select UserPrincipalName
	Write-Output $UserID.UserPrincipalName	
}

Function CreatedGroup ([String]$GroupName)
{	
	New-AzureADGroup -DisplayName $GroupName -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
	$GroupID = Get-AzureADGroup -SearchString $str_GroupName | Select ObjectId
	Write-Output $GroupID.ObjectId
}

Function AddUserToGroup ([String]$str_UserID,[String]$str_GroupID) 
{
	Add-AzureADGroupMember -ObjectId $str_GroupID -RefObjectId $str_UserID
	$Members = Get-AzureADGroupMember -ObjectId $str_GroupID  -all $True 
	If($Members.ObjectId -contains $str_UserID)
		{
			Write-Output $true
		}
		Else
		{
			Write-Output $false	
		}
		
}


#Setting Variables
$str_UserName = "Test User"
$str_GroupName = "Test Assignment Group"
$str_Domain = "Stratasys.com" # i used my Domain to test the script
$LogPath = "C:\Temp\Azure\"
$LogFile = "AzureTestUsers.log"

#Create LogFile
if(Test-Path $LogPath)
	{
		$LogFile = $LogPath + "\" + $LogFile
	}
	Else
	{
		New-Item $LogPath -ItemType Directory
		$LogFile = $LogPath + $LogFile
	}

#Connect To Azure AD
$UserCredential = Get-Credential
Connect-AzureAD -Credential $UserCredential
# Check if connection is established
$TenantInfo = Get-AzureADTenantDetail 
if ($TenantInfo)
{

#Create security group
$str_GroupID = CreatedGroup $str_GroupName #Call Function to create Azure security group
	if($str_GroupID)
	{	
		#create 20 Azure AD users
		for ($i=1;$i -le 20;$i++)
		{
			#User details
			$DisplayName = $str_UserName +$i
			$UserName = $str_UserName.Replace(" ","") + $i
			$UPN = $UserName + "@" + $str_Domain
			
			$str_UserID = CreateUser $DisplayName $UserName $UPN #Call Function to create Azure AD user
			if ($str_UserID)
			{
				Write-Host $str_UserID.UserPrincipalName " Created Successfuly." # Output in case of user created
				$UserInGroup = AddUserToGroup $str_UserID.ObjectID $str_GroupID.ObjectID #Call Function to add user to group
				$Stamp = (Get-Date).toString("mm/dd/yyyy HH:mm:ss")
				if ($UserInGroup)
						{				
							$Content = $Stamp + " User:" + $str_UserID.UserPrincipalName + " added to group:" + $str_GroupName + " Success"
							Add-Content $LogFile -Value  $Content # write to log file if user added to group success
						}
						Else
						{
							$Content = $Stamp + " User:" + $str_UserID.UserPrincipalName + " added to group:" + $str_GroupName  + " Failure"
							Add-Content $LogFile -Value  $Content # write to log file user added to group failure
						}
						
				$str_UserID = ""	# Clear user_id variable
			}
			else
			{
				# Output in case of user not created
				Write-Host "User: "  $str_UserName  " Createion Failed."
			}
		}
		Write-Host "Please see the results at the log file C:\Temp\Azure\AzureTestUsers.log"

	}
	Else
	{
		# Output in case of group not created
		Write-Host "Unble to Create Group. The operation was cancelled"
	}
}
Else
{
	# Output in case of Azure connection faild
	Write-Host "We are unble to connect you to Azure AD. The operation was cancelled"
}

Exit-PSSession
Write-Host "Script was completed."