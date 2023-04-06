QBCore = exports[Config.Exports.Core]:GetCoreObject()

RegisterNetEvent('QBCore:Client:UpdateObject', function()
	QBCore = exports[Config.Exports.Core]:GetCoreObject()
	
	SendNUIMessage({
		action = "UpdateChat",
		jobs = QBCore.Shared.Jobs
	    })
end)
