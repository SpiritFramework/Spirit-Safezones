local Config = {
    versionCheck = true,
    resourceName = "SafeZones",
    currentVersion = "2.0.0",
    versionUrl = "https://raw.githubusercontent.com/SpiritFramework/Spirit-Safezones-FiveM/refs/heads/main/version.txt"
}

-- Permission Check
RegisterNetEvent("SafeZones:CheckPermission")
AddEventHandler("SafeZones:CheckPermission", function()
    local src = source
    local hasPerm = IsPlayerAceAllowed(src, "safezones.bypass")
    TriggerClientEvent("SafeZones:ReturnPermission", src, hasPerm)
end)

-- Version Check
if Config.versionCheck then
    CreateThread(function()
        PerformHttpRequest(Config.versionUrl, function(status, body)
            if status ~= 200 then return end
            
            local latestVersion = body:gsub("%s+", "")
            if latestVersion ~= Config.currentVersion then
                print(string.format("\n^1[%s]^0 Version mismatch: current ^3%s^0, latest ^2%s^0", 
                    Config.resourceName, Config.currentVersion, latestVersion))
                print(string.format("^1[%s]^0 Please update from: https://github.com/SpiritFramework/Spirit-Safezones-FiveM\n", 
                    Config.resourceName))
            else
                print(string.format("^2[%s]^0 Running latest version (%s)", 
                    Config.resourceName, Config.currentVersion))
            end
        end, "GET")
    end)
end

-- Optional: Admin commands to manage zones at runtime
RegisterCommand("szreload", function(src)
    if not IsPlayerAceAllowed(src, "command.szreload") then
        TriggerClientEvent('notifications:show', src, 'error', 'No permission!', 5000)
        return
    end
    
    -- Trigger client reload
    TriggerClientEvent("SafeZones:ReloadConfig", -1)
    TriggerClientEvent('notifications:show', src, 'success', 'SafeZones config reloaded!', 5000)
end, false)
