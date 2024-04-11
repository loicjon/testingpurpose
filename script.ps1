# Téléchargement et exécution du script de configuration WinRM pour Ansible
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1' -OutFile 'ConfigureRemotingForAnsible.ps1'
.\ConfigureRemotingForAnsible.ps1

# Désactivation des profils de pare-feu
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
