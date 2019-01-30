<#
Code to add to the begin{} block of a script
    #-- load functions
    import-module $scriptpath\functions\functions.psm1 -DisableNameChecking -Force:$true   #-- the module scans the functions subfolder and loads them as functions

#>

write-verbose "Loading script functions."
# Gather all files
if (!(Test-Path -Path ($scriptpath.fullname+"\functions"))) {
    write-Error "Couldn't reach functions folder during loading of module."
    exit
}
$FunctionFiles  = @(Get-ChildItem -Path ($scriptpath.fullname+"\functions") -Filter *.ps1 -ErrorAction SilentlyContinue -Recurse)

#-- list current functions
$currentFunctions = Get-ChildItem function:
# Dot source the functions
ForEach ($File in @($FunctionFiles)) {
    Try {
        . $File.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($File.FullName): $_"
    }       
}

# Export the public functions for module use
$scriptFunctions = Get-ChildItem function: | Where-Object { $currentFunctions -notcontains $_ }
foreach ($ScriptFunction in $scriptFunctions) {
    # Export the public functions for module use
    Export-ModuleMember -Function $ScriptFunction.name
}