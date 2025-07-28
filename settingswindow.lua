local w = api.Interface:CreateWindow("RaidSortSettingsWnd", "Raid Sort Settings", 600, 700)
w:SetTitle("Raid Sort Settings")
w:AddAnchor("CENTER", "UIParent", 0, 0)
w:SetCloseOnEscape(true)

local closeButton = w:CreateChildWidget("button", "closeButton", 0, false)
closeButton:SetText("Save")
closeButton:AddAnchor("BOTTOM", w, -45, -10)
ApplyButtonSkin(closeButton, BUTTON_BASIC.DEFAULT)

w.closeButton = closeButton


w:Show(false)
w.OnCloseCallback = nil
w.filters = nil
w.settings = nil

function w:Open(filters, settings, onclose)
	w.filters = filters
	w.settings = settings
	w.OnCloseCallback = onclose
	w:Show(true)
end

function w:Close()
	local attempt, err = pcall(w.OnCloseCallback, w.filters, w.settings)
	w:Show(false)
end


w.closeButton:SetHandler("OnClick", w.Close)

return w