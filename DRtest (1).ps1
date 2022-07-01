# PowerShell code
########################################################
# Parameters
########################################################
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,Position=0)]
    [ValidateLength(1,100)]
    [string]$SecondaryDBServerResourceGroupName,
 
    [Parameter(Mandatory=$True,Position=1)]
    [ValidateLength(1,100)]
    [string]$secondaryDBservername,

	[Parameter(Mandatory=$false,Position=2)]
    [ValidateLength(1,100)]
    [string]$Failovergroupname = "fgdemo",

	[Parameter(Mandatory=$True,Position=3)]
    [ValidateLength(1,100)]
    [string]$Appservicerestartrequired
)

# Keep track of time
$StartDate=(GET-DATE)

 
########################################################
# Log in to Azure with AZ (standard code)
########################################################
Write-Verbose -Message 'Connecting to Azure'
  
# Name of the Azure Run As connection
$ConnectionName = 'AzureRunAsConnection'
try
{
    # Get the connection properties
    $ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName      
   
    'Log in to Azure...'
    $null = Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $ServicePrincipalConnection.TenantId `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$ServicePrincipalConnection)
    {
        # You forgot to turn on 'Create Azure Run As account' 
        $ErrorMessage = "Connection $ConnectionName not found."
        throw $ErrorMessage
    }
    else
    {
        # Something else went wrong
        Write-Error -Message $_.Exception.Message
        throw $_.Exception
    }
}

########################################################
########################################################
# SQL Failover
########################################################
#$MySQL = Get-AzSqlDatabaseFailoverGroup -ResourceGroupName $ResourceGroupName -ServerName $secondaryservername -FailoverGroupName $Failovergroupname | Switch-AzSqlDatabaseFailoverGroup -AllowDataLoss
$MySQL = Switch-AzSqlDatabaseFailoverGroup -ResourceGroupName $SecondaryDBServerResourceGroupName -ServerName $secondaryDBservername -FailoverGroupName $Failovergroupname
########################################################
# Show when finished
########################################################
Write-Output "Done with failover process"
if ($Appservicerestartrequired -eq 'Yes')
{
 $params = @{"StartStopRestartCommand"="RESTART"}
 Start-AzAutomationRunbook -AutomationAccountName "Automationtesting" -Name "Restartwebapp" -ResourceGroupName "App01" -Parameters @param
}
else
{
 Write-Output "Failed in RestartWebapp process"
}