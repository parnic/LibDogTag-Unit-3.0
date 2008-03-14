local DOGTAG_MAJOR_VERSION = "LibDogTag-3.0"
local MAJOR_VERSION = "LibDogTag-Unit-3.0"
local MINOR_VERSION = tonumber(("$Revision$"):match("%d+")) or 0

if MINOR_VERSION > _G.DogTag_Unit_MINOR_VERSION then
	_G.DogTag_Unit_MINOR_VERSION = MINOR_VERSION
end

local DogTag_Unit, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not DogTag_Unit then
	return
end

local DogTag = LibStub:GetLibrary(DOGTAG_MAJOR_VERSION)
if not DogTag then
	error(("Cannot load %s without first loading %s"):format(MAJOR_VERSION, DOGTAG_MAJOR_VERSION))
end

local oldLib
if next(DogTag_Unit) ~= nil then
	oldLib = {}
	for k,v in pairs(DogTag_Unit) do
		oldLib[k] = v
		DogTag_Unit[k] = nil
	end
end
DogTag_Unit.oldLib = oldLib

for _,v in ipairs(_G.DogTag_Unit_funcs) do
	v(DogTag_Unit, DogTag)
end

_G.DogTag_Unit_funcs = nil
