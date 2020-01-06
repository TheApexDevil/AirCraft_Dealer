local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

aircraftdealerObjectsCached = { }
aircraftdealerTable = {
{
		vehicles = {
				vehicle_20 = 3000,

		},
		colors = {
			black = "0000",
			red = "FF0000",
			blue = "0000FF",
			green = "00FF00"

		},
		location = { 146692.203125, -135356.8125, 1249.2750244141 },
		spawn = { 144858.390625, -135687.5625, 1254.0810546875 }
    },
}
AddEvent("OnPackageStart", function()
	for k,v in pairs(aircraftdealerTable) do
		v.npc = CreateNPC(v.location[1], v.location[2], v.location[3], v.location[4])
		CreateText3D(_("aircraft_dealer").."\n".._("press_e"), 18, v.location[1], v.location[2], v.location[3] + 120, 0, 0, 0)

		table.insert(aircraftdealerObjectsCached, v.npc)
	end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "aircraftdealerSetup", aircraftdealerObjectsCached)
end)

AddRemoteEvent("aircraftdealerInteract", function(player, aircraftdealerobject)
    local aircraftdealer = GetaircraftDealearByObject(aircraftdealerobject)
	if aircraftdealer then
		local x, y, z = GetNPCLocation(aircraftdealer.npc)
		local x2, y2, z2 = GetPlayerLocation(player)
        local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 150 then
			for k,v in pairs(aircraftdealerTable) do
				if aircraftdealerobject == v.npc then
					CallRemoteEvent(player, "openaircraftdealer", v.vehicles, v.colors)
				end
			end

		end
	end
end)

function GetaircraftDealearByObject(aircraftdealerobject)
	for k,v in pairs(aircraftdealerTable) do
		if v.npc == aircraftdealerobject then
			return v
		end
	end
	return nil
end

function CreateVehicleDatabase(player, vehicle, modelid, color, price)
    local query = mariadb_prepare(sql, "INSERT INTO player_garage (id, ownerid, modelid, color, garage, price) VALUES (NULL, '?', '?', '?', '0', '?');",
        tostring(PlayerData[player].accountid),
        tostring(modelid),
        tostring(color),
        tostring(price)
    )

    mariadb_async_query(sql, query, onVehicleCreateDatabase, vehicle)
end

function onVehicleCreateDatabase(vehicle)
    VehicleData[vehicle].garageid = mariadb_get_insert_id()
end

function buyaircraftServer(player, modelid, color, aircraftdealerobject)
	local name = _(modelid)
	local price = getVehiclePrice(modelid, aircraftdealerobject)
	local color = getVehicleColor(color, aircraftdealerobject)
	local modelid = getVehicleId(modelid)

	if tonumber(price) > GetPlayerCash(player) then
        CallRemoteEvent(player, "MakeNotification",_("no_money_aircraft"), "linear-gradient(to right, #ff5f6d, #ffc371)")
    else
        local x, y, z = GetPlayerLocation(player)

        for k,v in pairs(aircraftdealerTable) do
            local x2, y2, z2 = GetNPCLocation(v.npc)
            local dist = GetDistance3D(x, y, z, x2, y2, z2)
            if dist < 150.0 then
                local isSpawnable = true
                for k,w in pairs(GetAllVehicles()) do
                    local x3, y3, z3 = GetVehicleLocation(w)
                    local dist2 = GetDistance3D(v.spawn[1], v.spawn[2], v.spawn[3], x3, y3, z3)
                    if dist2 < 1000.0 then
                      isSpawnable = false
                      break
                    end
                end
                if isSpawnable then
                    local vehicle = CreateVehicle(modelid, v.spawn[1], v.spawn[2], v.spawn[3], v.spawn[4])
                    SetVehicleRespawnParams(vehicle, false)
                    SetVehicleColor(vehicle, "0x"..color)
                    SetVehiclePropertyValue(vehicle, "locked", true, true)
                    CreateVehicleData(player, vehicle, modelid)
                    CreateVehicleDatabase(player, vehicle, modelid, color, price)
                    RemovePlayerCash(player, price)
                    CallRemoteEvent(player, "closeaircraftdealer")
                    return CallRemoteEvent(player, "MakeNotification", _("aircraft_buy_sucess", name, price, _("currency")), "linear-gradient(to right, #00b09b, #96c93d)")
                else
                    return CallRemoteEvent(player, "MakeNotification", _("cannot_spawn_vehicle"), "linear-gradient(to right, #ff5f6d, #ffc371)")
                end
            end
        end
    end
end
AddRemoteEvent("buyaircraftServer", buyaircraftServer)
