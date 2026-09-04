
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
[Alias('MarkX','Markdown','Get-Markdown')]    
param()

$allInput = @($input) + $(if ($args) {
    $args
})

$markx = New-Object PSObject -Property @{
    PSTypeName = 'MarkX'        
}
$markx.Input = $allInput    
$markx
