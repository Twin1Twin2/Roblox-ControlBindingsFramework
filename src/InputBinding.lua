--- A component that holds data about an input
--
--

local Table = require(script.Parent.Table)

local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable


local InputBinding = {
    ClassName = "InputBinding";
}

InputBinding.__index = InputBinding


function InputBinding:RegisterAction(name, actionBinding)
    if (TableContains(self._ActionBindings, name) == true) then
        return
    end

    table.insert(self._ActionBindings, name)
end


function InputBinding:UnregisterAction(name, actionBinding)
    if (TableContains(self._ActionBindings, name) == false) then
        return
    end

    AttemptRemovalFromTable(self._ActionBindings, name)
end


function InputBinding:RegisterSystem(name, inputSystem)
    self._InputSystems[name] = inputSystem
end


function InputBinding:UnregisterSystem(name, inputSystem)
    self._InputSystems[name] = nil
end


function InputBinding:Destroy()
    if (self._Engine ~= nil) then
        self._Engine:RemoveInputBinding(self)
    end

    setmetatable(self, nil)
end


function InputBinding.new(name)
    assert(type(name) == "string", "InputBinding :: new() Arg [1] is not a string!")

    local self = setmetatable({}, InputBinding)

    self.Name = name

    self.Input = 0.0

    self._ActionBindings = {}
    self._InputSystems = {}

    self._Engine = nil

    self._IsInputBinding = true


    return self
end


return InputBinding