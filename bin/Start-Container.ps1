param(
   [string]$Project, 
   [string]$DockerImage,
   [switch]$Console
)

# Load configuration
. Load-Config

# Add route for docker if missing (with elevation)
$RouteMissing = (route print -4 172.17.0.0 | Select-String 172.17.0.0).Length -eq 0
if ($RouteMissing) {
   Start-Process powershell.exe '-NoProfile -ExecutionPolicy Bypass -Command "route add 172.17.0.0 mask 255.255.0.0 10.0.75.2 -p"' -Verb RunAs -Wait
}

# Start container if not running
$DockerContainer = docker ps -aqf "name=$Project"
if (!$DockerContainer) {
   $Args = @("run", "-d", "--rm", "--privileged", "--name", "$Project", "-h", "$Project")
   $Args += $DockerPorts.ForEach({@("-p", $_)})
   $Args += $DockerVolumes.ForEach({@("-v", """$_""")})
   $Args += $DockerImageTag
   $DockerContainer = Spawn-Process docker $Args -Wait -CaptureOutput
}

# Get and report container's IP address
$IPAddress = docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DockerContainer 
"$Project -> $IPAddress"

if ($Console) {
   # Start console
   docker exec -it $DockerContainer bash
}
else {
   # Start Terminal and VSCode
   docker exec -d $DockerContainer  lilyterm
   docker exec -d $DockerContainer  code ./project >$nul 2>&1

   # Attach Xpra to container
   $XpraCmd = "Xpra.exe" # or Xpra_cmd.exe for debug purposes
   $HostAndDisplay = "${IPAddress}:${ContainerXpraPort}"
   $XpraProcess = Get-WmiObject Win32_Process -Filter "name = '$XpraCmd'" | Where-Object { $_.CommandLine -like "*$HostAndDisplay*" }
   while (!$XpraProcess) {
      Spawn-Process "$env:ProgramFiles\Xpra\$XpraCmd" @("attach", "tcp:${ContainerUser}@${HostAndDisplay}")
      Start-Sleep -s 5
      $XpraProcess = Get-WmiObject Win32_Process -Filter "name = '$XpraCmd'" | Where-Object { $_.CommandLine -like "*$HostAndDisplay*" }
   } 
}
