<#
.SYNOPSIS
    Get Liquid
.DESCRIPTION
    Get Liquid within the Markdown
#>
if ($this.LiquidPattern -is [regex]) {
    return $this.LiquidPattern.Matches("$($this.Markdown)")
}
