. $(Join-Path $PSScriptRoot Like-Tern.ps1)

# Load configuration file
$Root = Split-Path $PSScriptRoot -Parent
$ConfigFile = Join-Path $Root config.json
$Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

# Load variables
foreach ($Item in $Config.Variables) {
   $Name = ($Item | Get-Member -MemberType NoteProperty).Name
   $Value = $ExecutionContext.InvokeCommand.ExpandString($Item.$($Name))
   Set-Variable -Name "$Name" -Value "$Value" -Scope Script
}

# Load docker ports
$DockerPorts = @()
foreach ($Item in $Config.DockerPorts) {
   $DockerPorts += $ExecutionContext.InvokeCommand.ExpandString($Item)
}

# Load docker volumes
$DockerVolumes = @()
foreach ($Item in $Config.DockerVolumes) {
   $DockerVolumes += $ExecutionContext.InvokeCommand.ExpandString($Item)
}

# Load build args
$BuildArgs = @()
foreach ($Item in $Config.BuildArgs) {
   $BuildArgs += $ExecutionContext.InvokeCommand.ExpandString($Item)
}

