param($header)

if ($header -is [string]) {
    $this | Add-Member NoteProperty '#FrontMatter' $header -Force
    return
}

$convertToYaml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertTo-Yaml', 'Alias,Cmdlet,Function')
if (-not $convertToYaml) {
    Write-Warning "ConvertTo-Yaml not found, setting header as json"
    $jsonHeader = $header | ConvertTo-Json -Depth 100 
    $this | Add-Member NoteProperty '#JsonHeader' $jsonHeader -Force
    $this | Add-Member NoteProperty '#FrontMatter' $jsonHeader -Force
    return
}

$convertParameters = @{}
try {
    if ($convertToYaml -and $convertToYaml.Parameters['Depth']) {
        $convertParameters['Depth'] = $FormatEnumerationLimit
    }
} catch {
    Write-Verbose "Could not set depth:  Please use YaYaml: $_"    
}
finally {
    $toYaml = $header | & $convertToYaml @convertParameters
    if ($toYaml -is [string]) {
        $this | Add-Member NoteProperty '#YamlHeader' $toYaml -Force
        $this | Add-Member NoteProperty '#FrontMatter' $toYaml -Force
    }
}