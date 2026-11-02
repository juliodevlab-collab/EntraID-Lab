
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

