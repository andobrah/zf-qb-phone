local CasinoTable = {}
local BetNumber = 0
local CasinoBetList = {}
local casino_status = true


-- Events
RegisterNetEvent('qb-phone:server:CasinoAddBet', function(data)
    BetNumber += 1
    CasinoTable[BetNumber] = {['Name'] = data.name, ['chanse'] = data.chanse, ['id'] = BetNumber}
    TriggerClientEvent('qb-phone:client:addbetForAll', -1, CasinoTable)
end)

RegisterNetEvent('qb-phone:server:BettingAddToTable', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(data.amount)
    local CSN = Player.PlayerData.citizenid
    if casino_status then
        if Player.Functions.GetMoney('bank') >= amount then
            if not CasinoBetList[CSN] then
                Player.Functions.RemoveMoney('bank', amount, "casino betting")
                CasinoBetList[CSN] = {['csn'] = CSN, ['amount'] = amount, ['player'] = data.player, ['chanse'] = data.chanse, ['id'] = data.id}
            else
                PhoneNotify(src, 'Casino', 'You are already betting...', 'fas fa-info-circle', '#f25f5c')
            end
        else
            PhoneNotify(src, 'Casino', 'You do not have enough money!', 'fas fa-exclamation-circle', '#f25f5c')
        end
    else
        PhoneNotify(src, 'Casino', 'Betting is not active...', 'fas fa-exclamation-circle', '#f25f5c')
    end
end)

RegisterNetEvent('qb-phone:server:DeleteAndClearTable', function()
    local src = source
    CasinoTable = {}
    CasinoBetList = {}
    BetNumber = 0
    TriggerClientEvent('qb-phone:client:addbetForAll', -1, CasinoTable)
    PhoneNotify(src, 'Casino', 'Done...', 'fas fa-info-circle', '#247ba0')
end)

RegisterNetEvent('qb-phone:server:casino_status', function()
    casino_status = not casino_status
end)

RegisterNetEvent('qb-phone:server:WineridCasino', function(data)
    local winner = data.id
    for _, v in pairs(CasinoBetList) do
        if v.id == winner then
            local OtherPly = QBCore.Functions.GetPlayerByCitizenId(v.csn)
            if OtherPly then
                local amount = v.amount * v.chanse
                OtherPly.Functions.AddMoney('bank', tonumber(amount), "casino winner")
            end
        end
    end
end)


-- Callbacks
QBCore.Functions.CreateCallback('qb-phone:server:CheckHasBetTable', function(_, cb)
    cb(CasinoTable)
end)

QBCore.Functions.CreateCallback('qb-phone:server:CheckHasBetStatus', function(_, cb)
    cb(casino_status)
end)
