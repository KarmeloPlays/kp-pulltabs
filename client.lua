local QBCore = exports['qb-core']:GetCoreObject()

local isOpen = false

RegisterNetEvent('kp-pulltabs:client:open', function(tabId)
    if isOpen then return end
    if not Config.PullTabs[tabId] then return end

    TriggerServerEvent('kp-pulltabs:server:start', tabId)
end)

RegisterNetEvent('kp-pulltabs:client:started', function(data)
    if isOpen then return end

    isOpen = true
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
    SetNuiFocus(false, false)

    SendNUIMessage({ action = 'close' })
    QBCore.Functions.Notify('Your pull tab expired.', 'error')
end)

RegisterNUICallback('pullLine', function(data, cb)
    local line = tonumber(data.line)

    if isOpen and line then
        TriggerServerEvent('kp-pulltabs:server:pullLine', line)
    end

    cb('ok')
end)

RegisterNUICallback('finish', function(_, cb)
    if isOpen then
        isOpen = false

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
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        TriggerServerEvent('kp-pulltabs:server:close')
        SendNUIMessage({ action = 'close' })
    end

    cb('ok')
end)

RegisterCommand('closepulltab', function()
    if not isOpen then return end

    isOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    TriggerServerEvent('kp-pulltabs:server:close')
    SendNUIMessage({ action = 'close' })
end, false)

CreateThread(function()
    while true do
        if isOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            Wait(0)
        else
            Wait(500)
        end
    end
end)
