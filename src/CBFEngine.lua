
local ActionBinding = require(script.Parent.ActionBinding)

local Table = require(script.Parent.Table)
local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable


local CBFEngine = {
    ClassName = "CBFEngine";
}

CBFEngine.__index = CBFEngine


function CBFEngine:GetActionBinding(name)
    return self._ActionBindings[name]
end


function CBFEngine:CreateActionBinding(name, inputBindings)
    
end


function CBFEngine:_RemoveActionBinding(actionBindingName, actionBinding)
    
end


function CBFEngine:RemoveActionBinding(actionBinding)
    local actionBindingName

    self:_RemoveActionBinding(actionBindingName, actionBinding)
end


function CBFEngine:_UpdateActionBindings()
    for _, actionBinding in pairs(self._ActionBindings) do
        actionBinding:Update()
    end
end


function CBFEngine:GetInputBinding(name)
    return self._InputBindings[name]
end


function CBFEngine:AddInputBinding(inputBinding)

end


function CBFEngine:RemoveInputBinding(inputBinding)

end


function CBFEngine:GetInputManager(name)
    return self._InputManagers[name]
end


function CBFEngine:AddInputManager(inputManager)
    assert(type(inputBinding) == "table" and inputBinding._IsInputManager == true)

end


function CBFEngine:_UpdateInputManager()
    for _, inputManager in pairs(self._InputManagers) do
        inputManager:Update()
    end
end


function CBFEngine:Update()
    --update input managers
    --update action bindings
end


function CBFEngine.new()
    local self = setmetatable({}, CBFEngine)


    self._ActionBindings = {}
    self._InputBindings = {}
    self._InputManagers = {}

    return self
end


return CBFEngine