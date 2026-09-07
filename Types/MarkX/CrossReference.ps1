<#
.SYNOPSIS
    Cross Reference Markdown
.DESCRIPTION
    Cross References references to other topics.
#>

param(
# A dictionary of topics to reference.
# The keys are the strings we will search for.
# The values may be anything, but should probably be titles or changelogs
[Alias('ReferenceTopics')]
[Collections.IDictionary]
$TopicReference
)

if (-not $TopicReference.Count) {
    throw "Nothing to cross reference"
}

# Get our content as a string
$content = "$($this.Content)"

# We do not want to cross reference within certain ranges
$avoidRange = @()
# For example, anything within a code block should not be cross-referenced
$avoidRange += @(foreach ($cb in $this.FindCodeBlock()) {
    $cb.Index..($cb.Index+$cb.Length)
})

# and anything within hyperlinks should also not be cross referenced.
$avoidRange += @(foreach ($hyperlink in $this.FindHyperLink()) {
    $hyperlink.Index..$($hyperlink.Index + $hyperlink.Length)
})

# Now we just need to reconstruct our string,
$index   = 0 # starting at index 0.
$newText = @(
# We find all references
foreach ($ref in $this.FindReference($TopicReference)) {
    # and skip any in avoided ranges.
    if ($ref.Index -in $avoidRange) { continue }    
    $refStart = $ref.Index
    # Then we get any content between this and the last reference.
    if ($refStart -gt $index) {
        $content.Substring($index, $refStart - $index)
    }
    # and then we replace our reference.
    "[$($ref)]($($topicReference["$ref"]))"
    # and update our index.
    $index = $ref.Index + $ref.Length
}

# If there was any remaining content after the last match
if ($index -lt $content.Length) {
    # include it.
    $content.Substring($index)
}
) -join '' # Join all of our content by '' and we have reconstructed the string

# Which we will reassign to the content
$this.Content = $newText
# and then return this.
return $this