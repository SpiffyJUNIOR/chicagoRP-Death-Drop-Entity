CreateConVar("sv_chicagoRP_deathdropentity_enable", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enables or disables players dropping their inventory on death.", 0, 1)
CreateConVar("sv_chicagoRP_weapon_blacklist", "weapon_fists,", {FCVAR_ARCHIVE, FCVAR_PROTECTED}, "Weapon classnames separated by a comma that will be blacklisted from the backpack entity.")

print("chicagoRP NPC Shop server convars loaded!")