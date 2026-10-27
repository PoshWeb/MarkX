<#
.SYNOPSIS
    Gets Markdown Json Header
.DESCRIPTION
    Gets Markdown Front Matter as JSON.

    If the front matter type is JSON, this will directly return the front matter.

    If the front matter type is not a `[string]`, this will convert the front matter to json.
#>
switch ($this.FrontMatterType) {
    json {
        return $this.'#FrontMatter'
    }
    default {        
        $header = $this.Header
        if ($header -is [string] -or $header -is [Management.Automation.ErrorRecord]) {
            return $header
        }        
        return $header | ConvertTo-Json -Depth 100                 
    }    
}
