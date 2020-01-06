local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local aircraftdealer
local isaircraftdealer
local StreamedaircraftdealerIds = { }
local aircraftdealerIds = { }
local carRetrieved

AddEvent("OnTranslationReady", function()
	aircraftdealer = Dialog.create(_("car_dealer"), nil, _("buy"), _("cancel"))
	Dialog.addSelect(aircraftdealer, 1, _("vehicle_list"), 10)
	Dialog.addSelect(aircraftdealer, 2, _("color"), 10)
end)

function OnKeyPress(key)
    if key == "E" and not onSpawn and not onCharacterCreation then
        local Nearestaircraftdealer = GetNearestaircraftdealer()
        if Nearestaircraftdealer ~= 0 then
            CallRemoteEvent("aircraftdealerInteract", Nearestaircraftdealer)
		end
	end
end
AddEvent("OnKeyPress", OnKeyPress)

AddEvent("OnDialogSubmit", function(dialog, button, ...)
	if dialog == aircraftdealer then
		local Nearestaircraftdealer = GetNearestaircraftdealer()
		local args = { ... }
		if button == 1 then
			if args[1] == "" or args[2] == "" then
				MakeNotification(_("select_car_to_buy"), "linear-gradient(to right, #ff5f6d, #ffc371)")
			else
				CallRemoteEvent("buyCarServer", args[1], args[2], Nearestaircraftdealer)
			end
        end
    end
end)

AddRemoteEvent("aircraftdealerSetup", function(aircraftdealerObject)
    aircraftdealerIds = aircraftdealerObject
end)

function GetNearestaircraftdealer()
	local x, y, z = GetPlayerLocation()
	
	for k,v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)

		if dist < 150.0 then
			for k,i in pairs(aircraftdealerIds) do
				if v == i then
					return v
				end
			end
		end
	end

	return 0
end

function tablefind(tab, el)
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end

function openaircraftdealer(lvehicles, lcolors)
	local cars = {}
	for k,v in pairs(lvehicles) do
		cars[k] = _(k).." ["..v.._("currency").."]"
	end
	local colors = {}
	for k,v in pairs(lcolors) do
		colors[k] = _(k)
	end
	Dialog.setSelectLabeledOptions(aircraftdealer, 1, 1, cars)
	Dialog.setSelectLabeledOptions(aircraftdealer, 2, 1, colors)
	Dialog.show(aircraftdealer)
end
AddRemoteEvent("openaircraftdealer", openaircraftdealer)
