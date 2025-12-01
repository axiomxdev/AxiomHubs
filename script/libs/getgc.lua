local Main

if getgc then
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "DataManager") then
            Main = v
            break
        end
    end
end

if Main then
    print("getgc disponible")
else
    print("getgc non disponible")
end