

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
