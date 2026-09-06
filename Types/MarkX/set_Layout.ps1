<#
.SYNOPSIS
    Sets Markdown Layout
.DESCRIPTION
    Sets the layout.  
    
    This can either set a PowerShell script has the layout
    or set the layout in the front matter.
#>
param($Layout)

if ($layout -is [string] -and $layout -match '\.ps1$') {
    $layout = $ExecutionContext.SessionState.InvokeCommand.GetCommand($layout, 'ExternalScript')
}

if ($layout -is [ScriptBlock]) {
    $This | Add-Member NoteProperty '#Layout' $Layout -Force
    return
}
elseif (
    $layout -is [Management.Automation.ExternalScriptInfo] -or
    $layout -is [Management.Automation.FunctionInfo]
) {
    $This | Add-Member NoteProperty '#Layout' $Layout.ScriptBlock -Force
}
else {
    $header = $this.Header

    if (-not $header) {
        $header = [Ordered]@{layout="$layout"}        
    } elseif ($header -isnot [string]) {
        $header.layout = "$layout"
    } else {
        throw "Header is a string, cannot set layout"        
    }

    $this.Header = $header
}