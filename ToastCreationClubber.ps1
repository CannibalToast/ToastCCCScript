$script:mo2RegKey = 'HKCU:\Software\Classes\nxm\shell\open\command\'
try {
    $script:mo2Path = Get-ItemPropertyValue -Path $script:mo2RegKey -Name '(default)' -ErrorAction Stop
    $script:mo2Path = $script:mo2Path -replace '"', ''
} catch {
    Write-Host "Mod Organizer 2 path not found in registry."
    exit
}

$script:modOrganizerDirectory = Split-Path -Parent $script:mo2Path
$script:modOrganizerModsFolder = Join-Path -Path $script:modOrganizerDirectory -ChildPath "mods"

if (-not (Test-Path -Path $script:modOrganizerModsFolder)) {
    Write-Host "Mod Organizer mods folder not found."
    exit
}

$script:fallout4RegKey = 'HKLM:\Software\Wow6432Node\Bethesda Softworks\Fallout4'
try {
    $script:fallout4Path = Get-ItemPropertyValue -Path $script:fallout4RegKey -Name 'Installed Path' -ErrorAction Stop
    $script:dataFolder = Join-Path -Path $script:fallout4Path -ChildPath "Data"
} catch {
    Write-Host "Fallout 4 installation path not found in registry."
    exit
}

$jsonContent = @{
    "ccbgsfo4046-tescan" = @{
        "enable_cc" = $true
        "move_to" = "Tesla Cannon"
        "others_to_enable" = @()
    }
    "ccbgsfo4096-as_enclave" = @{
        "enable_cc" = $true
        "move_to" = "Enclave Armor"
        "others_to_enable" = @()
    }
    "ccbgsfo4116-heavyflamer" = @{
        "enable_cc" = $true
        "move_to" = "Heavy Flamer"
        "others_to_enable" = @()
    }
    "ccbgsfo4110-ws_enclave" = @{
        "enable_cc" = $true
        "move_to" = "Enclave Weapons"
        "others_to_enable" = @()
    }
    "ccSBJFO4003-Grenade" = @{
        "enable_cc" = $true
        "move_to" = "Grenade"
        "others_to_enable" = @()
    }
    "ccFSVFO4007-Halloween" = @{
        "enable_cc" = $true
        "move_to" = "Halloween"
        "others_to_enable" = @()
    }
    "ccbgsfo4044-hellfirepowerarmor" = @{
        "enable_cc" = $true
        "move_to" = "Hellfire Power Armor"
        "others_to_enable" = @()
    }
    "ccOTMFO4001-Remnants" = @{
        "enable_cc" = $true
        "move_to" = "Enclave Remnants"
        "others_to_enable" = @()
    }
    "ccbgsfo4115-x02" = @{
        "enable_cc" = $true
        "move_to" = "X-02 Power Armor"
        "others_to_enable" = @()
    }
}

foreach ($key in $jsonContent.Keys) {
    $modName = "Creation Club - " + $jsonContent[$key].move_to
    $modFolder = Join-Path -Path $script:modOrganizerModsFolder -ChildPath $modName

    if (-not (Test-Path -Path $modFolder)) {
        try {
            New-Item -ItemType Directory -Path $modFolder -Force
        } catch {
            Write-Host "Failed to create directory: $modFolder"
            continue
        }
    }

    try {
        $ba2Files = Get-ChildItem -Path $script:dataFolder -Filter "$key*.ba2"
    } catch {
        Write-Host "Failed to retrieve .ba2 files for $key"
        continue
    }

    foreach ($ba2File in $ba2Files) {
        $destinationFilePath = Join-Path -Path $modFolder -ChildPath $ba2File.Name
        if (-not (Test-Path -Path $destinationFilePath)) {
            try {
                Copy-Item -Path $ba2File.FullName -Destination $destinationFilePath -Force
                if (Test-Path -Path $destinationFilePath) {
                    Remove-Item -Path $ba2File.FullName -Force -ErrorAction SilentlyContinue
                    if (Test-Path -Path $ba2File.FullName) {
                        Write-Host "Failed to delete file: $ba2File.FullName"
                    }
                } else {
                    Write-Host "Failed to verify file transfer: $ba2File.FullName"
                }
            } catch {
                Write-Host "Failed to copy file: $ba2File.FullName"
            }
        }
    }

    $sourceEslFilePath = Join-Path -Path $script:dataFolder -ChildPath "$key.esl"
    $destinationEslFilePath = Join-Path -Path $modFolder -ChildPath "$key.esl"
    if (Test-Path -Path $sourceEslFilePath) {
        if (-not (Test-Path -Path $destinationEslFilePath)) {
            try {
                Copy-Item -Path $sourceEslFilePath -Destination $destinationEslFilePath -Force
                if (Test-Path -Path $destinationEslFilePath) {
                    Remove-Item -Path $sourceEslFilePath -Force -ErrorAction SilentlyContinue
                    if (Test-Path -Path $sourceEslFilePath) {
                        Write-Host "Failed to delete file: $sourceEslFilePath"
                    }
                } else {
                    Write-Host "Failed to verify file transfer: $sourceEslFilePath"
                }
            } catch {
                Write-Host "Failed to copy file: $sourceEslFilePath"
            }
        }
    } else {
        Write-Host "File not found: `"$sourceEslFilePath`""
    }
    Write-Host "Made by Cannibal Toast, Stay toasty!"
}