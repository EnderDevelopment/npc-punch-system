local ESX = nil
local npc = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 38) then -- E key
            OpenNPCMenu()
        end
    end
end)

function OpenNPCMenu()
    local elements = {
        {label = Config.GUI.buttonText, value = 'summon_npc'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'npc_punch_menu', {
        title = Config.GUI.title,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'summon_npc' then
            SummonNPC()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function SummonNPC()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    RequestModel(GetHashKey(Config.NPCModel))
    while not HasModelLoaded(GetHashKey(Config.NPCModel)) do
        Citizen.Wait(0)
    end

    npc = CreatePed(4, GetHashKey(Config.NPCModel), playerCoords.x, playerCoords.y, playerCoords.z, 0.0, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetBlockingOfNonTemporaryEvents(npc, true)

    TaskStartScenarioInPlace(npc, Config.NPCAnimation.dict, 0, true)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if npc ~= nil then
                local npcCoords = GetEntityCoords(npc)
                local distance = #(playerCoords - npcCoords)

                if distance > 5.0 then
                    TaskGoToCoordAnyMeans(npc, playerCoords.x, playerCoords.y, playerCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
                else
                    TaskStartScenarioInPlace(npc, Config.NPCAnimation.dict, 0, true)
                end

                if distance < 2.0 then
                    RequestAnimDict(Config.PunchAnimation.dict)
                    while not HasAnimDictLoaded(Config.PunchAnimation.dict) do
                        Citizen.Wait(0)
                    end

                    TaskPlayAnim(npc, Config.PunchAnimation.dict, Config.PunchAnimation.anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                    Citizen.Wait(5000)
                    TaskStartScenarioInPlace(npc, Config.NPCAnimation.dict, 0, true)
                end
            else
                break
            end
        end
    end)
end