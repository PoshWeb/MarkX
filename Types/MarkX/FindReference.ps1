<#
.SYNOPSIS
    Find Markdown References
.DESCRIPTION
    Finds References to a dictionary of words within markdown.

    This allows us to find keyword mentions within a file, 
    and can be used to cross-reference content.
#>
param(
# A dictionary of topics to reference.
# The keys are the strings we will search for.
# The values may be anything, but should probably be titles or changelogs
[Alias('ReferenceTopics')]
[Collections.IDictionary]
$TopicReference
)

$skipReference = @()
$header = $this.Header
# Front matter may indicate we want to skip specific cross references
$skipReference += @(
    if ($header.SkipReference) { $header.SkipReference}
    elseif ($header.SkipReferences) { $header.SkipReferences }
    elseif ($header.NoReference) { $header.NoReference }
    elseif ($header.NoReferences) { $header.NoReferences}
)

# Sort all potential reference by length and then alphabetically
# (this lets us match the longest potential reference first)
$sortedKeys = $topicReference.Keys | Sort-Object Length, { $_ } -Descending

# We only want to match references that follow
# the start anchor or any whitespace, end tag, quote, underscore, or open parenthesis
$LookBehind = "(?<=(?>^|[\s\>'`"_\(]))" 

# We only want to match references that preceed
# the end anchor or any whitespace, end tag, quote, underscore, or close parenthesis
$LookAhead  = "(?=(?>$|[\s\>'`"_\.,\)]))"

$NotAfter = '(?<!\#{1,6}[\s\S-[\r\n]])'

$referencePattern = [Regex]::new("${LookBehind}${NotAfter}(?>$(
    @(foreach ($k in $sortedKeys) {
        [Regex]::Escape($k) -replace '\\\s', '[\s\-_]'
    }) -join '|'
))$LookAhead", 'Multiline,IgnoreCase')

# We will match any references within the markdown
foreach ($match in $referencePattern.Matches("$($this.markdown)")) {
    $topicAlias = $match -replace '[\s\-_]',' '
    if ($skipReference -and (
        $skipReference -contains $topicAlias -or 
        $skipReference -contains $topicReference["$topicAlias"].TopicName)
    ) {
        continue
    }
    
    $match
}