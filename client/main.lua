local cam = nil
local charPed = nil
local QBCore = exports['qb-core']:GetCoreObject()

-- Main Thread

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('mrf_charmenu:client:chooseChar')
			return
		end
	end
end)

-- Functions

local function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, 0.00, 0.00, 248.17, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

local function openCharMenu(bool)
    QBCore.Functions.TriggerCallback("mrf_charmenu:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
        })
        skyCam(bool)
    end)
end

-- Events

RegisterNetEvent('mrf_charmenu:client:closeNUIdefault', function() -- This event is only for no starting apartments
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    openCharMenu()
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('mrf_charmenu:client:closeNUI', function()
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
end)

RegisterNetEvent('mrf_charmenu:client:chooseChar', function()
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    local Interior = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z - 18.9)
    LoadInterior(Interior)
    while not IsInteriorReady(Interior) do
        Citizen.Wait(1000)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false)
    TriggerEvent('qb-weathersync:client:DisableSync')
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    openCharMenu(true)
end)

-- NUI Callbacks

RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('mrf_charmenu:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data)
    local cData = data.cData
    TaskGoStraightToCoord(charPed, Config.SelectPed.x, Config.SelectPed.y, Config.SelectPed.z - 0.98, 1.0, -1, Config.SelectPed.h)
    Citizen.SetTimeout(2000, function()
        DoScreenFadeOut(150)
        Citizen.Wait(150)
        NetworkRequestControlOfEntity(charPed)
        DeleteEntity(charPed)
        openCharMenu(false)
        charPed = nil
        TriggerServerEvent('mrf_charmenu:server:loadUserData', cData)
    end)
end)

RegisterNUICallback('cDataPed', function(nData, cb)
    local cData = nData.cData
    if charPed ~= nil then
        TaskGoStraightToCoord(charPed, Config.CreatePed.x, Config.CreatePed.y, Config.CreatePed.z - 0.98, 1.0, -1, Config.CreatePed.h)
        Citizen.Wait(2500)
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        Citizen.Wait(150)
    end
    if cData ~= nil then
        QBCore.Functions.TriggerCallback('mrf_charmenu:server:getSkin', function(skinData)
            if skinData then
                local model = joaat(skinData.model)
                CreateThread(function()
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.CreatePed.x, Config.CreatePed.y, Config.CreatePed.z - 0.98, Config.CreatePed.h, false, false)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    SetEveryoneIgnorePlayer(charPed, true)
                    NetworkSetEntityInvisibleToNetwork(charPed, true)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    SetPedConfigFlag(charPed, 410, true)
                    SetEntityCanBeDamagedByRelationshipGroup(charPed, false, GetHashKey('PLAYER'))
                    FreezeEntityPosition(charPed, false)
                    SetEntityAsMissionEntity(charPed, true, true)
                    PlaceObjectOnGroundProperly(charPed)
                    TaskGoStraightToCoord(charPed, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, 1.0, -1, 109.66) --change the 109.66 number according to the vector3 heading
                    exports['illenium-appearance']:setPedAppearance(charPed, skinData)
                end)
            else
                CreateThread(function()
                    local randommodels = {
                        "mp_m_freemode_01",
                        "mp_f_freemode_01",
                    }
                    model = joaat(randommodels[math.random(1, #randommodels)])
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.CreatePed.x, Config.CreatePed.y, Config.CreatePed.z - 0.98, Config.CreatePed.h, false, false)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    NetworkSetEntityInvisibleToNetwork(charPed, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetEntityCanBeDamagedByRelationshipGroup(charPed, false, `PLAYER`)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    TaskGoStraightToCoord(charPed, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, 1.0, -1, 109.66) --change the 109.66 number according to the vector3 heading
                end)
            end
            cb("ok")
        end, cData.citizenid)
    else
        CreateThread(function()
            local randommodels = {
                "mp_m_freemode_01",
                "mp_f_freemode_01",
            }
            local model = joaat(randommodels[math.random(1, #randommodels)])
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            charPed = CreatePed(2, model, Config.CreatePed.x, Config.CreatePed.y, Config.CreatePed.z - 0.98, Config.CreatePed.h, false, false)
            SetPedComponentVariation(charPed, 0, 0, 0, 2)
            NetworkSetEntityInvisibleToNetwork(charPed, true)
            SetPedComponentVariation(charPed, 0, 0, 0, 2)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            SetEntityCanBeDamagedByRelationshipGroup(charPed, false, `PLAYER`)
            PlaceObjectOnGroundProperly(charPed)
            SetBlockingOfNonTemporaryEvents(charPed, true)
            TaskGoStraightToCoord(charPed, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, 1.0, -1, 109.66) --change the 109.66 number according to the vector3 heading
        end)
        cb("ok")
    end
end)

RegisterNUICallback('setupCharacters', function()
    QBCore.Functions.TriggerCallback("mrf_charmenu:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
end)

RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data)
    local cData = data
    if cData.gender == "man" then
        cData.gender = 0
    elseif cData.gender == "woman" then
        cData.gender = 1
    end
    TaskGoStraightToCoord(charPed, Config.RemovePed.x, Config.RemovePed.y, Config.RemovePed.z)
    Citizen.SetTimeout(2000, function()
        DoScreenFadeOut(150)
        Citizen.Wait(150)
        NetworkRequestControlOfEntity(charPed)
        DeleteEntity(charPed)
        OpenCharMenu(false)
        charPed = nil
        TriggerServerEvent('mrf_charmenu:server:createCharacter', cData)
    end)
end)

RegisterNUICallback('removeCharacter', function(data)
    TaskGoStraightToCoord(charPed, Config.RemovePed.x, Config.RemovePed.y, Config.RemovePed.z)
    Citizen.SetTimeout(2500, function()
        DoScreenFadeOut(10)
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        OpenCharMenu(false)
        charPed = nil
        TriggerServerEvent('mrf_charmenu:server:deleteCharacter', data.citizenid)
        TriggerEvent('mrf_charmenu:client:chooseChar')
    end)
end)