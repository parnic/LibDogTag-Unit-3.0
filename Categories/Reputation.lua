local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("@project-date-integer@"):match("%d+")) or 33333333333333

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

local _G, coroutine = _G, coroutine
local wrap, yield = coroutine.wrap, coroutine.yield

local function ResolveFactionFromID(factionID)
	local data = C_Reputation.GetFactionDataByID(factionID)
	if not data or data.factionID == 0 then
		return nil, 0, 0, 0, 0
	end

	local reactionLabel = _G["FACTION_STANDING_LABEL"..data.reaction]
	local reactionLevel = data.reaction
	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
	local friendshipID = reputationInfo and reputationInfo.friendshipFactionID or 0

	local min, max, value = data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding
	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
		min, max = 0, threshold
		if currentValue and threshold then
			value = currentValue % threshold
		end
		if hasRewardPending then
			value = value + threshold
		end
	elseif C_Reputation.IsMajorFaction(factionID) then
		local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
		if majorFactionData then
			min, max = 0, majorFactionData.renownLevelThreshold
			value = majorFactionData.renownReputationEarned
			if RENOWN_LEVEL_LABEL then
				reactionLabel = RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel)
			end
		end
	elseif friendshipID > 0 then
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		reactionLabel = repInfo.reaction
		if repInfo.nextThreshold then
			min, max, value = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
		else
			local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
			min, max, value = 0, repRankInfo.maxLevel, repRankInfo.currentLevel
		end
	end

	return data.name, reactionLevel, min, max, value, reactionLabel
end

local GetWatchedFactionInfo = C_Reputation and C_Reputation.GetWatchedFactionData and function()
	local data = C_Reputation.GetWatchedFactionData()
	return ResolveFactionFromID(data and data.factionID or 0)
end or _G.GetWatchedFactionInfo

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local IterateFactions, TerminateIterateFactions
if C_Reputation and C_Reputation.GetNumFactions then
	local GetNumFactions = C_Reputation.GetNumFactions
	local GetFactionDataByIndex = C_Reputation.GetFactionDataByIndex
	local ExpandFactionHeader = C_Reputation.ExpandFactionHeader
	local CollapseFactionHeader = C_Reputation.CollapseFactionHeader

	local currentOpenHeader
	local function iter()
		for i = 1, GetNumFactions() do
			local data = GetFactionDataByIndex(i)
			if data then
				if data.isHeader == 1 then
					if data.isCollapsed == 1 then
						local NumFactions = GetNumFactions()
						ExpandFactionHeader(i)
						currentOpenHeader = i
						NumFactions = GetNumFactions() - NumFactions
						for j = i+1, i+NumFactions do
							data = GetFactionDataByIndex(j)
							if data then
								local name, reactionLevel, min, max, val, reactionLabel = ResolveFactionFromID(data.factionID)
								yield(name, data.description, reactionLevel, min, max, val, reactionLabel)
							end
						end
						CollapseFactionHeader(i)
						currentOpenHeader = nil
					end
				else
					local name, reactionLevel, min, max, val, reactionLabel = ResolveFactionFromID(data.factionID)
					yield(name, data.description, reactionLevel, min, max, val, reactionLabel)
				end
			end
		end
	end
	function TerminateIterateFactions()
		if currentOpenHeader then
			CollapseFactionHeader(currentOpenHeader)
			currentOpenHeader = nil
		end
	end

	function IterateFactions()
		currentOpenHeader = nil
		return wrap(iter)
	end
else
	local GetNumFactions, GetFactionInfo, ExpandFactionHeader, CollapseFactionHeader = 
		  GetNumFactions, GetFactionInfo, ExpandFactionHeader, CollapseFactionHeader

	local currentOpenHeader
	local function iter()
		for i = 1, GetNumFactions() do
			local name, description, standingID, min, max, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(i)
			if isHeader == 1 then
				if isCollapsed == 1 then
					local NumFactions = GetNumFactions()
					ExpandFactionHeader(i)
					currentOpenHeader = i
					NumFactions = GetNumFactions() - NumFactions
					for j = i+1, i+NumFactions do
						yield(GetFactionInfo(j))
					end
					CollapseFactionHeader(i)
					currentOpenHeader = nil
				end
			else
				yield(name, description, standingID, min, max, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild)
			end
		end
	end
	function TerminateIterateFactions()
		if currentOpenHeader then
			CollapseFactionHeader(currentOpenHeader)
			currentOpenHeader = nil
		end
	end

	function IterateFactions()
		currentOpenHeader = nil
		return wrap(iter)
	end
end
DogTag_Unit.IterateFactions = IterateFactions

DogTag:AddTag("Unit", "Reputation", {
	code = function(faction)
		if not faction then
			local _, _, min, _, value = GetWatchedFactionInfo()
			return value - min
		else
			for name, _, _, min, _, value in IterateFactions() do
				if faction == name then
					TerminateIterateFactions()
					return value - min
				end
			end
		end
	end,
	arg = {
		'faction', 'string;undef', "@undef"
	},
	ret = "number;nil",
	events = "UNIT_FACTION#player;UPDATE_FACTION",
	doc = L["Return the current reputation of the watched faction or specified"],
	example = ('[Reputation] => "1234"; [Reputation(%s)] => "2345"'):format(L["Exodar"]),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "MaxReputation", {
	code = function(faction)
		if not faction then
			local _, _, min, max = GetWatchedFactionInfo()
			return max - min
		else
			for name, _, _, min, max in IterateFactions() do
				if faction == name then
					TerminateIterateFactions()
					return max - min
				end
			end
		end
	end,
	arg = {
		'faction', 'string;undef', "@undef"
	},
	ret = "number;nil",
	events = "UNIT_FACTION#player;UPDATE_FACTION",
	doc = L["Return the maximum reputation of the watched faction or specified"],
	example = ('[MaxReputation] => "12000"; [MaxReputation(%s)] => "21000"'):format(L["Exodar"]),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "FractionalReputation", {
	alias = [=[Concatenate(Reputation(faction=faction), "/", MaxReputation(faction=faction))]=],
	arg = {
		'faction', 'string;undef', "@undef"
	},
	doc = L["Return the current and maximum reputation of the currently watched faction or argument"],
	example = ('[FractionalReputation] => "1234/12000"; [FractionalReputation(%s)] => "2345/21000"'):format(L["Exodar"], L["Exodar"], L["Exodar"]),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "PercentReputation", {
	alias = [=[(Reputation(faction=faction)/MaxReputation(faction=faction)*100):Round(1)]=],
	arg = {
		'faction', 'string;undef', "@undef"
	},
	doc = L["Return the percentage reputation of the currently watched faction or argument"],
	example = ('[PercentReputation] => "10.3"; [PercentReputation:Percent] => "10.3%%"; [PercentReputation(%s)] => "11.2"; [PercentReputation(%s):Percent] => "11.2%%"'):format(L["Exodar"], L["Exodar"]),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "MissingReputation", {
	alias = [=[MaxReputation(faction=faction) - Reputation(faction=faction)]=],
	arg = {
		'faction', 'string;undef', "@undef"
	},
	doc = L["Return the missing reputation of the currently watched faction or argument"],
	example = ('[MissingReputation] => "10766"; [MissingReputation(%s)] => "18655"'):format(L["Exodar"]),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "ReputationName", {
	code = function()
		return GetWatchedFactionInfo()
	end,
	ret = "string;nil",
	events = "UNIT_FACTION#player;UPDATE_FACTION",
	doc = L["Return the name of the currently watched faction"],
	example = ('[ReputationName] => %q'):format(L["Exodar"]),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "ReputationReaction", {
	code = function(faction)
		if not faction then
			local _, _, _, _, _, reactionLabel = GetWatchedFactionInfo()
			return reactionLabel
		else
			for name, _, _, _, _, _, reactionLabel in IterateFactions() do
				if faction == name then
					TerminateIterateFactions()
					return reactionLabel
				end
			end
		end
	end,
	arg = {
		'faction', 'string;undef', "@undef",
	},
	ret = "string;nil",
	events = "UNIT_FACTION#player;UPDATE_FACTION",
	doc = L["Return your current reputation rank with the watched faction or argument"],
	example = ('[ReputationReaction] => %q; [ReputationReaction(%s)] => %q'):format(_G.FACTION_STANDING_LABEL5, L["Exodar"], _G.FACTION_STANDING_LABEL6),
	category = L["Reputation"]
})

DogTag:AddTag("Unit", "ReputationColor", {
	code = function(value, faction)
		local nameResult, reactionLevel
		if not faction then
			nameResult, reactionLevel = GetWatchedFactionInfo()
		else
			for name, _, reaction in IterateFactions() do
				if faction == name then
					TerminateIterateFactions()
					nameResult, reactionLevel = name, reaction
					break
				end
			end
		end
		if nameResult then
			local color = FACTION_BAR_COLORS[reactionLevel]
			if value then
				return ("|cff%02x%02x%02x%s|r"):format(color.r * 255, color.g * 255, color.b * 255, value)
			else
				return ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
			end
		else
			return value
		end
	end,
	arg = {
		'value', 'string;undef', '@undef',
		'faction', 'string;undef', "@undef",
	},
	ret = "string;nil",
	events = "UNIT_FACTION#player;UPDATE_FACTION",
	doc = L["Return the color or wrap value with the color associated with either the currently watched faction or the given argument"],
	example = ('["Hello":ReputationColor] => "|cff7f0000Hello|r"; ["Hello":ReputationColor(%s)] => "|cff007f00Hello|r"; [ReputationColor(faction=%s) "Hello")] => "|cff007f00Hello"'):format(L["Exodar"], L["Exodar"]),
	category = L["Reputation"]
})

end
