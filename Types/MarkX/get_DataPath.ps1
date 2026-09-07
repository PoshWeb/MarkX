<#
.SYNOPSIS
    Gets a Markdown Data Path
.DESCRIPTION
    Gets a Markdown Data Path.

    This is a `.json` file that may accompany a Markdown file to represent external front matter.
.NOTES
    If a Markdown file has a `.Path`, the Data File Path will be it's name, minus the extension, plus `.json`
.LINK
    https://www.11ty.dev/docs/data-template-dir/
#>
param()

# If there is no path, there is no data 
if (-not $this.Path) { return}

# If the path is a json file, there is no additional data file path
if ($this.Path -match '\.json$') { return }

# If the path had no extension, there is no data file path
if ($this.Path -notmatch '\.[^\.]+$') { return }

# Replace the extension with json, and return it.
# This is our DataPath
return $this.Path -replace '\.[^\.]+$', '.json'