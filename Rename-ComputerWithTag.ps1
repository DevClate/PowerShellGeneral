<#
.SYNOPSIS
Renames a computer with a prefix and asset tag.

.DESCRIPTION
This function renames the local computer with a prefix of CA, MA, NC, NY, or FL followed by a hyphen and an asset tag. If an asset tag isn't given, it uses the computer's serial number with CIM.

.PARAMETER Prefix
The prefix to use for the new computer name.

.PARAMETER AssetTag
The asset tag to use for the new computer name. Optional.

.PARAMETER ComputerName
Computer you want to change the name of. Local or Remote.

.PARAMETER WhatIf
Displays what the command would do if run, without actually running the command.

.PARAMETER Confirm
Prompts you for confirmation before running the command.

.EXAMPLE
Rename-ComputerWithTag -Prefix CA -AssetTag 900123 -Confirm

This prompts you for confirmation before renaming the computer with the prefix "CA" and the asset tag "900123".

.EXAMPLE
Rename-ComputerWithTag -Prefix FL -WhatIf

This displays what the command would do if run, without actually renaming the computer. The new computer name will have the prefix "FL" and the asset tag set to the computer's serial number.

.EXAMPLE
Rename-ComputerWithTag -Prefix NC -AssetTag 900134 -ComputerName DESKTOP-4I9DF1

This prompts you for confirmation before renaming the remote computer "DESKTOP-4I9DF1" with the prefix "NC" and the asset tag "900134".

#>

function Rename-ComputerWithTag {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('CA', 'MA', 'NC', 'NY', 'FL')]
        [string]$Prefix,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$AssetTag,

        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    #Check if the computer is online
    $ComputerStatus = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet

    #If the computer is online, proceed with the name change
    if ($ComputerStatus -eq $true) {
        #Write that computer was found and beginning renaming process
        Write-Verbose -Message "$ComputerName was found. Beginning Rename Process"
    }

    #If the computer is offline, display an error message
    else {
        Write-Error "The computer $ComputerName is offline. Please try again when the computer is online."
    }

    # Get the computer's serial number with CIM if an asset tag isn't given
    if (-not $AssetTag) {
        $AssetTag = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
    }

    # Build the new computer name
    $NewName = '{0}-{1}' -f $Prefix, $AssetTag

    # Rename the computer
    if ($PSCmdlet.ShouldProcess($ComputerName, $NewName, "Rename-Computer")) {
        Rename-Computer -ComputerName $ComputerName -NewName $NewName -Force
    }

    # Output the new computer name
    Write-Verbose -Message "$ComputerName changed to $NewName"
    $NewName
}

