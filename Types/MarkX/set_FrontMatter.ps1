<#
.SYNOPSIS
    Sets Markdown Front Matter
.DESCRIPTION
    Sets the front matter for a Markdown file.

    This can be a string or object.

    If it is a string, it will set as-is.

    If existing front matter has been set,
    will attempt to set the front matter in the existing format.

    If no `.FrontMatterType` is detected, will default to json.
#>
param($header)

# If the header is a string
if ($header -is [string]) {
    # directly set front matter.    
    $this | Add-Member NoteProperty '#FrontMatter' $header -Force
    return
}

switch ("$($this.FrontMatterType)") {
    # If the header is javascript    
    javascript {
        # set the front matter as a string.
        $this | Add-Member NoteProperty '#FrontMatter' "$header" -Force
    }

    toml { $this.TomlHeader = $header }
    yaml { $this.YamlHeader = $header }
    default { $this.JsonHeader = $header }    
}