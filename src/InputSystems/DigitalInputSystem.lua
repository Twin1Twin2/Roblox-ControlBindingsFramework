
local ContextActionService = game:GetService("ContextActionService")

local InputSystem = require(script.Parent.Parent.InputSystem)


local ENUM_KEYCODE_IGNORE_LIST   = {
    --[[
    [Enum.KeyCode.ButtonX.Name] = true;
    [Enum.KeyCode.ButtonY.Name] = true;
    [Enum.KeyCode.ButtonA.Name] = true;
    [Enum.KeyCode.ButtonB.Name] = true;
    [Enum.KeyCode.ButtonR1.Name] = true;
    [Enum.KeyCode.ButtonL1.Name] = true;
    [Enum.KeyCode.ButtonR2.Name] = true;
    [Enum.KeyCode.ButtonL2.Name] = true;
    [Enum.KeyCode.ButtonR3.Name] = true;
    [Enum.KeyCode.ButtonL3.Name] = true;
    [Enum.KeyCode.ButtonStart.Name] = true;
    [Enum.KeyCode.ButtonSelect.Name] = true;
    [Enum.KeyCode.DPadLeft.Name] = true;
    [Enum.KeyCode.DPadRight.Name] = true;
    [Enum.KeyCode.DPadUp.Name] = true;
    [Enum.KeyCode.DPadDown.Name] = true;
    --]]
    [Enum.KeyCode.Thumbstick1.Name] = true;
    [Enum.KeyCode.Thumbstick2.Name] = true;
}

local ENUM_USERINPUTTYPE_BUTTON_LIST    = {
    [Enum.UserInputType.MouseButton1.Name] = true;
    [Enum.UserInputType.MouseButton2.Name] = true;
    [Enum.UserInputType.MouseButton3.Name] = true;
}


local DigitalInputBindingManager = {
    ClassName = "DigitalInputBindingManager";
}

DigitalInputBindingManager.__index = DigitalInputBindingManager


function DigitalInputBindingManager:Destroy()
    ContextActionService:UnbindAction(self.BindActionName)

    self.InputEnum = nil
    self.InputBinding = nil

    self.BindActionName = nil

    setmetatable(self, nil)
end


function DigitalInputBindingManager.new(inputEnum, inputBinding)
    local self = setmetatable({}, DigitalInputBindingManager)

    self.InputEnum = inputEnum
    self.InputBinding = inputBinding
    self.BindActionName = "DigitalInputBindingManager_" .. inputEnum.Name
    
    local function onInput(inputName, userInputState, inputObject)
        if (userInputState == Enum.UserInputState.Begin) then
            inputBinding.Input	= 1
        elseif (userInputState == Enum.UserInputState.Change) then
            inputBinding.Input	= 1
        elseif (userInputState == Enum.UserInputState.End) then
            inputBinding.Input	= 0
        end
    end

    ContextActionService:BindAction(self.BindActionName, onInput, false, inputEnum)


    return self
end


local DigitalInputSystem = InputSystem:Extend("DigitalInputSystem")

DigitalInputSystem.InputEnums = {}
DigitalInputSystem.InputBindingManagers = {}


function DigitalInputSystem:AddInputBindingFromEnum(enumItem)
    local bindingName = enumItem.Name

    table.insert(self.InputBindingList, enumItem.Name)
    self.InputEnums[bindingName] = enumItem
end


function DigitalInputSystem:Initialize()
    for _, enumItem in pairs (Enum.KeyCode:GetEnumItems()) do
        if (ENUM_KEYCODE_IGNORE_LIST[enumItem.Name] ~= true) then
            self:AddInputBindingFromEnum(enumItem)
        end
    end
    
    for _, enumItem in pairs (Enum.UserInputType:GetEnumItems()) do
        if (ENUM_USERINPUTTYPE_BUTTON_LIST[enumItem.Name] == true) then
            self:AddInputBindingFromEnum(enumItem)
        end
    end
end


function DigitalInputSystem:BindingAdded(name, inputBinding)
    local enumItem = self.InputEnums[name]
    local inputBindingManager = DigitalInputBindingManager.new(enumItem, inputBinding)

    self.InputBindingManagers[name] = inputBindingManager
end


function DigitalInputSystem:BindingRemoved(name, inputBinding)
    local inputBindingManager = self.InputBindingManagers[name]

    inputBindingManager:Destroy()

    self.InputBindingManagers[name] = nil
end


return DigitalInputSystem