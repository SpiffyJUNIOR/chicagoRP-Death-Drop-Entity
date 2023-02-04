AddCSLuaFile()

for _, f in ipairs(file.Find("chicagorp_deathdropentity/*.lua", "LUA")) do
    if string.Left(f, 3) == "sv_" then
        if SERVER then 
            include("chicagorp_deathdropentity/" .. f) 
        end
    elseif string.Left(f, 3) == "cl_" then
        if CLIENT then
            include("chicagorp_deathdropentity/" .. f)
        else
            AddCSLuaFile("chicagorp_deathdropentity/" .. f)
        end
    elseif string.Left(f, 3) == "sh_" then
        AddCSLuaFile("chicagorp_deathdropentity/" .. f)
        include("chicagorp_deathdropentity/" .. f)
    else
        print("chicagoRP Death Drop Entity detected unaccounted for lua file '" .. f .. "' - check prefixes!")
    end
    print("chicagoRP Death Drop Entity successfully loaded!")
end
