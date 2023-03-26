QBCore = exports[Config.Exports.Core]:GetCoreObject()
Webhook = '' -- Set your discord Webhook here for screenshots (Not GoPro Camera)

RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	QBCore = exports[Config.Exports.Core]:GetCoreObject()
end)

function PhoneNotify(source, title, message, icon, color, timeout)
    TriggerClientEvent('qb-phone:client:CustomNotification', source, title, message, icon, color, timeout or 5000)
end

function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        MySQL.query.await('DELETE FROM phone_tweets WHERE `date` < NOW() - INTERVAL ? hour', {Config.TweetDuration})
        MySQL.query.await('DELETE FROM player_mails WHERE `date` < NOW() - INTERVAL ? hour', {Config.MailDuration})
    end
end)

QBCore.Commands.Add("setmetadata", "Set Player Metadata (God Only)", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if args[1] then
        if args[1] == "trucker" then
            if args[2] then
                local newrep = Player.PlayerData.metadata["jobrep"]
                newrep.trucker = tonumber(args[2])
                Player.Functions.SetMetaData("jobrep", newrep)
            end
        end
    end
end, "god")

QBCore.Commands.Add("p#", "Provide Phone Number", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerPed = GetPlayerPed(src)
    local number = Player.PlayerData.charinfo.phone
	local PlayerCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		local TargetPed = GetPlayerPed(v)
		local dist = #(PlayerCoords - GetEntityCoords(TargetPed))

		if dist < 3.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 255, 0, 0},
                multiline = true,
                args = {"Phone #", number}
            })
		end
	end
end)

QBCore.Functions.CreateCallback("qb-phone:server:GetWebhook",function(_, cb)
	cb(WebHook)
end)