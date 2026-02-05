Config = {}

-- Zone Configuration (Only radius circles, no center blips)
Config.Zones = {
    {
        coords = vector3(1856.18, 3681.35, 34.27),
        radius = 50.0,
        label = "Sandy Shores PD",
        blipColor = 11,      -- Blue color for radius circle
        speedLimit = 50.0,   -- MPH (set to false to disable)
        allowWeapons = false,
        godMode = true
    },
    {
        coords = vector3(-1688.44, -1073.63, 13.15),
        radius = 50.0,
        label = "Zone 2",
        blipColor = 11,
        speedLimit = 50.0,
        allowWeapons = false,
        godMode = true
    },
    {
        coords = vector3(-2195.14, 4288.73, 49.17),
        radius = 50.0,
        label = "Zone 3",
        blipColor = 11,
        speedLimit = false,  -- No speed limit
        allowWeapons = false,
        godMode = true
    },
    {
        coords = vector3(-447.56, 6010.04, 31.72),
        radius = 50.0,
        label = "Paleto PD Safezone",
        blipColor = 11,
        speedLimit = 50.0,
        allowWeapons = false,
        godMode = true
    }
}

-- Settings
Config.DefaultRadius = 50.0
Config.NotificationDuration = 5000
Config.DebugMode = false  -- Set to true for testing, false for production

-- Messages
Config.Messages = {
    enter = "SAFEZONE ENTERED - %s MPH LIMIT",
    exit = "You left the safezone",
    bypassEnabled = "SafeZone Bypass Enabled",
    bypassDisabled = "SafeZone Bypass Disabled",
    noPermission = "Insufficient Permissions"
}

-- Controls to disable in safezone
Config.DisabledControls = {
    37,  -- Weapon wheel
    106, -- Vehicle mouse control
    24,  -- Attack
    69,  -- Vehicle attack
    70,  -- Vehicle attack 2
    92,  -- Passenger attack
    114, -- Fly attack
    257, -- Attack 2
    331, -- Melee attack
    68,  -- Aim
    263, -- Melee attack 1
    264  -- Melee attack 2
}