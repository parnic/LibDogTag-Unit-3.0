local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local LibMobHealth, MobHealth3, MobHealth_PPP
DogTag:AddAddonFinder("Unit", "LibStub", "LibMobHealth-4.0", function(v) LibMobHealth = v end)
DogTag:AddAddonFinder("Unit", "_G", "MobHealth3", function(v) MobHealth3 = v end)
DogTag:AddAddonFinder("Unit", "_G", "MobHealth_PPP", function(v) MobHealth_PPP = v end)

DogTag:AddTag("Unit", "HP", {
	code = function(args)
		if LibMobHealth then
			return [=[local hp, found = LibMobHealth:GetUnitCurrentHP(${unit})
			if ${known} and not found then
				return nil
			else
				return hp
			end]=]
		elseif MobHealth3 then
			return [=[local currValue = UnitHealth(${unit})
			if not UnitIsFriend("player", ${unit}) then
				local maxValue = UnitHealthMax(${unit})
				local curr, max, found = MobHealth3:GetUnitHealth(${unit}, currValue, maxValue)
				if found then
					currValue = curr
				elseif ${known} then
					currValue = nil
				end
			elseif ${known} and UnitHealthMax(${unit}) == 100 then
				currValue = nil
			end
			return currValue]=]
		elseif MobHealth_PPP then
			return [=[local currValue = UnitHealth(${unit})
			if not UnitIsFriend("player", ${unit}) then
				local name = UnitName(${unit})
				local level = UnitLevel(${unit})
				local ppp = MobHealth_PPP(name..":"..level)
				if ppp > 0 then
					currValue = math_floor(currValue * ppp + 0.5)
				elseif ${known} then
					currValue = nil
				end
			elseif ${known} and UnitHealthMax(${unit}) == 100 then
				currValue = nil
			end
			return currValue]=]
		else
			return [=[local hp = UnitHealth(${unit})
			if ${known} and UnitHealthMax(${unit}) == 100 then
				return nil
			else
				return hp
			end]=]
		end
	end,
	arg = {
		'unit', 'string', '@req',
		'known', 'boolean', false,
	},
	ret = function(args)
		if args.known.types == "nil" then
			return 'number'
		else
			return 'nil;number'
		end
	end,
	events = "UNIT_HEALTH#$unit;UNIT_MAXHEALTH#$unit",
	globals = function(args)
		if LibMobHealth then
			return "LibMobHealth-4.0"
		elseif MobHealth3 then
			return "UnitHealth;UnitIsFriend;UnitHealthMax;MobHealth3"
		elseif MobHealth_PPP then
			return "UnitHealth;UnitIsFriend;UnitHealthMax;UnitName;UnitLevel;MobHealth_PPP;math.floor"
		else
			return "UnitHealth;UnitHealthMax"
		end
	end,
	doc = L["Return the current health of unit, will use MobHealth if found"],
	example = ('[HP] => "%d"'):format(UnitHealthMax("player")*.758),
	category = L["Health"],
})

DogTag:AddTag("Unit", "MaxHP", {
	code = function(args)
		if LibMobHealth then
			return [=[local maxhp, found = LibMobHealth:GetUnitMaxHP(${unit})
			if ${known} and not found then
				return nil
			else
				return maxhp
			end]=]
		elseif MobHealth3 then
			return [=[local maxValue = UnitHealthMax(${unit})
			if not UnitIsFriend("player", ${unit}) then
				local curr, max, MHfound = MobHealth3:GetUnitHealth(${unit}, 1, maxValue)
				if MHfound then
					maxValue = max
				elseif ${known} then
					maxValue = nil
				end
			elseif ${known} and maxValue == 100 then
				maxValue = nil
			end
			return maxValue]=]
		elseif MobHealth_PPP then
			return [=[local maxValue = UnitHealthMax(${unit})
			if not UnitIsFriend("player", ${unit}) then
				local name = UnitName(${unit})
				local level = UnitLevel(${unit})
				local ppp = MobHealth_PPP(name..":"..level)
				if ppp > 0 then
					maxValue = math_floor(100 * ppp + 0.5)
				elseif ${known} then
					maxValue = nil
				end
			elseif ${known} and maxValue == 100 then
				maxValue = nil
			end
			return maxValue]=]
		else
			return [=[local maxhp = UnitHealthMax(${unit})
			if ${known} and maxhp == 100 then
				return nil
			else
				return maxhp
			end]=]
		end
	end,
	arg = {
		'unit', 'string', '@req',
		'known', 'boolean', false,
	},
	ret = function(args)
		if args.known.types == "nil" then
			return 'number'
		else
			return 'nil;number'
		end
	end,
	events = "UNIT_HEALTH#$unit;UNIT_MAXHEALTH#$unit",
	globals = function(args)
		if LibMobHealth then
			return "LibMobHealth-4.0"
		elseif MobHealth3 then
			return "UnitIsFriend;UnitHealthMax;MobHealth3"
		elseif MobHealth_PPP then
			return "UnitHealthMax;UnitIsFriend;UnitName;UnitLevel;MobHealth_PPP;math.floor"
		else
			return "UnitHealthMax"
		end
	end,
	doc = L["Return the maximum health of unit, will use MobHealth if found"],
	example = ('[MaxHP] => "%d"'):format(UnitHealthMax("player")),
	category = L["Health"],
})

DogTag:AddTag("Unit", "PercentHP", {
	code = [=[return math_floor(UnitHealth(${unit})/UnitHealthMax(${unit}) * 1000+0.5) / 10]=],
	fakeAlias = "[CurHP / MaxHP * 100]:Round(1)",
	arg = {
		'unit', 'string', '@req',
	},
	ret = "number",
	events = "UNIT_HEALTH#$unit;UNIT_MAXHEALTH#$unit",
	globals = "UnitHealth;UnitHealthMax;math.floor",
	doc = L["Return the percentage health of unit"],
	example = '[PercentHP] => "75.8"; [PercentHP:Percent] => "75.8%"',
	category = L["Health"],
})

DogTag:AddTag("Unit", "MissingHP", {
	alias = [=[MaxHP(unit=unit, known=known) - HP(unit=unit, known=known)]=],
	arg = {
		'unit', 'string', '@req',
		'known', 'boolean', false,
	},
	ret = "number",
	doc = L["Return the missing health of unit, will use MobHealth if found"],
	example = ('[MissingHP] => "%d"'):format(UnitHealthMax("player")*.242),
	category = L["Health"]
})

DogTag:AddTag("Unit", "FractionalHP", {
	alias = [=[HP(unit=unit, known=known):Append("/") MaxHP(unit=unit, known=known)]=],
	arg = {
		'unit', 'string', '@req',
		'known', 'boolean', false,
	},
	ret = "string",
	doc = L["Return the current health and maximum health of unit, will use MobHealth if found"],
	example = ('[FractionalHP] => "%d/%d"'):format(UnitHealthMax("player")*.758, UnitHealthMax("player")),
	category = L["Health"]
})

DogTag:AddTag("Unit", "IsMaxHP", {
	code = [=[return UnitHealth(${unit}) == UnitHealthMax(${unit})]=],
	arg = {
		'unit', 'string', '@req',
	},
	ret = "boolean",
	globals = "UnitHealth;UnitHealthMax",
	doc = L["Return True if unit is at full health"],
	example = ('[IsMaxHP] => %q; [IsMaxHP] => ""'):format(L["True"]),
	category = L["Health"]
})

DogTag:AddTag("Unit", "HPColor", {
	code = [=[local perc = UnitHealth(${unit}) / UnitHealthMax(${unit})
	local r1, g1, b1
	local r2, g2, b2
	if perc <= 0.5 then
		perc = perc * 2
		r1, g1, b1 = unpack(colors.minHP)
		r2, g2, b2 = unpack(colors.midHP)
	else
		perc = perc * 2 - 1
		r1, g1, b1 = unpack(colors.midHP)
		r2, g2, b2 = unpack(colors.maxHP)
	end
	local r, g, b = r1 + (r2 - r1)*perc, g1 + (g2 - g1)*perc, b1 + (b2 - b1)*perc
	if ${value} then
		return ("|cff%02x%02x%02x%s|r"):format(r*255, g*255, b*255, ${value})
	else
		return ("|cff%02x%02x%02x"):format(r*255, g*255, b*255)
	end]=],
	arg = {
		'value', 'string;undef', "@undef",
		'unit', 'string', '@req',
	},
	ret = "string",
	events = "UNIT_HEALTH#$unit;UNIT_MAXHEALTH#$unit",
	globals = "UnitHealth;UnitHealthMax",
	doc = L["Return the color or wrap value with the health color of unit"],
	example = '[Text(Hello):HPColor] => "|cffff7f00Hello|r"; [Text([HPColor]Hello)] => "|cffff7f00Hello"',
	category = L["Health"]
})

end