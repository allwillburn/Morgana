if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
 LoadMixLib()
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() Print("Update Complete, please 2x F6!") return end)
end

if GetObjectName(GetMyHero()) ~= "Morgana" then return end

require("OpenPredict")
require("DamageLib")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/UrgotURF/master/Urgot.lua', SCRIPT_PATH .. 'UrgotURF.lua', function() PrintChat('<font color = "#00FFFF">Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0
local MorganaMenu = Menu("Morgana", "Morgana")

MorganaMenu:SubMenu("Combo", "Combo")

MorganaMenu.Combo:Boolean("Q", "Use Q in combo", true)
MorganaMenu.Combo:Boolean("W", "Use W in combo", true)
MorganaMenu.Combo:Boolean("E", "Use E in combo", true)
MorganaMenu.Combo:Boolean("R", "Use R in combo", true)

MorganaMenu:SubMenu("URFMode", "URFMode")
MorganaMenu.URFMode:Boolean("Level", "Auto level spells", true)
MorganaMenu.URFMode:Boolean("Ghost", "Auto Ghost", true)
MorganaMenu.URFMode:Boolean("Q", "Auto Q", true)
MorganaMenu.URFMode:Boolean("W", "Auto W", true)
MorganaMenu.URFMode:Boolean("E", "Auto E", true)

MorganaMenu:SubMenu("LaneClear", "LaneClear")
MorganaMenu.LaneClear:Boolean("Q", "Use Q", true)
MorganaMenu.LaneClear:Boolean("W", "Use W", true)

MorganaMenu:SubMenu("Harass", "Harass")
MorganaMenu.Harass:Boolean("Q", "Use Q", true)
MorganaMenu.Harass:Boolean("W", "Use W", true)

MorganaMenu:SubMenu("KillSteal", "KillSteal")
MorganaMenu.KillSteal:Boolean("Q", "KS w Q", true)
MorganaMenu.KillSteal:Boolean("W", "KS w W", true)

MorganaMenu:SubMenu("AutoIgnite", "AutoIgnite")
MorganaMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

MorganaMenu:SubMenu("Drawings", "Drawings")
MorganaMenu.Drawings:Boolean("DQ", "Draw Q Range", true)
MorganaMenu.Drawings:Boolean("DW", "Draw W Range", true)
MorganaMenu.Drawings:Boolean("DR", "Draw R Range", true)

MorganaMenu:SubMenu("SkinChanger", "SkinChanger")
MorganaMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
MorganaMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	local target = GetCurrentTarget()

	--AUTO LEVEL UP
	if MorganaMenu.URFMode.Level:Value() then

			spellorder = {_Q, _W, _E, _Q, _W, _R, _Q, _W, _W, _Q, _R, _Q, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
                if Mix:Mode() == "Harass" then
            if MorganaMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1175) then
				CastSkillShot(_Q, target)
                        end
            if MorganaMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 900) then
				CastSkillShot(_W, target.pos)
                        end
               end
	--COMBO
		if Mix:Mode() == "Combo" then
            if MorganaMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1175) then
				CastSkillShot(_Q, target)
                        end

            if MorganaMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 900) then
				CastSkillShot(_W, target.pos)
                        end 
   	    
	    if MorganaMenu.Combo.E:Value() and Ready(_E) then
				CastSpell(_E)
			end
	    
            if MorganaMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 600) then
				CastTargetSpell(target, _R)
                        end

            end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 1175) and MorganaMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
		         CastSkillShot(_Q, enemy)
		
                end 

                if IsReady(_W) and ValidTarget(enemy, 900) and MorganaMenu.KillSteal.W:Value() and GetHP(enemy) < getdmg("E",enemy) then
		         CastSkillShot(_W, target.pos)
  
                end
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if MorganaMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 1000) then
	        	CastSkillShot(_Q, closeminion)
	        end
                if MorganaMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 900) then
	        	CastSkillShot(_W, closeminion)
	        end
      	  end
      end
        --URFMode
        if MorganaMenu.URFMode.Q:Value() then        
          if Ready(_Q) and ValidTarget(target, 1175) then
						CastSkillShot(_Q, target)
          end
        end 
        if MorganaMenu.URFMode.W:Value() then        
          if Ready(_E) then
	  	      CastSpell(_E)
          end
        end
         if MorganaMenu.URFMode.W:Value() then        
           if Ready(_W) and ValidTarget(target, 900) then
						CastSkillShot(_W, target.pos)
           end
        end
        
	       
 
                
	--AUTO GHOST
	if MorganaMenu.URFMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnDraw(function (myHero)
        
         if MorganaMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 1175, 0, 200, GoS.Red)
	end

	if MorganaMenu.Drawings.DW:Value() then
		DrawCircle(GetOrigin(myHero), 900, 0, 200, GoS.Blue)
	end

	if MorganaMenu.Drawings.DR:Value() then
		DrawCircle(GetOrigin(myHero), 600, 0, 200, GoS.Green)
	end

end)

local function SkinChanger()
	if MorganaMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Morgana</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')

