local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("@project-date-integer@"):match("%d+")) or 33333333333333

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

local _G, pairs, wipe, tonumber, GetTime = _G, pairs, wipe, tonumber, GetTime
local UnitName, UnitGUID, UnitCastingInfo, UnitChannelInfo, CastingInfo, ChannelInfo, UnitCastingDuration, UnitChannelDuration, UnitSpellTargetName =
	  UnitName, UnitGUID, UnitCastingInfo, UnitChannelInfo, CastingInfo, ChannelInfo, UnitCastingDuration, UnitChannelDuration, UnitSpellTargetName

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local newList = DogTag.newList
local del = DogTag.del
local castData = {}
local UnitGUID = UnitGUID
local IsNormalUnit = DogTag_Unit.IsNormalUnit
local issecretvalue = DogTag.issecretvalue
local hasSecrets = C_Secrets and C_Secrets.HasSecretRestrictions()

local wow_ver = select(4, GetBuildInfo())
local cast_api_has_ranks = wow_ver < 80000 and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local playerGuid = nil
local trackedUnits = {}
DogTag:AddEventHandler("Unit", "PLAYER_LOGIN", function()
	playerGuid = UnitGUID("player")
end)

local nextSpell, nextRank, nextTarget
local function populateCastData(event, unit, data)
	local guid = UnitGUID(unit)
	if not guid then
		return false
	end

	local spell, rank, displayName, icon, startTime, endTime, _, spellID
	local channeling = false
	if UnitCastingInfo then
		if cast_api_has_ranks then
			spell, rank, displayName, icon, startTime, endTime = UnitCastingInfo(unit)
			if not spell then
				spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)
				channeling = true
			end
		else
			spell, displayName, icon, startTime, endTime, _, _, _, spellID = UnitCastingInfo(unit)
			rank = nil
			if not spell then
				spell, displayName, icon, startTime, endTime, _, _, spellID = UnitChannelInfo(unit)
				channeling = true
			end
		end
	elseif CastingInfo then
		-- Classic only has an API for player spellcasts. No API for arbitrary units.
		if unit == "player" then
			spell, displayName, icon, startTime, endTime, _, _, _, spellID = CastingInfo()
			rank = nil
			if not spell then
				spell, displayName, icon, startTime, endTime, _, _, spellID = ChannelInfo()
				channeling = true
			end
		end
	end

	local durationFunc = channeling and UnitChannelDuration or UnitCastingDuration
	if durationFunc then
		data.duration = durationFunc(unit)
	end

	if spell then
		data.spell = spell
		rank = rank and tonumber(rank:match("%d+"))
		data.rank = rank
		local oldStart = data.startTime
		if not issecretvalue(startTime) then
			startTime = startTime * 0.001
		end
		data.startTime = startTime
		data.endTime = issecretvalue(endTime) and endTime or endTime * 0.001
		if not issecretvalue(startTime) and (event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then
			data.delay = (data.delay or 0) + (startTime - (oldStart or startTime))
		else
			data.delay = 0
		end
		if UnitSpellTargetName then
			data.target = UnitSpellTargetName(unit)
		elseif not issecretvalue(guid) and guid == playerGuid
			and not issecretvalue(spellID) and spellID == nextSpell
			and rank == nextRank then
			data.target = nextTarget
		end
		data.casting = not channeling
		data.channeling = channeling
		data.fadeOut = false
		data.stopTime = nil
		data.stopMessage = nil
		return true
	end

	if not data.spell then
		return true
	end

	if event == "UNIT_SPELLCAST_FAILED" then
		data.stopMessage = _G.FAILED
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		data.stopMessage = _G.INTERRUPTED
	end

	data.casting = false
	data.channeling = false
	data.fadeOut = true
	if not data.stopTime then
		data.stopTime = GetTime()
	end

	return true
end

local castEventIsSetup = false
DogTag:AddEventHandler("Unit", "EventRequested", function(_, event)
	if event ~= "Cast" or castEventIsSetup then return end
	castEventIsSetup = true

	local function updateInfo(event, unit)
		local guid = UnitGUID(unit)
		if not guid then
			return
		end
		if hasSecrets then
			trackedUnits[unit] = true
			DogTag:FireEvent("Cast", unit)
			return
		end
		local data = castData[guid]
		if not data then
			data = newList()
			castData[guid] = data
		end

		if not populateCastData(event, unit, data) then
			return
		end

		if not data.spell then
			castData[guid] = del(data)
		end

		DogTag:FireEvent("Cast", unit)
	end

	local guidsToFire, unitsToUpdate = {}, {}
	local function fixCastData()
		if hasSecrets then
			for unit, _ in pairs(trackedUnits) do
				DogTag:FireEvent("Cast", unit)
			end
			return
		end

		local currentTime = GetTime()
		for guid, data in pairs(castData) do
			if data.casting then
				if currentTime > data.endTime and playerGuid ~= guid then
					data.casting = false
					data.fadeOut = true
					data.stopTime = currentTime
				end
			elseif data.channeling then
				if currentTime > data.endTime then
					data.channeling = false
					data.fadeOut = true
					data.stopTime = currentTime
				end
			elseif data.fadeOut then
				local alpha = 0
				local stopTime = data.stopTime
				if stopTime then
					alpha = stopTime - currentTime + 1
				end

				if alpha <= 0 then
					castData[guid] = del(data)
				end
			else
				castData[guid] = del(data)
			end
			local found = false
			local normal = false
			for unit in DogTag_Unit.IterateUnitsWithGUID(guid) do
				found = unit
				if IsNormalUnit[unit] then
					normal = true
					break
				end
			end
			if not found then
				if castData[guid] then
					castData[guid] = del(data)
				end
			else
				if not normal then
					unitsToUpdate[found] = true
				end

				guidsToFire[guid] = true
			end
		end
		for unit in pairs(unitsToUpdate) do
			updateInfo(nil, unit)
		end
		wipe(unitsToUpdate)
		for guid in pairs(guidsToFire) do
			for unit in DogTag_Unit.IterateUnitsWithGUID(guid) do
				DogTag:FireEvent("Cast", unit)
			end
		end
		wipe(guidsToFire)
	end
	DogTag:AddTimerHandler("Unit", fixCastData)

	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_START", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_CHANNEL_START", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_STOP", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_FAILED", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_INTERRUPTED", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_DELAYED", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_CHANNEL_UPDATE", updateInfo)
	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_CHANNEL_STOP", updateInfo)
	DogTag:AddEventHandler("Unit", "UnitChanged", updateInfo)

	DogTag:AddEventHandler("Unit", "UNIT_SPELLCAST_SENT", function(event, unit, target, castGUID, spellID)

		-- The purpose of this event is to predict the next spell target.
		if unit == "player" then
			nextSpell = spellID
			nextTarget = target
		end
	end)

end)

local blank = {}
local function getCastData(unit)
	local guid = UnitGUID(unit)
	if not guid then
		return blank
	end

	if hasSecrets then
		local data = newList()
		populateCastData(nil, unit, data)
		return data
	end

	return castData[guid] or blank
end

DogTag:AddTag("Unit", "CastName", {
	code = function(unit)
		return getCastData(unit).spell
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	events = "Cast#$unit",
	doc = L["Return the current or last spell to be cast"],
	example = ('[CastName] => %q'):format(L["Holy Light"]),
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastTarget", {
	code = function(unit)
		return getCastData(unit).target
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	events = "Cast#$unit",
	doc = L["Return the current cast target name"],
	example = ('[CastTarget] => %q'):format((UnitName("player"))),
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastRank", {
	code = function(unit)
		return getCastData(unit).rank
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = "Cast#$unit",
	doc = L["Return the current cast rank"],
	example = '[CastRank] => "4"; [CastRank:Romanize] => "IV"',
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastStartDuration", {
	code = function(unit)
		local data = getCastData(unit)
		if data.duration then
			return data.duration:GetElapsedDuration()
		end
		local t = data.startTime
		if t then
			return GetTime() - t
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = "Cast#$unit",
	doc = L["Return the duration since the current cast started"],
	example = '[CastStartDuration] => "3.012367"; [CastStartDuration:FormatDuration] => "0:03"',
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastEndDuration", {
	code = function(unit)
		local data = getCastData(unit)
		if data.duration then
			return data.duration:GetRemainingDuration()
		end
		local t = data.endTime
		if t then
			return t - GetTime()
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = "Cast#$unit",
	globals = "DogTag.__castData",
	doc = L["Return the duration until the current cast is meant to finish"],
	example = '[CastEndDuration] => "2.07151"; [CastEndDuration:FormatDuration] => "0:02"',
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastDelay", {
	code = function(unit)
		return getCastData(unit).delay
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = "Cast#$unit",
	doc = L["Return the number of seconds the current cast has been delayed by interruption"],
	example = '[CastDelay] => "1.49997"; [CastDelay:Round(1)] => "1.5"',
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastIsChanneling", {
	code = function(unit)
		return getCastData(unit).channeling
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "boolean",
	events = "Cast#$unit",
	doc = L["Return True if the current cast is a channeling spell"],
	example = ('[CastIsChanneling] => %q; [CastIsChanneling] => ""'):format(L["True"]),
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastStopDuration", {
	code = function(unit)
		local t = getCastData(unit).stopTime
		if t then
			return GetTime() - t
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = "Cast#$unit",
	doc = L["Return the duration which the current cast has been stopped, blank if not stopped yet"],
	example = '[CastStopDuration] => "2.06467"; [CastStopDuration:FormatDuration] => "0:02"; [CastStopDuration] => ""',
	category = L["Casting"]
})

DogTag:AddTag("Unit", "CastStopMessage", {
	code = function(unit)
		return getCastData(unit).stopMessage
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	events = "Cast#$unit",
	doc = L["Return the message as to why the cast stopped, if there is an error"],
	example = ('[CastStopMessage] => %q; [CastStopMessage] => %q, [CastStopMessage] => ""'):format(_G.FAILED, _G.INTERRUPTED),
	category = L["Casting"]
})

end
