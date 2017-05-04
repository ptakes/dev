param(
   [parameter(Mandatory=$true)][string]$FileName,
   $Args,
   [switch]$Wait,
   [switch]$CaptureOutput,
   [switch]$UseShell
)

$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $FileName
$StartInfo.RedirectStandardError = $CaptureOutput
$StartInfo.RedirectStandardOutput = $CaptureOutput
$StartInfo.UseShellExecute = $UseShell
$StartInfo.Arguments = $Args

$Process = New-Object System.Diagnostics.Process
$Process.StartInfo = $StartInfo
$Process.Start() | Out-Null
if ($Wait) {
   $Process.WaitForExit()
   if ($CaptureOutput) {
      $StdErr = $Process.StandardError.ReadToEnd()
      $StdOut = $Process.StandardOutput.ReadToEnd()
      "${StdErr}`r`n$StdOut".trim()
   }
}
