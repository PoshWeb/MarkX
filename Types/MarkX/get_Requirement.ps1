<#
.SYNOPSIS
    Gets Requirements
.DESCRIPTION
    Gets Requirements for a MarkX file or site.

    If the file is or has a ScriptBlock, any requirements will be returned from the AST.

    If the site is a module, any Require* properties will be returned from the module.
#>

if ($this -is [ScriptBlock]) {
    return $this.AST.ScriptRequirements
}

if ($this.ScriptBlock) {
    return $this.ScriptBlock.AST.ScriptRequirements
}

if ($this.ResolvedCommand.ScriptBlock) {
    return $this.ResolvedCommand.ScriptBlock.AST.ScriptRequirements        
}

# If this is a module
if ($this -is [Management.Automation.PSModuleInfo]) {
    # map any requirements into a dictionary
    $requirements = [Ordered]@{}    
    foreach ($prop in $this.psobject.properties) {
        # any property whose name starts with require is a requirement
        if ($prop.Name -match 
            '^Require' -and
            # except for requirement and it's plural alias
            # (so we do not infinitely recurse)
            $prop.Name -notin 'Requirement', 'Requirements'
        ) {
            $requirements[$prop.Name] = $prop.Value
        }
    }
    return $requirements
}