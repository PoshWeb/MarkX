<#
.SYNOPSIS
    Sets MarkX Input
.DESCRIPTION
    Sets the input for a MarkX file or site.

    This will attempt to convert the input to Markdown, 
    and then will `.Sync()` the object.
#>
param(
# One or more input objects
[PSObject[]]$InputObject
)

# Set the `#Input` property
$this | Add-Member NoteProperty '#Input' $InputObject -Force

# and then Sync.
$this.Sync()