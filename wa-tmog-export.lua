function(event, ...)
    if event == "EXPORT_TMOG" then
        local transmogList = {}
        for slotID = 1, 19 do
            if slotID == 2 or slotID == 11 or slotID == 12 or slotID == 13 or slotID == 14 or slotID == 18 then
                print("Skipping slotID: " .. slotID)
            else
                local transmogSlot = {}
                local slotName = TransmogUtil.GetSlotName(slotID)
                local itemLoc = ItemLocation:CreateFromEquipmentSlot(slotID)
                
                transmogSlot.Slot = slotName
                
                local itemId = C_Item.GetItemID(itemLoc)       
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
                        local baseItemTransmogInfo = C_Item.GetBaseItemTransmogInfo(itemLoc)
                        
                        appearanceID = appliedItemTransmogInfo.appearanceID              
                        transmogSlot.ItemID = sourceInfo.itemID
                        transmogSlot.ItemName = sourceInfo.name
                    end
                else
                    print("Invalid Transmog Location for slotID " .. slotID)
                end
                transmogList[slotID] = transmogSlot.ItemID                     
            end
        end
        
        DevTool:AddData(transmogList, "Full Transmog List")
        
        local transmogStr = ""
        local count = 0
        local total = #transmogList   
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
