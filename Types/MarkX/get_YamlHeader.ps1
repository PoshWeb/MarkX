<#
.SYNOPSIS
    Gets Markdown Yaml Header
.DESCRIPTION
    Gets Markdown front matter as a Yaml Header

    If the front matter is already Yaml, will return as-is.

    If the front matter is `[string]`, will return as-is.

    Otherwise, will attempt to `ConvertFrom-Yaml`.

    If `ConvertTo-Yaml` is not installed, will `ConvertTo-Json` instead.
#>
switch ($this.FrontMatterType) {
    yaml {
        return $this.'#FrontMatter'
    }
    default {
        $header = $this.Header
        if ($header -is [string]){
            return $header
        }
        $convertToYaml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertTo-Yaml', 'Alias,Cmdlet,Function')
        if (-not $convertToYaml) {
            Write-Warning "ConvertTo-Yaml not found, returning header as json"
            $header | ConvertTo-Json -Depth 100 
            return
        }

        $convertParameters = @{}
        return try {
            if ($convertToYaml -and $convertToYaml.Parameters['Depth']) {
                $convertParameters['Depth'] = $FormatEnumerationLimit
            }
        } catch {
            Write-Verbose "Could not set depth:  Please use YaYaml: $_"    
        }
        finally {
            $header | & $convertToYaml @convertParameters
            if ($toYaml -is [string]) {
                $this | Add-Member NoteProperty '#FrontMatter' $toYaml -Force
            }
        }        
    }    
}
return