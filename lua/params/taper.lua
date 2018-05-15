--- Taper class
-- non-linear parameter using @catfact's taper function
-- @module taper

local util = require 'util'

local Taper = {}
Taper.__index = Taper

local tTAPER = 5

local function map(x, from_min, from_max, to_min, to_max)
  return (x - from_min) * (to_max - to_min) / (from_max - from_min) + to_min
end

function Taper.new(name, min, max, default, k, units)
  local p = setmetatable({}, Taper)
  p.t = tTAPER
  p.name = name
  p.min = min or 0
  p.max = max or 1
  p.k = k or 0
  p.action = function() end
  p.default = default or min
  p.units = units or ""
  p:set(p.default)
  return p
end

function Taper:get()
  local result

  if self.k == 0 then
    result = self.value
  else
    result = (math.exp(self.value * self.k) - 1) / (math.pow(math.exp(1), self.k) - 1)
  end

  return map(result, 0, 1, self.min, self.max)
end

function Taper:get_raw()
  return self.value
end

function Taper:set(v)
  local raw
  raw = map(v, self.min, self.max, 0, 1)

  if self.k ~= 0 then
    raw = math.log(raw * (math.pow(math.exp(1), self.k) - 1) + 1) / self.k
  end

  self:set_raw(raw)
end

function Taper:set_raw(v)
  if self.value ~= v then
    self.value = util.clamp(v, 0, 1)
    self:bang()
  end
end

function Taper:delta(d)
  self:set_raw(self.value + d / 200)
end

function Taper:set_default()
  self:set(self.default)
end

function Taper:bang()
  if self.value ~= nil then
    self.action(self.value)
  end
end

function Taper:string()
  return string.format("%.2f "..self.units, self:get())
end

return Taper
