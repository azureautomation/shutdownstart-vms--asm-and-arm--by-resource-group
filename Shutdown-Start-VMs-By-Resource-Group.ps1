workflow Shutdown-Start-VMs-By-Resource-Group
{
	Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $SubscriptionId,
        [Parameter(Mandatory=$true)]
        [String]
        $AzureResourceGroup,
	[Parameter(Mandatory=$true)]
        [Boolean]
	$Shutdown
    )
	
    #Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail...

    try
    {
        "Logging in to Azure..." 
        Disable-AzContextAutosave -Scope Process 
        Connect-AzAccount -Identity
        $AzureContext = Set-AzContext -SubscriptionId $SubscriptionId    
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
	
	if($Shutdown -eq $true){
		Write-Output "Stopping VMs in '$($AzureResourceGroup)' resource group";
	}
	else{
		Write-Output "Starting VMs in '$($AzureResourceGroup)' resource group";
	}
	
	#ARM VMs
	Write-Output "ARM VMs:";
	  
	Get-AzVM -ResourceGroupName $AzureResourceGroup -DefaultProfile $AzureContext | ForEach-Object {
	
		if($Shutdown -eq $true){
			
				Write-Output "Stopping '$($_.Name)' ...";
				Stop-AzVM -ResourceGroupName $AzureResourceGroup -Name $_.Name -DefaultProfile $AzureContext -Force;
		}
		else{
			Write-Output "Starting '$($_.Name)' ...";			
			Start-AzVM -ResourceGroupName $AzureResourceGroup -Name $_.Name -DefaultProfile $AzureContext;			
		}			
	};

}
