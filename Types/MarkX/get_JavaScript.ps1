<#
.SYNOPSIS
    Gets Markdown JavaScript
.DESCRIPTION
    Gets the JavaScript header of a Markdown or mdx file.

    Anything before the first
    
    * `# heading`
    * `<tag>`
    * or `<>` fragment 
    
    will be considered to be javascript, 
    as long as it has a line beginning with:

    * `import`
    * `export`
    * `const`
    * `let`
    * `document`
    * `window`
#>
param()

$header = $this.Header

if ($header -is [string] -and $header -match $this.JavaScriptKeywordPattern) {
    return $header
}
elseif ($header.javascript -match $this.JavaScriptKeywordPattern) {
    return $header.javascript
}
else {
    $before, $after = $this.Markdown -split $this.StartPattern, 2
    if ($before -match $this.JavaScriptKeywordPattern) {
        return $before
    }
}
