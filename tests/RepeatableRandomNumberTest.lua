-- Import LuaUnit module
local lu = require('luaunit')

-- Import the RepeatableRandomNumber class
local RepeatableRandomNumber = require('RepeatableRandomNumber')

-- luacheck: globals TestRepeatableRandomNumber
-- Test the RepeatableRandomNumber class
TestRepeatableRandomNumber = {}

---@type RepeatableRandomNumber
local rng
local firstNumberInSeq = '0.23145237586596'
local secondNumberInSeq = '0.58485671559801'
local hundredthNumberInSeq = '0.43037202063051'

function TestRepeatableRandomNumber.setUp()
    -- Set a fixed seed value for reproducibility in tests
    rng = RepeatableRandomNumber:new(12345)
end

function TestRepeatableRandomNumber.testGenerate()
    -- use tostring method, otherwise the comparison fails between floats
    -- Numbers are based on math.random(), given seed 12345
    lu.assertEquals(tostring(rng:generate()), firstNumberInSeq)
    lu.assertEquals(tostring(rng:generate()), secondNumberInSeq)

    for _=1, 100 do
        local result = rng:generate()
        lu.assertTrue(result > 0)
        lu.assertTrue(result < 1)
    end
end

function TestRepeatableRandomNumber.testGenerateOneArgument()
    for _=1, 100 do
        local result = math.random(1)
        lu.assertEquals(1, result)
    end

    for _=1, 1000 do
        local result = math.random(5)
        lu.assertTrue(result <= 5)
        lu.assertTrue(result >= 1)
    end
end

function TestRepeatableRandomNumber.testGenerateTwoArguments()
    for _=1, 100 do
        local result = math.random(1, 1)
        lu.assertEquals(1, result)
    end

    for _=1, 1000 do
        local result = math.random(10, 20)
        lu.assertTrue(result <= 20)
        lu.assertTrue(result >= 10)
    end
end

--- Tests that running math.radnom won't screw up our iteration/seed.
function TestRepeatableRandomNumber.testGenerateMathRandom()
    if not lu.skip then
        return true
    end
    lu.skip("Skipping this test, we utilize math.random(). One day this may be fixed.")
    math.random()
    lu.assertEquals(tostring(rng:generate()), firstNumberInSeq)
end

--- Tests that running other implementations.won't screw up our iteration/seed.
function TestRepeatableRandomNumber.testGenerateMathRandom()
    if not lu.skip then
        return true
    end
    lu.skip("Skipping this test, we utilize math.random(). One day this may be fixed.")
    local rng2 =  RepeatableRandomNumber:new(2)
    rng2.generate()
    lu.assertEquals(tostring(rng:generate()), firstNumberInSeq)
end

function TestRepeatableRandomNumber.testJump()
    rng:jumpToIteration(99)

    lu.assertEquals(rng.iteration, 99)
    lu.assertEquals(tostring(rng:generate()), hundredthNumberInSeq)
    lu.assertEquals(rng.iteration, 100)
end

function TestRepeatableRandomNumber.testGenerateAndJump()
    for _=1, 50 do
        rng:generate()
    end

    rng:jumpToIteration(99)

    lu.assertEquals(tostring(rng:generate()), hundredthNumberInSeq)
end

function TestRepeatableRandomNumber.testJumpBackwards()
    for _=1, 50 do
        rng:generate()
    end

    rng:jumpToIteration(1)

    lu.assertEquals(tostring(rng:generate()), secondNumberInSeq)
end

function TestRepeatableRandomNumber.testJumpZero()
    for _=1, 99 do
        rng:generate()
    end

    -- jump to the iteration 0
    rng:jumpToIteration(0)

    -- Should be 1st
    lu.assertEquals(tostring(rng:generate()), firstNumberInSeq)
end

function TestRepeatableRandomNumber.testJumpToSameSpot()
    for _=1, 99 do
        rng:generate()
    end

    rng:jumpToIteration(99)

    lu.assertEquals(tostring(rng:generate()), hundredthNumberInSeq)
end

function TestRepeatableRandomNumber.testReset()
    rng:generate()
    rng:jumpToIteration(105)
    rng:reset(12345)

    lu.assertEquals(tostring(rng:generate()), firstNumberInSeq)
    lu.assertEquals(tostring(rng:generate()), secondNumberInSeq)
end

function TestRepeatableRandomNumber.testJumpToIterationInvalidArgumentNegative()
    -- Use pcall to catch the error
    local success, errorMessage = pcall(function()
        rng:jumpToIteration(-1)
    end)

    -- Check that pcall was not successful (error was thrown)
    lu.assertFalse(success)

    -- Check that the error message is as expected
    lu.assertStrContains(errorMessage, "Invalid argument")
end

function TestRepeatableRandomNumber.testJumpToIterationInvalidArgumentNaN()
    -- Use pcall to catch the error
    local success, errorMessage = pcall(function()
        rng:jumpToIteration('11')
    end)

    -- Check that pcall was not successful (error was thrown)
    lu.assertFalse(success)

    -- Check that the error message is as expected
    lu.assertStrContains(errorMessage, "Invalid argument")
end

function TestRepeatableRandomNumber.testJumpToIterationInvalidArgumentNil()
    -- Use pcall to catch the error
    local success, errorMessage = pcall(function()
        rng:jumpToIteration(nil)
    end)

    -- Check that pcall was not successful (error was thrown)
    lu.assertFalse(success)

    -- Check that the error message is as expected
    lu.assertStrContains(errorMessage, "Invalid argument")
end

function TestRepeatableRandomNumber.testJumpToIterationNilSeed()
    local rngTarget = RepeatableRandomNumber:new()
    lu.assertNotNil(rngTarget.seed)
    local seed = rngTarget.seed

    rngTarget:generate()
    rngTarget:generate()

    rngTarget:jumpToIteration(0)
    lu.assertNotNil(rngTarget.seed)
    lu.assertEquals(rngTarget.seed, seed)

    rngTarget:generate()
    rngTarget:generate()
end

function TestRepeatableRandomNumber.testJumpToIterationWithSeed()
    local rngTarget = RepeatableRandomNumber:new(1550)
    lu.assertEquals(1550, rngTarget.seed)

    local a1 = rngTarget:generate()
    local a2 = rngTarget:generate()

    rngTarget:jumpToIteration(0)
    lu.assertEquals(1550, rngTarget.seed)

    local b1 = rngTarget:generate()
    local b2 = rngTarget:generate()

    lu.assertEquals(a1, b1)
    lu.assertEquals(a2, b2)
end

function TestRepeatableRandomNumber.testGetIteration()
    local rngTarget = RepeatableRandomNumber:new(1550)
    lu.assertEquals(0, rngTarget:getIteration())

    rngTarget:generate()
    rngTarget:generate()

    lu.assertEquals(2, rngTarget:getIteration())

    rngTarget:jumpToIteration(50)

    lu.assertEquals(50, rngTarget:getIteration())
end

-- Run the tests
os.exit(lu.LuaUnit.run())