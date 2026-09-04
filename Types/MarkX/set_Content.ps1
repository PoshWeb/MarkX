<#
.SYNOPSIS
    Sets Markdown Content
.DESCRIPTION
    Sets the combined content of the markdown
#>
param($InputObject)

$this | Add-Member NoteProperty '#Input' $InputObject -Force

$this.Sync()