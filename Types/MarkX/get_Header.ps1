<#
.SYNOPSIS
    Gets Markdown header
.DESCRIPTION
    Gets the Markdown front matter header as an object.

    If the front matter is JavaScript or no front matter type is detected,
    will output a `[string]`

    If 
#>
if (-not $this.'#FrontMatter') { return }

switch ($this.FrontMatterType) {
    yaml {
        $convertFromYaml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertFrom-Yaml', 'Alias,Cmdlet,Function')
        if (-not $convertFromYaml) {
            throw "Cannot get yaml header without ConvertFrom-Yaml"
        }
        return ($this.'#FrontMatter' | & $convertFromYaml)
    }
    json {
        return ($this.'#FrontMatter' | ConvertFrom-Json -AsHashtable)
    }
    toml {
        $convertFromToml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertFrom-Toml', 'Alias,Cmdlet,Function')
        if (-not $convertFromToml) {
            throw "Cannot get toml header without ConvertFrom-Toml"            
        }

        return ($this.'#FrontMatter' | & $convertFromToml)
    }
    default {
        return $this.'#FrontMatter'
    }
}