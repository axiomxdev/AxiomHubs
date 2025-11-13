function bitwise_xor(a, b)
    local result = 0
    local power_of_2 = 1
    while a > 0 or b > 0 do
        local bit_a = a % 2
        local bit_b = b % 2
        if bit_a ~= bit_b then
            result = result + power_of_2
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        power_of_2 = power_of_2 * 2
    end
    return result
end

function byte_to_hex(byte)
    return string.format("%02X", byte)
end

function derive_round_key(main_key, round_number)
    local derived_key = ""
    for i = 1, string.len(main_key) do
        local char_code = string.byte(main_key, i) + round_number + i
        derived_key = derived_key .. string.char(char_code % 256)
    end
    return derived_key
end

function pseudo_aes_mix(data, key, rounds)
    local mixed_data = {}
    for i = 1, #data do
        mixed_data[i] = string.byte(data, i)
    end
    local key_length = string.len(key)

    for round = 1, rounds do
        local round_key = derive_round_key(key, round)
        local round_key_length = string.len(round_key)
        local new_mixed_data = {}
        for i = 1, #mixed_data do
            local xor_value = bitwise_xor(mixed_data[i], string.byte(round_key, (i - 1) % round_key_length + 1))
            local shifted_value = (xor_value + round * i) % 256
            new_mixed_data[i] = shifted_value
        end
        mixed_data = new_mixed_data
    end
    local result = ""
    for _, byte in ipairs(mixed_data) do
        result = result .. string.char(byte)
    end
    return result
end

function encrypt_id_with_pseudo_aes(id, key)
    local encrypted_bytes = ""
    local key_length = string.len(key)

    for i = 1, string.len(id) do
        local id_char_code = string.byte(id, i)
        local key_char_code = string.byte(key, (i - 1) % key_length + 1)
        local shifted_code = (id_char_code + i) % 256
        local xored_code = bitwise_xor(shifted_code, key_char_code)
        encrypted_bytes = encrypted_bytes .. string.char(xored_code)
    end

    local mixed_bytes = pseudo_aes_mix(encrypted_bytes, key, 15)
    local encrypted_hex = ""
    for i = 1, #mixed_bytes do
        encrypted_hex = encrypted_hex .. byte_to_hex(string.byte(mixed_bytes, i))
    end
    return encrypted_hex
end


local id_to_encrypt = "1234567890"
local encryption_key = "AxiomHub"
local encrypted_value_hex = encrypt_id_with_pseudo_aes(id_to_encrypt^2, encryption_key)

print("ID Original                     |", id_to_encrypt)
print("Clé                             |", encryption_key)
print("ID Encrypté (Pseudo-AES Hex)    |", encrypted_value_hex)