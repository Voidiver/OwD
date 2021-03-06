local C, F, L = unpack(select(2, ...))
local oUF = oUF_OwD or oUF

-->>Lua APIs
local min = math.min
local max = math.max
local format = string.format
local floor = math.floor
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local rad = math.rad
-->>WoW APIs
local GetTime = GetTime

local Smooth_Update = function(f)
	local limit = 6 / GetFramerate()
	local per = f.Per or 0
	local cur = f.Cur or 0
	local new = cur + min((per - cur) / 3, max(per - cur, limit * 1))
	if new ~= new then
		new = per
	end
	f.Cur = floor(new*1e6+0.5)/1e6
	if abs(f.Cur) < 1e-5 then 
		new = 0
		f.Cur = 0 
	end
	if abs(cur - per) <= 1e-4 then
		f.Cur = per
	end
end

--- ----------------------------------------------------------------------
--> OnEvent
--- ----------------------------------------------------------------------

local event = {
	"ADDON_LOADED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_FOCUS_CHANGED",
	
	"UNIT_ENTERED_VEHICLE",
	"UNIT_EXITED_VEHICLE",
	
	"UNIT_HEALTH_FREQUENT",
	"UNIT_MAXHEALTH",
	
	"UNIT_POWER_FREQUENT",
	"UNIT_MAXPOWER",
	
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	
	"UNIT_ENTERED_VEHICLE",
	"UNIT_EXITED_VEHICLE",
	
	"UNIT_FACTION",
	
	"PLAYER_XP_UPDATE",
	"UPDATE_FACTION",
	
	"PLAYER_UPDATE_RESTING",
	
	"UNIT_THREAT_SITUATION_UPDATE",
	"UNIT_THREAT_LIST_UPDATE",
	
	"UNIT_PET",
	"PET_UI_CLOSE",
	"PET_UI_UPDATE",
}

local onEvent_OwD = function(f)
	F.rEvent(f, event)
	f:SetScript("OnEvent", function(self,event, arg1,arg2,arg2,arg4,arg5)
		L.OnEvent_Player(f.Player, event)
		L.OnEvent_Pet(f.Pet, event, arg1)
		L.OnEvent_FCS(f.FCS, event)
		L.OnEvent_Target(f.Target, event)
		L.OnEvent_Focus(f.Focus, event)
		--L.OnEvent_XP(f, event)	
		L.OnEvent_Minimap(f.mnMap, event)
		
		L.onevent_AltPower(f.Player, "player", event)
		L.onevent_AltPower(f.Target, "target", event)
		
		L.OnShow_Castbar(f, event)
		
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
			L.update_OutCombat_Fade(f)
		end
		if event == "PLAYER_ENTERING_WORLD" then
			f: SetScale(OwD_DB["OwD_Scale"])
			f.PlayerButton: SetScale(OwD_DB["OwD_Scale"])
			f.PetButton: SetScale(OwD_DB["OwD_Scale"])
			f.TargetButton: SetScale(OwD_DB["OwD_Scale"])
			f.ToTButton: SetScale(OwD_DB["OwD_Scale"])
			f.ToFButton: SetScale(OwD_DB["OwD_Scale"])
		end
	end)
end


--- ----------------------------------------------------------------------
--> OnUpdate
--- ----------------------------------------------------------------------

local last1 = 0
local last2 = 0
local onUpdate_OwD = function(f)
	f:SetScript("OnUpdate", function(self,elapsed)
		--> Player
		Smooth_Update(f.Player.Health)
		L.OnUpdate_Player(f.Player, elapsed)
		
		--> FCS
		Smooth_Update(f.FCS.Power)
		L.OnUpdate_FCS(f.FCS, elapsed)
		
		--> Pet
		Smooth_Update(f.Pet.Health)
		Smooth_Update(f.Pet.Power)
		L.OnUpdate_Pet(f.Pet, elapsed)
		
		--> Target
		Smooth_Update(f.Target.Health)
		Smooth_Update(f.Target.Power)
		L.OnUpdate_Target(f.Target, elapsed)
		
		--> Target of Target
		Smooth_Update(f.ToT.Health)
		--Smooth_Update(f.ToT.Power)
		L.OnUpdate_ToT(f.ToT, elapsed)
		
		--> Focus
		Smooth_Update(f.Focus.Health)
		Smooth_Update(f.Focus.Power)
		L.OnUpdate_Focus(f.Focus, elapsed)
		
		--> Target of Focus
		Smooth_Update(f.ToF.Health)
		--Smooth_Update(f.ToF.Power)
		L.OnUpdate_ToF(f.ToF, elapsed)
		
		--> Aura
		L.OnUpdate_Aura(f, elapsed)
		
		--> ------------------- for %w+target update
		last1 = last1 + elapsed
		if last1 >= 0.1 then
			last1 = 0
			
			L.OnUpdate_ToT_gap(f.ToT)
			L.OnUpdate_ToF_gap(f.ToF)
			
			L.OnUpdate_Minimap(f.mnMap)
			L.OnUpdate_Artwork_gap(f)
			L.OnUpdate_Config_gap(f.Config)
			
		end
		-----------------------
		
		--> ------------------- 
		last2 = last2 + elapsed
		if last2 >= 1 then
			last2 = 0
			L.OnUpdate_Minimap_gap(f.mnMap)
			--normalTexture = _G["ActionButton1"]:GetNormalTexture()
			--print(normalTexture: GetAlpha())
			--UpdateAddOnMemoryUsage()
			--UpdateAddOnCPUUsage()
			--print(GetAddOnMemoryUsage("Vii"), GetAddOnCPUUsage("Vii"))
			--[[
			local button = _G["ActionButton1"]
			start, duration, enable = GetActionCooldown(button.action);
			charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(button.action)
			print(button.spellID, start, duration, enable)
			-]]
		end
		-----------------------
	end)
end

--- ----------------------------------------------------------------------
--> OverWatch Display
--- ----------------------------------------------------------------------
OwD = CreateFrame("Frame", "OwD", UIParent)
OwD: SetSize(8,8)
OwD: SetPoint("CENTER", UIParent, "CENTER", 0,0)
--OwD: SetAlpha(1)
OwD: SetScale(OwD_DB["OwD_Scale"])

L.Init = function()
	-->
	L.Player_Frame(OwD)
	L.FCS_Frame(OwD)
	L.Right(OwD)
	--L.GCD(OwD)
	L.Pet_Frame(OwD)
	L.Target_Frame(OwD)
	L.ToT_Frame(OwD)
	L.Focus_Frame(OwD)
	L.ToF_Frame(OwD)

	-->
	L.Aura(OwD)
	L.AuraFrame(OwD)
	L.ActionBar(OwD)

	L.create_Castbar(OwD.Player, OwD.FCS, "player")
	L.create_Castbar(OwD.Target, OwD.Target, "target")
	L.create_Castbar(OwD.Focus, OwD.Focus, "focus")

	L.create_AltPower(OwD.Player, "player")
	L.create_AltPower(OwD.Target, "target")

	--L.create_Icons(OwD.Player)
	--L.create_Icons(OwD.Target)
	--L.create_Icons(OwD.Focus)

	--> Module
	--L.M.TradeSkillFrame()
	--L.M.AuraTooltip()
	--L.M.DamageFont()
	--L.M.Hunter_Alone(OwD)

	-->
	L.Artwork(OwD)
	L.Feedback(OwD)
	L.create_Unit(OwD)
	L.Config_Frame(OwD)
	L.Move_Frame(OwD)
	L.AuraWatch_Config(OwD)

	onEvent_OwD(OwD)
	onUpdate_OwD(OwD)
end
