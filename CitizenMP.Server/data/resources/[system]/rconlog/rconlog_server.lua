RconLog({ msgType = 'serverStart', hostname = 'lovely', maxplayers = 32 })

RegisterServerEvent('playerActivated')

local names = {}

AddEventHandler('playerActivated', function()
    RconLog({ msgType = 'playerActivated', netID = source, name = GetPlayerName(source), guid = GetPlayerGuid(source), ip = GetPlayerEP(source) })

    names[source] = GetPlayerName(source)

    TriggerClientEvent('rlUpdateNames', GetHostId())
end)

RegisterServerEvent('rlUpdateNamesResult')

AddEventHandler('rlUpdateNamesResult', function(res)
    if source ~= GetHostId() then
        print('bad guy')
        return
    end

    for id, data in pairs(res) do
        if data then
            if not names[id] then
                names[id] = data
            end

            if names[id].name ~= data.name or names[id].id ~= data.id then
                names[id] = data

                RconLog({ msgType = 'playerRenamed', netID = id, name = data.name })
            end
        else
            names[id] = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    RconLog({ msgType = 'playerDropped', netID = source, name = GetPlayerName(source) })

    names[source] = nil
end)

AddEventHandler('chatMessage', function(netID, name, message)
    RconLog({ msgType = 'chatMessage', netID = netID, name = name, message = message, guid = GetPlayerGuid(netID) })
end)

AddEventHandler('rconCommand', function(commandName, args)
    if commandName ~= 'status' then
        return
    end

    for netid, data in pairs(names) do
        RconPrint(netid .. ' ' .. GetPlayerGuid(netid) .. ' ' .. data.name .. ' ' .. GetPlayerEP(netid) .. "\n")
    end
end)