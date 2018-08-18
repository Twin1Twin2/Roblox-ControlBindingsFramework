
local ActionBinding = require(script.Parent.ActionBinding)
local InputBinding = require(script.Parent.InputBinding)

local Table = require(script.Parent.Table)
local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable


local CBEngine = {
    ClassName = "ControlBindingsFrameworkEngine";
}

CBEngine.__index = CBEngine


function CBEngine:IsActionBinding(actionBinding)
    return (type(actionBinding) == "table" and actionBinding._IsActionBinding == true)
end


function CBEngine:GetActionBinding(name)
    return self._ActionBindings[name]
end


function CBEngine:GetActionBindingFromObject(object)
    if (type(object) == "string") then
        return self:GetActionBinding(object)
    elseif (self:IsActionBinding(object) == true and TableContains(self._ActionBindings, object) == true) then
        return object
    end

    return nil
end


function CBEngine:_AddActionBinding(name, actionBinding)
    actionBinding.Engine = self

    self._ActionBindings[name] = actionBinding
end


function CBEngine:_RemoveActionBinding(name, actionBinding)
    actionBinding.Engine = nil

    self._ActionBindings[name] = nil
end


function CBEngine:AddActionBinding(actionBinding, inputBindingNames)
    local actionBindingName

    if (type(actionBinding) == "string") then
        actionBindingName = actionBinding
        actionBinding = self:GetActionBinding(actionBindingName)

        if (actionBinding ~= nil) then
            return actionBinding
        end

        actionBinding = ActionBinding.new(actionBindingName)
    else
        assert(self:IsActionBinding(actionBinding) == true)

        actionBindingName = actionBinding.Name

        local otherActionBinding = self:GetActionBinding(actionBindingName)

        if (otherActionBinding ~= nil) then
            error("ActionBinding already exists with the name " .. actionBindingName)
        end
    end

    if (type(inputBindingNames) == "table") then
        --Table.Merge(inputBindingNames, actionBinding.InputBindingList)
    else
        inputBindingNames = actionBinding.InputBindingList
    end

    self:_AddActionBinding(actionBindingName, actionBinding)
    self:AddInputBindingsToAction(actionBinding, inputBindingNames)
end


function CBEngine:RemoveActionBinding(actionBinding)
    local actionBindingName

    if (type(actionBinding) == "string") then
        actionBindingName = actionBinding
        actionBinding = self:GetActionBinding(actionBindingName)
    else
        assert(self:IsActionBinding(actionBinding) == true)

        if (TableContains(self._ActionBindings, actionBinding) == false) then
            return
        end

        actionBindingName = actionBinding.Name
    end

    self:_RemoveActionBinding(actionBindingName, actionBinding)

end


function CBEngine:_UpdateActionBindings()
    for _, actionBinding in pairs(self._ActionBindings) do
        actionBinding:Update()
    end
end


function CBEngine:IsInputBinding(inputBinding)
    return (type(inputBinding) == "table" and inputBinding._IsInputBinding == true)
end


function CBEngine:GetInputBinding(name)
    return self._InputBindings[name]
end


function CBEngine:_AddInputBinding(name, inputBinding)
    self._InputBindings[name] = inputBinding
    self:_RegisterInputBindingToSystems(name, inputBinding)
end


function CBEngine:_RemoveInputBinding(name, inputBinding)
    self._InputBindings[name] = nil
    self:_UnregisterInputBindingFromSystems(name, inputBinding)

    inputBinding:Destroy()
end


function CBEngine:_InputBindingBelongsInSystem(name, inputSystem)
    return inputSystem:ContainsBinding(name)
end


function CBEngine:_RegisterInputBindingToSystem(inputSystem, name, inputBinding)
    inputSystem:AddBinding(name, inputBinding)
end


function CBEngine:_UnregisterInputBindingFromSystem(inputSystem, name, inputBinding)
    inputSystem:RemoveBinding(name, inputBinding)
end


function CBEngine:_RegisterInputBindingToSystems(name, inputBinding)
    for _, inputSystem in pairs(self._InputSystems) do
        if (self:_InputBindingBelongsInSystem(name, inputSystem) == true) then
            self:_RegisterInputBindingToSystem(inputSystem, name, inputBinding)
        end
    end
end


function CBEngine:_UnregisterInputBindingFromSystems(name, inputBinding)
    for _, inputSystem in pairs(self._InputSystems) do
        if (self:_InputBindingBelongsInSystem(name, inputSystem) == true) then
            self:_UnregisterInputBindingFromSystem(inputSystem, name, inputBinding)
        end
    end
end


function CBEngine:_UpdateInputBinding(name, inputBinding)
    local registeredActions = inputBinding._ActionBindings

    if (#registeredActions == 0) then
        self:_RemoveInputBinding(name, inputBinding)
    end
end


function CBEngine:RegisterInputBindingToSystem(inputSystem, name)
    local inputBinding = self:GetInputBinding(name)

    if (inputBinding ~= nil) then
        self:_RegisterInputBindingToSystem(inputSystem, name, inputBinding)
    end
end


function CBEngine:UnregisterInputBindingFromSystem(inputSystem, name)
    local inputBinding = self:GetInputBinding(name)

    if (inputBinding ~= nil) then
        self:_UnregisterInputBindingFromSystem(inputSystem, name, inputBinding)
    end
end


function CBEngine:AddInputBinding(name)
    local inputBinding = self:GetInputBinding(name)

    if (inputBinding ~= nil) then
        return inputBinding
    end

    inputBinding = InputBinding.new(name)

    self:_AddInputBinding(name, inputBinding)

    return inputBinding
end


function CBEngine:RemoveInputBinding(inputBinding)
    local name

    if (type(inputBinding) == "string") then
        name = inputBinding
        inputBinding = self:GetInputBinding(name)

        if (inputBinding == nil) then
            return
        end
    elseif (TableContains(self._InputBindings, inputBinding) == false) then
        return
    else
        name = inputBinding.Name
    end

    self:_RemoveInputBinding(name, inputBinding)
end


function CBEngine:_AddInputBindingToAction(actionBinding, inputBindingName)
    assert(type(inputBindingName) == "string")

    local inputBinding = self:AddInputBinding(inputBindingName)

    actionBinding:RegisterInputBinding(inputBindingName, inputBinding)
end


function CBEngine:_RemoveInputBindingFromAction(actionBinding, inputBindingName)
    assert(type(inputBindingName) == "string")

    local inputBinding = self:GetInputBinding(inputBindingName)

    if (inputBinding == nil) then
        return
    end

    actionBinding:UnregisterInputBinding(inputBindingName, inputBinding)

    self:_UpdateInputBinding(inputBindingName, inputBinding)
end


function CBEngine:AddInputBindingsToAction(actionBinding, ...)
    actionBinding = self:GetActionBindingFromObject(actionBinding)

    assert(actionBinding ~= nil)

    local inputBindingNames = {...}

    if (type(inputBindingNames[1]) == "table") then
        inputBindingNames = inputBindingNames[1]
    end

    for _, inputBindingName in pairs(inputBindingNames) do
        self:_AddInputBindingToAction(actionBinding, inputBindingName)
    end
end


function CBEngine:RemoveInputBindingsFromAction(actionBinding, ...)
    actionBinding = self:GetActionBindingFromObject(actionBinding)

    assert(actionBinding ~= nil)

    local inputBindingNames = {...}

    if (type(inputBindingNames[1]) == "table") then
        inputBindingNames = inputBindingNames[1]
    end

    for _, inputBindingName in pairs(inputBindingNames) do
        self:_RemoveInputBindingFromAction(actionBinding, inputBindingName)
    end
end


function CBEngine:IsInputSystem(inputSystem)
    return (type(inputSystem) == "table" and inputSystem._IsInputSystem == true)
end


function CBEngine:GetInputSystem(name)
    for _, inputSystem in pairs(self._InputSystems) do
        if (inputSystem.Name == name) then
            return inputSystem
        end
    end

    return nil    
end


function CBEngine:_AddInputSystem(inputSystem)
    inputSystem.Engine = self
    table.insert(self._InputSystems, inputSystem)
end


function CBEngine:_RemoveInputSystem(inputSystem)
    for _, inputBindingName in pairs(inputSystem.InputBindingList) do
        local inputBinding = self:GetInputBinding(inputBindingName)
        if (inputBinding ~= nil) then
            self:_UnregisterInputBindingFromSystem(inputSystem, inputBindingName, inputBinding)
        end
    end

    inputSystem.Engine = nil

    AttemptRemovalFromTable(self._UpdatedInputSystems, inputSystem)
    AttemptRemovalFromTable(self._InputSystems, inputSystem)
end


function CBEngine:_InitializeInputSystem(inputSystem)
    if (inputSystem._CanUpdate == true) then
        table.insert(self._UpdatedInputSystems, inputSystem)
    end

    inputSystem:Initialize()
    inputSystem._IsInitialized = true

    for _, inputBindingName in pairs(inputSystem.InputBindingList) do
        self:RegisterInputBindingToSystem(inputSystem, inputBindingName)
    end
end


function CBEngine:InitializeInputSystems()
    for _, inputSystem in pairs(self._InputSystems) do
        if (inputSystem._IsInitialized ~= true) then
            self:_InitializeInputSystem(inputSystem)
        end
    end
end


function CBEngine:AddInputSystem(inputSystem, initialize)
    assert(self:IsInputSystem(inputSystem) == true)

    self:_AddInputSystem(inputSystem)

    if (initialize ~= false) then
        self:_InitializeInputSystem(inputSystem)
    end
end


function CBEngine:RemoveInputSystem(inputSystem)
    assert(self:IsInputSystem(inputSystem) == true)

    self:_RemoveInputSystem(inputSystem)
end


function CBEngine:_UpdateInputSystems()
    for _, inputSystem in pairs(self._UpdatedInputSystems) do
        inputSystem:Update()
    end
end


function CBEngine:Update()
    self:_UpdateInputSystems()
    self:_UpdateActionBindings()
end


function CBEngine:Destroy()

end


function CBEngine:SetConfiguration(config)
    --clear old config

    local inputSystems = config.InputSystems
    local actionBindings = config.ActionBindings

    for _, inputSystem in pairs(inputSystems) do
        self:AddInputSystem(inputSystem)
    end

    for actionBindingName, inputBindingNames in pairs(actionBindings) do
        self:AddActionBinding(actionBindingName, inputBindingNames)
    end
end


function CBEngine.new()
    local self = setmetatable({}, CBEngine)

    self._ActionBindings = {}
    self._InputBindings = {}
    self._InputSystems = {}
    self._UpdatedInputSystems = {}

    self._IsControlBindingsEngine = true


    return self
end


return CBEngine