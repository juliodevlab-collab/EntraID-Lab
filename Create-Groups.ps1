
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
