<#
.SYNOPSIS
    Gets Markdown as a Page
.DESCRIPTION
    Gets Markdown content as a Page dictionary.

    This can contain any data and be used in any way.  
    
    It will not be saved to disk.
.NOTES
    Some front-matter properties will be synchronized into page data when set.

    
#>
if (-not $this.'#Page') {
    $this |
        Add-Member NoteProperty '#Page' ([Ordered]@{
            title = $this.title            
            content = $this.html
        }) -Force
}

if ($this.date) {
    $this.'#Page'.date = $this.date
}
if ($this.tags) {
    $this.'#Page'.tags = $this.tags
}

$layout = $this.layout

if ($layout -is [string]) {
    $this.'#Page'.layout = $layout    
}


$this.'#Page' | 
    Add-Member NoteProperty MarkX $This -Force

$this.'#Page' | 
    Add-Member ScriptMethod ToString {
        $layout = $this.MarkX.Layout
        if ($layout -is [ScriptBlock]) {
            $this['Content'] | . $layout
        } else {
            $this['Content']
        }    
    } -Force 

$this.'#Page'