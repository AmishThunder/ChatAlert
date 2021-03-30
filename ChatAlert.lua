local ChatAlertFrame = CreateFrame("Frame")

PLAYER_ALERTS = {}
PLAYER_ALERTS["ENTER_COMBAT"] = { print=true, say=false, yell=false, party=false, raid=false, text="Entered Combat" }
PLAYER_ALERTS["EXIT_COMBAT"] = { print=true, say=false, yell=false, party=false, raid=false, text="Exited Combat" }
PLAYER_ALERTS["CURRENT_HEALTH"] = { print=false, say=false, yell=false, party=false, raid=false, text="Current Health {health}" }
PLAYER_ALERTS["CURRENT_MANA"] = { print=false, say=false, yell=false, party=false, raid=false, text="Current Mana {mana}" }
PLAYER_ALERTS["MELEE_HIT"] = { print=true, say=false, yell=false, party=false, raid=false, text="Melee hit for {amount}" }
PLAYER_ALERTS["MELEE_CRITICAL_HIT"] = { print=true, say=false, yell=false, party=false, raid=false, text="Melee CRITICALLY hit for {amount}" }
PLAYER_ALERTS["MELEE_MISS"] = { print=true, say=false, yell=false, party=false, raid=false, text="Melee hit missed" }
PLAYER_ALERTS["SPELL_AURA_APPLIED"] = { print=true, say=false, yell=false, party=false, raid=false, text="Gained Aura {spellName}" }
PLAYER_ALERTS["SPELL_AURA_REMOVED"] = { print=true, say=false, yell=false, party=false, raid=false, text="Removed Aura {spellName}" }
PLAYER_ALERTS["SPELL_HIT"] = { print=true, say=false, yell=false, party=false, raid=false, text="{spellName} hit for {amount}" }
PLAYER_ALERTS["SPELL_CRITICAL_HIT"] = { print=true, say=false, yell=false, party=false, raid=false, text="{spellName} CRITICALLY hit for {amount}" }

ChatAlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
ChatAlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
ChatAlertFrame:RegisterEvent("UNIT_HEALTH");
ChatAlertFrame:RegisterEvent("UNIT_MANA");
ChatAlertFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

function PlayerAlert(playerAlertKey, textParts)
    local alert = PLAYER_ALERTS[playerAlertKey];
    if (alert == nil or alert.enabled == false) then return end;

    local text = alert.text;
    if (textParts ~= nil) then
        for i = 1, #textParts do
            text = string.gsub(text, "{"..textParts[i].id.."}", textParts[i].value)
        end 
    end

    if (alert.print) then print(text); end
    if (alert.say) then end
    if (alert.yell) then end
    if (alert.party) then end
    if (alert.raid) then end
end

ChatAlertFrame:SetScript("OnEvent", function(self,event, ...)
    local playerName = UnitName("player");

    if (event == "PLAYER_REGEN_DISABLED") then
        PlayerAlert("ENTER_COMBAT", nil);
    end

    if (event == "PLAYER_REGEN_ENABLED") then 
        PlayerAlert("EXIT_COMBAT", nil);
    end

    if (event == "UNIT_HEALTH") then 
        PlayerAlert("CURRENT_HEALTH", {{ id="health", value=UnitHealth("player")}});
    end

    if (event == "UNIT_MANA") then 
        --print("Mana: "..UnitMana("player"));
    end

    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then         
        local timestamp, subevent, param3, param4, sourceName, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16, param17, param18, param19, param20, param21 = CombatLogGetCurrentEventInfo()
        print(table.concat({tostringall(CombatLogGetCurrentEventInfo())}, "||"));
        print(sourceName);
        if (sourceName ~= playerName) then return; end

        if (subevent == "SWING_DAMAGE") then
            local criticalHit = param18;
            local amount = param12
            if (criticalHit) then
                PlayerAlert("MELEE_CRITICAL_HIT", {{ id="amount", value=amount}});
            else
                PlayerAlert("MELEE_HIT", {{ id="amount", value=amount}});
            end
        end
        if (subevent == "SWING_MISSED") then
            PlayerAlert("MELEE_HIT", nil);
        end
        if (subevent == "SPELL_AURA_APPLIED") then
            local spellName = param13;
            PlayerAlert("SPELL_AURA_APPLIED", {{ id="spellName", value=spellName}});
        end
        if (subevent == "SPELL_AURA_REMOVED") then
            local spellName = param13;
            PlayerAlert("SPELL_AURA_REMOVED", {{ id="spellName", value=spellName}});
        end
        if (subevent == "SPELL_DAMAGE") then      
            local criticalHit = param21;
            local spellName = param13;
            local amount = param12 ;
            if (criticalHit) then
                PlayerAlert("SPELL_CRITICAL_HIT", {{id="spellName", value=spellName},{ id="amount", value=amount}});
            else
                PlayerAlert("SPELL_HIT", {{id="spellName", value=spellName},{ id="amount", value=amount}});
            end
        end
    end
end)