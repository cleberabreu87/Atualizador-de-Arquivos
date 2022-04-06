function Converter {
    param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        [Alias("FullName")]
        $Path
    )
 
    process {
        $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content -Path $Path -Raw -Encoding UTF8)))
        $newPath = [Io.Path]::ChangeExtension($Path, ".bat")
        "@echo off`nPowershell.exe -NoExit -WindowStyle Maximized -EncodedCommand $encoded" | Set-Content -Path $newPath -Encoding Ascii
    }
}
 
Get-ChildItem -Path .\ -Filter .\Atualizador.ps1 | Converter