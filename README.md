# Harel-assignments

Files:

Assignment 1:

Assignment1.ps1 - PowerShell script that interacts with Azure Active directory.

AzureTestUsers.log - PowerShell script log file

assignment1 screen output.jpg - PowerShell screen output printscreen

Assignment 3:

main.tf - Terraform - Create Azure Infrastructure resources

Assignment3_Terraform .jpg - Resource diagram 


Assignment 1: PowerShell script that interacts with Azure Active directory.

Tasks:
1. Setting Variables: here we can change the variables to fit each environment ( i used my domain for testing)
2. Create log file: if path not exist path will be created.
3. Connect To Azure AD: Check if connection is established, if not error will be present 
4. Create Azure security group: Call Function to create Azure security group
5. Create 20 Azure AD users: if Group was created, loop = 20

    5.1 set user info
    
    5.2 Call function to create Azure AD user. Function get the user info and output the user object ID
    
    5.3 Output to screen user created Successfuly or failed
    
    5.4 Call Function to add user to group
    
    5.5 Output to log file if user added to group success\failure
    
    ################################################################################################################
    
    Assignment 2: Terraform - Create Azure Infrastructure resources
    
    Tasks:
      1. Connect to azure
      2. Create resource group 
      3. Create network settings in region North Europe
          3.1 Virtual network
          3.2 2 X subnets
          3.3 2 X  Nettwork interfaces
          3.4 2 X VMs
      4. Create the same resources in region West Europe
      5. Create 2 X load balance
      6. Connect load balnce to each VM's region
      7. Create Azure Trafic Manager Profile with traffic_routing_method = "Performance" (Traffic is routed via the User's closest Endpoint)
      8. Create 2 X Trafic Manager Profile Endpoints
      9. connect Endpoints to each load balance
      
