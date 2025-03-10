# PowerShell Script to Check Used Windows PC Health Before Buying
# Run this as Administrator for full details

Clear-Host
Write-Host "Fetching system details... Please wait." -ForegroundColor Yellow

# Function to Assign Ratings
function Get-Rating {
    param ([int]$score)
    switch ($score) {
        {$_ -le 20} { return "❌ Very Bad" }
        {$_ -le 40} { return "⚠️ Bad" }
        {$_ -le 60} { return "🔸 Normal" }
        {$_ -le 80} { return "✅ Good" }
        default { return "⭐ Excellent" }
    }
}

# Score system (0-100)
$totalScore = 100

# System Info
Write-Host "`n=== SYSTEM INFORMATION ===" -ForegroundColor Cyan
$systemInfo = Get-ComputerInfo | Select-Object CsManufacturer, CsModel, WindowsVersion, WindowsBuildLabEx, WindowsRegisteredOwner
$systemInfo

# CPU Details
Write-Host "`n=== PROCESSOR DETAILS ===" -ForegroundColor Cyan
$cpu = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
$cpu
if ($cpu.MaxClockSpeed -lt 2000) { $totalScore -= 20 }  # Low-speed CPU penalty

# RAM Details
Write-Host "`n=== MEMORY DETAILS ===" -ForegroundColor Cyan
$ram = Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed
$ram
$totalRAM = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
if ($totalRAM -lt 4) { $totalScore -= 20 }  # Less than 4GB RAM penalty

# Storage Information
Write-Host "`n=== STORAGE DETAILS ===" -ForegroundColor Cyan
$disks = Get-PhysicalDisk | Select-Object DeviceID, MediaType, Size, HealthStatus
$disks
if ($disks.HealthStatus -ne "Healthy") { $totalScore -= 30 }  # Disk failure penalty

# Battery Health (Laptops)
Write-Host "`n=== BATTERY HEALTH (if applicable) ===" -ForegroundColor Cyan
$battery = Get-WmiObject -Class BatteryStatus -Namespace "root\WMI" | Select-Object PowerOnline, BatteryStatus, ChargeRate, DischargeRate, BatteryRemaining
$battery
if ($battery.BatteryRemaining -lt 30) { $totalScore -= 15 }  # Weak battery penalty

# GPU Information
Write-Host "`n=== GRAPHICS CARD DETAILS ===" -ForegroundColor Cyan
$gpu = Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM
$gpu
$gpuMemory = $gpu.AdapterRAM / 1GB
if ($gpuMemory -lt 1) { $totalScore -= 15 }  # Low VRAM penalty

# Network Adapters
Write-Host "`n=== NETWORK DETAILS ===" -ForegroundColor Cyan
$network = Get-NetAdapter | Select-Object Name, InterfaceDescription, Status
$network

# Windows Activation Status
Write-Host "`n=== WINDOWS ACTIVATION STATUS ===" -ForegroundColor Cyan
$activation = (slmgr /xpr)  # Windows Activation Check
$activation
if ($activation -match "not permanently activated") { $totalScore -= 10 }  # Unactivated Windows penalty

# Installed Software Summary
Write-Host "`n=== INSTALLED SOFTWARE SUMMARY ===" -ForegroundColor Cyan
$softwareCount = (Get-WmiObject -Query "SELECT * FROM Win32_Product").Count
Write-Host "Total Installed Programs: $softwareCount"
if ($softwareCount -gt 100) { $totalScore -= 10 }  # Too many installed programs

# SMART Disk Health Check
Write-Host "`n=== HARD DISK SMART HEALTH STATUS ===" -ForegroundColor Cyan
$diskHealth = Get-WmiObject -Namespace root\WMI -Class MSStorageDriver_FailurePredictStatus | Select-Object PredictFailure, Reason
$diskHealth
if ($diskHealth.PredictFailure -eq $true) { $totalScore -= 40 }  # Critical failure penalty

# Final Score and Rating
Write-Host "`n==== FINAL SYSTEM RATING ====" -ForegroundColor Green
$rating = Get-Rating -score $totalScore
Write-Host "Overall Condition: $rating" -ForegroundColor Magenta
