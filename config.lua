Config = Config or {}

Config.StartingApartment = false   -- If you want to enabled apartment spawn
Config.DefaultSpawn = vector3(-1014.05, -2692.65, 13.98)   -- Default spawn if you to disabled apartment spawn

Config.Interior = vector3(-1453.56, -551.53, 72.84) -- Interior to load where characters are previewed
Config.CamCoords = vector3(-1458.66, -550.97, 73.00) -- Camera coordinates for character preview screen
Config.HiddenCoords = vector3(-1453.58, -556.30, 72.88) -- Hides your actual ped while you are in selection
Config.PedCoords = vector3(-1453.56, -551.53, 72.84) -- Coords where characters walk to. and change the heading in client side
Config.CreatePed = vector4(-1450.20, -549.20, 72.84, 125.14) -- Coords where characters are placed
Config.RemovePed = vector3(-1449.11, -548.54, 72.00) -- Coords where character will walk when chosen when creating
Config.SelectPed = vector4(-1449.65, -555.63, 72.84, 299.70) -- Coords where character will walk when chosen

Config.DefaultNumberOfCharacters = 5   -- Define maximum amount of default characters (max 5)
Config.PlayersNumberOfCharacters = {   -- Define maximum amount of player characters by rockstar license
   { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 5 },
}