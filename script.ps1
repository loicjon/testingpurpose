# Configure WinRM for HTTPS listener
WinRM Set-Listener -Name * -Force -Transport HTTPS

# Set WinRM authentication to Basic
WinRM Set-WinRM -Force -Authentication Basic

# Disable all firewall profiles
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

# Increase WinRM memory quota (optional)
# WinRM Set-WinRM -MaxMemory 512MB
