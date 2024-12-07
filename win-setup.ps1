<#
.SYNOPSIS
Script de setup initial d'une machine Windows (création de compte, vérification winget, installation de logiciels)

.EXAMPLE
Ouvrez PowerShell en administrateur, puis lancez :
.\win-setup.ps1
#>

# Assurer que le script s'exécute en mode Administrateur
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Ce script doit être lancé en tant qu'administrateur."
    exit 1
}

### 1. Création d’un compte local
Write-Host "Souhaitez-vous créer un nouveau compte local ? (o/n)"
$createUser = Read-Host

if ($createUser -eq "o") {
    $username = Read-Host "Entrez le nom du nouvel utilisateur local"
    Write-Host "Cet utilisateur doit-il être admin ? (o/n)"
    $isAdmin = Read-Host

    # Création de l'utilisateur avec mot de passe vide
    # /add ajoute l'utilisateur
    # "" comme mot de passe le laisse vide
    # /passwordchg:yes force la demande de nouveau mdp à la prochaine connexion
    Write-Host "Création de l'utilisateur $username ..."
    net user $username "" /add /passwordchg:yes

    if ($LASTEXITCODE -ne 0) {
        Write-Error "La création de l'utilisateur a échoué. Vérifiez que vous avez les droits nécessaires ou que l'utilisateur n'existe pas déjà."
        exit 1
    }

    if ($isAdmin -eq "o") {
        Write-Host "Ajout de $username au groupe Administrators..."
        net localgroup Administrators $username /add
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Impossible d'ajouter l'utilisateur au groupe Administrators."
        }
    }

    Write-Host "Utilisateur $username créé. Il devra définir un mot de passe à sa première connexion."
}

### 2. Vérifier l'installation de winget
Function Test-Winget {
    try {
        winget --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

Write-Host "Vérification de winget..."
if (Test-Winget) {
    Write-Host "Winget est déjà installé."
} else {
    Write-Host "Winget n'est pas installé. Tentative d'installation..."

    # Sous Windows 11, winget est généralement présent. Sous Windows 10, il faut passer par le Microsoft Store ou télécharger App Installer.
    # Tentative simpliste : utilisation de Add-AppxPackage (nécessite un package .appxbundle ou .msixbundle)
    # Vous pouvez télécharger App Installer directement depuis : 
    # https://github.com/microsoft/winget-cli/releases
    # Et l'installer via Add-AppxPackage. Par exemple :
    # Add-AppxPackage -Path "C:\Chemin\Vers\AppInstaller.Msixbundle"

    # Dans cet exemple, on suppose que le PC a accès au Microsoft Store. On peut tenter :
    # Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1" -Wait
    # Ceci ouvrira le Store sur l'App Installer. L'utilisateur devra l'installer manuellement.
    # Sinon, si vous avez déjà le package, par exemple :
    # Add-AppxPackage -Path "C:\path\to\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appx"

    # Pour ce script, on va juste avertir l'utilisateur.
    Write-Host "Veuillez installer App Installer (winget) via le Microsoft Store. Le script s'interrompra."
    Write-Host "URL: https://www.microsoft.com/store/productId/9NBLGGH4NNS1"
    Start-Sleep -Seconds 5
    exit 1
}

# Re-test après installation (si nécessaire)
if (-not (Test-Winget)) {
    Write-Error "Winget n'est pas disponible. Arrêt du script."
    exit 1
}

### 3. Installation de Firefox, Brave et VSCode via winget
# Options :
# --id <ID>           : Nom du package ID
# -e, --exact         : correspondance exacte du nom
# --scope machine     : installe pour tous les utilisateurs (admin requis)
# --accept-source-agreements --accept-package-agreements : acceptez les licences automatiquement (sinon interaction)
# --silent ou --quiet : mode silencieux

Write-Host "Installation de Firefox (Mozilla.Firefox) ..."
winget install --id Mozilla.Firefox -e --scope machine --accept-source-agreements --accept-package-agreements --silent

Write-Host "Installation de Brave (Brave.Brave) ..."
winget install --id Brave.Brave -e --scope machine --accept-source-agreements --accept-package-agreements --silent

Write-Host "Installation de Visual Studio Code (Microsoft.VisualStudioCode) ..."
winget install --id Microsoft.VisualStudioCode -e --scope machine --accept-source-agreements --accept-package-agreements --silent

Write-Host "Les installations sont terminées."
