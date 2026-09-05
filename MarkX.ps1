<#
.SYNOPSIS
    Gets MarkX
.DESCRIPTION
    Gets MarkX - Markdown as XML
    
    This allows us to query, extract, and customize markdown.
.EXAMPLE
    # 'Hello World' In Markdown / MarkX
    '# Hello World' | MarkX
.EXAMPLE
    # MarkX is aliased to Markdown
    # 'Hello World' as Markdown as XML
    '# Hello World' | Markdown | Select -Expand XML
.EXAMPLE
    # We can generate tables by piping in objects
    @{n1=1;n2=2}, @{n1=2;n3=3} | MarkX
.EXAMPLE
    # Make a TimesTable in MarkX
    @(
        "#### TimesTable"
        foreach ($rowN in 1..9) {
            $row = [Ordered]@{}
            foreach ($colN in 1..9) {
                $row["$colN"] = $colN * $rowN
            }
            $row
        }
    ) | Get-MarkX
.EXAMPLE
    # We can pipe a command into MarkX
    # This will get the command help as Markdown
    Get-Command Get-MarkX | MarkX
.EXAMPLE
    # We can pipe help into MarkX
    Get-Help Get-MarkX | MarkX
.EXAMPLE
    # We can get code from markdown
    Get-Help Get-MarkX | 
        MarkX | 
        Select-Object -ExpandProperty Code
#>
[Alias('Markdown','Get-Markdown')]    
param()

# Collect all input and arguments.
# This function treats all input and arguments as interchangeable.
$allInput = @($input) + $(if ($args) {
    $args
})

# We could have been provided a list of markdown files
# or markdown itself.

# So we need to make a pass over each input
$remainingInput = @()
$inputFiles = @()
$markXProtoType = [PSCustomObject]@{PSTypename='MarkX'}
foreach ($in in $AllInput) {
    # If the input starts as slashes
    $inFile = if ($in -match '^\.[\\/]') {
        # get the unresolved path and attempt to cast it to a file
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($in) -as [IO.FileInfo]
    } else {
        # otherwise, attempt to cast the input to a file
        $in -as [IO.FileInfo]
    }

    # If the file was empty (or null)
    if (-not $inFile.Length) {
        # we will treat it as plain markdown
        $remainingInput += $in
        continue # and should continue.
    }
    
    # If the file does not exist
    if (-not [IO.File]::Exists($inFile.FullName)) {
        # we will treat it as markdown
        $remainingInput += $in
        continue # and should continue.
    }
    
    # If the file was not markdown or mdx.
    if ($inFile.Extension -notin $markXProtoType.MarkdownExtension) {
        # we will treat the input as markdown
        $remainingInput += $in
        continue # and should continue.
    }

    $inputFiles += $inFile    
}

# If we have a number of input files,
# we will want to show progress
$progress = [Ordered]@{id=[random]::new().Next()}
$progress.Activity = "Converting Markdown"

# Walk over each of our input files
for ($inputNumber = 0; $inputNumber -lt $inputFiles.Count; $inputNumber++) {
    # determine percent complete
    $progress.PercentComplete = $inputNumber * 100 / $inputFiles.Length
    $progress.Status = $inputFiles[$inputNumber].Name
    # and write a progress message.
    Write-Progress @progress

    # Then, create a new MarkX object
    $markx = New-Object PSObject -Property @{
        PSTypeName = 'MarkX'        
    }
    # set its input to the input file
    $markx.Input = $inputFiles[$inputNumber]
    # and output the object
    $markx
}

# If we had any input
if ($inputNumber) {
    # We need to complete our progress bars.
    $progress.Remove('PercentComplete')
    $progress.Completed = $true
    Write-Progress @progress
}

# If there was no remaining input, return
if (-not $remainingInput.Length) { return }
# Otherwise, create a property bag for the Markdown.
$markx = New-Object PSObject -Property @{
    PSTypeName = 'MarkX'
}
# set its input to all remaining input
$markx.Input = $remainingInput
# and then output the MarkX / Markdown
return $markx