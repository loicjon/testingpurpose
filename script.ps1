# Vérifie si l'utilisateur a des privilèges administratifs
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = (New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if (-not $isAdmin) {
    Write-Output "Erreur : Vous devez disposer de privilèges d'administrateur pour exécuter ce script."
    Write-Output "Exécutez Windows PowerShell en tant qu'administrateur."
    Exit 2
}

# Vérifie si le service WinRM est installé et en cours d'exécution
if (-not (Get-Service "WinRM")) {
    Write-Output "Erreur : Le service WinRM n'a pas été trouvé."
    Exit 1
}

# Configure le service WinRM pour démarrer automatiquement au démarrage
Set-Service -Name "WinRM" -StartupType Automatic

# Démarre le service WinRM s'il n'est pas déjà en cours d'exécution
Start-Service -Name "WinRM"

# Active PS Remoting
Enable-PSRemoting -Force

# Génère un certificat SSL auto-signé
$thumbprint = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(3)

# Configure un écouteur WSMan avec le certificat auto-signé
$valueset = @{
    Hostname              = $env:COMPUTERNAME
    CertificateThumbprint = $thumbprint.Thumbprint
}
$selectorset = @{
    Transport = "HTTPS"
    Address   = "*"
}
New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset

# Active ou désactive l'authentification de base selon les besoins
if ($DisableBasicAuth) {
    Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $false
}
else {
    Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $true
}

# Active l'authentification CredSSP si spécifié
if ($EnableCredSSP) {
    Enable-WSManCredSSP -Role Server
}

# Ajoute une règle dans le pare-feu pour autoriser les connexions WinRM HTTPS
netsh advfirewall firewall add rule name="Allow WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

# Teste la connexion à distance en utilisant HTTP
Invoke-Command -ComputerName "localhost" -ScriptBlock { $env:COMPUTERNAME }

# Teste la connexion à distance en utilisant HTTPS
$httpsOptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
New-PSSession -UseSSL -ComputerName "localhost" -SessionOption $httpsOptions


# Disable all firewall profiles
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

# Increase WinRM memory quota (optional)
# WinRM Set-WinRM -MaxMemory 512MB
