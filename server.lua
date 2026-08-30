local QBCore = exports['qb-core']:GetCoreObject()

local Sessions = {}

math.randomseed(os.time() + GetGameTimer())

local function debugPrint(...)
    if Config.Debug then
        print('[kp-pulltabs]', ...)
    end
end

local function getTabByItem(itemName)
    for tabId, tab in pairs(Config.PullTabs) do
        if tab.item == itemName then
            return tabId, tab
        end
    end
    return nil, nil
end

local function weightedPrize(prizes)
    local total = 0

    for _, prize in ipairs(prizes) do
        total = total + (tonumber(prize.weight) or 0)
    end

    if total <= 0 then return nil end

    local roll = math.random() * total
    local current = 0

    for _, prize in ipairs(prizes) do
        current = current + (tonumber(prize.weight) or 0)
        if roll <= current then
            return prize
        end
    end

    return prizes[#prizes]
end

local function givePrize(Player, prize)
    if not Player or not prize then
        return false, 'Invalid prize.'
    end

    if prize.type == 'money' then
        local amount = math.floor(tonumber(prize.amount) or 0)

        if amount <= 0 then
            return false, 'Invalid money amount.'
        end

        local account = prize.account or Config.DefaultMoneyAccount

        if account ~= 'cash' and account ~= 'bank' then
            account = Config.DefaultMoneyAccount
        end

        Player.Functions.AddMoney(account, amount, 'pull-tab-win')

        return true, ('$%s'):format(amount)
    end

    if prize.type == 'item' then
        local item = tostring(prize.item or '')
        local amount = math.floor(tonumber(prize.amount) or 1)

        if item == '' or amount <= 0 then
            return false, 'Invalid item prize.'
        end

        local itemData = exports.ox_inventory:Items(item)

        if not itemData then
            print(('[kp-pulltabs] ERROR: Item "%s" does not exist in ox_inventory.'):format(item))
            return false, 'Invalid item.'
        end

        local success, response = exports.ox_inventory:AddItem(
            Player.PlayerData.source,
            item,
            amount
        )

        if not success then
            print(('[kp-pulltabs] Failed to give %sx %s: %s'):format(
                amount,
                item,
                tostring(response)
            ))

            return false, 'Your inventory is full.'
        end

        local label = itemData.label or item

        return true, ('%sx %s'):format(amount, label)
    end

    return false, 'Unknown prize type.'
end

-- Registers every configured pull tab item.
CreateThread(function()
    for tabId, tab in pairs(Config.PullTabs) do
        if tab.item then
            QBCore.Functions.CreateUseableItem(tab.item, function(source, item)
                local Player = QBCore.Functions.GetPlayer(source)
                if not Player then return end

                TriggerClientEvent('kp-pulltabs:client:open', source, tabId)
            end)

            debugPrint('Registered usable item:', tab.item, tabId)
        end
    end
end)

RegisterNetEvent('kp-pulltabs:server:start', function(tabId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local tab = Config.PullTabs[tabId]

    if not Player or not tab then return end

    if Sessions[src] then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a pull tab open.', 'error')
        return
    end

    if Config.RemoveTabOnStart then
        local item = Player.Functions.GetItemByName(tab.item)

        if not item or item.amount < 1 then
            TriggerClientEvent('QBCore:Notify', src, 'You do not have this pull tab.', 'error')
            return
        end

        Player.Functions.RemoveItem(tab.item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[tab.item], 'remove', 1)
    end

    -- The server creates the results. The client only receives one result
    -- when that specific line has actually been pulled.
    Sessions[src] = {
        tabId = tabId,
        created = os.time(),
        nextLine = 1,
        results = {}
    }

    TriggerClientEvent('kp-pulltabs:client:started', src, {
        tabId = tabId,
        label = tab.label,
        image = tab.image,
        lineCount = #tab.lines
    })
end)

RegisterNetEvent('kp-pulltabs:server:pullLine', function(lineIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local session = Sessions[src]

    lineIndex = tonumber(lineIndex)

    if not Player or not session or not lineIndex then return end

    if os.time() - session.created > Config.SessionTimeout then
        Sessions[src] = nil
        TriggerClientEvent('kp-pulltabs:client:expired', src)
        return
    end

    -- Only allow the next line in order.
    if lineIndex ~= session.nextLine then
        debugPrint(('Rejected out-of-order pull from %s: %s'):format(src, tostring(lineIndex)))
        return
    end

    local tab = Config.PullTabs[session.tabId]
    local line = tab and tab.lines[lineIndex]

    if not line then return end

    local prize = weightedPrize(line.prizes)

    if not prize then
        TriggerClientEvent('kp-pulltabs:client:lineResult', src, lineIndex, {
            won = false,
            text = 'NO PRIZE'
        })
        session.nextLine = session.nextLine + 1
        return
    end

    local success, text = givePrize(Player, prize)

    local result = {
        won = success,
        type = prize.type,
        text = success and text or 'NO PRIZE',
        amount = prize.amount,
        item = prize.item
    }

    session.results[lineIndex] = result
    session.nextLine = session.nextLine + 1

    TriggerClientEvent('kp-pulltabs:client:lineResult', src, lineIndex, result)
end)

RegisterNetEvent('kp-pulltabs:server:finish', function()
    local src = source
    local session = Sessions[src]
    if not session then return end

    local tab = Config.PullTabs[session.tabId]
    if not tab then
        Sessions[src] = nil
        return
    end

    if session.nextLine > #tab.lines then
        Sessions[src] = nil
    end
end)

-- Closing early DOES NOT refund the tab by default.
-- This prevents people from repeatedly opening/closing to manipulate results.
RegisterNetEvent('kp-pulltabs:server:close', function()
    local src = source
    Sessions[src] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    Sessions[src] = nil
end)
