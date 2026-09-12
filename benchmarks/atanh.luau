-- SPDX-License-Identifier: Apache-2.0
-- Copyright 2026 Jerren

--[[
Math.atanh against the direct formula, which is faster and wrong.

Luau has no math.atanh. The usual replacement is ½ln((1+n)/(1-n)), which loses
the low bits of a small n in the same way that math.log(1 + n) does.
Math.atanh calls Math.log1p to keep them. This suite prices the accuracy.
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
		["Math.atanh"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				total += Math.atanh(values[index])
			end
			return total
		end,

		["0.5 * math.log((1 + n) / (1 - n))"] = function(_, values)
			local total = 0
			for index = 1, COUNT do
				local value = values[index]
				total += 0.5 * math.log((1 + value) / (1 - value))
			end
			return total
		end,
	},

	Benchmarkr = {
		Id = "essence-math-atanh",
		Name = "Math.atanh",
		Runs = 500,
		WarmupRuns = 25,
		BeforeAll = function()
			-- Half of the inputs are below 0.5, which is the branch that
			-- Math.atanh uses to keep accuracy.
			local random = Random.new(20260912)
			for index = 1, COUNT do
				local value = if index % 2 == 0
					then random:NextNumber(0, 0.5)
					else random:NextNumber(0.5, 0.999999)
				inputs[index] = if random:NextNumber() < 0.5 then -value else value
			end
		end,
	},
}
