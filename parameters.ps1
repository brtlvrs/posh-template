# Script Parameters for <scriptname>.ps1
<#
    Author             : <Script Author>
    Last Edit          : <Initials> - <date>
#>

@{
    #-- default script parameters
        LogPath="D:\beheer\logs"
        LogDays=5 #-- Logs older dan x days will be removed

    #-- Syslog settings
        SyslogServer="syslog.shire.lan" #-- syslog FQDN or IP address

    #-- disconnect viServer in exit-script function
        DisconnectviServerOnExit=$true

    #-- vSphere vCenter FQDN
        vCenter="value" #-- vCenter FQDN
}