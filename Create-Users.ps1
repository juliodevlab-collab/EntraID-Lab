
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
