--- A component that holds data about an input
--
--

local InputBinding = {
    ClassName = "InputBinding";
}

InputBinding.__index = InputBinding


function InputBinding:Destroy()
    if (self._Engine ~= nil) then
        self._Engine:RemoveInputBinding(self)
    end

    setmetatable(self, nil)
end


function InputBinding.new(name)
    assert(type(name) == "string", "InputBinding :: new() Arg [1] is not a string!")

    local self = setmetatable({}, InputBinding)

    self.Name = ""

    self.Input = 0.0
    self.InputChanged = false

    self._Engine = nil

    self._IsInputBinding = true


    return self
end


return InputBinding