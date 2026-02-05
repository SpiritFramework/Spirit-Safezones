local PlayerData = {
    inSafezone = false,
    currentZone = nil,
    bypassEnabled = false,
    hasPermission = false,
    originalMaxSpeed = nil,
    threadActive = false
}

local Blips = {}
local Zones = {}

-- Initialize - Wait for player to be fully loaded
CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(1000)
    end
    
    while not DoesEntityExist(PlayerPedId()) do
        Wait(1000)
    end
    
    Wait(2000)
    
    if not Config or not Config.Zones then
        print("[SafeZones] ERROR: Config not loaded!")
        return
    end
    
    LoadZones()
    InitializeBlips()
    TriggerServerEvent("SafeZones:CheckPermission")
    StartSafezoneThread()
    
    if Config.DebugMode then
        print("[SafeZones] System initialized with " .. #Zones .. " zones")
        Wait(1000)
        TriggerEvent('notifications:show', 'info', 'SafeZone system active', 3000)
    end
end)

function LoadZones()
    Zones = {}
    
    for i, zone in ipairs(Config.Zones) do
        local coords = zone.coords
        if not coords and zone.x then
            coords = vector3(zone.x, zone.y, zone.z)
        end
        
        if coords then
            table.insert(Zones, {
                coords = coords,
                radius = zone.radius or Config.DefaultRadius or 50.0,
                speedLimit = zone.speedLimit,
                allowWeapons = zone.allowWeapons,
                godMode = zone.godMode ~= false,
                label = zone.label or ("Safe Zone " .. i),
                blipColor = zone.blipColor or 11
            })
        end
    end
end

function InitializeBlips()
    -- Clear existing
    for _, blipData in ipairs(Blips) do
        if blipData.radius and DoesBlipExist(blipData.radius) then
            RemoveBlip(blipData.radius)
        end
    end
    Blips = {}

    for i, zone in ipairs(Zones) do
        local blipData = {}
        
        -- Only radius circle - no center icon blip
        blipData.radius = AddBlipForRadius(
            zone.coords.x, 
            zone.coords.y, 
            zone.coords.z, 
            zone.radius
        )
        SetBlipHighDetail(blipData.radius, true)
        SetBlipColour(blipData.radius, zone.blipColor)
        SetBlipAlpha(blipData.radius, 128)
        
        Blips[i] = blipData
        
        if Config.DebugMode then
            print(string.format("[SafeZones] Radius blip %d created: %s", i, zone.label))
        end
    end
end

RegisterNetEvent("SafeZones:ReturnPermission")
AddEventHandler("SafeZones:ReturnPermission", function(hasPerm)
    PlayerData.hasPermission = hasPerm
    if Config.DebugMode then
        print("[SafeZones] Permission received:", hasPerm)
    end
end)

RegisterCommand("sbypass", function()
    if not PlayerData.hasPermission then
        TriggerEvent('notifications:show', 'error', Config.Messages.noPermission, 5000)
        return
    end
    
    PlayerData.bypassEnabled = not PlayerData.bypassEnabled
    local msg = PlayerData.bypassEnabled and Config.Messages.bypassEnabled or Config.Messages.bypassDisabled
    local notifyType = PlayerData.bypassEnabled and 'success' or 'warning'
    
    TriggerEvent('notifications:show', notifyType, msg, 5000)
end, false)

RegisterCommand("sztest", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    print("[SafeZones] === DEBUG INFO ===")
    print("Player position: " .. tostring(pos))
    print("Total zones: " .. #Zones)
    print("In safezone: " .. tostring(PlayerData.inSafezone))
    
    for i, zone in ipairs(Zones) do
        local dist = #(pos - zone.coords)
        print(string.format("Zone %d (%s): %.2f units away (radius: %.2f)", 
            i, zone.label, dist, zone.radius))
    end
    
    TriggerEvent('notifications:show', 'success', 'Test notification working!', 5000)
end, false)

function StartSafezoneThread()
    if PlayerData.threadActive then return end
    PlayerData.threadActive = true
    
    CreateThread(function()
        local checkInterval = 500
        
        while true do
            local playerPed = PlayerPedId()
            
            if DoesEntityExist(playerPed) then
                local playerCoords = GetEntityCoords(playerPed)
                local inAnyZone = false
                local currentZone = nil
                local zoneId = nil
                
                for i, zone in ipairs(Zones) do
                    local dist = #(playerCoords - zone.coords)
                    
                    if dist <= zone.radius then
                        inAnyZone = true
                        currentZone = zone
                        zoneId = i
                        break
                    end
                end
                
                if inAnyZone and not PlayerData.inSafezone then
                    EnterSafezone(zoneId, currentZone)
                elseif not inAnyZone and PlayerData.inSafezone then
                    ExitSafezone()
                end
                
                if PlayerData.inSafezone and currentZone then
                    ApplySafezoneEffects(playerPed, currentZone)
                    checkInterval = 0
                else
                    checkInterval = 500
                end
            end
            
            Wait(checkInterval)
        end
    end)
end

function EnterSafezone(zoneId, zone)
    PlayerData.inSafezone = true
    PlayerData.currentZone = zoneId
    
    NetworkSetFriendlyFireOption(false)
    ClearPlayerWantedLevel(PlayerId())
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if DoesEntityExist(vehicle) then
        local handlingMaxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
        PlayerData.originalMaxSpeed = handlingMaxSpeed
    end
    
    local speedText = zone.speedLimit and tostring(zone.speedLimit) or "NO"
    local msg = string.format(Config.Messages.enter, speedText)
    TriggerEvent('notifications:show', 'success', msg, Config.NotificationDuration or 5000)
    
    if Config.DebugMode then
        print("[SafeZones] Entered zone:", zone.label)
    end
end

function ExitSafezone()
    local playerPed = PlayerPedId()
    
    NetworkSetFriendlyFireOption(true)
    
    if PlayerData.originalMaxSpeed then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if DoesEntityExist(vehicle) then
            SetVehicleMaxSpeed(vehicle, -1.0)
        end
        PlayerData.originalMaxSpeed = nil
    end
    
    SetEntityInvincible(playerPed, false)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if DoesEntityExist(vehicle) then
        SetEntityInvincible(vehicle, false)
        SetEntityCanBeDamaged(vehicle, true)
    end
    
    TriggerEvent('notifications:show', 'info', Config.Messages.exit, Config.NotificationDuration or 5000)
    
    PlayerData.inSafezone = false
    PlayerData.currentZone = nil
    
    if Config.DebugMode then
        print("[SafeZones] Exited safezone")
    end
end

function ApplySafezoneEffects(playerPed, zone)
    if PlayerData.bypassEnabled then return end
    
    if zone.godMode then
        SetEntityInvincible(playerPed, true)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if DoesEntityExist(vehicle) then
            SetEntityInvincible(vehicle, true)
            SetEntityCanBeDamaged(vehicle, false)
        end
    end
    
    if not zone.allowWeapons then
        local currentWeapon = GetSelectedPedWeapon(playerPed)
        if currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
            SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
        end
        
        for _, control in ipairs(Config.DisabledControls or {}) do
            DisableControlAction(0, control, true)
            DisableControlAction(1, control, true)
            DisableControlAction(2, control, true)
        end
        
        SetPlayerCanDoDriveBy(PlayerId(), false)
        DisablePlayerFiring(PlayerId(), true)
    end
    
    if zone.speedLimit then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            local maxSpeedMs = zone.speedLimit * 0.44704
            SetVehicleMaxSpeed(vehicle, maxSpeedMs)
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, blipData in ipairs(Blips) do
        if blipData.radius and DoesBlipExist(blipData.radius) then
            RemoveBlip(blipData.radius)
        end
    end
    
    if PlayerData.inSafezone then
        NetworkSetFriendlyFireOption(true)
        local playerPed = PlayerPedId()
        SetEntityInvincible(playerPed, false)
        
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if DoesEntityExist(vehicle) then
            SetEntityInvincible(vehicle, false)
            SetEntityCanBeDamaged(vehicle, true)
            SetVehicleMaxSpeed(vehicle, -1.0)
        end
    end
end)