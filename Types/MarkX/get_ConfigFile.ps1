<#
.SYNOPSIS
    Gets Config Files
.DESCRIPTION
    Gets Configuration Files from a MarkX site.
.NOTES
    This should be any file with config in it's name, as long as:
    
    * It is preceeded by `\`, `/` or `.`.
    * It is followed by an extension
#>
$this.File -match '[\\/\.]config\.[^\.]+$'
