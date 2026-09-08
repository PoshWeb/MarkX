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
        if ($header -isnot [string]) {
            return $header | ConvertTo-Json -Depth 100
        } else {
            return $header
        }         
    }    
}
