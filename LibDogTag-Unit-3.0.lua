--[[
Name: LibDogTag-3.0
Revision: $Rev$
Author: Cameron Kenneth Knight (ckknight@gmail.com)
Website: http://www.wowace.com/
Description: A library to provide a markup syntax
]]

local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

DogTag_Unit_funcs[#DogTag_Unit_funcs+1] = function(DogTag_Unit, DogTag)

local L = DogTag_Unit.L

local UnitToLocale = {player = L["Player"], target = L["Target"], pet = L["%s's pet"]:format(L["Player"]), focus = L["Focus-target"], mouseover = L["Mouse-over"]}
setmetatable(UnitToLocale, {__index=function(self, unit)
	if unit:find("pet$") then
		local nonPet = unit:sub(1, -4)
		self[unit] = L["%s's pet"]:format(self[nonPet])
		return self[unit]
	elseif not unit:find("target$") then
		if unit:find("^party%d$") then
			local num = unit:match("^party(%d)$")
			self[unit] = L["Party member #%d"]:format(num)
			return self[unit]
		elseif unit:find("^raid%d%d?$") then
			local num = unit:match("^raid(%d%d?)$")
			self[unit] = L["Raid member #%d"]:format(num)
			return self[unit]
		elseif unit:find("^partypet%d$") then
			local num = unit:match("^partypet(%d)$")
			self[unit] = UnitToLocale["party" .. num .. "pet"]
			return self[unit]
		elseif unit:find("^raidpet%d%d?$") then
			local num = unit:match("^raidpet(%d%d?)$")
			self[unit] = UnitToLocale["raid" .. num .. "pet"]
			return self[unit]
		end
		self[unit] = unit
		return unit
	end
	local nonTarget = unit:sub(1, -7)
	self[unit] = L["%s's target"]:format(self[nonTarget])
	return self[unit]
end})
DogTag.UnitToLocale = UnitToLocale

local IsLegitimateUnit = { player = true, target = true, focus = true, pet = true, playerpet = true, mouseover = true, npc = true, NPC = true }
DogTag.IsLegitimateUnit = IsLegitimateUnit
for i = 1, 4 do
	IsLegitimateUnit["party" .. i] = true
	IsLegitimateUnit["partypet" .. i] = true
	IsLegitimateUnit["party" .. i .. "pet"] = true
end
for i = 1, 40 do
	IsLegitimateUnit["raid" .. i] = true
	IsLegitimateUnit["raidpet" .. i] = true
	IsLegitimateUnit["raid" .. i .. "pet"] = true
end
setmetatable(IsLegitimateUnit, { __index = function(self, key)
	if type(key) ~= "string" then
		return false
	end
	if key:match("target$") then
		self[key] = self[key:sub(1, -7)]
		return self[key]
	end
	self[key] = false
	return false
end, __call = function(self, key)
	return self[key]
end})

local function searchForNameTag(ast)
	if type(ast) ~= "table" then
		return false
	end
	if ast[1] == "tag" and ast[2]:lower() == "name" then
		return true
	end
	for i = 2, #ast do
		if searchForNameTag(ast[i]) then
			return true
		end
	end
	if ast.kwarg then
		for k, v in pairs(ast.kwarg) do
			if searchForNametag(v) then
				return true
			end
		end
	end
	return false
end

DogTag:AddCompilationStep("Unit", "start", function(t, ast, kwargTypes, extraKwargs)
	if kwargTypes["unit"] then
		t[#t+1] = [=[if not DogTag.IsLegitimateUnit[]=]
		t[#t+1] = extraKwargs["unit"][1]
		t[#t+1] = [=[] then return ("Bad unit: %q"):format(]=]
		t[#t+1] = extraKwargs["unit"][1]
		t[#t+1] = [=[), nil;end;]=]
		t[#t+1] = [=[if not UnitExists(]=]
		t[#t+1] = extraKwargs["unit"][1]
		t[#t+1] = [=[) then return ]=]
		if searchForNameTag(ast) then
			t[#t+1] = [=[DogTag.UnitToLocale[]=]
			t[#t+1] = extraKwargs["unit"][1]
			t[#t+1] = [=[]]=]
		else
			t[#t+1] = [=[nil]=]
		end
		t[#t+1] = [=[, nil;end;]=]
	end
end)

DogTag:AddCompilationStep("Unit", "tag", function(ast, t, tag, tagData, kwargs, extraKwargs, compiledKwargs)
	if compiledKwargs["unit"] and kwargs["unit"] ~= extraKwargs then
		if type(kwargs["unit"]) ~= "table" then
		 	if not IsLegitimateUnit[kwargs["unit"]] then
				t[#t+1] = [=[do return ]=]
				t[#t+1] = [=[("Bad unit: %q"):format(tostring(]=]
				t[#t+1] = compiledKwargs["unit"][1]
				t[#t+1] = [=[));]=]
				t[#t+1] = [=[end;]=]
			end
		else
			t[#t+1] = [=[if not DogTag.IsLegitimateUnit[]=]
			t[#t+1] = compiledKwargs["unit"][1]
			t[#t+1] = [=[] then return ]=]
			t[#t+1] = [=[("Bad unit: %q"):format(tostring(]=]
			t[#t+1] = compiledKwargs["unit"][1]	
			t[#t+1] = [=[));]=]
			t[#t+1] = [=[end;]=]
		end
	end
end)

end