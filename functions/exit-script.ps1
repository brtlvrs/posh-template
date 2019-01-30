function exit-script 
{
    <#
    .DESCRIPTION
        Clean up actions before we exit the script.
    .PARAMETER CleanupCode
        [scriptblock] Unique code to invoke when exiting script.
    #>
    [CmdletBinding()]
    param(
        [scriptblock]$CleanupCode #-- (optional) extra code to run before exit script.
    )

    #-- check why script is called and react apropiatly
    if ($finished_normal) {
        $msg= "Hooray.... finished without any bugs....."
        if ($log) {$log.verbose($msg)} else {Write-Verbose $msg}
    } else {
        $msg= "(1) Script ended with errors."
        if ($log) {$log.error($msg)} else {Write-Error $msg}
    }

    #-- General cleanup actions
    if ($CleanupCode) {
        try {Invoke-Expression -Command $CleanupCode -ErrorVariable Err1}
        catch {
            Write-Warning "Failed to execute custom cleanupcode, resulted in error $err1"
        }

    }
    if ($ts_start) {
        #-- Output runtime and say greetings
        $ts_end=get-date
        $msg="Runtime script: {0:hh}:{0:mm}:{0:ss}" -f ($ts_end- $ts_start)  
        write-host $msg
    } else {
        write-warning "No ts_start variable found, cannot calculate runtime."
    }
    read-host "The End <press Enter to close window>."
    exit
}