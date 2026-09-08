<#
.SYNOPSIS
    Sets Markdown Toml Header
.DESCRIPTION
    Sets the Markdown Front Matter as a Toml header.

    If the value is a `[string]`, will directly set front matter.
    
    If the value is not a `[string]`, it will be converted to Toml.

    If `ConvertTo-Toml` is not installed, will `ConvertTo-Json`.
#>
param($header)

if ($header -is [string]) {
    $this | Add-Member NoteProperty '#FrontMatter' $header -Force
    return
}

$convertToToml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertTo-Toml', 'Alias,Cmdlet,Function')
if (-not $convertToToml) {
    Write-Warning "ConvertTo-Yaml not found, setting header as json"
    $jsonHeader = $header | ConvertTo-Json -Depth 100
    $this | Add-Member NoteProperty '#JsonHeader' $jsonHeader -Force
    $this | Add-Member NoteProperty '#FrontMatter' $jsonHeader -Force
    return
}

$convertParameters = @{}
try {
    if ($convertToToml -and $convertToToml.Parameters['Depth']) {
        $convertParameters['Depth'] = $FormatEnumerationLimit
    }
} catch {
    Write-Verbose "Could not set depth:  Please use YaYaml: $_"    
}
finally {
    $toToml = $header | & $convertToToml @convertParameters
    if ($toYaml -is [string]) {
        $this | Add-Member NoteProperty '#FrontMatter' $toToml -Force
    }
}