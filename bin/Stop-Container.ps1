param(
   [string]$DockerContainer
)

# Stop Xpra
Get-Process Xpra 2>$nul | Stop-Process

# Stop docker container(s)
if ("$DockerContainer" -ne "") {
   docker stop $DockerContainer >$nul 2>&1
}
else  {
   docker stop $(docker ps -a -q) >$nul 2>&1
}
