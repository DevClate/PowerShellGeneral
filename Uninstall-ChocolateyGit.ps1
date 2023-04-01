# Uninstall Chocolatey and Git

choco uninstall git.install -y
Remove-Item "$($env:USERPROFILE)\.gitconfig" -force
Remove-Item "$($env:ProgramFiles)\Git" -Recurse -force