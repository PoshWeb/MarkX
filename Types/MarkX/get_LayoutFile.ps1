<#
.SYNOPSIS
    Gets Layout Files
.DESCRIPTION
    Gets Layout Files from a site.
.NOTES
    This should be any file within a directory called `layout`, or any `layout.ps1`

    The directory can have a preceeding underscore, and can optionally pluralization.        
#>
$this.File -match '(?>[\\/]_?layouts?[\\/]|[\\/\._]layout\.ps1$)'
