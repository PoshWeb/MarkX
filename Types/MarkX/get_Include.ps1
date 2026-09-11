<#
.SYNOPSIS
    Get MarkX includes
.DESCRIPTION
    Gets MarkX includes as a dictionary.
    
    Includes are files within a site beneath a directory matching `_?includes?`

    This will return all of the includes beneath a site as a dictionary of objects.
#>
$includes = [Ordered]@{}
foreach ($file in $this.IncludeFile) {

    $includeName = $file.FullName -replace 
        '^.+?[\\/]_?includes?[\\/]' -replace 
            '\.ps1$' -replace 
                '[\\/]', '/'

    $includes[$includeName] = 
        if ($file.Extension -eq '.ps1') {
            # If this does not have a cache, create one now
            if (-not $this.'#Cache') {
                $this | Add-Member NoteProperty '#Cache' ([Ordered]@{}) -Force
            }

            # If they have not yet been cached,
            if (-not $this.'#Cache'[$file.FullName]) {
                # cache them.
                $this.'#Cache'[$file.FullName] = markx (
                    $ExecutionContext.SessionState.InvokeCommand.GetCommand($file.Fullname, 'ExternalScript')
                )
                if ($this.'#site') {
                    $this.'#Cache'[$file.FullName].Site = $this.Site
                }                
            }
            $this.'#Cache'[$file.FullName]       
        } else {
            $file
        }
}
return $includes