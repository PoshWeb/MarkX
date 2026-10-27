<#
.SYNOPSIS
    Gets Markdown as `markpub.at`
.DESCRIPTION
    Gets Markdown as a `markpub.at` lexicon
.EXAMPLE
    (markx "# Hello from MarkX").MarkPub
.LINK
    https://markpub.at
#>
$markpub = [Ordered]@{
    '$type' = 'at.markpub.markdown'
    PSTypeName = 'at.markpub.markdown'    
}

$header = $this.Header

if ($header -and $Header -isnot [string]) {
    $markpub.frontMatter = $header
}

$markpub.text = [Ordered]@{
    '$type'='at.markpub.text'
    PSTypeName = 'at.markpub.text'
}

$markpub.text.markdown = $this.markdown

$markpub.text = [PSCustomObject]$markpub.text

[PSCustomObject]$markpub