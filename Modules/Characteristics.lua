local MAJOR_VERSION = "LibDogTag-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_MINOR_VERSION then
	_G.DogTag_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L
local FakeGlobals = DogTag.FakeGlobals

DogTag:AddTag("Unit", "IsFriend", {
	code = [=[return UnitIsFriend('player', ${unit})]=],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	events = "UNIT_FACTION#$unit",
	globals = "UnitIsFriend",
	doc = L["Return True if unit is a friend"],
	example = ('[IsFriend] => %q; [IsFriend] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsEnemy", {
	alias = "Boolean(not IsFriend(unit=unit))",
	arg = {
		'unit', 'string', '@req'
	},
	doc = L["Return True if unit is an enemy"],
	example = ('[IsEnemy] => %q; [IsEnemy] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "CanAttack", {
	code = [[return UnitCanAttack('player', ${unit})]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	globals = "UnitCanAttack",
	events = "UNIT_FACTION#$unit",
	doc = L["Return True if unit can be attacked"],
	example = ('[CanAttack] => %q; [CanAttack] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Name", {
	code = [[return UnitName(${unit})]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	events = "UNIT_NAME_UPDATE#$unit",
	globals = "UnitName",
	doc = L["Return the name of unit"],
	example = ('[Name] => %q'):format(UnitName("player")),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Exists", {
	code = [[return UnitExists(${unit})]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	globals = "UnitExists",
	doc = L["Return True if unit exists"],
	example = ('[Exists] => %q; [Exists] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Realm", {
	code = [[local _, realm = UnitName(${unit})
	if realm == "" then
		realm = nil
	end
	return realm]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	events = "UNIT_NAME_UPDATE#$unit",
	globals = "UnitName",
	doc = L["Return the realm of unit if not your own realm"],
	example = ('[Realm] => %q'):format(GetRealmName()), 
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "NameRealm", {
	alias = [=[Name(unit=unit) "-":Append(Realm(unit=unit))]=],
	arg = {
		'unit', 'string', '@req'
	},
	doc = L["Return the name of unit, appending unit's realm if different from yours"],
	example = ('[NameRealm] => %q'):format(UnitName("player") .. "-" .. GetRealmName()),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Level", {
	code = [[local level = UnitLevel(${unit})
	if level <= 0 then
		level = "??"
	end
	return level]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "number;string",
	events = "UNIT_LEVEL#$unit",
	globals = "UnitLevel",
	doc = L["Return the level of unit"],
	example = ('[Level] => "%d"; [Level] => "??"'):format(UnitLevel("player")),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsMaxLevel", {
	alias = ("Boolean(Level(unit=unit) >= %d)"):format(_G.MAX_PLAYER_LEVEL),
	arg = {
		'unit', 'string', '@req'
	},
	doc = L["Return True if the level of unit is %d"]:format(_G.MAX_PLAYER_LEVEL),
	example = ('[IsMaxLevel] => %q'):format(UnitLevel("player") >= _G.MAX_PLAYER_LEVEL and L["True"] or ""),
	category = L["Characteristics"],
})

DogTag:AddTag("Unit", "Class", {
	code = ([[return UnitClass]] .. (_G.UnitClassBase and "Base" or "") .. [[(${unit}) or %q]]):format(UNKNOWN),
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	globals = _G.UnitClassBase and "UnitClassBase" or "UnitClass",
	doc = L["Return the class of unit"],
	example = ('[Class] => %q'):format((UnitClass("player"))),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Creature", {
	code = ([[return UnitCreatureFamily(${unit}) or UnitCreatureType(${unit}) or %q]]):format(UNKNOWN),
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	globals = "UnitCreatureFamily;UnitCreatureType",
	doc = L["Return the creature family or type of unit"],
	example = ('[Creature] => %q; [Creature] => %q'):format(L["Cat"], L["Humanoid"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "CreatureType", {
	code = ([[return UnitCreatureType(${unit}) or %q]]):format(UNKNOWN),
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	globals = "UnitCreatureType",
	doc = L["Return the creature type of unit"],
	example = ('[CreatureType] => %q; [CreatureType] => %q'):format(L["Beast"], L["Humanoid"]),
	category = L["Characteristics"]
})


DogTag:AddTag("Unit", "Classification", {
	code = ([[local c = UnitClassification(${unit})
	if c == "rare" then
		return %q
	elseif c == "rareelite" then
		return %q
	elseif c == "elite" then
		return %q
	elseif c == "worldboss" then
		return %q
	else
		return nil
	end]]):format(L["Rare"], L["Rare-Elite"], L["Elite"], L["Boss"]),
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	globals = "UnitClassification",
	doc = L["Return the classification of unit"],
	example = ('[Classification] => %q; [Classification] => %q; [Classification] => ""'):format(L["Elite"], L["Boss"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Race", {
	code = [[return UnitRace(${unit})]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	globals = "UnitRace",
	doc = L["Return the race of unit"],
	example = ('[Race] => %q'):format((UnitRace("player"))),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "SmartRace", {
	alias = "IsPlayer(unit=unit) ? Race(unit=unit) ! Creature(unit=unit)",
	arg = {
		'unit', 'string', '@req'
	},
	doc = L["Return the race if unit is a player, otherwise the creature family"],
	example = ('[SmartRace] => %q; [SmartRace] => %q'):format(UnitRace("player"), L["Humanoid"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Sex", {
	code = ([[local sex = UnitSex(${unit})
	if sex == 2 then
		return %q
	elseif sex == 3 then
		return %q
	else
		return nil
	end]]):format(L["Male"], L["Female"]),
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	globals = "UnitSex",
	doc = L["Return Male, Female, or blank depending on unit"],
	example = ('[Sex] => %q; [Sex] => %q; [Sex] => ""'):format(L["Male"], L["Female"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "GuildRank", {
	code = [[local _, rank = GetGuildInfo(${unit})
	return rank]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	globals = "GetGuildInfo",
	doc = L["Return the guild rank of unit"],
	example = ('[GuildRank] => %q; [GuildRank] => %q'):format(L["Guild Leader"], L["Initiate"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsPlayer", {
	code = [[return UnitIsPlayer(${unit})]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	globals = "UnitIsPlayer",
	doc = L["Return True if unit is a player"],
	example = ('[IsPlayer] => %q; [IsPlayer] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsPet", {
	code = [[return not UnitIsPlayer(${unit}) and UnitPlayerControlled(${unit})]],
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	globals = "UnitIsPlayer;UnitPlayerControlled",
	doc = L["Return True if unit is a player's pet"],
	example = ('[IsPet] => %q; [IsPet] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsPlayerOrPet", {
	code = [[return (UnitIsPlayer(${unit}) or UnitPlayerControlled(${unit}) or UnitPlayerOrPetInRaid(${unit}))]],
	arg = {
		'unit', 'string', '@req'
	},
	fakeAlias = "IsPlayer || IsPet",
	ret = "boolean",
	globals = "UnitIsPlayer;UnitPlayerControlled;UnitPlayerOrPetInRaid",
	doc = L["Return True if unit is a player or a player's pet"],
	example = ('[IsPlayerOrPet] => %q; [IsPlayerOrPet] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "PvPRank", {
	code = [=[local pvpname = UnitPVPName(${unit})
	local name = UnitName(${unit})
	if name ~= pvpname and pvpname then
		if not ${value} then
			local str = "%s*" .. name .. "%s*"
			return pvpname:gsub(str, '')
		else
			return pvpname:gsub(name, ${value})
		end
	else
		return ${value}
	end]=],
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string;nil",
	events = "UNIT_NAME_UPDATE#$unit;PLAYER_ENTERING_WORLD#$unit",
	globals = "UnitPVPName;UnitName",
	doc = L["Return the PvP rank or wrap the PvP rank of unit around value"],
	example = ('[PvPRank] => %q; [NameRealm:PvPRank] => %q'):format(_G.PVP_RANK_10_1, _G.PVP_RANK_10_1 .. " " .. UnitName("player") .. "-" .. GetRealmName()),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "HostileColor", {
	code = [[local r, g, b

	if UnitIsPlayer(${unit}) or UnitPlayerControlled(${unit}) then
		if UnitCanAttack(${unit}, "player") then
			-- they can attack me
			if UnitCanAttack("player", ${unit}) then
				-- and I can attack them
				r, g, b = unpack(colors.hostile)
			else
				-- but I can't attack them
				r, g, b = unpack(colors.civilian)
			end
		elseif UnitCanAttack("player", ${unit}) then
			-- they can't attack me, but I can attack them
			r, g, b = unpack(colors.neutral)
		elseif UnitIsPVP(${unit}) then
			-- on my team
			r, g, b = unpack(colors.friendly)
		else
			-- either enemy or friend, no violence
			r, g, b = unpack(colors.civilian)
		end
	elseif (UnitIsTapped(${unit}) and not UnitIsTappedByPlayer(${unit})) or UnitIsDead(${unit}) then
		r, g, b = unpack(colors.tapped)
	else
		local reaction = UnitReaction(${unit}, "player")
		if reaction then
			if reaction >= 5 then
				r, g, b = unpack(colors.friendly)
			elseif reaction == 4 then
				r, g, b = unpack(colors.neutral)
			else
				r, g, b = unpack(colors.hostile)
			end
		else
			r, g, b = unpack(colors.unknown)
		end
	end
	
	if ${value} then
		return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, ${value})
	else
		return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	end]],
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_FACTION#$unit",
	globals = "UnitIsPlayer;UnitPlayerControlled;UnitCanAttack;UnitIsPVP;UnitIsTapped;UnitIsTappedByPlayer;UnitIsDead;UnitReaction",
	doc = L["Return the color or wrap value with the hostility color of unit"],
	example = '["Hello":HostileColor] => "|cffff0000Hello|r"; [HostileColor "Hello"] => "|cffff0000Hello"',
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "AggroColor", {
	code = [=[local val = UnitReaction("player", ${unit}) or 5

	local info = UnitReactionColor[val]
	if ${value} then
		return ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, ${value})
	else
		return ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
	end
	]=],
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_FACTION#$unit",
	globals = "UnitReaction;UnitReactionColor",
	doc = L["Return the color or wrap value with the aggression color of unit"],
	example = '["Hello":AggroColor] => "|cffffff00Hello|r"; [AggroColor "Hello"] => "|cffffff00Hello"',
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "ClassColor", {
	code = [=[local _, class = UnitClass(${unit})
	local r, g, b = unpack(colors[class] or colors.unknown)
	if ${value} then
		return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, ${value})
	else
		return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	end]=],
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	globals = "UnitClass",
	doc = L["Return the color or wrap value with the class color of unit"],
	example = '["Hello":ClassColor] => "|cfff58cbdHello|r"; [ClassColor "Hello"] => "|cfff58cbdHello"',
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "DifficultyColor", {
	code = [=[local level = UnitLevel(${unit})
	if level <= 0 or UnitClassification(${unit}) ~= "normal" then
		level = 99
	end
	local info = GetDifficultyColor(level)
	if ${value} then
		return ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, ${value})
	else
		return ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
	end]=],
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_LEVEL#$unit;PLAYER_LEVEL_UP#$unit",
	globals = "GetDifficultyColor;UnitLevel;UnitClassification",
	doc = L["Return the color or wrap value with the difficulty color of unit's level compared to your own level"],
	example = '["Hello":DifficultyColor] => "|cffff7f00Hello|r"; [DifficultyColor "Hello"] => "|cffff7f00Hello"',
	category = L["Characteristics"]
})

end