param($header)

if ($header -is [string]) {
    $this | Add-Member NoteProperty '#YamlHeader' $header -Force
    $this | Add-Member NoteProperty '#FrontMatter' $toYaml -Force
    return
}

$convertToYaml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertTo-Yaml', 'Alias,Cmdlet,Function')
if (-not $convertToYaml) {
    Write-Warning "Cannot set yaml header without ConvertTo-Yaml"
    return
}

$convertParameters = @{}
if ($convertToYaml.Parameters['Depth']) {
    $convertParameters['Depth'] = $FormatEnumerationLimit
}
$toYaml = $header | & $convertToYaml @convertParameters
if ($toYaml -is [string]) {
    $this | Add-Member NoteProperty '#YamlHeader' $toYaml -Force
    $this | Add-Member NoteProperty '#FrontMatter' $toYaml -Force
}


