<#
.SYNOPSIS
    Require modules
.DESCRIPTION
    Installs and Imports any required modules.
#>
[OutputType([Management.Automation.PSModuleInfo])]
param()

# If this had no requirements, this does nothing.
if (-not $this.Requirement) {return}

# Collect any required modules
$requiredModules = @($this.Requirement.RequiredModules)

# Prepare our progress
$progress = @{
    id = Get-Random
    Activity = "Installing Requirements"
}
# If the script has requirements, walk over each of them.
:nextRequirement foreach ($requirement in $requiredModules) {    
    # Check if they are loaded
    $requiredModule = Get-Module -ErrorAction Ignore -Name $requirement.Name
    # If they are
    if ($requiredModule) {
        # output them
        $requiredModule
        continue nextRequirement # and continue to the next requirement
    }

    $progress.Status ="Importing Requirement $($requirement.Name) for $($this.Path)"
    Write-Progress @progress    
        
    $requiredModule = Import-Module $requiredModule -Force -PassThru -ErrorAction Ignore

    if ($requiredModule) {
        $requiredModule
        continue nextRequirement
    }

    # If that did not work,
    $progress.Status ="Installing Requirement $($requirement.Name)"
    Write-Progress @progress
        
    Install-Module $requirement.Name -Scope CurrentUser -Force

    Import-Module $requirement.Name -Global -Force -PassThru    
}

$progress.Completed = $true
Write-Progress @progress