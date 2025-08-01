local api = require("api")
local CreateTooltip = nil

local SettingsWindow

CLASS_BATTLERAGE = 1
CLASS_WITCHCRAFT = 2
CLASS_DEFENSE = 3
CLASS_AURAMANCY = 4
CLASS_OCCULTISM = 5
CLASS_ARCHER = 6
CLASS_MAGE = 7
CLASS_SHADOWPLAY = 8
CLASS_SONGCRAFT = 9
CLASS_HEALER = 10

STAT_MELEE = 8
STAT_RANGED = 9
STAT_MAGIC = 10
STAT_HEALING = 11
STAT_MELEEHP = 12
STAT_RANGEDHP = 13
STAT_MAGICHP = 14

SORT_MELEE = 1
SORT_RANGED = 2
SORT_MAGIC = 3
SORT_HEALING = 4
SORT_DEFENSE = 5

STAT_ARRAY = {}
STAT_ARRAY[SORT_MELEE] = {STAT_MELEE}
STAT_ARRAY[SORT_RANGED] = {STAT_RANGED}
STAT_ARRAY[SORT_MAGIC] = {STAT_MAGIC}
STAT_ARRAY[SORT_HEALING] = {STAT_HEALING}
STAT_ARRAY[SORT_DEFENSE] = {STAT_MELEEHP, STAT_RANGEDHP, STAT_MAGICHP, STAT_MAGICHP}

DEFAULT_ODE_MAX = 4
DEFAULT_MAX = 50

-- First up is the addon definition!
-- This information is shown in the Addon Manager.
-- You also specify "unload" which is the function called when unloading your addon.
local raid_mgr_addon = {
  name = "Raid Sort",
  author = "Delarme",
  desc = "Sorts the raid",
  version = "1.0.7"
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
    raidmanager.party[fromparty].member[frommember].eventWindow:OnDragStop()
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

local function CreateFilter(name, max, classtable, stattable, postable, continueflag, playertable)
    local data = {}
    data.name = name
    data.max = max
    data.isplayertable = playertable ~= nil
    data.classtable = classtable
    data.stat = stattable
    data.playertable = playertable
    data.posarray = postable
    data.continueflag = continueflag
    return data
end

local savedata
local settings

function GetDefaults()
    local filters = {}
    filters[1] = CreateFilter("Players", DEFAULT_MAX, {}, {}, {}, false, {""})
    filters[2] = CreateFilter("Ode", DEFAULT_ODE_MAX, {CLASS_HEALER, CLASS_SONGCRAFT}, {STAT_HEALING}, {21,22,23,24}, true)
    filters[3] = CreateFilter("Tank", DEFAULT_MAX, {CLASS_OCCULTISM}, {STAT_MELEEHP, STAT_RANGEDHP, STAT_MAGICHP, STAT_MAGICHP}, {1,2,3,4,6,11,16,7,8,9}, false)
    filters[4] = CreateFilter("Mage", DEFAULT_MAX, {CLASS_MAGE}, {STAT_MAGIC}, {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}, false)
    filters[5] = CreateFilter("Melee", DEFAULT_MAX, {CLASS_BATTLERAGE}, {STAT_MELEE}, {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}, false)
    filters[6] = CreateFilter("Ranged", DEFAULT_MAX, {CLASS_ARCHER}, {STAT_RANGED}, {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}, false)
    filters[7] = CreateFilter("Healer", DEFAULT_MAX, {CLASS_HEALER}, {STAT_HEALING}, {5,10,15,20,25,30,35,40,45,46,47,48,49,50}, false)

    return filters
end


function GetDefaultSettings()
    settings = {}
    settings.autoquery = true
    settings.autosort = false
end

SAVEFILEFILTERS = "raidsort\\data\\filters.lua"
_SETTINGSFILE = "raidsort\\data\\settings.lua"

function LoadFilters()
	return api.File:Read(SAVEFILEFILTERS)
end
function LoadSettings()
    return api.File:Read(_SETTINGSFILE)
end

function LoadData()
    local loaded, data = pcall(LoadFilters)
    if loaded and data ~= nil then 
        savedata = data
    else
        savedata = GetDefaults()
    end
    local loadsettings, settingdata = pcall(LoadSettings)
    if loadsettings and settingdata ~= nil then
        settings = settingdata
    else
       GetDefaultSettings()
    end
end

function SaveData(filtersettings, globalsettings)
	api.File:Write(SAVEFILEFILTERS, filtersettings)
    api.File:Write(_SETTINGSFILE, globalsettings)
end


local function IsNameMatch(filterobject, name)
    for i = 1, #filterobject.playertable do
        if name == filterobject.playertable[i] then
            return true, filterobject.max - i
        end
    end
    return false, 0
end

local function IsClassMatch(filterobject, classes)
    local matchcount = 0
    for k,v in pairs(classes) do
        for i = 1, #filterobject.classtable do
            if v == filterobject.classtable[i] then
                matchcount = matchcount + 1
            end
        end
    end
    return matchcount == #filterobject.classtable
end

local function GetStatValue(filterobject, data)
    local retval = 0
    for i = 1, #filterobject.stat do
        retval = retval + data[filterobject.stat[i]]
    end
    return retval
end

posstartarray = {}
maxarray = {}
local function ResetRaidTable()
    for i = 1, 50 do
        raidtable[i] = false
    end
    for i = 1, #savedata do
        posstartarray[i] = 1
        maxarray[i] = 0
    end
end

local function FilterGetNext(filterobject, index)
    --api.Log:Info("FilterGetNext " .. posstartarray[index] .. " " .. #filterobject.posarray)
    if maxarray[index] >= filterobject.max then
        return 0
    end

    for i = posstartarray[index], #filterobject.posarray do
        local idx = filterobject.posarray[i]
        --api.Log:Info(idx)
        if raidtable[idx] == false then
            maxarray[index] = maxarray[index] + 1
            raidtable[idx] = true
            return idx
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
            data = cachedData[name]
            gotdata = true
        end        
    else
        cachedData[name] = data
    end

    local gotunitinfo, info = pcall(GetUnitInfo, uid)
    
    if gotunitinfo == false or info == nil then
    
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
    local sortdata = {}
    for i = 1, #savedata do
        sortdata[i] = {}
    end
    for i = 1, 50 do
        local unitid, uid = GetUnit(i)
        local name = GetName(i)
        local success, data, info = GetOrGetCache(unitid, uid, name)
        if uid ~= nil and success then
            for ii = 1, #savedata do
                local add = false
                local stat = 0
                if savedata[ii].isplayertable then
                    local isMatch
                    isMatch, stat = IsNameMatch(savedata[ii], name)
                    if (isMatch  == true) then
                        add = true
                    end
                else
                    if IsClassMatch(savedata[ii], info.class) then
                        add = true
                        stat = GetStatValue(savedata[ii], data)
                    end
                end
                if add then
                    local tdata = {["id"]=name, ["value"] = stat}
                    table.insert(sortdata[ii], tdata)
                    if (savedata[ii].continueflag == false) then
                        break
                    end
                end
            end
        end
    end
    
    for i = 1, #savedata do
        local playerlist = sortdata[i]
        local filterobject = savedata[i]
        table.sort(playerlist, sortvalue)
        for ii = 1, #playerlist do
            unit = playerlist[ii]
            pos = FilterGetNext(filterobject, i)
            if filterobject.continueflag == true then
                for iii = i + 1, #savedata do
                    RemoveFromTable(sortdata[iii], unit.id)
                end
            end
            local idx = GetMemberIndexByName(unit.id)
            if pos ~= 0 then
                Swap(idx, pos)
            end
        end
    end
end




function OnCloseSettings(filters, newsettings)
    if filters ~= savedata then
        savedata = filters
    end
    if settings ~= newsettings then
        settings = newsettings
    end

    SaveData(savedata, settings)
end
function OpenSettings()
     SettingsWindow:Open(savedata, settings, OnCloseSettings)
end

local counter = 0

local teammember = 0
local sortcounter = 0


local function DoUpdate(dt)
    if updaterunning then
        return
    end
    updaterunning = true
    counter = counter + 1
    if counter >= 60 then
        counter = 0

        if api.Team:IsPartyTeam() then
            updaterunning = false
            return
        end
        local mypos = api.Team:GetTeamPlayerIndex()
        if mypos == 0 then
            updaterunning = false
            return
        end
        
        local myunitid = "team" .. mypos
        local isleader = api.Unit:UnitTeamAuthority(myunitid) == "leader"

        if settings.autoquery then
            teammember = teammember + 1
            if teammember >= 51 then
                teammember = 1
            end

            local unitid, uid = GetUnit(teammember)
            if uid ~= nil then
                local name = GetName(teammember)
                local success, data, info = GetOrGetCache(unitid, uid, name)
            end
        end

        if settings.autosort and isleader then
            sortcounter = sortcounter + 1
            if sortcounter >= 3 then
                SortRaid()
                sortcounter = 0
            end
        end

    end
    updaterunning = false
end

local function OnUpdate(dt)
    
    local success, err = pcall(DoUpdate, dt)
    if success == false then
        api.Log:Err(err)

    end
    
end
-- The Load Function is called as soon as the game loads its UI. Use it to initialize anything you need!
local function Load() 
    SettingsWindow = require("raidsort\\settingswindow")
    CreateTooltip = api._Library.UI.CreateTooltip
    LoadData()
    SaveData(savedata, settings)

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
    if raidmanager == nil then
        return
    end
    if raidmanager.sortBtn ~= nil then
        raidmanager.sortBtn:Show(false)
        raidmanager.sortBtn = nil
    end
    if SettingsWindow ~= nil then
        SettingsWindow:OnClose()
        SettingsWindow:Show(false)
        SettingsWindow = nil
    end
end

-- Here we make sure to bind the functions we defined to our addon. This is how the game knows what function to use!
raid_mgr_addon.OnLoad = Load
raid_mgr_addon.OnUnload = Unload
raid_mgr_addon.OnSettingToggle = OpenSettings
api.On("UPDATE", OnUpdate)

return raid_mgr_addon