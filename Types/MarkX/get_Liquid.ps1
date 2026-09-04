<#
.SYNOPSIS
    Get Liquid
.DESCRIPTION
    Get Liquid within the Markdown or Yaml Header
#>
if ($this.LiquidPattern -is [regex]) {    
    $this.LiquidPattern.Matches("$($this.Content)")
    return 
}
