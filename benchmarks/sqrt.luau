-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.sqrt against the Luau builtin and the exponent operator.

Math.sqrt calls Math.frexp, refines a quadratic estimate of 1/√m with four
Newton steps, and does one more Newton step for √m. The builtin is one machine
instruction, so it gives the floor of this suite.
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
		["Math.sqrt"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.sqrt(values[index])
			end
			return total
		end,

		["math.sqrt"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += math.sqrt(values[index])
			end
			return total
		end,

		["n ^ 0.5"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += values[index] ^ 0.5
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-sqrt",
		Name = "Math.sqrt",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			-- The exponents cover the full range of a double, because the cost
			-- of Math.frexp changes with the exponent.
			local random = Random.new(20260912)
			for index = 1, COUNT do
				inputs[index] = 2 ^ random:NextNumber(-1020, 1020)
			end
		end,
	},
}
