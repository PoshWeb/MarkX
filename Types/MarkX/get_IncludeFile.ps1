<#
.SYNOPSIS
    Gets Include Files
.DESCRIPTION
    Gets Include Files from a MarkX site.
.NOTES
    This should be any file within a directory called `_includes`:        
#>
$this.File -match '[\\/]_includes?[\\/]'
