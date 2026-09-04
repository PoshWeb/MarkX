<#
.SYNOPSIS
    Set a Markdown Path
.DESCRIPTION
    Sets the path associated with a Markdown file.
#>
param([string]$Path)
$this | Add-Member NoteProperty '#Path' $Path -Force