<#
.SYNOPSIS
    Gets Markdown TOML Header
.DESCRIPTION
    Gets Markdown Front Matter as TOML.

    If the front matter is already TOML, will return as-is.

    If the front matter is not TOML and is not a `[string]`, it will be converted to TOML.

    If the front matter is a string, it will be returned directly.    

    If `ConvertTo-Toml` is not loaded, it will return as JSON.    
#>
switch ($this.FrontMatterType) {
    toml {
        return $this.'#FrontMatter'
    }
    default {        
        $header = $this.Header

        if ($header -is [string]) {
            return $header
        }

        $convertToToml = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ConvertTo-Toml', 'Alias,Cmdlet,Function')
        if (-not $convertToToml) {
            Write-Warning "ConvertTo-Toml not found, getting header as json"
            $header | ConvertTo-Json -Depth 100
            return
        }

        $convertParameters = @{}
        return $(try {
            if ($convertToToml -and $convertToToml.Parameters['Depth']) {
                $convertParameters['Depth'] = $FormatEnumerationLimit
            }
        } catch {
            Write-Verbose "Could not set depth:  Please use YaYaml: $_"    
        }
        finally {
            $header | & $convertToToml @convertParameters            
        })                    
    }    
}
return