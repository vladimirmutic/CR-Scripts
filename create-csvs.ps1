    <#
    .SYNOPSIS
    Puts Active Directory users or computers to Active Directory groups using a CSV
    .DESCRIPTION
    Author: Daniel Classon and Vladimir Mutić
    Version 1.1

    This script will take the information in the CSV and add the users or computers specified in the Object column and add them to the Group specified in the Group column
    IMPORTANT - Computers must have $ at the end eg. myDC01$
    .PARAMETER CSV (MANDATORY)
    Specify the full source to the CSV file i.e c:\temp\members.csv
    CSV file need to have GROUP and OBJECT column. Computer accounts need to have $ at the end.
    .EXAMPLE
    .\add_objects_to_multiple_groups.ps1 -CSV c:\temp\members.csv
    .PARAMETER CLEAN (OpTIONAL)
    If you specify parameter CLEAN (Switch parameter), script will clean up group so only users stated in CSV file will remain as members.
    .EXAMPLE
    .\add_objects_to_multiple_groups.ps1 -CSV c:\temp\members.csv -clean

    .DISCLAIMER
    All scripts and other powershell references are offered AS IS with no warranty.
    These script and functions are tested in my environment and it is recommended that you test these scripts in a test environment before using in your production environment.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $DomainList
    )

    $Domains = Import-Csv $DomainList

    $pathdefined = $false
    $folderdefined = $false

    $path = Read-Host "Where do you want to create PEDs folder"
    
    while ($pathdefined -eq $false) {
        if (Test-Path $Path) {
            Write-Host "Great, lets proceed.." -ForegroundColor Green
            $pathdefined = $true
        } else {
            $path = Read-Host "Defined folder doesn't exist, please define another one"
        }
    }

    $folder = "PEDs"
    $tfolder = "\" + $folder

    if (Test-Path ($path + $tfolder)) {
        while ($folderdefined -eq $false) {
            $dec = $null
            $dec = Read-Host "Folder $folder already exists on defined path. Would you like to delete existing PEDs folder and proceed or to define new folder name (type 'del' or 'new')"
            while ($dec -notin ("del", "new")) {
                $dec = Read-Host ("Please type 'del' or 'new'")
            }
            if ($dec -eq "del") {
                Remove-Item -Path ($path+$tfolder)
                $folderdefined = $true
            } elseif ($dec -eq "new") {
                $folder = Read-Host "Define new folder name"
                while ($folder -eq "") {
                    $folder = Read-Host "Define new folder name"
                }
                $tfolder = "\" + $folder
                if (!(Test-Path ($path + $tfolder))) {
                    $folderdefined = $true
                } 

            }
        }
    }

    $tpath = $path + $tfolder

    New-Item -Path $path -Name $folder -ItemType Directory
   
    ForEach ($Domain in $Domains) {
        $dPath = $tpath + "\" + $Domain.DN
        New-Item -ItemType Directory -Path $tPath -Name $Domain.DN
        New-Item -ItemType Directory -Path $dPath -Name "PED"  | Out-Null
        New-Item -ItemType Directory -Path $dPath -Name "PED\Scripts" | Out-Null
        New-Item -ItemType Directory -Path $dPath -Name "PED\Guides" | Out-Null
        New-Item -ItemType Directory -Path $dPath -Name "PED\CSVs" | Out-Null
        New-Item -ItemType File -Path $dPath -Name "PED\ped.txt" | Out-Null
    }