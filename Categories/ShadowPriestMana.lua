local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 281 $"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

local _G, select = _G, select
local UnitClass, UnitPowerMax, UnitPower, UnitPowerType =
	  UnitClass, UnitPowerMax, UnitPower, UnitPowerType

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local wow_700 = select(4, GetBuildInfo()) >= 70000
local mpEvents = "ShadowPriestMana;UNIT_POWER#$unit;UNIT_MAXPOWER#$unit"

if wow_700 then
DogTag:AddTag("Unit", "ShadowPriestMP", {
	code = function(unit)
		if select(2, UnitClass(unit)) == "PRIEST" and UnitPowerType(unit) == SPELL_POWER_INSANITY then
			return UnitPower(unit, SPELL_POWER_MANA)
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = mpEvents,
	doc = L["Return the current mana of unit if unit is a shadow priest"],
	example = ('[ShadowPriestMP] => "%d"'):format(UnitPowerMax("player",SPELL_POWER_MANA)*.632),
	category = L["ShadowPriest"],
})

DogTag:AddTag("Unit", "MaxShadowPriestMP", {
	code = function(unit)
		if select(2, UnitClass(unit)) == "PRIEST" and UnitPowerType(unit) == SPELL_POWER_INSANITY then
			return UnitPowerMax(unit, SPELL_POWER_MANA)
		else
			return nil
		end
	end,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = "number;nil",
	events = mpEvents,
	doc = L["Return the maximum mana of unit if unit is a shadow priest"],
	example = ('[MaxShadowPriestMP] => "%d"'):format(UnitPowerMax("player",SPELL_POWER_MANA)),
	category = L["ShadowPriest"],
})

DogTag:AddTag("Unit", "PercentShadowPriestMP", {
	alias = "[ShadowPriestMP(unit=unit) / MaxShadowPriestMP(unit=unit) * 100]:Round(1)",
	arg = {
		'unit', 'string;undef', 'player'
	},
	doc = L["Return the percentage mana of unit if unit is a shadow priest"],
	example = '[PercentShadowPriestMP] => "63.2"; [PercentShadowPriestMP:Percent] => "63.2%"',
	category = L["ShadowPriest"],
})

DogTag:AddTag("Unit", "MissingShadowPriestMP", {
	alias = "MaxShadowPriestMP(unit=unit) - ShadowPriestMP(unit=unit)",
	arg = {
		'unit', 'string;undef', 'player'
	},
	doc = L["Return the missing mana of unit if unit is a shadow priest"],
	example = ('[MissingShadowPriestMP] => "%d"'):format(UnitPowerMax("player",0)*.368),
	category = L["ShadowPriest"]
})

DogTag:AddTag("Unit", "FractionalShadowPriestMP", {
	alias = "Concatenate(ShadowPriestMP(unit=unit), '/', MaxShadowPriestMP(unit=unit))",
	arg = {
		'unit', 'string;undef', 'player'
	},
	doc = L["Return the current and maximum mana of unit if unit is a shadow priest"],
	example = ('[FractionalShadowPriestMP] => "%d/%d"'):format(UnitPowerMax("player",0)*.632, UnitPowerMax("player",0)),
	category = L["ShadowPriest"]
})

DogTag:AddTag("Unit", "IsMaxShadowPriestMP", {
	alias = "Boolean(ShadowPriestMP(unit=unit) = MaxShadowPriestMP(unit=unit))",
	arg = {
		'unit', 'string;undef', 'player'
	},
	doc = L["Return True if at max mana or unit is not a shadow priest"],
	example = ('[IsMaxShadowPriestMP] => %q; [IsMaxShadowPriestMP] => ""'):format(L["True"]),
	category = L["ShadowPriest"]
})
end -- wow_700

end
