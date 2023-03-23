-- Functions
local function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end


-- Events
RegisterNetEvent('qb-phone:server:sendVehicleRequest', function(data)
    local src = source
    local Seller = QBCore.Functions.GetPlayer(src)
    local Buyer = QBCore.Functions.GetPlayer(tonumber(data.id))

    if not Buyer then PhoneNotify(src, 'Vehicle Sale', 'Buyer was not found.', 'fas fa-exclamation-circle', '#f25f5c') return end
    if not data.price or not data.plate then return end
    if Player.PlayerData.citizenid == OtherAsshole.PlayerData.citizenid then PhoneNotify(src, 'Vehicle Sale', 'You can\'t sell a vehicle to yourself.', 'fas fa-exclamation-circle', '#f25f5c') return end

    TriggerClientEvent('qb-phone:client:sendVehicleRequest', Asshole, data, Player)
end)

RegisterNetEvent('qb-phone:server:sellVehicle', function(data, Seller, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SellerData = QBCore.Functions.GetPlayerByCitizenId(Seller.PlayerData.citizenid)

    if type == 'accepted' then
        if Player.Functions.GetMoney('bank') and Player.Functions.GetMoney('bank') >= tonumber(data.price) then
            Player.Functions.RemoveMoney('bank', data.price, "vehicle sale")
            SellerData.Functions.AddMoney('bank', data.price)            
            PhoneNotify(src, 'Vehicle Sale', 'You purchased the vehicle for $' .. data.price, 'fas fa-check-circle', '#70c1b3')
            PhoneNotify(Seller.PlayerData.source, 'Vehicle Sale', 'Your vehicle was successfully purchased', 'fas fa-check-circle', '#70c1b3')

            MySQL.update('UPDATE player_vehicles SET citizenid = ?, garage = ?, state = ? WHERE plate = ?',{Player.PlayerData.citizenid, Config.SellGarage, 1, data.plate})
            -- Update Garages
            TriggerClientEvent('qb-phone:client:updateGarages', src)
            TriggerClientEvent('qb-phone:client:updateGarages', Seller.PlayerData.source)
        else
            PhoneNotify(src, 'Vehicle Sale', 'Insufficient Funds', 'fas fa-exclamation-circle', '#f25f5c')
            PhoneNotify(Seller.PlayerData.source, 'Vehicle Sale', 'Your vehicle was not purchased', 'fas fa-exclamation-circle', '#f25f5c')
        end
    elseif type == 'denied' then
        PhoneNotify(src, 'Vehicle Sale', 'Request denied', 'fas fa-exclamation-circle', '#f25f5c')
        PhoneNotify(Seller.PlayerData.source, 'Vehicle Sale', 'Your sale request was denied', 'fas fa-exclamation-circle', '#f25f5c')
    end
end)


-- Callbacks
QBCore.Functions.CreateCallback('qb-phone:server:GetGarageVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}
    local vehdata
    local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if result[1] then
        for _, v in pairs(result) do
            local VehicleData = QBCore.Shared.Vehicles[v.vehicle]
            local VehicleGarage = "None"
            local enginePercent = round(v.engine / 10, 0)
            local bodyPercent = round(v.body / 10, 0)
            if v.garage then
                if Config.Garages[v.garage] then
                    VehicleGarage = Config.Garages[v.garage]["label"]
                else
                    VehicleGarage = v.garage
                end
            end

            local VehicleState = "In"
            if v.state == 0 then
                VehicleState = "Out"
            elseif v.state == 2 then
                VehicleState = "Impounded"
            end

            if VehicleData["brand"] then
                vehdata = {
                    fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                    brand = VehicleData["brand"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = enginePercent,
                    body = bodyPercent,
                    paymentsleft = v.paymentsleft
                }
            else
                vehdata = {
                    fullname = VehicleData["name"],
                    brand = VehicleData["name"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = enginePercent,
                    body = bodyPercent,
                    paymentsleft = v.paymentsleft
                }
            end
            Vehicles[#Vehicles+1] = vehdata
        end
        cb(Vehicles)
    else
        cb(nil)
    end
end)
