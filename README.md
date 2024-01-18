RandomNumber.lua  
----------------  
Simple Lua Class for Generating and Managing Random Numbers

    The RandomNumber class is designed to facilitate the generation of random numbers
    using Lua's built-in math.random function. It includes features for tracking the
    number of generated random numbers and the ability to 'jump' to a specific iteration.
    This functionality is particularly useful for debugging and testing. Example if
    a program is to save its state and 'resume' and we want numbers generated to not
    reset,

    Usage:
    local rng = RandomNumber.new()           -- Generate a random number
    RandomNumber:jumpToIteration(10)         -- Jump to the 10th iteration.

