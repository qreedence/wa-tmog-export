function(event, ...)
    if event == "EXPORT_TMOG" then
        local transmogList = {}
        local equippedItems = {}
        local excludedSlots = {
            [2] = true, [11] = true, [12] = true, [13] = true, [14] = true, [18] = true
        }
        for slotID = 1, 19 do
            if GetInventoryItemID("player", slotID) and not excludedSlots[slotID] then
                table.insert(equippedItems, slotID)
            end
        end
        for __, slotID in pairs(equippedItems)do
            local transmogSlot = {}
            local slotName = TransmogUtil.GetSlotName(slotID)
            local itemLoc = ItemLocation:CreateFromEquipmentSlot(slotID)
            transmogSlot.Slot = slotName
            local transmogLoc = TransmogUtil.CreateTransmogLocation(slotName, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            if transmogLoc then
                local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = C_Transmog.GetSlotInfo(transmogLoc) 
                local slotinfo = {
                    isTransmogrified = isTransmogrified,
                    hasPending = hasPending,
                    isPendingCollected = isPendingCollected,
                    canTransmogrify = canTransmogrify,
                    cannotTransmogrifyReason = cannotTransmogrifyReason,
                    hasUndo = hasUndo,
                    isHideVisual = isHideVisual,
                    texture = texture
                }
                if not slotinfo["isTransmogrified"] then
                    local itemId = C_Item.GetItemID(itemLoc)
                    transmogSlot.ItemID = itemId
                    transmogSlot.ItemName = "some shit"
                else
                    local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasUndo, isHideVisual, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLoc) 
                    local visualSlotInfo = {
                        baseSourceID = baseSourceID,
                        baseVisualID = baseVisualID,
                        appliedSourceID = appliedSourceID,
                        appliedVisualID = appliedVisualID,
                        pendingSourceID = pendingSourceID,
                        pendingVisualID = pendingVisualID,
                        hasUndo = hasUndo,
                        isHideVisual = isHideVisual,
                        itemSubclass = itemSubclass,
                    }
                    local sourceInfo = C_TransmogCollection.GetSourceInfo(visualSlotInfo["appliedSourceID"])
                    local appliedItemTransmogInfo = C_Item.GetAppliedItemTransmogInfo(itemLoc)
                    appearanceID = appliedItemTransmogInfo.appearanceID
                    transmogSlot.ItemID = sourceInfo.itemID
                    transmogSlot.ItemName = sourceInfo.name
                end
                transmogList[slotID] = transmogSlot.ItemID  
            else
                print("Invalid Transmog Location for slotID " .. slotID)
            end 
        end
        DevTool:AddData(transmogList, "Full Transmog List")
        local transmogStr = '{"transmog":{'
        for key, value in pairs(transmogList) do
            if key and value then
                if next(transmogList, key) then
                    transmogStr = transmogStr..'"'..key..'": '..value..', '
                else
                    transmogStr = transmogStr..'"'..key..'": '..value
                end
            end
        end
        transmogStr = transmogStr.."}}"
        StaticPopupDialogs["TRANSMOG_ALERT"] = {
            text = "Copy this string",
            hasEditBox = true,
            OnShow = function(self, data)
                self.editBox:SetText(transmogStr)
            end,
            button1 = "OK",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("TRANSMOG_ALERT")       
    end
end
