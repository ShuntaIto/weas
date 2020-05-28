## Need Set-ExecutionPolicy RemoteSigned and admin

filter Invoke-Choice
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $Caption,

        [Parameter(Mandatory=$true)]
        [string] $Message,

        [Parameter(Mandatory=$true)]
        [array] $Choices,

        [switch] $MultipleSelection
    )

    $tCollection = "System.Collections.ObjectModel.Collection"
    $tChoiceDescription = "System.Management.Automation.Host.ChoiceDescription"

    $collection = New-Object "${tCollection}[${tChoiceDescription}]"
    $defaultChoices = New-Object "System.Collections.Generic.List[Int]"
    for ($i = 0; $i -lt $Choices.Count; $i++)
    {
        $collection.Add($Choices[$i].ChoiceDescription)
        if ($Choices[$i].Default) {$defaultChoices.Add($i)}
    }

    if ($defaultChoices.Count -eq 0) {$defaultChoices.Add(0)}
    $default = if ($MultipleSelection) {,$defaultChoices}
               else {$defaultChoices[0]}

    foreach ($_ in $Host.UI.PromptForChoice($Caption, $Message, $collection, $default))
    {
        & $Choices[$_].ScriptBlock
    }
}

filter New-ChoiceCase
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $Label,

        [Parameter(Mandatory=$true)]
        [string] $HelpMessage,

        [Parameter(Mandatory=$true)]
        [scriptblock] $ScriptBlock,

        [switch] $Default
    )

    $tChoiceDescription = "System.Management.Automation.Host.ChoiceDescription"

    @{
        ChoiceDescription = New-Object $tChoiceDescription ($Label, $HelpMessage)
        ScriptBlock = $ScriptBlock
        Default = $Default
    }
}

Set-Alias cSwitch Invoke-Choice
Set-Alias cCase New-ChoiceCase

## https://qiita.com/yumura_s/items/274e8e49c975cce3a2ce

# Register the script running after restart
function registerRunOnceScriptAfterLogin() {
    Param(
        $script    
    )

    $regRunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    $powerShell = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")
    $restartKey = "Restart-And-RunOnce"

    Set-ItemProperty -path $regRunOnceKey -name $restartKey -value "$powerShell $script"
}

## Load status
Get-Content "config.ini" | where-object {$_ -notmatch '^\s*$'} | where-object {!($_.TrimStart().StartsWith("#"))}| Invoke-Expression
## http://tooljp.com/language/powershell/html/Sample-code-for-reading-and-setting-variables-from-ini-file.html

if($restartFlag -eq 0){
cSwitch "WSL2" "Do you want to install WSL2? (require restart)" `
@(
    cCase "&Yes" "Yes" {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        $scriptPath = (Get-Location).Path + "\weas.ps1"
        registerRunOnceScriptAfterLogin $scriptPath
        Write-Output '$restartFlag=1' | Set-Content -Encoding Default config.ini
        Restart-Computer -Force
        Read-Host "Waiting Restart……" 
    }
    cCase "&No"  "No" {
        "Skip setup WSL2"
    }
)
}
else{
    wsl --set-default-version 2 
}  

## Install software

$softwareList = (Get-Content softwareListCommon.txt) -as [string[]]

cSwitch "Environment Type" "Private or Business?" `
@(
    cCase "&Private" "Private" {
        $softwareListPrivate = (Get-Content softwareListPrivate.txt) -as [string[]]
        $softwareList = $softwareList + $softwareListPrivate
    }
    cCase "&Business"  "Business" {
        $softwareListBusiness = (Get-Content softwareListBusiness.txt) -as [string[]]
        $softwareList = $softwareList + $softwareListBusiness
    }
)


for ($i=0; $i -lt $softwareList.Count; $i++){
    winget install -e $softwareList[$i]
}