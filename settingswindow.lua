local CreateCheckButton = api._Library.UI.CreateCheckButton
local w

local VERSION = 1.0

local ROWPADDING = 16

local LIST_COLUMN_HEIGHT = 35
local ROWDATA_COLUMN_OFFSET = 1

local CLASS_NONE = 0
local CLASS_BATTLERAGE = 1
local CLASS_WITCHCRAFT = 2
local CLASS_DEFENSE = 3
local CLASS_AURAMANCY = 4
local CLASS_OCCULTISM = 5
local CLASS_ARCHER = 6
local CLASS_MAGE = 7
local CLASS_SHADOWPLAY = 8
local CLASS_SONGCRAFT = 9
local CLASS_HEALER = 10

local CLASSTABLE = {}
CLASSTABLE[CLASS_BATTLERAGE] = "B "
CLASSTABLE[CLASS_WITCHCRAFT] = "W "
CLASSTABLE[CLASS_DEFENSE] = "D "
CLASSTABLE[CLASS_AURAMANCY] = "Au "
CLASSTABLE[CLASS_OCCULTISM] = "O "
CLASSTABLE[CLASS_ARCHER] = "Ar "
CLASSTABLE[CLASS_MAGE] = "Sor "
CLASSTABLE[CLASS_SHADOWPLAY] = "Sh "
CLASSTABLE[CLASS_SONGCRAFT] = "Son "
CLASSTABLE[CLASS_HEALER] = "V "

local OFFSETFORCONTROL = 1
local CLASSTABLENAME = {}
CLASSTABLENAME[CLASS_NONE + OFFSETFORCONTROL] = "None        "
CLASSTABLENAME[CLASS_BATTLERAGE + OFFSETFORCONTROL] = "Battlerage"
CLASSTABLENAME[CLASS_WITCHCRAFT + OFFSETFORCONTROL] = "Witchcraft"
CLASSTABLENAME[CLASS_DEFENSE + OFFSETFORCONTROL] = "Defense"
CLASSTABLENAME[CLASS_AURAMANCY + OFFSETFORCONTROL] = "Auramancy"
CLASSTABLENAME[CLASS_OCCULTISM + OFFSETFORCONTROL] = "Occultism"
CLASSTABLENAME[CLASS_ARCHER + OFFSETFORCONTROL] = "Archery"
CLASSTABLENAME[CLASS_MAGE + OFFSETFORCONTROL] = "Sorcery"
CLASSTABLENAME[CLASS_SHADOWPLAY + OFFSETFORCONTROL] = "Shadowplay"
CLASSTABLENAME[CLASS_SONGCRAFT + OFFSETFORCONTROL] = "Songcraft"
CLASSTABLENAME[CLASS_HEALER + OFFSETFORCONTROL] = "Vitalism"

local STAT_MELEE = 8
local STAT_RANGED = 9
local STAT_MAGIC = 10
local STAT_HEALING = 11
local STAT_MELEEHP = 12
local STAT_RANGEDHP = 13
local STAT_MAGICHP = 14

local SORT_MELEE = 1
local SORT_RANGED = 2
local SORT_MAGIC = 3
local SORT_HEALING = 4
local SORT_DEFENSE = 5
local SORT_OTHER = 0

local STAT_ARRAY = {}
STAT_ARRAY[SORT_MELEE] = {STAT_MELEE}
STAT_ARRAY[SORT_RANGED] = {STAT_RANGED}
STAT_ARRAY[SORT_MAGIC] = {STAT_MAGIC}
STAT_ARRAY[SORT_HEALING] = {STAT_HEALING}
STAT_ARRAY[SORT_DEFENSE] = {STAT_MELEEHP, STAT_RANGEDHP, STAT_MAGICHP, STAT_MAGICHP}

local STAT_ARRAYNAME = {}
STAT_ARRAYNAME[SORT_OTHER] = "Other"
STAT_ARRAYNAME[SORT_MELEE] = "Melee Damage"
STAT_ARRAYNAME[SORT_RANGED] = "Ranged Damage"
STAT_ARRAYNAME[SORT_MAGIC] = "Magic Damage"
STAT_ARRAYNAME[SORT_HEALING] = "Healing Power"
STAT_ARRAYNAME[SORT_DEFENSE] = "Tank"

local DEFAULT_ODE_MAX = 4
local DEFAULT_MAX = 50



local function SetButtonFontColor(button, color)
    local n = color.normal
    local h = color.highlight
    local p = color.pushed
    local d = color.disabled
    button:SetTextColor(n[1], n[2], n[3], n[4])
    button:SetHighlightTextColor(h[1], h[2], h[3], h[4])
    button:SetPushedTextColor(p[1], p[2], p[3], p[4])
    button:SetDisabledTextColor(d[1], d[2], d[3], d[4])
end

local function GetButtonDefaultFontColor()
    local color = {}
    color.normal = {ConvertColor(104), ConvertColor(68), ConvertColor(18), 1}
    color.highlight = {ConvertColor(154), ConvertColor(96), ConvertColor(16), 1}
    color.pushed = {ConvertColor(104), ConvertColor(68), ConvertColor(18), 1}
    color.disabled = {ConvertColor(92), ConvertColor(92), ConvertColor(92), 1}
    return color
end

local function SettingListColumn(listCtrl, column)
  listCtrl:SetColumnHeight(LIST_COLUMN_HEIGHT)
  api.Interface:ApplyButtonSkin(column, BUTTON_BASIC.LISTCTRL_COLUMN)
  column.style:SetShadow(false)
  column.style:SetFontSize(FONT_SIZE.LARGE)
  SetButtonFontColor(column, GetButtonDefaultFontColor())
end

local function DrawListCtrlUnderLine(listCtrl, offsetY, colorWhite, offsetX)
  if colorWhite == nil then
    colorWhite = false
  end
  local width = listCtrl:GetWidth()
  if offsetX == nil then
    offsetX = 0
  end
  local underLine_1 = listCtrl:CreateImageDrawable(TEXTURE_PATH.TAB_LIST, "artwork")
  underLine_1:SetCoords(0, 6, 256, 3)
  underLine_1:SetExtent(width / 2, 3)
  local underLine_2 = listCtrl:CreateImageDrawable(TEXTURE_PATH.TAB_LIST, "artwork")
  underLine_2:SetCoords(256, 6, -256, 3)
  underLine_2:SetExtent(width / 2, 3)
  if not colorWhite then
    underLine_1:SetColor(ConvertColor(73), ConvertColor(45), ConvertColor(11), 1)
    underLine_2:SetColor(ConvertColor(73), ConvertColor(45), ConvertColor(11), 1)
  end
  if offsetY == nil then
    underLine_1:AddAnchor("TOPLEFT", listCtrl, offsetX, LIST_COLUMN_HEIGHT - 2)
    underLine_2:AddAnchor("TOPRIGHT", listCtrl, -offsetX, LIST_COLUMN_HEIGHT - 2)
  else
    underLine_1:AddAnchor("TOPLEFT", listCtrl, offsetX, offsetY)
    underLine_2:AddAnchor("TOPRIGHT", listCtrl, -offsetX, offsetY)
  end
end

local function DrawListCtrlColumnSperatorLine(widget, totalCount, count, colorWhite)
  local inset = 3
  if colorWhite == nil then
    colorWhite = false
  end
  local divideLine
  if count < totalCount then
    divideLine = widget:CreateImageDrawable("ui/common/tab_list.dds", "overlay")
    if count % 3 == 1 then
      divideLine:SetExtent(24, 55)
      divideLine:SetCoords(182, 9, 24, 55)
      divideLine:AddAnchor("BOTTOMLEFT", widget, "BOTTOMRIGHT", 0, 33)
    elseif count % 3 == 2 then
      divideLine:SetExtent(25, 51)
      divideLine:SetCoords(206, 9, 25, 51)
      divideLine:AddAnchor("BOTTOMLEFT", widget, "BOTTOMRIGHT", 0, 22)
    else
      divideLine:SetExtent(25, 15)
      divideLine:SetCoords(231, 9, 25, 15)
      divideLine:AddAnchor("BOTTOMLEFT", widget, "BOTTOMRIGHT", 0, 0)
    end
    if not colorWhite then
      divideLine:SetColor(ConvertColor(114), ConvertColor(94), ConvertColor(50), 1)
    end
  end
  return divideLine
end

local function GetColumnRow(index)
    
    index = index - 1
    local column = math.floor(index / 5) + 1
    local row = math.fmod(index, 5) + 1
    if column > 5 then
        column = column - 5
        row = row + 6
    end
    return column, row
end

local function getSortOption(array)
    if (array == nil or #array == 0) then
        return SORT_OTHER
    end
    if #array == 1 then
        if array[1] == STAT_MELEE then
            return SORT_MELEE
        end
        if array[1] == STAT_MAGIC then
            return SORT_MAGIC
        end
        if array[1] == STAT_RANGED then
            return SORT_RANGED
        end
        if array[1] == STAT_HEALING then
            return SORT_HEALING
        end
    end
    if #array == 4 then
        if array[1] == STAT_MELEEHP and array[2] == STAT_RANGEDHP and array[3] == STAT_MAGICHP and array[4] == STAT_MAGICHP then
            return SORT_DEFENSE
        end
    end
    return SORT_OTHER
end

--Rule edit frame

local filtersettingsframe = api.Interface:CreateWindow("RaidSortSettingsWnd", "Rule Settings", 300, 530)
filtersettingsframe:SetTitle("Rule Settings")
filtersettingsframe:AddAnchor("CENTER", "UIParent", 0, 0)
filtersettingsframe:SetCloseOnEscape(true)
filtersettingsframe:Show(false)

filtersettingsframe.parentframe = nil
filtersettingsframe.dataline = 0
filtersettingsframe.rawdata = nil
local function all_trim(s)
   return s:match( "^%s*(.-)%s*$" )
end

function filtersettingsframe:OnClose(save)
    if save ~= nil then
        filtersettingsframe.rawdata.name = filtersettingsframe.nameEditbox:GetText()
        local newmax = tonumber(filtersettingsframe.maxEditbox:GetText())
        if newmax <= 0 or newmax > 50 then
            newmax = 50
        end
        
        filtersettingsframe.rawdata.max = newmax
        --api.Log:Info(tostring(newmax ~= 50))
        filtersettingsframe.rawdata.continueflag = newmax ~= 50
        filtersettingsframe.rawdata.posarray = {}
        for i = 1, #filtersettingsframe.newposarray do
            table.insert(filtersettingsframe.rawdata.posarray, filtersettingsframe.newposarray[i])
        end
        
        
        local type = filtersettingsframe.typeButton:GetSelectedIndex()
        filtersettingsframe.rawdata.classtable = {}
        
        if type == 2 then
            --player type
            filtersettingsframe.rawdata.isplayertable = true
            filtersettingsframe.rawdata.stat = {} -- doesnt matter
            local playerlist = filtersettingsframe.PlayerListBox:GetText()
            local t = {}
            for str in string.gmatch(playerlist, "([^,]+)") do
                table.insert(t, all_trim(str))
            end
            
            filtersettingsframe.rawdata.playertable = t

        else
            filtersettingsframe.rawdata.isplayertable = false
            --class type
            for i = 1, #filtersettingsframe.class do
                local classidx = filtersettingsframe.class[i]:GetSelectedIndex() - OFFSETFORCONTROL
                if classidx > 0 then
                    table.insert(filtersettingsframe.rawdata.classtable, classidx)
                end
            end
            local statgroup = filtersettingsframe.statButton:GetSelectedIndex()
            if statgroup > 0 and statgroup <= #STAT_ARRAY then
                filtersettingsframe.rawdata.stat = {}
                local statarray = STAT_ARRAY[statgroup]
                for i = 1, #statarray do
                    table.insert(filtersettingsframe.rawdata.stat, statarray[i])
                end
            end
        end

        filtersettingsframe.parentframe.filters[filtersettingsframe.dataline] = filtersettingsframe.rawdata
        filtersettingsframe.parentframe:Refresh()
    end
    filtersettingsframe:Show(false)
end


local rulecloseButton = filtersettingsframe:CreateChildWidget("button", "rulecloseButton", 0, false)
rulecloseButton:SetText("Save")
rulecloseButton:AddAnchor("BOTTOM", filtersettingsframe, -45, -10)
ApplyButtonSkin(rulecloseButton, BUTTON_BASIC.DEFAULT)

filtersettingsframe.rulecloseButton = rulecloseButton

local deleteButton = filtersettingsframe:CreateChildWidget("button", "deleteButton", 0, false)
deleteButton:SetText("Delete")
deleteButton:AddAnchor("BOTTOMRIGHT", filtersettingsframe, -10, -10)
ApplyButtonSkin(deleteButton, BUTTON_BASIC.DEFAULT)

filtersettingsframe.deleteButton = deleteButton



function filtersettingsframe:Close()

    filtersettingsframe:OnClose(true)
end

function filtersettingsframe:DeleteRule()
    if filtersettingsframe.parentframe == nil then
        return
    end
    filtersettingsframe.parentframe:RemoveFilter(filtersettingsframe.dataline)
    filtersettingsframe:Show(false)
end
filtersettingsframe.rulecloseButton:SetHandler("OnClick", filtersettingsframe.Close)


filtersettingsframe.deleteButton:SetHandler("OnClick", filtersettingsframe.DeleteRule)

local labeltext = "Rule Name:"
RuleNameLabel = filtersettingsframe:CreateChildWidget("label", "RuleNameLabel", 0, true)
RuleNameLabel:AddAnchor("TOPLEFT", filtersettingsframe, 15, 47 + (FONT_SIZE.LARGE + ROWPADDING) * 0)
RuleNameLabel:SetText(labeltext)
RuleNameLabel:SetHeight(FONT_SIZE.LARGE)
local width = RuleNameLabel.style:GetTextWidth(labeltext) + 14
RuleNameLabel:SetWidth(width)
RuleNameLabel.style:SetFontSize(FONT_SIZE.LARGE)
RuleNameLabel.style:SetAlign(3)
ApplyTextColor(RuleNameLabel, FONT_COLOR.DEFAULT)

local nameEditbox = W_CTRL.CreateEdit("titleEditbox", filtersettingsframe)
nameEditbox:AddAnchor("LEFT", RuleNameLabel, "RIGHT", 0, 0)
nameEditbox:SetExtent(140, 24)
nameEditbox:SetMaxTextLength(15)

filtersettingsframe.nameEditbox = nameEditbox



labeltext = "Rule Type:"
local RuleTypeLabel = filtersettingsframe:CreateChildWidget("label", "RuleTypeLabel", 0, true)
RuleTypeLabel:AddAnchor("BOTTOMLEFT", RuleNameLabel, 0, (FONT_SIZE.LARGE + ROWPADDING))
RuleTypeLabel:SetText(labeltext)
RuleTypeLabel:SetHeight(FONT_SIZE.LARGE)
local width = RuleTypeLabel.style:GetTextWidth(labeltext) + 14
RuleTypeLabel:SetWidth(width)
RuleTypeLabel.style:SetFontSize(FONT_SIZE.LARGE)
RuleTypeLabel.style:SetAlign(3)
ApplyTextColor(RuleTypeLabel, FONT_COLOR.DEFAULT)

typeDisplay = {"Class", "Player"}

local typeButton = api.Interface:CreateComboBox(filtersettingsframe)
typeButton:AddAnchor("LEFT", RuleTypeLabel, "RIGHT", 0, 0)
typeButton:SetExtent(100, 24)
typeButton.dropdownItem = typeDisplay
typeButton:Select(1)
filtersettingsframe.typeButton = typeButton


labeltext = "Max:"
local MaxLabel = filtersettingsframe:CreateChildWidget("label", "MaxLabel", 0, true)
MaxLabel:AddAnchor("BOTTOMLEFT", RuleTypeLabel, 0, (FONT_SIZE.LARGE + ROWPADDING))
MaxLabel:SetText(labeltext)
MaxLabel:SetHeight(FONT_SIZE.LARGE)
local width = MaxLabel.style:GetTextWidth(labeltext) + 14
MaxLabel:SetWidth(width)
MaxLabel.style:SetFontSize(FONT_SIZE.LARGE)
MaxLabel.style:SetAlign(3)
ApplyTextColor(MaxLabel, FONT_COLOR.DEFAULT)

local maxEditbox = W_CTRL.CreateEdit("titleEditbox", filtersettingsframe)
maxEditbox:AddAnchor("LEFT", MaxLabel, "RIGHT", 0, 0)
maxEditbox:SetExtent(30, 24)
maxEditbox:SetMaxTextLength(2)

filtersettingsframe.maxEditbox = maxEditbox

labeltext = "Players:"
local PlayerLabel = filtersettingsframe:CreateChildWidget("label", "PlayerLabel", 0, true)
PlayerLabel:AddAnchor("BOTTOMLEFT", MaxLabel, 0, (FONT_SIZE.LARGE + ROWPADDING))
PlayerLabel:SetText(labeltext)
PlayerLabel:SetHeight(FONT_SIZE.LARGE)
local width = PlayerLabel.style:GetTextWidth(labeltext) + 14
PlayerLabel:SetWidth(width)
PlayerLabel.style:SetFontSize(FONT_SIZE.LARGE)
PlayerLabel.style:SetAlign(3)
ApplyTextColor(PlayerLabel, FONT_COLOR.DEFAULT)
PlayerLabel:Show(false)

local PlayerListBox = W_CTRL.CreateMultiLineEdit("PlayerListBox", filtersettingsframe)
PlayerListBox:AddAnchor("TOPLEFT", PlayerLabel, "TOPRIGHT", 20, 0)
PlayerListBox:SetExtent(170,130)
PlayerListBox:Show(false)
PlayerListBox.textLength = 1000
PlayerListBox:SetMaxTextLength(PlayerListBox.textLength)
PlayerListBox:SetInset(5, 5, 5, 5)
filtersettingsframe.PlayerListBox = PlayerListBox

labeltext = "Class:"
local ClassLabel = filtersettingsframe:CreateChildWidget("label", "ClassLabel", 0, true)
ClassLabel:AddAnchor("BOTTOMLEFT", MaxLabel, 0, (FONT_SIZE.LARGE + ROWPADDING))
ClassLabel:SetText(labeltext)
ClassLabel:SetHeight(FONT_SIZE.LARGE)
local width = ClassLabel.style:GetTextWidth(labeltext) + 14
ClassLabel:SetWidth(width)
ClassLabel.style:SetFontSize(FONT_SIZE.LARGE)
ClassLabel.style:SetAlign(3)
ApplyTextColor(ClassLabel, FONT_COLOR.DEFAULT)



local CLASSBUTTONWIDTH = 100
filtersettingsframe.class = {}



local class1Button = api.Interface:CreateComboBox(filtersettingsframe)
class1Button:SetExtent(CLASSBUTTONWIDTH, 24)

class1Button:AddAnchor("LEFT", ClassLabel, "RIGHT", 20, ROWPADDING / 2)

class1Button.dropdownItem = CLASSTABLENAME
class1Button:Select(1)
--class1Button.style:SetFontSize(FONT_SIZE.LARGE)

filtersettingsframe.class[1] = class1Button

local class2Button = api.Interface:CreateComboBox(filtersettingsframe)
class2Button:AddAnchor("TOP", class1Button, "BOTTOM", 0, ROWPADDING / 2)
class2Button:SetExtent(CLASSBUTTONWIDTH, 24)
class2Button.dropdownItem = CLASSTABLENAME
class2Button:Select(1)
--class2Button.style:SetFontSize(FONT_SIZE.LARGE)

filtersettingsframe.class[2] = class2Button

local class3Button = api.Interface:CreateComboBox(filtersettingsframe)
class3Button:AddAnchor("TOP", class2Button, "BOTTOM", 0, ROWPADDING / 2)
class3Button:SetExtent(CLASSBUTTONWIDTH, 24)
class3Button.dropdownItem = CLASSTABLENAME
class3Button:Select(1)
--class3Button.style:SetFontSize(FONT_SIZE.LARGE)

filtersettingsframe.class[3] = class3Button


labeltext = "Stat:"
local StatLabel = filtersettingsframe:CreateChildWidget("label", "StatLabel", 0, true)
StatLabel:AddAnchor("BOTTOMLEFT", ClassLabel, 0, (FONT_SIZE.LARGE + ROWPADDING) + 70)
StatLabel:SetText(labeltext)
StatLabel:SetHeight(FONT_SIZE.LARGE)
local width = StatLabel.style:GetTextWidth(labeltext) + 14
StatLabel:SetWidth(width)
StatLabel.style:SetFontSize(FONT_SIZE.LARGE)
StatLabel.style:SetAlign(3)
ApplyTextColor(StatLabel, FONT_COLOR.DEFAULT)

local statButton = api.Interface:CreateComboBox(filtersettingsframe)
statButton:AddAnchor("LEFT", StatLabel, "RIGHT", 0, 0)
statButton:SetExtent(130, 24)
statButton.dropdownItem = STAT_ARRAYNAME
statButton:Select(1)

filtersettingsframe.statButton = statButton

labeltext = "Position:"
local PositionLabel = filtersettingsframe:CreateChildWidget("label", "PositionLabel", 0, true)
PositionLabel:AddAnchor("BOTTOMLEFT", StatLabel, 0, (FONT_SIZE.LARGE + ROWPADDING))
PositionLabel:SetText(labeltext)
PositionLabel:SetHeight(FONT_SIZE.LARGE)
local width = StatLabel.style:GetTextWidth(labeltext) + 14
PositionLabel:SetWidth(width)
PositionLabel.style:SetFontSize(FONT_SIZE.LARGE)
PositionLabel.style:SetAlign(3)
ApplyTextColor(PositionLabel, FONT_COLOR.DEFAULT)
filtersettingsframe.positionbutton = {}

local resetposButton = filtersettingsframe:CreateChildWidget("button", "resetposButton", 0, false)
resetposButton:SetText("Reset")
resetposButton:AddAnchor("BOTTOM", PositionLabel, -5, 50)
ApplyButtonSkin(resetposButton, BUTTON_BASIC.DEFAULT)
--resetposButton:SetWidth(70)
filtersettingsframe.resetposButton = resetposButton


filtersettingsframe.currentposition = 0
filtersettingsframe.newposarray = {}

function filtersettingsframe:ResetPosArray()
    for i = 1, 50 do
        filtersettingsframe.positionbutton[i]:Reset()
    end

    filtersettingsframe.currentposition = 0
    filtersettingsframe.newposarray = {}
end

filtersettingsframe.resetposButton:SetHandler("OnClick", filtersettingsframe.ResetPosArray)


local GRIDPADDING = 17
local COLUMNPADDING = 36


for i = 1, 50 do
    local column, row = GetColumnRow(i)
    local checkbutton = CreateCheckButton("positionbutton" .. i, filtersettingsframe, nil)
    checkbutton:AddAnchor("TOPLEFT", PositionLabel, "TOPRIGHT", COLUMNPADDING * column - COLUMNPADDING + 5 , GRIDPADDING * row - GRIDPADDING)
    checkbutton:SetButtonStyle("default")
    checkbutton:Show(true)
    checkbutton.index = i

    function checkbutton:OnCheckChanged()
        
        local checked = self:GetChecked()
        if checked then
            self.label:Show(true)
            filtersettingsframe.currentposition = filtersettingsframe.currentposition + 1
            self.label:SetText(tostring(filtersettingsframe.currentposition))
            self:Enable(false)
            table.insert(filtersettingsframe.newposarray, self.index)
        end
    end

    function checkbutton:Reset()
        
        local checked = self:SetChecked(false)
        self.label:Show(false)
        self:Enable(true)
    end
    checkbutton:SetHandler("OnCheckChanged", checkbutton.OnCheckChanged)

    checkbutton.label = filtersettingsframe:CreateChildWidget("label", "positionbutton" .. i .. "Label", 0, true)
    checkbutton.label:AddAnchor("LEFT", checkbutton, "RIGHT", -4, 0)
    checkbutton.label.style:SetFontSize(FONT_SIZE.LARGE)
    checkbutton.label:SetText("00")
    checkbutton.label:Show(false)
    checkbutton.label.style:SetAlign(3)
    ApplyTextColor(checkbutton.label, FONT_COLOR.DEFAULT)
    filtersettingsframe.positionbutton[i] = checkbutton
    
end

function typeButton:SelectedProc()
    if filtersettingsframe.loading then
        return
    end

    local type = filtersettingsframe.typeButton:GetSelectedIndex()
    if type == 2 then
        for i = 1, #filtersettingsframe.class do
            filtersettingsframe.class[i]:Show(false)
        end
        PlayerListBox:SetText("")
        statButton:Show(false)
        StatLabel:Show(false)
        ClassLabel:Show(false)
        PlayerLabel:Show(true)
        PlayerListBox:Show(true)
    else
        PlayerLabel:Show(false)
        PlayerListBox:Show(false)
        statButton:Show(true)
        StatLabel:Show(true)
        ClassLabel:Show(true)
        statButton:Select(1)
        for i = 1, #filtersettingsframe.class do
            filtersettingsframe.class[i]:Show(true)
        end
        for i = 1, #filtersettingsframe.class do
            filtersettingsframe.class[i]:Select(1)
        end
    end
end

filtersettingsframe.loading = false
function filtersettingsframe:Open(line, w)
    
    local data = w.filters[line]
    filtersettingsframe.loading = true
    filtersettingsframe.parentframe = w
    filtersettingsframe.dataline = line
    filtersettingsframe.rawdata = data
    filtersettingsframe.nameEditbox:SetText(data.name)

    filtersettingsframe.maxEditbox:SetText(tostring(data.max))
    
    filtersettingsframe:ResetPosArray()
    for i = 1, #data.posarray do
        if data.posarray[i] > 0 and data.posarray[i] <= 50 then
            filtersettingsframe.positionbutton[data.posarray[i]]:SetChecked(true)
        end
    end
    if data.isplayertable then
        typeButton:Select(2)
        for i = 1, #filtersettingsframe.class do
            filtersettingsframe.class[i]:Show(false)
        end
        local ptext = ""
        local first = true
        for i = 1, #data.playertable do
            if first == false then
            ptext = ptext .. ", "
            end
            first = false
            ptext = ptext .. data.playertable[i]
        end
        PlayerListBox:SetText(ptext)
        statButton:Show(false)
        StatLabel:Show(false)
        ClassLabel:Show(false)
        PlayerLabel:Show(true)
        PlayerListBox:Show(true)
    else
        PlayerLabel:Show(false)
        PlayerListBox:Show(false)
        statButton:Show(true)
        StatLabel:Show(true)
        ClassLabel:Show(true)
        typeButton:Select(1)
        sortoption = getSortOption(data.stat)
        statButton:Select(sortoption)
        for i = 1, #filtersettingsframe.class do
            filtersettingsframe.class[i]:Show(true)
        end
        for i = 1, #filtersettingsframe.class do
            filtersettingsframe.class[i]:Select(1)
        end
        for i = 1, #data.classtable do
            filtersettingsframe.class[i]:Select(data.classtable[i] + OFFSETFORCONTROL)
        end

    end

    
    filtersettingsframe:Show(true)
    filtersettingsframe.loading = false
end


--

local w = api.Interface:CreateWindow("RaidSortSettingsWnd", "Raid Sort Settings", 600, 700)

w:SetTitle("Raid Sort Settings")
w:AddAnchor("CENTER", "UIParent", 0, 0)
w:SetCloseOnEscape(true)

local closeButton = w:CreateChildWidget("button", "closeButton", 0, false)
closeButton:SetText("Save")
closeButton:AddAnchor("BOTTOM", w, -25, -10)
ApplyButtonSkin(closeButton, BUTTON_BASIC.DEFAULT)

w.closeButton = closeButton
w.Refresh = nil

local text = "Auto-Poll:"
local AutoPollLabel = w:CreateChildWidget("label", "AutoPollLabel", 0, true)
AutoPollLabel:AddAnchor("TOPLEFT", w, 15, 20 + (FONT_SIZE.LARGE + ROWPADDING))
AutoPollLabel:SetText(text)
AutoPollLabel:SetHeight(FONT_SIZE.LARGE)
local width = AutoPollLabel.style:GetTextWidth(text) + 14
AutoPollLabel:SetWidth(width)
AutoPollLabel.style:SetFontSize(FONT_SIZE.LARGE)
AutoPollLabel.style:SetAlign(3)
ApplyTextColor(AutoPollLabel, FONT_COLOR.DEFAULT)


--Enable Auto Polling
w.AutoPoll = CreateCheckButton("autopollcheck", w, nil)
w.AutoPoll:AddAnchor("RIGHT", AutoPollLabel, 24, 0)
w.AutoPoll:SetButtonStyle("default")
w.AutoPoll:Show(true)

--Enable Auto Swap
local text = "Auto-Sort:"
local AutoSortLabel = w:CreateChildWidget("label", "AutoSortLabel", 0, true)
AutoSortLabel:AddAnchor("BOTTOMLEFT", AutoPollLabel, 0 , (FONT_SIZE.LARGE + ROWPADDING))
AutoSortLabel:SetText(text)
AutoSortLabel:SetHeight(FONT_SIZE.LARGE)
AutoSortLabel:SetWidth(width)
AutoSortLabel.style:SetFontSize(FONT_SIZE.LARGE)
AutoSortLabel.style:SetAlign(3)
ApplyTextColor(AutoSortLabel, FONT_COLOR.DEFAULT)


--Enable Auto Sorting
w.AutoSort = CreateCheckButton("autopollcheck", w, nil)
w.AutoSort:AddAnchor("RIGHT", AutoSortLabel, 24, 0)
w.AutoSort:SetButtonStyle("default")
w.AutoSort:Show(true)


text = "Debug:"
local DebugLabel = w:CreateChildWidget("label", "AutoSortLabel", 0, true)
DebugLabel:AddAnchor("BOTTOMLEFT", AutoPollLabel, 400 , 0)
DebugLabel:SetText(text)
DebugLabel:SetHeight(FONT_SIZE.LARGE)
DebugLabel:SetWidth(width + 50)
DebugLabel.style:SetFontSize(FONT_SIZE.LARGE)
DebugLabel.style:SetAlign(3)
ApplyTextColor(DebugLabel, FONT_COLOR.DEFAULT)


--Enable Auto Sorting
w.Debug = CreateCheckButton("debugcheck", w, nil)
w.Debug:AddAnchor("RIGHT", DebugLabel, 24, 0)
w.Debug:SetButtonStyle("default")
w.Debug:Show(true)

text = "Extreme Debug:"
local HighDebugLabel = w:CreateChildWidget("label", "AutoSortLabel", 0, true)
HighDebugLabel:AddAnchor("BOTTOMLEFT", DebugLabel, 0 , (FONT_SIZE.LARGE + ROWPADDING))
HighDebugLabel:SetText(text)
HighDebugLabel:SetHeight(FONT_SIZE.LARGE)
HighDebugLabel:SetWidth(width + 50)
HighDebugLabel.style:SetFontSize(FONT_SIZE.LARGE)
HighDebugLabel.style:SetAlign(3)
ApplyTextColor(HighDebugLabel, FONT_COLOR.DEFAULT)


--Enable Auto Sorting
w.HighDebug = CreateCheckButton("highdebugcheck", w, nil)
w.HighDebug:AddAnchor("RIGHT", HighDebugLabel, 24, 0)
w.HighDebug:SetButtonStyle("default")
w.HighDebug:Show(true)

--Create Filter Header
text = "Filters:"
local FilterLabel = w:CreateChildWidget("label", "FilterLabel", 0, true)
FilterLabel:AddAnchor("BOTTOMLEFT", AutoSortLabel, 0 , (FONT_SIZE.LARGE + ROWPADDING))
FilterLabel:SetText(text)
FilterLabel:SetHeight(FONT_SIZE.LARGE)
FilterLabel:SetWidth(500)
FilterLabel.style:SetFontSize(FONT_SIZE.LARGE)
FilterLabel.style:SetAlign(3)
ApplyTextColor(FilterLabel, FONT_COLOR.DEFAULT)

local addButton = w:CreateChildWidget("button", "addButton", 0, false)
addButton:SetText("Add")
addButton:AddAnchor("LEFT", FilterLabel, 450, 10)
ApplyButtonSkin(addButton, BUTTON_BASIC.DEFAULT)

w.addButton = addButton

local defaultsButton = w:CreateChildWidget("button", "defaultsButton", 0, false)
defaultsButton:SetText("Default")
defaultsButton:AddAnchor("BOTTOMRIGHT", w, -40, -10)
ApplyButtonSkin(defaultsButton, BUTTON_BASIC.DEFAULT)

w.defaultsButton = defaultsButton



w:Show(false)
w.OnCloseCallback = nil
w.filters = nil
w.settings = nil

w.rows = {}

--edit methods

function w:SwapFilterRows(src, dst)
    local temp = w.filters[src]
    w.filters[src] = w.filters[dst]
    w.filters[dst] = temp
    w:Refresh()
end

function w:AddFilter()
    local filter = w:CreateFilter("new", 50, {}, {STAT_MELEE}, {}, false, nil)
    table.insert(w.filters, filter)
    w:Refresh()
end

function w:ResetToDefault()
    w.filters = w:GetDefaults()
    w:Refresh()
end

function w:RemoveFilter(line)
    for i = line, #w.filters do
        if i < #w.filters then
            w.filters[i] = w.filters[i+1]
        else
            w.filters[i] = nil
        end
    end
    w:Refresh()
end

w.addButton:SetHandler("OnClick", w.AddFilter)
w.defaultsButton:SetHandler("OnClick", w.ResetToDefault)

local SetNameFunc = function(subItem, info, setValue)
    subItem:SetText(info.name)
end
local SetMaxFunc = function(subItem, info, setValue)
    subItem:SetText(tostring(info.max))
end

local SetPTFunc = function(subItem, info, setValue)
    if info.isplayertable then
        subItem:SetText("Player")
    else
        subItem:SetText("Class")
    end
    
end

local SetClassFilterFunc = function(subItem, info, setValue)
    if info.isplayertable or info.classtable == nil then
        subItem:SetText("...")
        return
    end
    local text = ""
    for i = 1, #info.classtable do
        text = text .. CLASSTABLE[info.classtable[i]]
    end
    subItem:SetText(text)
end

local SetStatFunc = function(subItem, info, setValue)

    if (info.stat == nil or #info.stat == 0) then
        subItem:SetText("n/a")
        return
    end
    if info.stat[1] == STAT_MELEE then
        subItem:SetText("Melee DPS")
        return
    end
    if info.stat[1] == STAT_MAGIC then
        subItem:SetText("Magic DPS")
        return
    end
    if info.stat[1] == STAT_RANGED then
        subItem:SetText("Ranged DPS")
        return
    end
    if info.stat[1] == STAT_HEALING then
        subItem:SetText("Healing")
        return
    end
    if #info.stat == 4 then
        if info.stat[1] == STAT_MELEEHP and info.stat[2] == STAT_RANGEDHP and info.stat[3] == STAT_MAGICHP and info.stat[4] == STAT_MAGICHP then
            subItem:SetText("Tank")
            return
        end
    end
    subItem:SetText("Other")
end

local SetContinueFunc = function(subItem, info, setValue)
    subItem:SetText(tostring(info.continueflag))
end

local MAXWIDTH = 190 - 7

local PosArrayLayoutFunc = function(applicantList, rowIndex, colIndex, subItem)

    subItem.style:SetAlign(ALIGN.LEFT)
    ApplyTextColor(subItem, FONT_COLOR.DEFAULT)
end

local PosArrayFunc = function(subItem, info, setValue)
    if info.posarray == nil then
        subItem:SetText("")
        return
    end
    local text = ""
    local width = 0
    for i = 1, #info.posarray do
        local addition = tostring(info.posarray[i]) .. " "
        width = width + subItem.style:GetTextWidth(addition)
        if width > MAXWIDTH then
            text = text .. ".."
            break
        end
        text = text .. addition
    end
    subItem:SetText(text)

end


local EditLayoutFunc = function(applicantList, rowIndex, colIndex, subItem)
    local optionButton = w:CreateChildWidget("button", subItem:GetId() .. ".optionsButton", 0, true)
    optionButton:AddAnchor("LEFT", subItem, 2, 0)
    subItem.options = optionButton
    subItem.options.name = ""
    subItem.options.rowIndex = rowIndex
    function subItem.options:OnClick(arg)
        if filtersettingsframe:IsVisible() then
            return
        end
        
        --should lock edits while open
        filtersettingsframe:Open(self.rowIndex, w)
         
    end
    subItem.options:SetHandler("OnMouseUp", subItem.options.OnClick)
    ApplyButtonSkin(optionButton, BUTTON_CONTENTS.APPELLATION)
    subItem.options:Show(false)

    local plusButton = w:CreateChildWidget("button", subItem:GetId() .. ".plusButton", 0, true)
    plusButton:AddAnchor("LEFT", optionButton, "RIGHT", 0, 0)
    subItem.plus = plusButton
    subItem.plus.name = ""
    subItem.plus.rowIndex = rowIndex
    function subItem.plus:OnClick(arg)
        if filtersettingsframe:IsVisible() then
            return
        end
        if self.rowIndex > 1 then
            w:SwapFilterRows(self.rowIndex, self.rowIndex - 1)
        end

    end
    subItem.plus:SetHandler("OnMouseUp", subItem.plus.OnClick)
    ApplyButtonSkin(plusButton, BUTTON_BASIC.PLUS)
    subItem.plus:Show(false)

    local minusButton = w:CreateChildWidget("button", subItem:GetId() .. ".minusButton", 0, true)
    minusButton:AddAnchor("LEFT", plusButton, "RIGHT", 0, 0)
    subItem.minus = minusButton
    subItem.minus.name = ""
    subItem.minus.rowIndex = rowIndex
    function subItem.minus:OnClick(arg)
        if filtersettingsframe:IsVisible() then
            return
        end
       if self.rowIndex < #w.filters then
            w:SwapFilterRows(self.rowIndex, self.rowIndex + 1)
        end
    end
    subItem.minus:SetHandler("OnMouseUp", subItem.minus.OnClick)
    ApplyButtonSkin(minusButton, BUTTON_BASIC.MINUS)
    subItem.minus:Show(false)

end

local EditFunc = function(subItem, info, setValue)
    
    if setValue == false then
        subItem.options:Show(false)
        subItem.plus:Show(false)
        subItem.minus:Show(false)
        return
    end
    subItem.options:Show(true)
    subItem.plus:Enable(subItem.plus.rowIndex ~= 1)
    subItem.plus:Show(true)
    subItem.minus:Enable(subItem.plus.rowIndex ~= #w.filters)
    subItem.minus:Show(true)
end

local filterlist = W_CTRL.CreatePageScrollListCtrl("filterList", w )
filterlist:Show(true)
filterlist:SetExtent(w:GetWidth() - 20, w:GetHeight() - 150)
filterlist:AddAnchor("TOPLEFT", w, "TOPLEFT", 0, 150)
filterlist:AddAnchor("BOTTOMLEFT", closeButton, "TOPLEFT", 0, -40)
local LISTTYPE = 3
local COLUMNS = 7
filterlist:InsertColumn("Name", 75, LISTTYPE, SetNameFunc, nil, nil, nil)
filterlist:InsertColumn("Max", 35, LISTTYPE, SetMaxFunc, nil, nil, nil)
filterlist:InsertColumn("Type", 40, LISTTYPE, SetPTFunc, nil, nil, nil)
filterlist:InsertColumn("Class Filter", 80, LISTTYPE, SetClassFilterFunc, nil, nil, nil)
filterlist:InsertColumn("Stat", 80, LISTTYPE, SetStatFunc, nil, nil, nil)
--filterlist:InsertColumn("Cont", 35, LISTTYPE, SetContinueFunc, nil, nil, nil)
filterlist:InsertColumn("Pos", 190, LISTTYPE, PosArrayFunc, nil, nil, PosArrayLayoutFunc)
filterlist:InsertColumn("Edit", 45, LISTTYPE, EditFunc, nil, nil, EditLayoutFunc)
filterlist:InsertRows(20, false)

DrawListCtrlUnderLine(filterlist.listCtrl)
for i = 1, #filterlist.listCtrl.column do
    SettingListColumn(filterlist.listCtrl, filterlist.listCtrl.column[i])
    DrawListCtrlColumnSperatorLine(filterlist.listCtrl.column[i], #filterlist.listCtrl.column, i)
    filterlist.listCtrl.column[i]:Enable(false)
end



function w:CreateFilter(name, max, classtable, stattable, postable, continueflag, playertable)
    local data = {}
    data.version = VERSION
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

function w:GetDefaults()

    local filters = {}
    filters[1] = w:CreateFilter("Players", DEFAULT_MAX, {}, {}, {}, false, {""})
    filters[2] = w:CreateFilter("Ode", DEFAULT_ODE_MAX, {CLASS_HEALER, CLASS_SONGCRAFT}, {STAT_HEALING}, {21,22,23,24}, true)
    filters[3] = w:CreateFilter("Tank", DEFAULT_MAX, {CLASS_OCCULTISM}, {STAT_MELEEHP, STAT_RANGEDHP, STAT_MAGICHP, STAT_MAGICHP}, {1,2,3,4,6,11,16,7,8,9}, false)
    filters[4] = w:CreateFilter("Mage", DEFAULT_MAX, {CLASS_MAGE}, {STAT_MAGIC}, {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}, false)
    filters[5] = w:CreateFilter("Melee", DEFAULT_MAX, {CLASS_BATTLERAGE}, {STAT_MELEE}, {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}, false)
    filters[6] = w:CreateFilter("Ranged", DEFAULT_MAX, {CLASS_ARCHER}, {STAT_RANGED}, {1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,21,22,23,24,26,27,28,29,31,32,33,34,36,37,38,39,41,42,43,44,46,47,48,49}, false)
    filters[7] = w:CreateFilter("Healer", DEFAULT_MAX, {CLASS_HEALER}, {STAT_HEALING}, {5,10,15,20,25,30,35,40,45,46,47,48,49,50}, false)

    return filters
end



local function CreateFilterRows(filters)
    filterlist:DeleteAllDatas()

    for i = 1, #filters do
        filterlist:InsertRowData(i, COLUMNS, filters[i])
    end
    filterlist:UpdateView()
end

function w:Refresh()
	local success, err = pcall(CreateFilterRows, w.filters)
    if success == false then
        api.Log:Err(err)
    end
end

function w:Open(filters, settings, onclose)


	w.filters = filters
    w.Refresh()
	w.settings = settings
    w.AutoPoll:SetChecked(settings.autoquery)
    w.AutoSort:SetChecked(settings.autosort)
    w.Debug:SetChecked(settings.debug)
    w.HighDebug:SetChecked(settings.highdebug)
	w.OnCloseCallback = onclose
	w:Show(true)
    filtersettingsframe:Show(false)
end

function w:OnClose()
    filtersettingsframe:Show(false)

end

function w:Save()
    w.settings.autoquery = w.AutoPoll:GetChecked()
    w.settings.autosort = w.AutoSort:GetChecked()
    w.settings.debug = w.Debug:GetChecked()
    w.settings.highdebug = w.HighDebug:GetChecked()
	local attempt, err = pcall(w.OnCloseCallback, w.filters, w.settings)
    if attempt == false then
        api.Log:Err(err)
    end
	w:Show(false)
    filtersettingsframe:Show(false)
end

w.closeButton:SetHandler("OnClick", w.Save)

return w