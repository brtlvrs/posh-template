<## 
.SYNOPSYS
    Set / remove email actions based on alarm triggers.

.DESCRIPTION
    Script to set or remove the email action type for alarm triggers.
    It wil set the general e-mail settings. 

.NOTES
    Files needed:
        - parameters.ps1
        - CSV file provided in pramaters.ps1 file

    *** DISCLAIMER ***

    This software is provided "AS IS", without warranty of any kind, express or implied, 
    fitness for a particular purpose and noninfringement. 
    In no event shall the authors or copyright holders be liable for any claim, damages or other liability,
    whether in an action of contract, tort or otherwise, arising from, 
    out of or in connection with the software or the use or other dealings in the software.
##>
[CmdletBinding()]
Param ()

Begin {
    $global:ts_start=Get-Date
    $VerbosePreference="SilentlyContinue"
    $WarningPreference="Continue"
    $DebugPreference="SilentlyContinue"
    $ErrorActionPreference="SilentlyContinue"
    Clear-Host

    #-- Get Script Parameters
    $scriptPath=(get-item (Split-Path -Path $MyInvocation.MyCommand.Definition)).FullName
    $scriptName=Split-Path -Leaf $MyInvocation.MyCommand.path
    write-verbose "Scriptpath : " $scriptpath
    write-verbose "Scriptname : "$scriptName
    write-verbose "================================"

    #-- load script parameters
    if(!(Test-Path -Path $scriptPath\parameters.ps1 -IsValid)) {
        Write-Warning "Parameters.ps1 not found. Script will exit."
        exit
    }
    $P = & $scriptPath\parameters.ps1

    #-- load functions
    if (Test-Path -IsValid -Path($scriptpath+"\functions\functions.psm1") ) {
        write-host "Loading functions" -ForegroundColor cyan
        import-module ($scriptpath+"\functions\functions.psm1") -DisableNameChecking -Force:$true  #-- the module scans the functions subfolder and loads them as functions
    } else {
        write-verbose "functions module not found."
        exit-script
    }

    #-- connect to vCenter (if not already connected)
    connect-vSphere -vCenter $P.vCenterFQDN

    #-- load Alarm settings
    if (!(Test-Path $scriptPath\AlarmSettings.ps1)) {
        write-host "Couldn't find " $scriptPath "\AlarmSettings.ps1. Will exit."  -ForegroundColor Yellow
        exit
    }
    $alarmSettings= & $scriptPath\AlarmSettings.ps1
}

End {
    exit-script -finished_normal
}

Process {
    #-- set SMTP settings
    Get-AdvancedSetting -Entity $global:defaultviserver.Name -Name mail.smtp.server | Set-AdvancedSetting -Value $alarmsettings.SMTPserver -Confirm:$false
    Get-AdvancedSetting -Entity $global:defaultviserver.Name -Name mail.smtp.port | Set-AdvancedSetting -Value $alarmsettings.SMTPport -Confirm:$false
    Get-AdvancedSetting -Entity $global:defaultviserver.Name -Name mail.smtp.sender | Set-AdvancedSetting -Value $alarmsettings.SMTPSendingAddress -Confirm:$false

    #-- load CSV
    $alarmPriorities= Import-Csv $scriptpath\$($alarmsettings.CSVfile) -Delimiter ";"
    Write-host "Found "  $alarmPriorities.Count  " Alarms in the following groups : "
    $alarmPriorities | Group-Object -Property alarmClass | select name,count | ft 


    #-- disable Alarm actions
    foreach ($disabledAlarm in ($alarmPriorities | ?{$_.alarmClass -ilike "disabled"})) {
        Get-AlarmDefinition -Name $disabledAlarm.Name | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false #-- remove send-email actions
        Get-AlarmDefinition -Name $disabledAlarm.name | Set-AlarmDefinition -Enabled:$false -Confirm:$false #-- disable alarm
    }
 
    #-- Set Low Priority Alarms
    foreach ($lowPriorityAlarm in ($alarmPriorities | ?{$_.alarmClass -ilike "Low"})) {
        $alarmDef = Get-AlarmDefinition -Name $lowPriorityAlarm.name
        $alarmdef | Set-AlarmDefinition -Enabled (!($AlarmSettings.Profiles.Low.disabled))
        $alarmDef | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false
      #  $alarmDef | Set-AlarmDefinition -ActionRepeatMinutes ($AlarmSettings.profiles.Low.repeatMinutes)
        $alarmdef | New-AlarmAction -Email -To @($alarmSettings.profiles.low.emailTo) -Subject $alarmSettings.Profiles.Low.emailSubject
        $alarmaction= $alarmDef | Get-AlarmAction -ActionType SendEmail 
        $alarmaction | New-AlarmActionTrigger -StartStatus Green -EndStatus Yellow
     #   $alarmaction | New-AlarmActionTrigger -StartStatus yellow -EndStatus red
        $alarmaction | New-AlarmActionTrigger -StartStatus red -EndStatus Yellow
        $alarmaction | New-AlarmActionTrigger -StartStatus yellow -EndStatus green
    }

    #-- Set medium Priority Alarms
    foreach ($mediumPriority in ($alarmPriorities | ?{$_.alarmClass -ilike "Medium"})) {
        $alarmDef = Get-AlarmDefinition -Name $mediumPriority.name
        $alarmDef | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false
        $alarmDef | Set-AlarmDefinition -ActionRepeatMinutes ($alarmsettings.profiles.Medium.repeatMinutes) -Enabled (!($AlarmSettings.Profiles.medium.disabled))
        $alarmdef | New-AlarmAction -Email -To @($alarmSettings.profiles.Medium.emailTo) -Subject $alarmSettings.Profiles.medium.emailSubject
        $alarmaction= $alarmDef | Get-AlarmAction -ActionType SendEmail 
        $alarmaction | New-AlarmActionTrigger -StartStatus Green -EndStatus Yellow
        $alarmaction | Get-AlarmActionTrigger  | ?{($_.StartStatus -ilike "yellow" ) -and ($_.endStatus -ilike "red") -and ($_.alarmaction -ilike "sendemail")}  | Remove-AlarmActionTrigger -Confirm:$false
        $alarmaction | New-AlarmActionTrigger -StartStatus yellow -EndStatus red -Repeat
        $alarmaction | New-AlarmActionTrigger -StartStatus red -EndStatus Yellow
        $alarmaction | New-AlarmActionTrigger -StartStatus yellow -EndStatus green
    }

    foreach ($highPriority in ($alarmPriorities | ?{$_.alarmClass -ilike "High"})) {
        $alarmDef = Get-AlarmDefinition -Name $highPriority.name
        $alarmDef | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false
        $alarmDef | Set-AlarmDefinition -ActionRepeatMinutes ($alarmsettings.profiles.High.repeatMinutes) -Enabled   (!($AlarmSettings.Profiles.high.disabled))
        $alarmdef | New-AlarmAction -Email -To @($alarmSettings.profiles.High.emailTo) -Subject $alarmSettings.Profiles.High.emailSubject
        $alarmaction= $alarmDef | Get-AlarmAction -ActionType SendEmail 
        $alarmaction | New-AlarmActionTrigger -StartStatus Green -EndStatus Yellow
        $alarmaction | Get-AlarmActionTrigger  | ?{($_.StartStatus -ilike "yellow" ) -and ($_.endStatus -ilike "red") -and ($_.alarmaction -ilike "sendemail")}  | Remove-AlarmActionTrigger -Confirm:$false
        $alarmaction | New-AlarmActionTrigger -StartStatus yellow -EndStatus red -Repeat
        $alarmaction | New-AlarmActionTrigger -StartStatus red -EndStatus Yellow
        $alarmaction | New-AlarmActionTrigger -StartStatus yellow -EndStatus green
    }
}
