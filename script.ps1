# Configure WinRM for Ansible
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))

# Disable all firewall profiles
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
