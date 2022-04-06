########## ATUALIZADOR DE ARQUIVOS ##########

# PARAMETRIZAÇÕES GERAIS

# Diretório LOCAL (Colocar entre aspas duplas "" e terminar com "\")
$dir_loc = ""

# Diretório do SERVIDOR (Colocar entre aspas duplas "" e terminar com "\")
$dir_srv = ""

# Arquivos que serão atualizados => Colocar dentro dos parênteses o(s) nome(s) do(s) arquivo(s) + extensão entre aspas duplas "", por exemplo: @("Exemplo.exe"). Se for mais de um arquivo, separar os arquivos por vírgula ",", por exemplo: @("Exemplo.exe","Texte.txt")
$arquivos = @("")

########## NÃO ALTERAR AS INFORMAÇÕES ABAIXO ##########
#_________________________________________________________________________________________________________________________________________

# Variável que conta quantos arquivos serão atualizados
$Global:n = $arquivos.Count - 1

# Variável que configura o cabeçalho do atualizador
$Global:cabecalho = @("-----------------------------------------------------------", "Esse programa atualiza os arquivos nessa Estação.", "-----------------------------------------------------------")

# Variável que configura o rodapé do atualizador
$Global:rodape = @("-----------------------------------------------------------", "Obrigado por utilizar o atualizador de arquivos!", "-----------------------------------------------------------")

# Variável que configura as mensagens do atualizador
$Global:mensagem = @("")

# Variável que configura o diretório de log
$Global:dir_log = $dir_loc + "Log\"

# Principal função que inicia e termina o atualizador
function Atualiza_estacao {
    Verifica_diretorios
    Write-Output $cabecalho | Out-String 
    for ( $n = 0; $n -lt $arquivos.count; $n++) {
        Verifica_arquivo
    }
    Write-Output $rodape
    Pause
    Exit
}

# Função que valida a existência dos diretórios LOCAL, SERVIDOR e LOG (Se o diretório de LOG não existir, será criado dentro do diretório LOCAL)
function Verifica_diretorios {
    if (-not(Test-path -ErrorAction SilentlyContinue -Path $dir_loc)) {
        Write-Output $cabecalho | Out-String
        $mensagem += Write-Host -ForegroundColor Red ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => O diretório LOCAL " + $dir_loc + " não foi localizado. Por gentileza informar um diretório válido.") | Out-String   
        Write-Output $mensagem
        Write-Output $rodape
        Pause
        Exit
    }
    else {
        if (-not(Test-path -ErrorAction SilentlyContinue -Path $dir_log)) {
            New-Item -Path $dir_log -ItemType directory > $null           
        }
        if (-not(Test-path -ErrorAction SilentlyContinue -Path $dir_srv)) {
            Write-Output $cabecalho | Out-String
            $mensagem += Write-Host -ForegroundColor Red ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => O diretório do SERVIDOR " + $dir_srv + " não foi localizado. Por gentileza informar um diretório válido.") | Out-String
            Write-Output $mensagem
            Write-Output $rodape
            Pause
            Exit
        }
    }
}

# Função que verifica se os arquivos a serem atualizados foram realmente informados, se eles existem no SERVIDOR e se eles estão abertos na Estação
function Verifica_arquivo {
    if ([string]::IsNullOrEmpty($arquivos)) {
        $mensagem += ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => não há arquivos para serem atualizados. Informe um arquivo válido.") | Add-Content -Path ($dir_log + "Log.txt") -PassThru -Encoding "UTF8" -Force | Out-String | Write-Host -ForegroundColor Red       
    }
    else {
        if (-not((Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_srv $arquivos[$n])).Exists)) {
            $mensagem += ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => O arquivo " + $arquivos[$n] + " não foi localizado no SERVIDOR. Informe um arquivo válido.") | Out-String | Add-Content -Path ($dir_log + "Log.txt") -PassThru -Encoding "UTF8" -Force | Write-Host -ForegroundColor Red
        }
        else {
            if ((Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_srv $arquivos[$n])).Attributes -ne 'File') {
                $arquivo = New-Object System.IO.FileInfo (Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_srv $arquivos[$n]))
                try {
                    $oStream = $arquivo.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
                    $oStream.Close()
                    Atualiza_arquivos
                }
                catch {
                    $mensagem += ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => O arquivo " + $arquivos[$n] + " está aberto na Estação. Por gentileza fechar e tentar novamente.") | Out-String | Add-Content -Path ($dir_log + "Log.txt") -PassThru -Encoding "UTF8" -Force | Write-Host -ForegroundColor Yellow
                } 
            }                      
        }
    }
}

# Função que compara e atualiza os arquivos mais recentes
function Atualiza_arquivos {
    if (-not((Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_srv $arquivos[$n])).LastWriteTime -eq (Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_loc $arquivos[$n])).LastWriteTime)) {
        $extensao = ((Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_loc $arquivos[$n])).Extension)
        $nome = ((Get-ChildItem -ErrorAction SilentlyContinue (Join-Path $dir_loc $arquivos[$n])).BaseName)
        Copy-Item -ErrorAction SilentlyContinue -Path ($dir_loc + $arquivos[$n]) -Destination ($dir_loc + $nome + "2" + $extensao) -Force
        Remove-Item -ErrorAction SilentlyContinue -Path ($dir_loc + $arquivos[$n]) -Force
        Copy-Item -ErrorAction SilentlyContinue -Path ($dir_srv + $arquivos[$n]) -Destination ($dir_loc + $arquivos[$n]) -Force
        $mensagem += ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => O arquivo " + $arquivos[$n] + " foi atualizado para a versão mais recente!") | Add-Content -Path ($dir_log + "Log.txt") -PassThru -Encoding "UTF8" -Force | Out-String | Write-Host -ForegroundColor Cyan
    }
    else {
        $mensagem += ((Get-Date -Uformat %d/%m/%Y" "%H:%M:%S) + " - IP: " + ((Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address).IPAddressToString) + " - Estação: " + ((Get-WmiObject win32_computersystem).Name) + "." + ((Get-WmiObject win32_computersystem).Domain) + " - Usuário: " + ((Get-WMIObject Win32_ComputerSystem).Username) + " => O arquivo " + $arquivos[$n] + " já está atualizado, atualização ignorada!") | Add-Content -Path ($dir_log + "Log.txt") -PassThru -Encoding "UTF8" -Force | Out-String | Write-Host -ForegroundColor White
    }    
}

# Inicia o atualizador
Atualiza_estacao