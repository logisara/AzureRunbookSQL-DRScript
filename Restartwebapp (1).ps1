# PowerShell code
########################################################
# Parameters
########################################################
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,Position=0)]
    [ValidateLength(1,100)]
    [string]$ResourceGroupName = "App01",
 
    [Parameter(Mandatory=$false,Position=1)]
    [ValidateLength(1,100)]
    [string]$WebAppName = "curry30",

	[Parameter(Mandatory=$false,Position=2)]
    [ValidateLength(1,100)]
    [string]$WebAppName01 = "dray23",
     
    [Parameter(Mandatory=$false,Position=3)]
    [ValidateLength(1,100)]
    [string]$StartStopRestartCommand = "RESTART"
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
# Getting the WebApp
########################################################
$MyWebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
$MyWebApp01 = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName01

if (!$MyWebApp)
{
    Write-Error "$($WebAppName) not found in $($ResourceGroupName)"
    return
}
else
{
    Write-Output "Current WebApp: $($MyWebApp.Name) in $($ResourceGroupName) HostName: $($MyWebApp.DefaultHostName)"
}

if (!$MyWebApp01)
{
    Write-Error "$($WebAppName) not found in $($ResourceGroupName)"
    return
}
else
{
    Write-Output "Current WebApp: $($MyWebApp.Name) in $($ResourceGroupName) HostName: $($MyWebApp.DefaultHostName)"
}
 
########################################################
# Start Stop Restart
########################################################
# Check for incompatible actions
if ($StartStopRestartCommand -eq "Start")
{
    $MyWebApp1 = Start-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
	$MyWebApp01 = Start-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName01
    Write-Output "Start WebApp: $($MyWebApp1.Name) in $($ResourceGroupName) HostName: $($MyWebApp1.DefaultHostName)"
	Write-Output "Start WebApp: $($MyWebApp01.Name) in $($ResourceGroupName) HostName: $($MyWebApp01.DefaultHostName)"
}
elseif ($StartStopRestartCommand -eq "Stop")
{
    $MyWebApp2 = Stop-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
	$MyWebApp02 = Stop-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName01
    Write-Output "Stop WebApp: $($MyWebApp2.Name) in $($ResourceGroupName) HostName: $($MyWebApp2.DefaultHostName)"
	Write-Output "Stop WebApp: $($MyWebApp02.Name) in $($ResourceGroupName) HostName: $($MyWebApp02.DefaultHostName)"
}
elseif ($StartStopRestartCommand -eq "Restart")
{
    $MyWebApp3 = Restart-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
	$MyWebApp03 = Restart-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName01
    Write-Output "Restart WebApp: $($MyWebApp3.Name) in $($ResourceGroupName) HostName: $($MyWebApp3.DefaultHostName)"
	Write-Output "Restart WebApp: $($MyWebApp03.Name) in $($ResourceGroupName) HostName: $($MyWebApp03.DefaultHostName)"
}
else
{
    Write-Error "$($StartStopRestartCommand) is not recognized as a command."
}

 
########################################################
# Show when finished
########################################################
$Duration = NEW-TIMESPAN â€“Start $StartDate â€“End (GET-DATE)
Write-Output "Done in $([int]$Duration.TotalMinutes) minute(s) and $([int]$Duration.Seconds) second(s)"