param(
   [parameter(Mandatory=$true)][string]$Path
)

$Writer = New-Object System.IO.StreamWriter $Path
$Writer.NewLine = "`n"
$Writer.WriteLine('#!/bin/bash')
$Writer.WriteLine("uid=$ContainerUserID")
$Writer.WriteLine("gid=$ContainerGroupID")
$Writer.WriteLine("volumes=$ContainerVolumes")
$Writer.WriteLine('IFS=":" read -r -a userinfo <<< `getent passwd $uid`')
$Writer.WriteLine('home=${userinfo[5]}')
$Writer.WriteLine('')
$Writer.WriteLine('function mountvolume {')
$Writer.WriteLine('  dst=$home/$1')
$Writer.WriteLine('  src=$volumes/$1')
$Writer.WriteLine('  if [ ! -d $dst ]')
$Writer.WriteLine('  then')
$Writer.WriteLine('    mkdir -p $dst')
$Writer.WriteLine('  fi')
$Writer.WriteLine('  chown -R $uid:$gid $dst')
$Writer.WriteLine('  bindfs -u $uid -g $gid -p 777 $src $dst')
$Writer.WriteLine('}')
$Writer.WriteLine('')

$DockerVolumes.ForEach({
   $VolumePath = $_.Substring($_.LastIndexOf(':') + 1).Substring($ContainerVolumes.Length + 1)
   $Writer.WriteLine("mountvolume '$VolumePath'")
})

$Writer.WriteLine('chown -R $uid:$gid $home')

$Writer.Flush()
$Writer.Close()
