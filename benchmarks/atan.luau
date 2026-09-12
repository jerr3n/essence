-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.atan against the Luau builtin.

Math.atan follows fdlibm. It reduces the argument to one of five ranges and
evaluates an eleven-term odd polynomial. That is the same shape the builtin
uses, so this suite shows the cost of Luau against native code for one
well-formed function. Compare it with the trig suite, where Math.sin uses a
Taylor sum instead.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Math = require(ReplicatedStorage.essence.math.math)

local COUNT = 256
local inputs = table.create(COUNT)

return {
	ParameterGenerator = function()
		return inputs
	end,

	Functions = {
		["Math.atan"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.atan(values[index])
			end
			return total
		end,

		["math.atan"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += math.atan(values[index])
			end
			return total
		end,

		["Math.atan2"] = function(_, values)
			local total = 0
			for index = 2, COUNT do
				total += Math.atan2(values[index], values[index - 1])
			end
			return total
		end,

		["math.atan2"] = function(_, values)
			local total = 0
			for index = 2, COUNT do
				total += math.atan2(values[index], values[index - 1])
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-atan",
		Name = "Math.atan",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			-- The exponents cross every argument reduction threshold of
			-- Math.atan, which are 0.4375, 0.6875, 1.1875, and 2.4375.
			local random = Random.new(20260912)
			for index = 1, COUNT do
				local value = 2 ^ random:NextNumber(-8, 8)
				inputs[index] = if random:NextNumber() < 0.5 then -value else value
			end
		end,
	},
}
