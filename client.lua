local QBCore = exports['qb-core']:GetCoreObject()
local isOpen = false
local isPlayingAnim = false

local function StartPullTabAnimation()
    if isPlayingAnim then return end

    local ped = PlayerPedId()

    if IsEntityDead(ped) then return end

    if IsPedInAnyVehicle(ped, false) then return end

    isPlayingAnim = true
    ClearPedTasks(ped)

    TaskStartScenarioInPlace(ped,'PROP_HUMAN_PARKING_METER',0,true)
end

local function StopPullTabAnimation()
    if not isPlayingAnim then return end

    local ped = PlayerPedId()
    ClearPedTasks(ped)

    isPlayingAnim = false
end

RegisterNetEvent('kp-pulltabs:client:open', function(tabId)
    if isOpen then return end
    if not Config.PullTabs[tabId] then return end

    TriggerServerEvent('kp-pulltabs:server:start', tabId)
end)

RegisterNetEvent('kp-pulltabs:client:started', function(data)
    if isOpen then return end

    isOpen = true
    StartPullTabAnimation()
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        tabId = data.tabId,
        label = data.label,
        image = data.image,
        lineCount = data.lineCount
    })
end)

RegisterNetEvent('kp-pulltabs:client:lineResult', function(lineIndex, result)
    SendNUIMessage({
        action = 'lineResult',
        line = lineIndex,
        result = result
    })
end)

RegisterNetEvent('kp-pulltabs:client:expired', function()
    isOpen = false
    StopPullTabAnimation()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({ action = 'close' })
    QBCore.Functions.Notify('Your pull tab expired.', 'error')
end)

RegisterNUICallback('pullLine', function(data, cb)
    local line = tonumber(data.line)

    if isOpen and line then
        if not isPlayingAnim then StartPullTabAnimation() end

        TriggerServerEvent('kp-pulltabs:server:pullLine', line)
    end

    cb('ok')
end)

RegisterNUICallback('finish', function(_, cb)
    if isOpen then
        isOpen = false
        StopPullTabAnimation()

        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)

        TriggerServerEvent('kp-pulltabs:server:finish')

        SendNUIMessage({ action = 'close' })
    end

    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    if isOpen then
        isOpen = false
        StopPullTabAnimation()

        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)

        TriggerServerEvent('kp-pulltabs:server:close')
        SendNUIMessage({ action = 'close' })
    end

    cb('ok')
end)

CreateThread(function()
    while true do
        if isOpen then
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped, false) and isPlayingAnim then
                StopPullTabAnimation()
            end

            DisableControlAction(0, 1, true)   -- Look Left/Right
            DisableControlAction(0, 2, true)   -- Look Up/Down
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 22, true)  -- Jump
            DisableControlAction(0, 23, true)  -- Enter Vehicle
            DisableControlAction(0, 75, true)  -- Exit Vehicle
            DisableControlAction(0, 21, true)  -- Sprint
            DisableControlAction(0, 44, true)  -- Cover
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    StopPullTabAnimation()

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end)
