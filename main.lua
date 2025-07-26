local api = require("api")
local CreateTooltip = nil
-- First up is the addon definition!
-- This information is shown in the Addon Manager.
-- You also specify "unload" which is the function called when unloading your addon.
local raid_mgr_addon = {
  name = "Raid Sort",
  author = "Delarme",
  desc = "Sorts the raid",
  version = "0.1"
}
local raidmanager

local function GetPartyAndMember(index)
    
    index = index - 1
    local party = math.floor(index / 5) + 1
    local member = math.fmod(index, 5) + 1
   
    return party, member
end

local function GetName(index)
        local party, member = GetPartyAndMember(index)
        return raidmanager.party[party].member[member].nameLabel:GetText()  
end

local function Swap(fromindex, toindex)

    fromname = GetName(fromindex)
    toname = GetName(toindex)
    local fromteam = "team" .. fromindex
    local toteam = "team" .. toindex
    fromindex = fromindex - 1
    local fromparty = math.floor(fromindex / 5) + 1
    local frommember = math.fmod(fromindex, 5) + 1
    toindex = toindex - 1
    local toparty = math.floor(toindex / 5) + 1
    local tomember = math.fmod(toindex, 5) + 1

    raidmanager.party[fromparty].member[frommember].eventWindow:OnDragStart()
    raidmanager.party[toparty].member[tomember].eventWindow:OnDragReceive()

end
function sortvalue(a, b)
    return a.value > b.value
end
function RemoveFromTable(_table, id)
    for i = 1, #_table do
        if _table[i].id == id then
            table.remove(_table, i)
            return
        end
    end
end
local raidtable = {}
for i = 1,50 do
    table.insert(raidtable, false)
end

TYPEODE = 1
TYPETANK = 2
TYPEMAGE = 3
TYPEMELEE = 4
TYPERANGED = 5
TYPEHEALER = 6
odepos = {21,22,23,24}
healerpos = {5,10,15,20,25,30,35,40,45,46,47,48,49,50}
tankpos = {1,2,3,4,6,11,16,7,8,9}
elsepos = {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}

odestart = 1
tankstart = 1
healerstart = 1
elsestart = 1

local function ResetRaidTable()
    for i = 1, 50 do
        raidtable[i] = false
    end
    odestart = 1
    tankstart = 1
    healerstart = 1
    elsestart = 1
end

local function GetNext(Type)
    if Type == TYPEODE then
        for i = odestart, #odepos do
            if raidtable[odepos[i]] == false then
                raidtable[odepos[i]] = true
                odestart = i + 1
                return odepos[i]
            end
        end
    elseif Type == TYPETANK then
        for i = tankstart, #tankpos do
            if raidtable[tankpos[i]] == false then
                raidtable[tankpos[i]] = true
                tankstart = i + 1
                return tankpos[i]
            end
        end
    elseif Type == TYPEHEALER then
        for i = healerstart, #healerpos do
            if raidtable[healerpos[i]] == false then
                raidtable[healerpos[i]] = true
                healerstart = i + 1
                return healerpos[i]
            end
        end
    else 
        for i = elsestart, #elsepos do
            if raidtable[elsepos[i]] == false then
                raidtable[elsepos[i]] = true
                elsestart = i + 1
                return elsepos[i]
            end
        end
    end
    for i = 1, 50 do
        if raidtable[i] == false then
            raidtable[i] = true
            return i
        end
    end
    return 0
end
local function GetUnitInfo(uid)
    return api.Unit:GetUnitInfoById(uid)
end

cachedData = {}
cachedInfo = {}

local function GetOrGetCache(unitid, uid, name)
    
    if(uid == nil) then
        return false, nil, nil
    end
    local gotdata, data = pcall(api._Addons.AdvStats.GetData, unitid)
    

    if gotdata == false then
        if cachedData[name] ~= nil then
            info = cachedData[name]
            gotdata = true
        end        
    else
        cachedData[name] = data
    end
    local gotunitinfo, info = pcall(GetUnitInfo, uid)
    
    if gotunitinfo == false then
    
        if cachedInfo[name] ~= nil then
            info = cachedInfo[name]
            gotunitinfo = true
        end
    else 
        cachedInfo[name] = info
    end
    
    return gotdata and gotunitinfo, data, info
end

local function GetUnit(pos)
    local unitid = "team" .. pos
    
    local uid = api.Unit:GetUnitId(unitid)
    if uid ~= nil then
        --cachedId[unitid] = uid
        return unitid, uid
    end
    return nil, nil
end

local function GetMemberIndexByName(name)
    local i = 0
    for i = 1, 50 do
        local unit = "team" .. i
        if api.Unit:GetUnitId(unit) ~= nil then
            if GetName(i) == name then
                return i
            end
        end
    end
    return nil
end

local function SortRaid()
    ResetRaidTable()
    
    odel = {}
    healers = {}
    mdps = {}
    rdps = {}
    mages = {}
    tanks = {}

    for i = 1,50 do
  
        local unitid, uid = GetUnit(i)
        local name = GetName(i)
        local success, data, info = GetOrGetCache(unitid, uid, name)
        
        if uid ~= nil and success then
            
            --local data = msg
            --local data = api._Addons.AdvStats.GetData(unitid)
            --local info = GetUnitInfo(uid)
            --api.Log:Info(name)
            local battle = false
            local occult = false
            local mage = false
            local ranged = false
            local healer = false
            local ode = false
            local song = false
            --api.Log:Info(info.class)
            for k,v in pairs(info.class) do
                --api.Log:Info(v)
                if v == 4 then
                    --aura
                elseif v == 10 then
                    healer = true
                elseif v == 9 then
                    song = true
                elseif v == 8 then
                    --shadowplay
                elseif v == 1 then
                    battle = true
                elseif v == 2 then
                    --witchcraft
                elseif v == 5 then
                    occult = true
                elseif v == 3 then
                    --defense
                elseif v == 6 then
                    ranged = true
                elseif v == 7 then
                    mage = true
                else
                    --api.Log:Info(v)
                end
            end
            if healer and song then
                ode = true
            end
            if battle then 
               healer = false
               ode = false
               occult = false
               mage = false
               ranged = false
               --api.Log:Info(data[8])
               local tdata = {["id"]=name, ["value"] = data[8]}
               table.insert(mdps, tdata)
            end

            if occult then 
               healer = false
               ode = false
               mage = false
               ranged = false
               local defense = data[12] + data[13] + data[14] + data[14]
               local tdata = {["id"]=name, ["value"] = defense}
               table.insert(tanks, tdata)
            end

            if mage then 
               healer = false
               ode = false
               ranged = false
               --api.Log:Info(data[10])
               local tdata = {["id"]=name, ["value"] = data[10]}
               table.insert(mages, tdata)
            end

            if ranged then 
               healer = false
               ode = false
               --api.Log:Info(data[8])
               local tdata = {["id"]=name, ["value"] = data[9]}
               table.insert(rdps, tdata)
            end


            if healer then 
               local tdata = {["id"]=name, ["value"] = data[11]}
               table.insert(healers, tdata)
            end
            if ode then
               local tdata = {["id"]=name, ["value"] = data[11]}
               table.insert(odel, tdata)
            end           
        end
        
        
    end

    table.sort(odel, sortvalue)
    --api.Log:Info("#healers b " .. #healers)
    local k = #odel
    if k > 4 then
        k = 4
    end

    for i = 1, k do
        unit = odel[i]
        pos = GetNext(TYPEODE)
        RemoveFromTable(healers, unit.id)
        local idx = GetMemberIndexByName(unit.id)
        Swap(idx, pos)
    end
    --api.Log:Info("#healers a " .. #healers)
    --api.Log:Info("#tanks a " .. #tanks)
    --api.Log:Info("#mages a " .. #mages)
    --api.Log:Info("#mdps a " .. #mdps)
    --api.Log:Info("#rdps a " .. #rdps)

    --put tanks and mages in First
    table.sort(tanks, sortvalue)
    for i = 1, #tanks do
        pos = GetNext(TYPETANK)
        unit = tanks[i]
        local idx = GetMemberIndexByName(unit.id)
        Swap(idx, pos)
    end

    table.sort(mages, sortvalue)
    for i = 1, #mages do
        pos = GetNext(TYPEMAGE)
        unit = mages[i]
        local idx = GetMemberIndexByName(unit.id)
        --api.Log:Info(unit.id)
        --api.Log:Info(idx .. " " .. pos)
        Swap(idx, pos)
    end

    table.sort(mdps, sortvalue)
    for i = 1, #mdps do
        pos = GetNext(TYPEMELEE)
        unit = mdps[i]
        local idx = GetMemberIndexByName(unit.id)

        Swap(idx, pos)
    end

    table.sort(rdps, sortvalue)
    for i = 1, #rdps do
        pos = GetNext(TYPERANGED)
        unit = rdps[i]
        local idx = GetMemberIndexByName(unit.id)
        Swap(idx, pos)
    end

    table.sort(healers, sortvalue)
    for i = 1, #healers do
        
        pos = GetNext(TYPEHEALER)
        unit = healers[i]
        --api.Log:Info(unit.id)
        local idx = GetMemberIndexByName(unit.id)
        --api.Log:Info(idx .. " " .. pos)
        Swap(idx, pos)
    end

end
local function Testing()
    api.Log:Info("UnitInfo")
    local unit = "team1"
    --api.Log:Info(api.Unit:UnitInfo("team1")) -- doesnt work when out of range
    api.Log:Info(api.Team:GetMemberIndexByName("Evergreen")) --works when out of ranged
    api.Log:Info(tostring(api.Unit:UnitIsTeamMember(unit))) -- works when out of range
    local id = api.Unit:GetUnitId(unit) -- works out of range...
    api.Log:Info(tostring(id))
    --local name = api.Unit:GetUnitScreenNameTagOffset(unit) -- does not work out of range
    --api.Log:Info(tostring(name))
    local text = raidmanager.party[1].member[1].nameLabel:GetText() -- we can get name this way
    api.Log:Info(text)
end


-- The Load Function is called as soon as the game loads its UI. Use it to initialize anything you need!
local function Load() 
    CreateTooltip = api._Library.UI.CreateTooltip
    raidmanager = ADDON:GetContent(UIC.RAID_MANAGER )

    if raidmanager.sortBtn ~= nil then
        raidmanager.sortBtn:Show(false)
        raidmanager.sortBtn = nil
    end

    local sortBtn = raidmanager:CreateChildWidget("button", "sortBtn", 0, false)
    sortBtn:AddAnchor("BOTTOMRIGHT", raidmanager, -20, -60)
    
    ApplyButtonSkin(sortBtn, BUTTON_CONTENTS.INVENTORY_SORT)
    CreateTooltip("sorttooltip", sortBtn, "Auto Sort Raid")
    sortBtn.tooltip:RemoveAllAnchors()
    sortBtn.tooltip:AddAnchor("BOTTOM", sortBtn, "TOP", 0, -1)
    raidmanager.sortBtn = sortBtn

    sortBtn:SetHandler("OnClick", SortRaid)

end

-- Unload is called when addons are reloaded.
-- Here you want to destroy your windows and do other tasks you find useful.
local function Unload()
    if raidmanager.testbtn2 ~= nil then
        raidmanager.testbtn2:Show(false)
        raidmanager.testbtn2 = nil
    end
    if raidmanager.sortBtn ~= nil then
        raidmanager.sortBtn:Show(false)
        raidmanager.sortBtn = nil
    end
    if raidmanager.testbtn1 ~= nil then
        raidmanager.testbtn1:Show(false)
        raidmanager.testbtn1 = nil
    end
end
--api.On("ShowPopUp", OnRightClickMenu)
-- Here we make sure to bind the functions we defined to our addon. This is how the game knows what function to use!
raid_mgr_addon.OnLoad = Load
raid_mgr_addon.OnUnload = Unload


return raid_mgr_addon
