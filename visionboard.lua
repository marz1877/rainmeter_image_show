local lastPaths = {}
local numSlots = 7
local isUpdating = false

function Initialize()
    print("VisionBoard: Initializing Liquid Glass v8.1...")
    for i=1, numSlots do
        lastPaths[i] = ""
        -- Pre-initialize variables to prevent '...' ToolTips
        SKIN:Bang('!SetVariable', 'Name' .. i, 'Loading...')
    end
end

-- This function is called by each measure's OnChangeAction or manually
function CheckUnique(slot)
    if isUpdating then return end
    
    local measure = SKIN:GetMeasure('MeasureImage' .. slot)
    if not measure then return end
    
    local currentPath = measure:GetStringValue()
    if currentPath == "" then return end
    
    -- Check for exact path duplicates in other slots
    local isDuplicate = false
    for i=1, numSlots do
        if i ~= slot and lastPaths[i] == currentPath then
            isDuplicate = true
            break
        end
    end
    
    if isDuplicate then
        isUpdating = true
        SKIN:Bang('!UpdateMeasure', 'MeasureImage' .. slot)
        isUpdating = false
    else
        lastPaths[slot] = currentPath
        
        -- Filename Cleaning: Strip path and extension
        local filename = currentPath:match("^.+\\(.-)%..-$") or currentPath:match("^.+/(.-)%..-$") or currentPath:match("(.+)%..-$") or currentPath
        
        -- Push to Rainmeter
        SKIN:Bang('!SetVariable', 'Name' .. slot, filename)
        SKIN:Bang('!UpdateMeter', 'MeterImage' .. slot)
        
        print("VisionBoard: Slot " .. slot .. " verified: " .. filename)
    end
end

function Update()
    -- Ensure initial filenames are processed if measures are already populated
    if lastPaths[1] == "" then
       for i=1, numSlots do CheckUnique(i) end
    end
end

function ShuffleAll()
    print("VisionBoard: Shuffling all slots...")
    for i=1, numSlots do
        SKIN:Bang('!UpdateMeasure', 'MeasureImage' .. i)
        -- CheckUnique will be triggered by OnChangeAction or manually if needed
        CheckUnique(i)
    end
end
