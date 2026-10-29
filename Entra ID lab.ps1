# Connexion Microsoft Graph
Connect-MgGraph `
-Scopes User.ReadWrite.All,Group.ReadWrite.All

<# Création des groupes qui reflette nos differents departement dans notre organisations
    Notons pour cette exemple nous avons 
      GG-Direction  : Direction
      GG-RH          : Ressources Humaines
      GG-IT          : Informatique
      GG-Finance      : Finance
      GG-Ventes       : Vente
#>

$Groups = @(
"GG-Direction",
"GG-RH",
"GG-IT",
"GG-Finance",
"GG-Ventes"
)

foreach ($Group in $Groups)
{
    New-MgGroup `
      -DisplayName $Group `
      -MailEnabled:$false `
      -SecurityEnabled:$true `
      -MailNickname ($Group.Replace("-",""))
}

<# Definitions nos Utilisateurs pour ce projet 
    Notons pour cette exemple nous avons 
    ceo@mytestcomptoutlook003.onmicrosoft.com
    rh01@mytestcomptoutlook003.onmicrosoft.com
    it01@mytestcomptoutlook003.onmicrosoft.com
    finance01@mytestcomptoutlook003.onmicrosoft.com
    vente01@mytestcomptoutlook003.onmicrosoft.com
#>

$Users = @(
@{
Nom="Directeur Général"
UPN="ceo@mytestcomptoutlook003.onmicrosoft.com"
Groupe="GG-Direction"
},

@{
Nom="Agent RH"
UPN="rh01@mytestcomptoutlook003.onmicrosoft.com"
Groupe="GG-RH"
},

@{
Nom="Technicien IT"
UPN="it01@mytestcomptoutlook003.onmicrosoft.com"
Groupe="GG-IT"
},

@{
Nom="Comptable"
UPN="finance01@mytestcomptoutlook003.onmicrosoft.com"
Groupe="GG-Finance"
},

@{
Nom="Commercial"
UPN="vente01@mytestcomptoutlook003.onmicrosoft.com"
Groupe="GG-Ventes"
}
)

# Creation des utilisateurs
foreach ($User in $Users)
{
    $PasswordProfile = @{
        Password = "Temp12345!"
        ForceChangePasswordNextSignIn = $true
    }

    New-MgUser `
        -DisplayName $User.Nom `
        -UserPrincipalName $User.UPN `
        -MailNickname $User.UPN.Split("@")[0] `
        -AccountEnabled `
        -PasswordProfile $PasswordProfile
}
# Ajouter les utilisateurs aux groupes
foreach ($User in $Users)
{
    $GroupId = (
        Get-MgGroup `
        -Filter "displayName eq '$($User.Groupe)'"
    ).Id

    $UserId = (
        Get-MgUser `
        -Filter "userPrincipalName eq '$($User.UPN)'"
    ).Id

    New-MgGroupMemberByRef `
        -GroupId $GroupId `
        -BodyParameter @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
        }
}

# Exporter les Utilisateurs nouvellement creer vers un fichier .csv 

$DesktopPath = :GetFolderPath("Desktop")

$ExportFolder = Join-Path $DesktopPath "Entra ID"

if (!(Test-Path $ExportFolder))
{
    New-Item -Path $ExportFolder -ItemType Directory | Out-Null
}

Get-MgUser -All `
-Property DisplayName,UserPrincipalName,UserType,AccountEnabled |
Select-Object `
DisplayName,
UserPrincipalName,
UserType,
AccountEnabled |
Export-Csv `
-Path (Join-Path $ExportFolder "Entra ID Lab.csv") `
-NoTypeInformation `
-Encoding UTF8

Write-Host "Rapport créé avec succès" -ForegroundColor Green
Write-Host "Emplacement : $ExportFolder\Entra ID Lab.csv" -ForegroundColor Yellow

