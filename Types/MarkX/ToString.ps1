<#
.SYNOPSIS
    Stringifies MarkX
.DESCRIPTION
    Converts MarkX to string output.

    With no parameters, will output Markdown as HTML.

    Any parameters may be names of properties.

    If more than one parameter is provided,
    all matching values will be joined with a newline.
#>

if ($args) {
    $anyOutput = foreach ($arg in $args) {
        $thisArg = $this.$arg
        if ($thisArg) {
            if ($thisArg.XHTML.InnerXML) {
                "$($thisArg.XHTML.InnerXML)" + [Environment]::NewLine
            } 
            elseif ($thisArg -is [xml]) {
                $thisArg.OuterXML
            }
            else {
                "$thisArg"
            }
        }
    }
    if ($anyOutput) {
        return $anyOutput -join [Environment]::NewLine
    }    
}

return $this.HTML