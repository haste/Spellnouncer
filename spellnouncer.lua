local announces = {
	['Ritual of Souls'] = 'Click the portal for free candy!',
	['Ritual of Summoning'] = 'Summoning <target>',
}

local tags = {
	['target'] = function()
		local name = UnitName'target'

		return name or '<no target>'
	end,
}

local handleTag = function(tag)
	local handler = tags[tag]
	if(handler) then
		return handler()
	end
end

local smartSend = function(msg)
	if(not msg) then return end

	msg = msg:gsub('<(%w+)>', handleTag)

	local dest
	local inInstance, instanceType = IsInInstance()
	if(instanceType == 'pvp') then
		dest = 'BATTLEGROUND'
	elseif(GetNumRaidMembers() > 0) then
		dest = 'RAID'
	elseif(GetNumPartyMembers() > 0) then
		dest = 'PARTY'
	else
		-- Drop out if we aren't in a group.
		return
	end

	SendChatMessage(msg, dest)
end

local addon = CreateFrame'Frame'

addon:SetScript('OnEvent', function(self, event, unit, spell)
	if(unit == 'player') then
		self[event](self, event, unit, spell)
	end
end)

function addon:UNIT_SPELLCAST_SUCCEEDED(event, unit, spell)
	local announce = announces[spell]

	if(announce) then
		smartSend(announce)
	end
end

addon:RegisterEvent'UNIT_SPELLCAST_SUCCEEDED'
