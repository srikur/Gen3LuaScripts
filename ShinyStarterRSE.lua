-- Script to automate the process of soft-resetting for a shiny starter in Pokémon Ruby, Sapphire, and Emerald

-- Detect the game: Ruby, Sapphire, or Emerald
-- local game = memory.readbyte(0x030011A3)
-- if game == 0x08 then
--     print("Ruby")
-- elseif game == 0x0A then
--     print("Sapphire")
-- elseif game == 0x0C then
--     print("Emerald")
-- else
--     print("This script is for RSE, not FRLG")
--     return
-- end

-- Trainer party pkmn 1 memory locations:
-- Ruby & Sapphire: 0x03004360
-- Emerald (US): 0x020244EC

-- assign based on game
game = 0x0A
local memory_start = 0x03004360

while true do

    local pid = memory.readdwordunsigned(memory_start)
    -- local trainer_id = memory.readdwordunsigned(memory_start + 4)
    -- local secret_id = memory.readdwordunsigned(memory_start + 0x9C4)
    local trainer_id = memory.readwordunsigned(0x02024EAE)
    local secret_id = memory.readdwordunsigned(0x02024EB0)
    local magic_word = bit.bxor(pid, trainer_id)

    -- Substructure Order Correction
    local i = pid % 24
    local growth_offset = 0
    local misc_offset = 0
    if i <= 5 then
        growth_offset = 0
    elseif i % 6 <= 1 then
        growth_offset = 12
    elseif i % 2 == 0 then
        growth_offset = 24
    else
        growth_offset = 36
    end

    if i >= 18 then
        misc_offset = 0
    elseif i % 6 >= 4 then
        misc_offset = 12
    elseif i % 2 == 1 then
        misc_offset = 24
    else
        misc_offset = 36
    end


    species = bit.band(bit.bxor(memory.readdwordunsigned(memory_start + 32 + growth_offset), magic_word), 0xFFF)

    -- Is the pkmn shiny
    -- TrainerID xor SecretID xor PersonalityValue31..16 xor PersonalityValue15..0
    local shiny = "No"
    if bit.bxor(trainer_id, secret_id, bit.band(pid, 0xFFFF0000), bit.band(pid, 0xFFFF)) < 8 then
        shiny = "Yes"
    end
    
    -- GUI Drawing
    gui.text(0, 0, string.format("Species: %s", species))
    gui.text(80, 0, string.format("PID: %08X", pid))
    print(tostring(tonumber(trainer_id, 10)))
    gui.text(0, 10, string.format("Trainer ID: %s", trainer_id))
    gui.text(0, 20, string.format("Secret ID: %d", secret_id))
    if shiny == "Yes" then
        gui.text(100, 10, string.format("Shiny?: Yes"), "green")
    else
        gui.text(100, 10, string.format("Shiny?: No"), "red")
    end

    emu.frameadvance()
end