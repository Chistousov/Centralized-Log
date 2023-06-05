-- custom split
-- https://stackoverflow.com/questions/1426954/split-string-in-lua
function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function pre_kafka_parser(tag, timestamp, record)

    -- Add a kafka topic
    -- Добавим топик kafka
    local tag_split = mysplit(tag,"/")
    record["app"] = tag_split[1]
    record["env"] = tag_split[2]

    local container_name_split = mysplit(record["container_name"],"/")
    -- take the last value
    -- берем последнее значение
    for key, val in pairs(container_name_split) do
        record["app_part"] = val
    end

    -- The name of the computer where the log was created
    -- Имя компьютера, где создан лог
    record["hostname"] = os.getenv("HOSTNAME")

    -- Date and time according to iso8601 with a time zone (timezone offset)
    -- Дата и время по iso8601 c временной зоной (timezone offset)
    record["datetime_iso8601_with_timezone_offset"] = os.date("%Y-%m-%dT%T%z", math.floor(timestamp))

    return 2, timestamp, record
end