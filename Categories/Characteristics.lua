local MAJOR_VERSION = "LibDogTag-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

DogTag:AddTag("Unit", "IsFriend", {
	code = function(unit)
		return UnitIsFriend('player', unit)
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	events = "UNIT_FACTION#$unit",
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
	code = function(unit)
		return UnitCanAttack('player', unit)
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	events = "UNIT_FACTION#$unit",
	doc = L["Return True if unit can be attacked"],
	example = ('[CanAttack] => %q; [CanAttack] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Name", {
	code = UnitName,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	events = "UNIT_NAME_UPDATE#$unit",
	doc = L["Return the name of unit"],
	example = ('[Name] => %q'):format(UnitName("player")),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Exists", {
	code = UnitExists,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	doc = L["Return True if unit exists"],
	example = ('[Exists] => %q; [Exists] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Realm", {
	code = function(unit)
		local _, realm = UnitName(unit)
		if realm == "" then
			realm = nil
		end
		return realm
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	events = "UNIT_NAME_UPDATE#$unit",
	doc = L["Return the realm of unit if not your own realm"],
	example = ('[Realm] => %q'):format(GetRealmName()), 
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "NameRealm", {
	alias = [=[Name(unit=unit) Concatenate("-", Realm(unit=unit))]=],
	arg = {
		'unit', 'string', '@req'
	},
	doc = L["Return the name of unit, appending unit's realm if different from yours"],
	example = ('[NameRealm] => %q'):format(UnitName("player") .. "-" .. GetRealmName()),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Level", {
	code = function(unit)
		local level = UnitLevel(unit)
		if level <= 0 then
			level = "??"
		end
		return level
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "number;string",
	events = "UNIT_LEVEL#$unit",
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
	code = _G.UnitClassBase and function(unit)
		return UnitClassBase(unit) or UNKNOWN
	end or function(unit)
		return UnitClass(unit) or UNKNOWN
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	doc = L["Return the class of unit"],
	example = ('[Class] => %q'):format((UnitClass("player"))),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Creature", {
	code = function(unit)
		return UnitCreatureFamily(unit) or UnitCreatureType(unit) or UNKNOWN
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	doc = L["Return the creature family or type of unit"],
	example = ('[Creature] => %q; [Creature] => %q'):format(L["Cat"], L["Humanoid"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "CreatureType", {
	code = function(unit)
		return UnitCreatureType(unit) or UNKNOWN
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
	doc = L["Return the creature type of unit"],
	example = ('[CreatureType] => %q; [CreatureType] => %q'):format(L["Beast"], L["Humanoid"]),
	category = L["Characteristics"]
})


DogTag:AddTag("Unit", "Classification", {
	code = function(unit)
		local c = UnitClassification(unit)
		if c == "rare" then
			return L["Rare"]
		elseif c == "rareelite" then
			return L["Rare-Elite"]
		elseif c == "elite" then
			return L["Elite"]
		elseif c == "worldboss" then
			return L["Boss"]
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	doc = L["Return the classification of unit"],
	example = ('[Classification] => %q; [Classification] => %q; [Classification] => ""'):format(L["Elite"], L["Boss"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "Race", {
	code = UnitRace,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string",
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
	code = function(unit)
		local sex = UnitSex(unit)
		if sex == 2 then
			return L["Male"]
		elseif sex == 3 then
			return L["Female"]
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	doc = L["Return Male, Female, or blank depending on unit"],
	example = ('[Sex] => %q; [Sex] => %q; [Sex] => ""'):format(L["Male"], L["Female"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "GuildRank", {
	code = function(unit)
		local _, rank = GetGuildInfo(unit)
		return rank
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "string;nil",
	doc = L["Return the guild rank of unit"],
	example = ('[GuildRank] => %q; [GuildRank] => %q'):format(L["Guild Leader"], L["Initiate"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsPlayer", {
	code = UnitIsPlayer,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	doc = L["Return True if unit is a player"],
	example = ('[IsPlayer] => %q; [IsPlayer] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsPet", {
	code = function(unit)
		return not UnitIsPlayer(unit) and (UnitPlayerControlled(unit) or UnitPlayerOrPetInRaid(unit))
	end,
	arg = {
		'unit', 'string', '@req'
	},
	ret = "boolean",
	doc = L["Return True if unit is a player's pet"],
	example = ('[IsPet] => %q; [IsPet] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "IsPlayerOrPet", {
	code = function(unit)
		return UnitIsPlayer(unit) or UnitPlayerControlled(unit) or UnitPlayerOrPetInRaid(unit)
	end,
	arg = {
		'unit', 'string', '@req'
	},
	fakeAlias = "IsPlayer || IsPet",
	ret = "boolean",
	doc = L["Return True if unit is a player or a player's pet"],
	example = ('[IsPlayerOrPet] => %q; [IsPlayerOrPet] => ""'):format(L["True"]),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "PvPRank", {
	code = function(value, unit)
		local pvpname = UnitPVPName(unit)
		local name = UnitName(unit)
		if name ~= pvpname and pvpname then
			if not value then
				local str = "%s*" .. name .. "%s*"
				return pvpname:gsub(str, '')
			else
				return pvpname:gsub(name, value)
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
	events = "UNIT_NAME_UPDATE#$unit;PLAYER_ENTERING_WORLD#$unit",
	doc = L["Return the PvP rank or wrap the PvP rank of unit around value"],
	example = ('[PvPRank] => %q; [NameRealm:PvPRank] => %q'):format(_G.PVP_RANK_10_1, _G.PVP_RANK_10_1 .. " " .. UnitName("player") .. "-" .. GetRealmName()),
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "HostileColor", {
	code = function(value, unit)
		local r, g, b

		if UnitIsPlayer(unit) or UnitPlayerControlled(unit) then
			if UnitCanAttack(unit, "player") then
				-- they can attack me
				if UnitCanAttack("player", unit) then
					-- and I can attack them
					r, g, b = unpack(DogTag.__colors.hostile)
				else
					-- but I can't attack them
					r, g, b = unpack(DogTag.__colors.civilian)
				end
			elseif UnitCanAttack("player", unit) then
				-- they can't attack me, but I can attack them
				r, g, b = unpack(DogTag.__colors.neutral)
			elseif UnitIsPVP(unit) then
				-- on my team
				r, g, b = unpack(DogTag.__colors.friendly)
			else
				-- either enemy or friend, no violence
				r, g, b = unpack(DogTag.__colors.civilian)
			end
		elseif (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) or UnitIsDead(unit) then
			r, g, b = unpack(colors.tapped)
		else
			local reaction = UnitReaction(unit, "player")
			if reaction then
				if reaction >= 5 then
					r, g, b = unpack(DogTag.__colors.friendly)
				elseif reaction == 4 then
					r, g, b = unpack(DogTag.__colors.neutral)
				else
					r, g, b = unpack(DogTag.__colors.hostile)
				end
			else
				r, g, b = unpack(DogTag.__colors.unknown)
			end
		end
	
		if value then
			return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
		else
			return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
		end
	end,
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_FACTION#$unit",
	doc = L["Return the color or wrap value with the hostility color of unit"],
	example = '["Hello":HostileColor] => "|cffff0000Hello|r"; [HostileColor "Hello"] => "|cffff0000Hello"',
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "AggroColor", {
	code = function(value, unit)
		local val = UnitReaction("player", unit) or 5

		local info = UnitReactionColor[val]
		if value then
			return ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, value)
		else
			return ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
		end
	end,
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_FACTION#$unit",
	doc = L["Return the color or wrap value with the aggression color of unit"],
	example = '["Hello":AggroColor] => "|cffffff00Hello|r"; [AggroColor "Hello"] => "|cffffff00Hello"',
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "ClassColor", {
	code = function(value, unit)
		local _, class = UnitClass(unit)
		local r, g, b = unpack(DogTag.__colors[class] or DogTag.__colors.unknown)
		if value then
			return ("|cff%02x%02x%02x%s|r"):format(r * 255, g * 255, b * 255, value)
		else
			return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
		end
	end,
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	doc = L["Return the color or wrap value with the class color of unit"],
	example = '["Hello":ClassColor] => "|cfff58cbdHello|r"; [ClassColor "Hello"] => "|cfff58cbdHello"',
	category = L["Characteristics"]
})

DogTag:AddTag("Unit", "DifficultyColor", {
	code = function(value, unit)
		local level = UnitLevel(unit)
		if level <= 0 or UnitClassification(unit) ~= "normal" then
			level = 99
		end
		local info = GetDifficultyColor(level)
		if value then
			return ("|cff%02x%02x%02x%s|r"):format(info.r * 255, info.g * 255, info.b * 255, value)
		else
			return ("|cff%02x%02x%02x"):format(info.r * 255, info.g * 255, info.b * 255)
		end
	end,
	arg = {
		'value', 'string;undef', '@undef',
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_LEVEL#$unit;PLAYER_LEVEL_UP#$unit",
	doc = L["Return the color or wrap value with the difficulty color of unit's level compared to your own level"],
	example = '["Hello":DifficultyColor] => "|cffff7f00Hello|r"; [DifficultyColor "Hello"] => "|cffff7f00Hello"',
	category = L["Characteristics"]
})

if _G.UnitClassBase then
	DogTag:AddTag("Unit", "Guid", {
		code = UnitGUID,
		arg = {
			'unit', 'string', '@req',
		},
		ret = "string",
		doc = L["Return the GUID for the unit, an internal identifier."]
	})
end

end