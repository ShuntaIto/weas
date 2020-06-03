# WEAS
WEAS(Windows Environment Auto-Setup) is a powershell script to automate initial setup process on Windows.

# Feature

1. Auto-setup WSL2
2. Auto-install softwares listed on softwareList*.txt

# How to Use

## Preparing

First, install winget-cli from https://github.com/microsoft/winget-cli .

Second, change ExcutionPolicy on Powershell(Admin).

```
Set-ExecutionPolicy RemoteSigned
```

## Check and update your software list

You can edit softwareList*.txt for your environment.

You can see available software list with following command.
```
winget search
```

https://github.com/microsoft/winget-pkgs/tree/master/manifests

## Run

Run WEAS script.
```
cd <path to WEAS>
.\weas.ps1
```
