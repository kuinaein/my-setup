﻿#!/usr/bin/env pwsh
[CmdletBinding()] param();
Set-StrictMode -Version Latest;
$script:ErrorActionPreference = 'Stop';

Remove-Module 'Kuina.PSMySetup' -Force -ErrorAction SilentlyContinue;
[string] $private:myModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Kuina.PSMySetup';
Import-Module $myModulePath
Invoke-KNMain -Verbose:('Continue' -eq $VerbosePreference) -Block {
    [string] $scoopShims = Join-Path -Path $env:USERPROFILE -ChildPath 'scoop\shims';
    [string] $scoop = Join-Path -Path $scoopShims -ChildPath 'scoop.ps1';
    if (!(Test-Path $scoop)) {
        Write-KNNotice 'scoopをインストールします...';
        Invoke-WithNoDebug {
            Invoke-Expression (New-object Net.Webclient).DownloadString('https://get.scoop.sh');
        };
    }

    if (!(Test-Path $ARCH_EXE)) {
        Write-KNNotice -Message 'ArchWSLをインストールします...';
        & $scoop install archwsl;
        $preSetupSh = ConvertTo-ArchPath -WinPath (Join-Path -Path $PSScriptRoot -ChildPath 'pre-setup-arch.sh');
        & $ARCH_EXE run bash $preSetupSh;
    }

    [string] $ansible = & $ARCH_EXE run 'pacman -Q ansible 2>/dev/null';
    if (!$ansible) {
        Write-KNNotice -Message 'Ansibleをインストールします...';
        & $ARCH_EXE run sudo pacman -Syy;
        & $ARCH_EXE run sudo pacman -S --needed --noconfirm ansible;
    }

    # if (!(Get-Command vagrant -ErrorAction Continue)) {
    #     & $MySetup.'Write-KNNotice'.Script 'vagrantをインストールします...';
    #     & $MySetup.'Invoke-WithNoDebug'.Script {
    #         scoop install vagrant;
    #     }.GetNewClosure();
    # }

    Write-Warning -Message '続行する前に再起動することを推奨します' -ErrorAction Continue;
};