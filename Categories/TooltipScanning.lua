local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("@project-date-integer@"):match("%d+")) or 33333333333333

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

local _G, ipairs, type, GetTime = _G, ipairs, type, GetTime
local UnitName, UnitFactionGroup, UnitPlayerControlled, UnitIsPlayer, UnitIsVisible, UnitIsConnected, UnitPlayerControlled =
	  UnitName, UnitFactionGroup, UnitPlayerControlled, UnitIsPlayer, UnitIsVisible, UnitIsConnected, UnitPlayerControlled
local InCombatLockdown, GetNumFactions, GetFactionInfo, ExpandFactionHeader, CollapseFactionHeader, GetGuildInfo =
	  InCombatLockdown, GetNumFactions, GetFactionInfo, ExpandFactionHeader, CollapseFactionHeader, GetGuildInfo

local GetClassicExpansionLevel = GetClassicExpansionLevel

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L
local issecretvalue = DogTag.issecretvalue

local tt
if not C_TooltipInfo then
	tt = CreateFrame("GameTooltip", "LibDogTag-Unit-3.0-"..MAJOR_VERSION.."."..MINOR_VERSION)
	tt:SetOwner(WorldFrame, "ANCHOR_NONE")
	tt.left = {}
	tt.right = {}
	for i = 1, 30 do
		tt.left[i] = tt:CreateFontString()
		tt.left[i]:SetFontObject(GameFontNormal)
		tt.right[i] = tt:CreateFontString()
		tt.right[i]:SetFontObject(GameFontNormal)
		tt:AddFontStrings(tt.left[i], tt.right[i])
	end
end
local nextTime = 0
local lastName
local lastUnit
local function updateTT(unit)
	if C_TooltipInfo then
		local tooltipData = C_TooltipInfo.GetUnit(unit)
		if TooltipUtil.SurfaceArgs then
			TooltipUtil.SurfaceArgs(tooltipData)
			for _, line in ipairs(tooltipData.lines) do
				TooltipUtil.SurfaceArgs(line)
			end
		end

		return tooltipData
	end

	local name = UnitName(unit)
	local time = GetTime()
	if lastUnit == unit and lastName == name and nextTime < time then
		return
	end
	-- Parnic: temp: don't do any of this while Wrath Classic is crashing in these functions under certain conditions.
	-- https://github.com/parnic/LibDogTag-Unit-3.0/issues/8
	if InCombatLockdown() and GetClassicExpansionLevel and GetClassicExpansionLevel() == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		return
	end
	lastUnit = unit
	lastName = name
	nextTime = time + 1
	tt:ClearLines()
	tt:SetUnit(unit)
	if not tt:IsOwned(WorldFrame) then
		tt:SetOwner(WorldFrame, "ANCHOR_NONE")
	end
end

-- tooltips can contain any data, including quest info, so check for the type of the line before using it, if present
local function TooltipLineCouldBeGuild(line)
	if not line then
		return false
	end
	if not Enum or not Enum.TooltipDataLineType then
		return false
	end

	return line.type == Enum.TooltipDataLineType.None
end

-- there's no special flag for factions vs guilds as of this writing, but if that gets added, this will make things easier
local function TooltipLineCouldBeFaction(line)
	return TooltipLineCouldBeGuild(line)
end

local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
local function FigureNPCGuild(unit)
	local info = updateTT(unit)
	local left_2
	if info then
		left_2 = info.lines[2] and info.lines[2].leftText or nil
	elseif tt then
		left_2 = tt.left[2] and tt.left[2]:GetText() or nil
	end
	if not left_2 or issecretvalue(left_2) or left_2:find(LEVEL_start) then
		return nil
	end
	if info and not TooltipLineCouldBeGuild(info.lines[2]) then
		return nil
	end
	return left_2
end

local factionList = {}

local PVP = type(PVP) == "string" and PVP or "PvP"
local function FigureFaction(unit)
	local _, faction = UnitFactionGroup(unit)
	if UnitPlayerControlled(unit) or UnitIsPlayer(unit) then
		return faction
	end

	local info = updateTT(unit)
	local left_2
	local left_3
	if info then
		left_2 = info.lines[2] and info.lines[2].leftText or nil
		left_3 = info.lines[3] and info.lines[3].leftText or nil
	elseif tt then
		left_2 = tt.left[2] and tt.left[2]:GetText() or nil
		left_3 = tt.left[3] and tt.left[3]:GetText() or nil
	end
	if not left_2 or not left_3 then
		return faction
	end
	local hasGuild = not left_2:find(LEVEL_start)
	local left_4
	if info and info.lines[4] then
		left_4 = info.lines[4].leftText
	elseif tt and tt.left[4] then
		left_4 = tt.left[4]:GetText()
	end
	local factionText = not hasGuild and left_3 or left_4
	if factionText == PVP then
		return faction
	end
	if factionList[factionText] or faction then
		return factionText
	end
end

local function FigureZone(unit)
	if UnitIsVisible(unit) then
		return nil
	end
	if not UnitIsConnected(unit) then
		return nil
	end
	local info = updateTT(unit)
	local left_2
	local left_3
	local left_4
	local left_5
	if info then
		left_2 = info.lines[2] and info.lines[2].leftText or nil
		left_3 = info.lines[3] and info.lines[3].leftText or nil
		left_4 = info.lines[4] and info.lines[4].leftText or nil
		left_5 = info.lines[5] and info.lines[5].leftText or nil
	elseif tt then
		left_2 = tt.left[2] and tt.left[2]:GetText() or nil
		left_3 = tt.left[3] and tt.left[3]:GetText() or nil
		left_4 = tt.left[4] and tt.left[4]:GetText() or nil
		left_5 = tt.left[5] and tt.left[5]:GetText() or nil
	end
	if not left_2 or not left_3 then
		return nil
	end
	local hasGuild = not left_2:find(LEVEL_start)
	if info and not TooltipLineCouldBeGuild(info.lines[2]) then
		hasGuild = false
	end
	local factionText = not hasGuild and left_3 or left_4
	if info then
		if not hasGuild then
			factionText = TooltipLineCouldBeFaction(info.lines[3]) and left_3 or nil
		else
			factionText = TooltipLineCouldBeFaction(info.lines[4]) and left_4 or nil
		end
	end
	if factionText == PVP then
		factionText = nil
	end
	local hasFaction = factionText and not UnitPlayerControlled(unit) and not UnitIsPlayer(unit) and (UnitFactionGroup(unit) or factionList[factionText])
	if hasGuild and hasFaction then
		return left_5
	elseif hasGuild or hasFaction then
		return left_4
	else
		return left_3
	end
end

local should_UPDATE_FACTION = false
local in_UNIT_FACTION = false
local function UPDATE_FACTION()
	if in_UNIT_FACTION then return end
	in_UNIT_FACTION = true
	if InCombatLockdown() then
		should_UPDATE_FACTION = true
		return
	end
	
	for name in DogTag_Unit.IterateFactions() do
		factionList[name] = true
	end
	
	in_UNIT_FACTION = false
end
DogTag:AddEventHandler("Unit", "UPDATE_FACTION", UPDATE_FACTION)
DogTag:AddEventHandler("Unit", "PLAYER_LOGIN", UPDATE_FACTION)
DogTag:AddEventHandler("Unit", "PLAYER_REGEN_ENABLED", function()
	if should_UPDATE_FACTION then
		should_UPDATE_FACTION = false
		UPDATE_FACTION()
	end
end)

DogTag:AddTag("Unit", "Guild", {
	code = function(unit)
		if UnitIsPlayer(unit) then
			return GetGuildInfo(unit)
		else
			return FigureNPCGuild(unit)
		end
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	doc = L["Return the guild name or title of unit"],
	example = ('[Guild] => %q; [Guild] => %q; [Guild] => %q'):format(L["My Little Pwnies"], L["Banker"], _G.UNITNAME_TITLE_PET:format("Grommash")),
	category = L["Characteristics"]
})

local checks = {
	_G.UNITNAME_TITLE_CHARM:gsub("%%s", "(.+)"),
	_G.UNITNAME_TITLE_COMPANION:gsub("%%s", "(.+)"),
	_G.UNITNAME_TITLE_CREATION:gsub("%%s", "(.+)"),
	_G.UNITNAME_TITLE_GUARDIAN:gsub("%%s", "(.+)"),
	_G.UNITNAME_TITLE_MINION:gsub("%%s", "(.+)"),
	_G.UNITNAME_TITLE_PET:gsub("%%s", "(.+)")
}

DogTag:AddTag("Unit", "Owner", {
	code = function(unit)
		if not UnitIsPlayer(unit) then
			local guild = FigureNPCGuild(unit)
			if guild then
				for i, v in ipairs(checks) do
					local owner = guild:match(v)
					if owner then
						return owner
					end
				end
			end
		end
		return nil
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	doc = L["Return the name of the owner of unit, if a pet"],
	example = ('[Owner] => %q'):format(L["Grommash"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Faction", {
	code = FigureFaction,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	events = "UNIT_FACTION",
	doc = L["Return the faction of unit"],
	example = ('[Faction] => %q; [Faction] => %q'):format(L["Alliance"], L["Aldor"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Zone", {
	code = FigureZone,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "string;nil",
	events = "SlowUpdate",
	doc = L["Return the zone of unit. Note: only works when unit is out of your sight."],
	example = ('[Zone] => %q'):format(L["Shattrath"]),
	category = L["Status"]
})

end
