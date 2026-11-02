
# ==========================================
# Connexion à Microsoft Graph
# ==========================================

Connect-MgGraph `
-Scopes User.ReadWrite.All,
         Group.ReadWrite.All,
         AuditLog.Read.All

Get-MgContext

