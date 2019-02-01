<#
    This file is used as input file for set-emailAlarmActions.ps1
#>
@{

    SMTPserver=""
    SMTPport=25
    SMTPSendingAddress="NLDC01VS011@vdlgroep.local"
    CSVfile="alarmDefinitions.csv"
    Profiles=@{
        disabled=@{
            disabled=$true
            }
        High=@{
            disabled=$false
            emailTo=@("b.lievers@tsp.nl")
            repeatMinutes=240 #-- 60 * 4 uur
            emailSubject="[HIGH] NLDC01VS011 alarmnotification"
            }
        Medium=@{
            disabled=$false
            emailTo=@("b.lievers@tsp.nl")
            repeatMinutes=1440 #-- 60 [min] * 24 [uur]
            emailSubject="[MEDIUM] NLDC01VS011 alarmnotification"
            }
        Low=@{
            disabled=$false
            emailTo=@("b.lievers@tsp.nl")
            repeatMinutes=0 #-- don't repeat
            emailSubject="[LOW] NLDC01VS011 alarmnotification"
            }
            
    }
}