local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L
local GetNameServer = DogTag_Unit.GetNameServer

local offlineTimes = {}
local afkTimes = {}
local deadTimes = {}

local iterateGroupMembers
local iterateGroupMembers__t = {}
do
	function iterateGroupMembers()
		return pairs(iterateGroupMembers__t)
	end
end

local tmp = {}
DogTag:AddEventHandler("PARTY_MEMBERS_CHANGED", function(event)
	local prefix, min, max = "raid", 1, GetNumRaidMembers()
	if max == 0 then
		prefix, min, max = "party", 0, GetNumPartyMembers()
	end
	
	for i = min, max do
		local unit
		if i == 0 then
			unit = 'player'
		else
			unit = prefix .. i
		end
		
		if not UnitExists(unit) then
			break
		end
		
		iterateGroupMembers__t[unit] = UnitGUID(unit)
	end
	
	for unit, guid in iterateGroupMembers() do
		tmp[guid] = true
		
		if not UnitIsConnected(unit) then
			if not offlineTimes[guid] then
				offlineTimes[guid] = GetTime()
			end
			afkTimes[guid] = nil
		else
			offlineTimes[guid] = nil
			if UnitIsAFK(unit) then
				if not afkTimes[guid] then
					afkTimes[guid] = GetTime()
				end
			else
				afkTimes[guid] = nil
			end
		end
		if UnitIsDeadOrGhost(unit) then
			if not deadTimes[guid] then
				deadTimes[guid] = GetTime()
			end
		else
			deadTimes[guid] = nil
		end
	end
	
	for guid in pairs(offlineTimes) do
		if not tmp[guid] then
			offlineTimes[guid] = nil
		end
	end
	for guid in pairs(deadTimes) do
		if not tmp[guid] then
			deadTimes[guid] = nil
		end
	end
	for guid in pairs(afkTimes) do
		if not tmp[guid] then
			afkTimes[guid] = nil
		end
	end
	for guid in pairs(tmp) do
		tmp[guid] = nil
	end
end)

DogTag:AddTimerHandler(function(currentTime, num)
	for guid in pairs(offlineTimes) do
		for unit in DogTag_Unit.IterateUnitsWithGUID(guid) do
			DogTag:FireEvent("OfflineDuration", unit)
		end
	end
	for unit, guid in iterateGroupMembers() do
		if UnitIsDeadOrGhost(unit) then
			if not deadTimes[guid] then
				deadTimes[guid] = GetTime()
			end
		else
			deadTimes[guid] = nil
		end
		
		if UnitIsAFK(unit) then
			if not afkTimes[guid] then
				afkTimes[guid] = GetTime()
			end
		else
			afkTimes[guid] = nil
		end
	end
	for guid in pairs(deadTimes) do
		for unit in DogTag_Unit.IterateUnitsWithGUID(guid) do
			DogTag:FireEvent("DeadDuration", unit)
		end
	end
	for guid in pairs(afkTimes) do
		for unit in DogTag_Unit.IterateUnitsWithGUID(guid) do
			DogTag:FireEvent("AFKDuration", unit)
		end
	end
end)

DogTag:AddTag("Unit", "OfflineDuration", {
	code = function(unit)
		local t = offlineTimes[UnitGUID(unit)]
		if not t then
			return nil
		else
			return GetTime() - t
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "number;nil",
	events = "OfflineDuration#$unit",
	doc = L["Return the duration offline if unit is offline"],
	example = ('[OfflineDuration] => "110"; [OfflineDuration:FormatDuration] => "1:50"'),
	category = L["Status"]
})

DogTag:AddTag("Unit", "Offline", {
	alias = ("Concatenate(%q, ' ', OfflineDuration:FormatDuration:Paren)"):format(L["Offline"]),
	doc = L["Return Offline and the time offline if unit is offline"],
	example = ('[Offline] => "%s (2:45)"; [Offline] => ""'):format(L["Offline"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "DeadDuration", {
	code = function(unit)
		local t = deadTimes[UnitGUID(unit)]
		if not t then
			return nil
		else
			return GetTime() - t
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "number;nil",
	events = "DeadDuration#$unit",
	doc = L["Return the duration dead if unit is dead and time is known, unit can be dead and have an unknown time of death"],
	example = ('[DeadDuration] => "110"; [DeadDuration:FormatDuration] => "1:50"'),
	category = L["Status"]
})

DogTag:AddTag("Unit", "DeadType", {
	code = function(unit)
		if UnitIsGhost(unit) then
			return L["Ghost"]
		elseif UnitIsDead(unit) then
			return L["Dead"]
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	events = "DeadDuration#$unit",
	doc = L["Return Dead or Ghost if unit is dead"],
	example = ('[DeadType] => "%s"; [DeadType] => "%s"; [DeadType] => ""'):format(L["Dead"], L["Ghost"]),
	category = L["Status"],
})

DogTag:AddTag("Unit", "Dead", {
	alias = "DeadType(unit=unit) Concatenate(' ', DeadDuration(unit=unit):FormatDuration:Paren)",
	arg = {
		'unit', 'string', '@req',
	},
	doc = L["Return Dead or Ghost and the duration dead if unit is dead"],
	example = ('[Dead] => "%s (1:34)"; [Dead] => "%s"; [Dead] => ""'):format(L["Dead"], L["Ghost"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "AFKDuration", {
	code = function(unit)
		local t = afkTimes[UnitGUID(unit)]
		if not t then
			return nil
		else
			return GetTime() - t
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "number;nil",
	events = "AFKDuration#$unit",
	doc = L["Return the duration AFK if unit is AFK"],
	example = ('[AFKDuration] => "110"; [AFKDuration:FormatDuration] => "1:50"'),
	category = L["Status"]
})

DogTag:AddTag("Unit", "AFK", {
	alias = ("Concatenate(%q, ' ', AFKDuration:FormatDuration:Paren)"):format(L["AFK"]),
	doc = L["Return AFK and the time AFK if unit is AFK"],
	example = ('[AFK] => "%s (2:12)"; [AFK] => ""'):format(L["AFK"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "DND", {
	code = function(unit)
		if UnitIsDND(unit) then
			return L["DND"]
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	events = "PLAYER_FLAGS_CHANGED#$unit",
	doc = L["Return DND if the unit has specified DND"],
	example = ('[DND] => %q; [DND] => ""'):format(L["DND"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "PvP", {
	code = function(unit)
		if UnitIsPVPFreeForAll(unit) then
			return L["FFA"]
		elseif UnitIsPVP(unit) then
			return L["PvP"]
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Return PvP or FFA if the unit is PvP-enabled"],
	example = ('[PvP] => %q; [PvP] => %q; [PvP] => ""'):format(L["PvP"], L["FFA"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsResting", {
	code = IsResting,
	ret = "boolean",
	events = "PLAYER_UPDATE_RESTING",
	doc = L["Return True if you are in an inn or capital city"],
	example = ('[IsResting] => %q; [IsResting] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsLeader", {
	code = UnitIsPartyLeader,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	doc = L["Return True if unit is a party leader"],
	example = ('[IsLeader] => %q; [IsLeader] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsFeignedDeath", {
	code = UnitIsFeignDeath,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	doc = L["Return True if unit is feigning death"],
	example = ('[IsFeignedDeath] => "%q"; [IsFeignedDeath] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "HappyNum", {
	code = function()
		return GetPetHappiness() or 0
	end,
	ret = "number",
	events = "UNIT_HAPPINESS",
	doc = L["Return the happiness number of your pet"],
	example = '[HappyNum] => "3"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "HappyText", {
	code = function()
		return _G["PET_HAPPINESS" .. (GetPetHappiness() or 0)]
	end,
	ret = "number",
	events = "UNIT_HAPPINESS",
	doc = L["Return a description of how happy your pet is"],
	example = ('[HappyText] => %q'):format(_G.PET_HAPPINESS3),
	category = L["Status"]
})

DogTag:AddTag("Unit", "HappyIcon", {
	code = function(happy, content, unhappy)
		local num = GetPetHappiness()
		if num == 3 then
			return happy
		elseif num == 2 then
			return content
		elseif num == 1 then
			return unhappy
		end
	end,
	arg = {
		'happy', 'string', ':D',
		'content', 'string', ':I',
		'unhappy', 'string', 'B(',
	},
	ret = "string;nil",
	events = "UNIT_HAPPINESS",
	doc = L["Return an icon representative of how happy your pet is"],
	example = ('[HappyIcon] => ":D"; [HappyIcon] => ":I"; [HappyIcon] => "B("'),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsTappedByMe", {
	code = UnitIsTappedByPlayer,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	events = "Update",
	doc = L["Return True if unit is tapped by you"],
	example = '[IsTappedByMe] => "True"; [IsTappedByMe] => ""',
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsTapped", {
	code = function(unit)
		return UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	events = "Update",
	doc = L["Return * if unit is tapped, but not by you"],
	example = ('[IsTapped] => %q; [IsTapped] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "InCombat", {
	code = UnitAffectingCombat,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	events = "Update",
	doc = L["Return True if unit is in combat"],
	example = ('[InCombat] => %q; [InCombat] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "FKey", {
	code = function(unit)
		local fkey
		if UnitIsUnit(unit, "player") then
			return "F1"
		else
			for i = 1, 4 do
				if UnitIsUnit(unit, "party" .. i) then
					return "F" .. (i+1)
				end
			end
		end
		return nil
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Return the function key to press to select unit"],
	example = '[FKey] => "F5"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "RaidGroup", {
	code = function(unit)
		local n, s = UnitName(unit)
		if s and s ~= "" then
			n = n .. "-" .. s
		end
		for i = 1, GetNumRaidMembers() do
			local name, rank, subgroup = GetRaidRosterInfo(i)
			if name == n then
				return subgroup
			end
		end
		return nil
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "number;nil",
	doc = L["Return the raid group that unit is in"],
	example = '[RaidGroup] => "3"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsMasterLooter", {
	code = function(unit)
		local n, s = UnitName(unit)
		if s and s ~= "" then
			n = n .. "-" .. s
		end
		for i = 1, GetNumRaidMembers() do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			if name == n then
				return true
			end
		end
		return false
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	doc = L["Return True if unit is the master looter for your raid"],
	example = ('[IsMasterLooter] => %q; [IsMasterLooter] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "Target", {
	code = function(unit)
		if unit == "player" then
			return "target"
		else
			return unit .. "target"
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string",
	doc = L["Return the unit id of unit's target"],
	example = '[Target] => "party1target"; [HP(unit=Target)] => "1000"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "Pet", {
	code = function(unit)
		if unit == "player" then
			return "pet"
		elseif unit:match("^party%d$") then
			return "partypet" .. unit:match("(%d+)")
		elseif unit:match("^raid%d$") then
			return "raidpet" .. unit:match("(%d+)")
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	doc = L["Return the unit id of unit's pet"],
	example = '[Pet] => "partypet1"; [HP(unit=Pet)] => "500"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "NumTargeting", {
	code = function(unit)
		local num = 0
		for u in iterateGroupMembers() do
			if UnitIsUnit(u .. "target", unit) then
				num = num + 1
			end
		end
		return num
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "number",
	events = "UNIT_TARGET;Update",
	doc = L["Return the number of group members currently targeting unit"],
	example = '[NumTargeting] => "2"',
	category = L["Status"]
})

local t = {}
DogTag:AddTag("Unit", "TargetingList", {
	code = function(unit)
		for u in iterateGroupMembers() do
			if UnitIsUnit(u .. "target", unit) then
				local name = GetNameServer(u)
				t[#t+1] = name
			end
		end
		table.sort(t)
		local s = table.concat(t, ", ")
		for k in pairs(t) do
			t[k] = nil
		end
		return s
	end,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	events = "UNIT_TARGET;Update",
	doc = L["Return an alphabetized, comma-separated list of group members currently targeting unit"],
	example = '[TargetingList] => "Grommash, Thrall"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "InGroup", {
	code = function()
		return GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0
	end,
	ret = "boolean",
	doc = L["Return True if you are in a party or raid"],
	example = ('[InGroup] => %q; [InGroup] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsUnit", {
	code = UnitIsUnit,
	arg = {
		'other', 'string', '@req',
		'unit', 'string', '@req',
	},
	ret = "boolean",
	events = "UNIT_FACTION#$unit",
	doc = L["Return True if unit is the same as argument"],
	example = ('[IsUnit("target")] => %q; [IsUnit("party1")] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsCharmed", {
	code = UnitIsCharmed,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	events = "UNIT_FACTION#$unit",
	doc = L["Return True if unit is under mind control"],
	example = ('[IsCharmed] => %q; [IsCharmed] => ""'):format(L["True"]),
	category = L["Status"]
})

DogTag:AddTag("Unit", "IsVisible", {
	code = UnitIsVisible,
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	events = "UNIT_PORTRAIT_UPDATE",
	doc = L["Return True if unit is in visible range"],
	example = ('[IsVisible] => %q; [IsVisible] => ""'):format(L["True"]),
	category = L["Status"]
})


DogTag:AddTag("Unit", "StatusColor", {
	code = function(value, unit)
		local r, g, b
		if not UnitIsConnected(unit) then
			r, g, b = unpack(DogTag.__colors.disconnected)
		elseif UnitIsDeadOrGhost(unit) then
			r, g, b = unpack(DogTag.__colors.dead)
		end
		if r then
			if value then
				return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
			else
				return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
			end
		else
			return value
		end
	end,
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	events = "DeadDuration#$unit",
	doc = L["Return the color or wrap value with the color associated with unit's current status"],
	example = '[Text(Hello):StatusColor] => "|cff7f7f7fHello|r"; [Text([StatusColor]Hello)] => "|cff7f7f7fHello"',
	category = L["Status"]
})

DogTag:AddTag("Unit", "HappyColor", {
	code = function(value)
		local x = GetPetHappiness()
		local r,g,b
		if x == 3 then
			r,g,b = unpack(DogTag.__colors.petHappy)
		elseif x == 2 then
			r,g,b = unpack(DogTag.__colors.petNeutral)
		elseif x == 1 then
			r,g,b = unpack(DogTag.__colors.petAngry)
		end
		if r then
			if value then
				return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
			else
				return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
			end
		else
			return value
		end
	end,
	arg = {
		'value', 'string;undef', "@undef",
	},
	ret = "nil;string",
	events = "UNIT_HAPPINESS",
	doc = L["Return the color or wrap value with the color associated with your pet's happiness"],
	example = '[Text(Hello):HappyColor] => "|cff00ff00Hello|r"; [Text([HappyColor]Hello)] => "|cff00ff00Hello"',
	category = L["Status"]
})

local DIVINE_INTERVENTION = GetSpellInfo(19752)
DogTag:AddTag("Unit", "Status", {
	alias = ("Offline(unit=unit) or (HasDivineIntervention(unit=unit) ? %q) or (IsFeignedDeath(unit=unit) ? %q) or [if Dead(unit=unit) then ((HasSoulstone(unit=unit) ? %q) or Dead(unit=unit))]"):format(DIVINE_INTERVENTION, L["Feigned Death"], L["Soulstoned"]),
	arg = {
		'unit', 'string', '@req',
	},
	doc = L["Return whether unit is offline, has divine intervention, is dead, feigning death, or has a soulstone while dead"],
	example = ('[Status] => "Offline"; [Status] => "Dead"; [Status] => ""'),
	category = L["Status"]
})

end