function Initialize-Store {
    <#
        .SYNOPSIS
        Initializes local Storage to cache state from ACME Servers.

        .DESCRIPTION
        This will create files needed to keep track of the local state for communication with the remote ACME servers.

        
    #>
    [CmdletBinding(DefaultParameterSetName="ByName", SupportsShouldProcess=$true)]
    param(
        [Parameter(ParameterSetName="ByName")]
        [string]
        $ACMEEndpointName = "LetsEncrypt-Staging",

        [Parameter(ParameterSetName="ByUrl")]
        [Uri]
        $ACMEDirectoryUrl,

        [Parameter(ParameterSetName="ByServiceDirectory", ValueFromPipeline=$true)]
        [ACMEServiceDirectory]
        $ACMEServiceDirectory,

        [Parameter(Mandatory=$true, Position = 0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LiteralPath,

        [Switch]
        $PassThrough
    )

    process {
        if(Test-Path "$LiteralPath/*") {
            throw "Initializing the store can only be done on a non exitent or empty directory."
        }

        [ACMEServiceDirectory]$serviceDirectory;

        if($PSCmdlet.ParameterSetName -eq "ByName") {
            $serviceDirectory = Get-ServiceDirectory -ACMEEndpointName $ACMEEndpointName
        } elseif ($PSCmdlet.ParameterSetName -eq "ByUrl"){
            $serviceDirectory = Get-ServiceDirectory -ACMEDirectoryUrl $ACMEDirectoryUrl
        } else {
            $serviceDirectory = $ACMEServiceDirectory
        }
        
        if($serviceDirectory -eq $null) {
            throw "Either provide a well-known ACME service name, ACME service url or ServiceDirectory object."
        }            

        [LocalStore]::Create($LiteralPath, $serviceDirectory)
    }
}