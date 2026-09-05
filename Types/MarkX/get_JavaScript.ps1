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
$before, $after = $this.Markdown -split $this.StartPattern, 2
if ($before -match '(?m)^\s{0,}(?>import|export|const|let|document|window)') {
    return $before
}
