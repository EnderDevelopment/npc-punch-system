local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('npc_punch_system:summonNPC', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.execute('INSERT INTO npc_punch_system (player_id, npc_model) VALUES (@player_id, @npc_model)', {
            ['@player_id'] = xPlayer.identifier,
            ['@npc_model'] = Config.NPCModel
        }, function(rowsChanged)
            cb(true)
        end)
    else
        cb(false)
    end
end)