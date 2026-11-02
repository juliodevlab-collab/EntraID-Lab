
# ==========================================
# Connexion à Microsoft Graph
# ==========================================

Connect-MgGraph `
-Scopes User.ReadWrite.All,
         Group.ReadWrite.All,
         AuditLog.Read.All

Get-MgContext

# ==========================================
# Création de la structure organisationnelle
# ==========================================
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


# ==========================================
# Création des utilisateurs
# ==========================================
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


# ==========================================
# Affectation automatique aux groupes
# ==========================================
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

<#
    Exporter les Utilisateurs nouvellement creer vers un fichier .csv 

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

#>

# ==========================================
# Rapport d'inventaire Entra ID
# ==========================================

$DesktopPath = :GetFolderPath("Desktop")

$EntraIDFolder = Join-Path $DesktopPath "Entra ID"

$LabFolder = Join-Path $EntraIDFolder "Entra ID Lab"

if (!(Test-Path $LabFolder))
{
    New-Item `
    -Path $LabFolder `
    -ItemType Directory | Out-Null
}

$Today = Get-Date

$Report = Get-MgUser -All `
-Property DisplayName,
          UserPrincipalName,
          UserType,
          AccountEnabled,
          CreatedDateTime |
ForEach-Object {

    $Age = $Today - $_.CreatedDateTime

    [PSCustomObject]@{

        DisplayName = $_.DisplayName

        UserPrincipalName = $_.UserPrincipalName

        UserType = $_.UserType

        AccountStatus = if ($_.AccountEnabled)
        {
            "Actif"
        }
        else
        {
            "Inactif"
        }

        CreatedDate = $_.CreatedDateTime

        AccountAgeDays = $Age.Days

        AccountAgeMonths = :Round($Age.Days / 30,1)

        AccountAgeYears = :Round($Age.Days / 365,2)
    }
}

$CsvFile = Join-Path $LabFolder "Entra ID Lab.csv"

$Report |
Export-Csv `
-Path $CsvFile `
-NoTypeInformation `
-Encoding UTF8

Write-Host "Rapport exporté :" $CsvFile -ForegroundColor Green

