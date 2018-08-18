--- A system that operates on a group of InputBindings and updates their input value
-- Has a fixed set of InputBindings 'InputBindingList' that are created and added when this object is added to the engine
--

local Table = require(script.Table)

local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable


local InputSystem = {
    ClassName = "InputSystem";
}

InputSystem.__index = InputSystem


function InputSystem:ContainsBinding(name)
    return TableContains(self.InputBindingList, name)
end


function InputSystem:RegisterBinding(name)
    if (self:ContainsBinding(name) == true) then
        return
    end

    table.insert(self.InputBindingList, name)

    if (self.Engine ~= nil) then
        self.Engine:RegisterInputBindingToSystem(self, name)
    end
end


function InputSystem:UnregisterBinding(name)
    if (self:ContainsBinding(name) == true) then
        return
    end

    local wasRemoved = AttemptRemovalFromTable(self.InputBindingList, name)

    if (wasRemoved == true and self.Engine ~= nil) then
        self.Engine:UnregisterInputBindingFromSystem(self, name)
    end
end


function InputSystem:_AddBinding(name, inputBinding)
    if (self.InputBindings[name] == inputBinding) then
        return
    elseif (self.InputBindings[name] ~= nil) then
        self:_RemoveBinding(name, inputBinding)
    end

    self.InputBindings[name] = inputBinding
    inputBinding:RegisterSystem(self.Name, self)

    self:BindingAdded(name, inputBinding)
end


function InputSystem:_RemoveBinding(name, inputBinding)
    if (self.InputBindings[name] ~= inputBinding) then
        return
    end

    self.InputBindings[name] = nil
    inputBinding:UnregisterSystem(self.Name, self)

    self:BindingRemoved(name, inputBinding)
end


function InputSystem:AddBinding(name, inputBinding)
    self:_AddBinding(name, inputBinding)
end


function InputSystem:RemoveBinding(name, inputBinding)
    self:_RemoveBinding(name, inputBinding)
end


function InputSystem:Initialize()

end


function InputSystem:BindingAdded(name, inputBinding)

end


function InputSystem:BindingRemoved(name, inputBinding)

end


function InputSystem:Update()

end


function InputSystem:Destroy()
    setmetatable(self, nil)
end


function InputSystem:Extend(name)
    local this = InputSystem.new(name)

    return this
end


function InputSystem.new(name)
    assert(type(name) == "string", "InputSystem :: new() Arg [1] is not a string!")

    local self = setmetatable({}, InputSystem)

    self.Name = ""

    self.Engine = nil

    self.InputBindings = {}
    self.InputBindingList = {}

    self._IsInputSystem = true
    self._IsInitialized = false
    self._CanUpdate = false


    return self
end


return InputSystem