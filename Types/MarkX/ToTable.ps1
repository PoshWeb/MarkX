<#
.SYNOPSIS
    Converts objects to tables
.DESCRIPTION
    Converts objects to markdown tables
#>
param(
# The rows in the table.
[PSObject[]]
$Rows
)

$allInput = @($input)
$allRows = @($allInput) + $(if ($Rows) {
    $rows
})

$MarkdownLines = @()
$IsFirst = $true
foreach ($in in $Rows) {
    $propertyList = @(
        # we first need to get a list of properties.
        if ($in -is [Collections.IDictionary]) 
        {
            foreach ($k in $in.Keys) { # take all keys from the dictionary                
                $k
            }                        
        }
        # Otherwise, walk over all properties on the object
        else {
            foreach ($psProp in $In.psobject.properties) {                                                
                $psProp                        
            }
        }
    )

    # If we're rendering the first row of a table
    if ($IsFirst) {
        # Create the header
        $markdownLines +=
            '|' + (@(foreach ($prop in $propertyList) {
                if ($prop -is [string]) {
                    $prop
                } else {
                    $prop.Name
                }
            }) -replace ([Environment]::newline), '<br/>' -replace '\|', '\|' -join '|') + '|'
        # Then create the alignment row.
        $markdownLines +=
            '|' + $(
                $columnNumber =0 
                @(
                    foreach ($prop in $propertyList) {
                        $colLength = 
                            if ($prop -is [string]) {
                                $prop.Length
                            } else {
                                $prop.Name.Length
                            }
                        
                        "-" * $colLength
                        
                        
                        $columnNumber++
                    }
                ) -replace ([Environment]::newline), '<br/>' -replace '\|', '\|' -join '|') + '|'                    
        $IsFirst = $false
    }
    
    # Now we create the row for this object.

    $markdownLine = '|' + (
        @(
            foreach ($prop in $propertyList) {
                if ($prop -is [string]) {
                    $in.$prop
                } else {
                    $prop.Value 
                }
            }
        ) -replace ([Environment]::newline), '<br/>' -replace '\|', '\|' -join '|') + '|'

    $markdownLines += $markdownLine
}
$markdownLines