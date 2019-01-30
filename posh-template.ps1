<#
.SYNOPSIS
   Small description - oneliner - 
.DESCRIPTION
   Script usage description [optional]
.EXAMPLE
    One or more examples for how to use this script
.NOTES
    File Name          : <filename>.ps1
    Author             : <Script Author>
    Prerequisite       : <Preruiqisites like
                         Min. PowerShell version : 2.0
                         PS Modules and version : 
                            PowerCLI - 6.0 R2
    Version/GIT Tag    : <GIT tag>
    Last Edit          : <Initials> - <date>

#>
[CmdletBinding()]
Param(
    #-- Define Powershell input parameters (optional)
    [string]$text

)

Begin{
    #-- initialize environment
    $DebugPreference="SilentlyContinue"
    $VerbosePreference="SilentlyContinue"
    $ErrorActionPreference="Continue"
    $WarningPreference="Continue"
    clear-host #-- clear CLi
    $ts_start=get-date #-- note start time of script
    if ($finished_normal) {Remove-Variable -Name finished_normal -Confirm:$false }

	#-- determine script location and name
	$scriptpath=get-item (Split-Path -parent $MyInvocation.MyCommand.Definition)
    $scriptname=(Split-Path -Leaf $MyInvocation.mycommand.path).Split(".")[0]
    
    #-- Load Parameterfile
    if (!(test-path -Path $scriptpath\parameters.ps1 -IsValid)) {
        write-warning "Cannot find parameters.ps1 file, exiting script."
        exit
    } 
    $P = & $scriptpath\parameters.ps1

    #-- load functions
    if (!(Test-Path -Path $scriptpath\functions\functions.psm1 -IsValid)) {
        write-warning "No PS function files found, running script."
    } else {
        #-- the module scans the functions subfolder and loads them as functions
        import-module $scriptpath\functions\functions.psm1 -DisableNameChecking -Force:$true   
    }
    
#region for Private script functions
    #-- note: place any specific function in this region

#endregion
}

Process{
#-- note: area to write script code.....
    write-host "hello world"
}

End{
    #-- we made it, exit script.
    $finished_normal=$true
    exit-script
}