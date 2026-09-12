-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.log against the Luau builtin.

Math.log calls Math.frexp, centers the mantissa, and evaluates a seven-term
polynomial. Compare the result with the frexp suite to see how much of the
cost is the split and how much is the polynomial.
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
		["Math.log"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.log(values[index])
			end
			return total
		end,

		["math.log"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += math.log(values[index])
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-log",
		Name = "Math.log",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			local random = Random.new(20260912)
			for index = 1, COUNT do
				inputs[index] = 2 ^ random:NextNumber(-1020, 1020)
			end
		end,
	},
}
