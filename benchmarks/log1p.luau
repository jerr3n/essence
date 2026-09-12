-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.log1p against the direct formula, which is faster and wrong.

math.log(1 + n) rounds away the low bits of a small n before it takes the
logarithm. It costs one addition and one builtin call. Math.log1p costs a
Math.log call and a correction. This suite prices the accuracy.

The inputs are small, because that is where the two results differ.
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
		["Math.log1p"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.log1p(values[index])
			end
			return total
		end,

		["Math.log(1 + n)"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.log(1 + values[index])
			end
			return total
		end,

		["math.log(1 + n)"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += math.log(1 + values[index])
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-log1p",
		Name = "Math.log1p",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			local random = Random.new(20260912)
			for index = 1, COUNT do
				local value = 2 ^ random:NextNumber(-60, -1)
				inputs[index] = if random:NextNumber() < 0.5 then -value else value
			end
		end,
	},
}
