# Build release APK using M: drive only (saves C: space).
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path "M:\gradle-home", "M:\pub-cache", "M:\build-temp" | Out-Null
$env:GRADLE_USER_HOME = "M:\gradle-home"
$env:PUB_CACHE = "M:\pub-cache"
$env:TEMP = "M:\build-temp"
$env:TMP = "M:\build-temp"

Set-Location "M:\karigar\ustaad_ai_app"
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# One architecture = ~7–10 min, much less disk than full universal APK.
flutter build apk --release --target-platform android-arm64

$apk = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apk)) {
  $apk = Get-ChildItem "build\app\outputs\flutter-apk\*.apk" | Select-Object -First 1 -ExpandProperty FullName
}
if ($apk) {
  Copy-Item $apk "M:\karigar\UstaadAI-release.apk" -Force
  Write-Host "APK ready: M:\karigar\UstaadAI-release.apk"
}
