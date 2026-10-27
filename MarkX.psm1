#region Eponym

# Functions and scripts are interchangeable in PowerShell
# So we can make a small module using an eponym file.
# First we need to identify the module name 
$moduleName = $MyInvocation.MyCommand.Name -replace '\.psm1$'

# Once we have done this, we can look for an eponymous script: 
$eponym = 
    $ExecutionContext.SessionState.InvokeCommand.GetCommand((
        Join-Path $PSScriptRoot "$moduleName.ps1"
    ), 'ExternalScript')

# If we did not find one,
if (-not $eponym) {
    # warn and return.
    Write-Warning "Missing ./$moduleName.ps1"
    return
}

# We want to define two functions from this script

# One is the name of the script
# The other is the "verb" form of the script.

# Collect our list of verbs
$verbs = Get-Verb | 
    Sort-Object { $_.Verb.Length }, {$_.Verb } -Descending |
    Select-Object -ExpandProperty Verb
    
# and craft a regex to see if we start with the verb.
$startsWithVerb = "^(?>$(
    $verbs -join '|'
))"

# Our Exports are:
$exports = 
    $moduleName, # * The Eponym 
    $(
        # The `Verb-Noun` form
        if ($moduleName -match $startsWithVerb) {
            "$($matches.0)-$($moduleName -replace "$startsWithVerb\p{P}?")"
        } else {
            "Get-$($ModuleName -replace '\p{P}')"
        }
    )

# We can use the function provider to create functions in this scope.
foreach ($functionName in $exports) {
    # This allows us to dynamically set each export to by the eponym
    $ExecutionContext.SessionState.PSVariable.Set(
        "function:$functionName",
        $eponym.ScriptBlock
    )
}

# We also want to export any aliases
# and add support for argument completers.
$argumentCompleter = $null
$aliasExports = @(
    # walk over all of our attributes
    foreach ($attribute in $eponym.ScriptBlock.Attributes) {
        # and keep track of any argument completers we find.
        if ($attribute -is [ArgumentCompleter]) {
            $argumentCompleter = $attribute
        }
        # Then make our aliases
        foreach ($alias in $attribute.aliasNames) {
            # (unless the alias is already exported as a function)
            if ($alias -in $exports) { continue }
            $ExecutionContext.SessionState.PSVariable.Set(
                "alias:$alias", $moduleName
            )
            $alias
        }
    }
)

# If we had an argument completer
if ($argumentCompleter.ScriptBlock) {
    # now is the time to register it.

    # Argument completers need to be registered for each function
    foreach ($functionExport in $exports) {
        Register-ArgumentCompleter -CommandName $functionExport -ScriptBlock $argumentCompleter.ScriptBlock
    }

    # and alias
    foreach ($aliasExport in $aliasExports) {
        Register-ArgumentCompleter -CommandName $aliasExport -ScriptBlock $argumentCompleter.ScriptBlock
    }
}

# We will also be exporting our eponym as a variable
$ExecutionContext.SessionState.PSVariable.Set($moduleName, $eponym)

# All that's left to do is explicitly export just these functions.
Export-ModuleMember -Function $exports -Alias $aliasExports -Variable $moduleName
#endregion Eponym