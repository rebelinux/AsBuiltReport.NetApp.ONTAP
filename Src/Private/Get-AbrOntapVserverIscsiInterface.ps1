function Get-AbrOntapVserverIscsiInterface {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve NetApp ONTAP Vserver ISCSI interface information from the Cluster Management Network
    .DESCRIPTION

    .NOTES
        Version:        0.4.0
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
    param (
    )

    begin {
        Write-PscriboMessage "Collecting ONTAP Vserver ISCSI interface information."
    }

    process {
        $VserverData = Get-NcIscsiInterface
        $VserverObj = @()
        if ($VserverData) {
            foreach ($Item in $VserverData) {
                $inObj = [ordered] @{
                    'Interface Name' = $Item.InterfaceName
                    'IP Address' = $Item.IpAddress
                    'Port' = $Item.IpPort
                    'Status' = Switch ($Item.IsInterfaceEnabled) {
                        'True' { 'Up' }
                        'False' { 'Down' }
                        default { $Item.IsInterfaceEnabled }
                    }
                    'Vserver' = $Item.Vserver
                }
                $VserverObj += [pscustomobject]$inobj
            }
            if ($Healthcheck.Vserver.Iscsi) {
                $VserverObj | Where-Object { $_.'Status' -like 'Down' } | Set-Style -Style Warning -Property 'Status'
            }

            $TableParams = @{
                Name = "ISCSI Interface Information - $($ClusterInfo.ClusterName)"
                List = $false
                ColumnWidths = 35, 25, 10, 10, 20
            }
            if ($Report.ShowTableCaptions) {
                $TableParams['Caption'] = "- $($TableParams.Name)"
            }
            $VserverObj | Table @TableParams
        }
    }

    end {}

}