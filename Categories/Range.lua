local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local function MinRange_func(unit) return nil end
local function MaxRange_func(unit) return nil end
local function MinMaxRange_func(unit) return nil end

DogTag:AddAddonFinder("Unit", "AceLibrary", "RangeCheck-1.0", function(RangeCheckLib)
	function MinRange_func(unit)
		return (RangeCheckLib:getRange(unit))
	end
	function MaxRange_func(unit)
		local _, max = RangeCheckLib:getRange(unit)
		return max
	end
	function MinMaxRange_func(unit)
		local min, max = RangeCheckLib:getRange(unit)
		if min then
			if max then
				return min .. " - " .. max
			else
				return min .. "+"
			end
		end
		return nil
	end
end)

DogTag:AddTag("Unit", "Range", {
	code = function(data)
		return MinMaxRange_func
	end,
	dynamicCode = true,
	arg = {
		'unit', 'string;undef', 'player'
	},
	doc = L["Return the approximate range of unit, if RangeCheck-1.0 is available"],
	ret = function()
		if not RangeCheckLib then
			return "nil"
		else
			return "string"
		end
	end,
	events = function()
		if not RangeCheckLib then
			return nil
		else
			return "Update"
		end
	end,
	example = '[Range] => "5 - 15"; [Range] => "30+"; [Range] => ""',
	category = L["Range"]
})

DogTag:AddTag("Unit", "MinRange", {
	code = function(data)
		return MinRange_func
	end,
	dynamicCode = true,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = function()
		if not RangeCheckLib then
			return "nil"
		else
			return "number"
		end
	end,
	events = function()
		if not RangeCheckLib then
			return nil
		else
			return "Update"
		end
	end,
	doc = L["Return the approximate minimum range of unit, if RangeCheck-1.0 is available"],
	example = '[MinRange] => "5"; [MinRange] => ""',
	category = L["Range"]
})

DogTag:AddTag("Unit", "MaxRange", {
	code = function(data)
		return MaxRange_func
	end,
	dynamicCode = true,
	arg = {
		'unit', 'string;undef', 'player'
	},
	ret = function()
		if not RangeCheckLib then
			return "nil"
		else
			return "nil;number"
		end
	end,
	events = function()
		if not RangeCheckLib then
			return nil
		else
			return "Update"
		end
	end,
	doc = L["Return the approximate maximum range of unit, if RangeCheck-1.0 is available"],
	example = '[MaxRange] => "15"; [MaxRange] => ""',
	category = L["Range"]
})

end
