param(
   [string]$DockerImage,
   [switch]$Force
)

# Load configuration
. Load-Config
$Dockerfile = Join-Path $HostDocker "$DockerImage.dockerfile"

# Stop Xpra and all docker containers
Stop-Container

# Remove all docker containers and unused volumes
docker rm $(docker ps -a -q) >$nul 2>&1
docker volume prune -q >$nul 2>&1

# Remove old image
if ($Force) {
   docker rmi $DockerImageTag >$nul 2>&1
}

# Generate volumes mount script
Generate-MountVolumesScript $(Join-Path $HostDocker mountvolumes.sh)

# Build docker image
$args = @("build", "-t", $DockerImageTag, "-f", $Dockerfile)
$args += $BuildArgs.ForEach({@("--build-arg", "`"$_`"")})
$args += $HostDocker
Spawn-Process docker $args -Wait

# Remove all dangling docker images
docker rmi $(docker images -f dangling=true -q) >$nul 2>&1