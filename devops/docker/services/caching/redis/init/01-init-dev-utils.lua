-- Redis initialization script for development environment

-- Function to load a Lua script and return its SHA
local function load_script(name, code)
    local sha = redis.call('SCRIPT', 'LOAD', code)
    redis.log(redis.LOG_NOTICE, string.format("Loaded script '%s' with SHA: %s", name, sha))
    return sha
end

-- Development utility scripts

-- Monitor memory usage across all databases
local monitor_memory_sha = load_script('monitor_memory', [[
    local result = {}
    for db = 0, tonumber(redis.call('CONFIG', 'GET', 'databases')[2])-1 do
        redis.call('SELECT', db)
        local info = redis.call('INFO', 'memory')
        local used_memory = string.match(info, 'used_memory:(%d+)')
        local used_memory_peak = string.match(info, 'used_memory_peak:(%d+)')
        result[db+1] = {
            db = db,
            used_memory = tonumber(used_memory),
            used_memory_peak = tonumber(used_memory_peak)
        }
    end
    return cjson.encode(result)
]])

-- Analyze key patterns and sizes
local analyze_keys_sha = load_script('analyze_keys', [[
    local function get_key_info(key)
        local type = redis.call('TYPE', key)['ok']
        local ttl = redis.call('TTL', key)
        local size = 0
        if type == 'string' then
            size = #redis.call('GET', key)
        elseif type == 'list' then
            size = redis.call('LLEN', key)
        elseif type == 'set' then
            size = redis.call('SCARD', key)
        elseif type == 'zset' then
            size = redis.call('ZCARD', key)
        elseif type == 'hash' then
            size = redis.call('HLEN', key)
        end
        return {
            key = key,
            type = type,
            ttl = ttl,
            size = size
        }
    end

    local pattern = ARGV[1] or '*'
    local limit = tonumber(ARGV[2]) or 100
    local keys = redis.call('KEYS', pattern)
    local result = {}
    for i, key in ipairs(keys) do
        if i > limit then break end
        result[i] = get_key_info(key)
    end
    return cjson.encode(result)
]])

-- Monitor command statistics
local command_stats_sha = load_script('command_stats', [[
    local info = redis.call('INFO', 'commandstats')
    local stats = {}
    for line in string.gmatch(info, '[^\r\n]+') do
        local cmd = string.match(line, 'cmdstat_([^:]+)')
        if cmd then
            local calls = string.match(line, 'calls=(%d+)')
            local usec = string.match(line, 'usec=(%d+)')
            local usec_per_call = string.match(line, 'usec_per_call=([%d%.]+)')
            stats[cmd] = {
                calls = tonumber(calls),
                usec = tonumber(usec),
                usec_per_call = tonumber(usec_per_call)
            }
        end
    end
    return cjson.encode(stats)
]])

-- Find big keys
local find_big_keys_sha = load_script('find_big_keys', [[
    local function get_key_size(key, type)
        if type == 'string' then
            return #redis.call('GET', key)
        elseif type == 'list' then
            return redis.call('LLEN', key)
        elseif type == 'set' then
            return redis.call('SCARD', key)
        elseif type == 'zset' then
            return redis.call('ZCARD', key)
        elseif type == 'hash' then
            return redis.call('HLEN', key)
        end
        return 0
    end

    local min_size = tonumber(ARGV[1]) or 1000
    local limit = tonumber(ARGV[2]) or 100
    local keys = redis.call('KEYS', '*')
    local big_keys = {}
    local count = 0

    for _, key in ipairs(keys) do
        if count >= limit then break end
        local type = redis.call('TYPE', key)['ok']
        local size = get_key_size(key, type)
        if size >= min_size then
            count = count + 1
            big_keys[count] = {
                key = key,
                type = type,
                size = size
            }
        end
    end

    table.sort(big_keys, function(a, b) return a.size > b.size end)
    return cjson.encode(big_keys)
]])

-- Monitor client connections
local client_monitor_sha = load_script('client_monitor', [[
    local clients = redis.call('CLIENT', 'LIST')
    local result = {}
    local count = 0
    for client in string.gmatch(clients, '[^\n]+') do
        count = count + 1
        local info = {}
        for k, v in string.gmatch(client, '([^=]+)=([^ ]+)') do
            info[k] = v
        end
        result[count] = info
    end
    return cjson.encode(result)
]])

-- Store script SHAs for later use
redis.call('HSET', 'dev:scripts',
    'monitor_memory', monitor_memory_sha,
    'analyze_keys', analyze_keys_sha,
    'command_stats', command_stats_sha,
    'find_big_keys', find_big_keys_sha,
    'client_monitor', client_monitor_sha
)

-- Create development keyspace for monitoring
redis.call('SADD', 'dev:monitors', 'memory', 'keys', 'commands', 'clients')

-- Set up some development configurations
redis.call('CONFIG', 'SET', 'slowlog-log-slower-than', '10000')
redis.call('CONFIG', 'SET', 'slowlog-max-len', '128')
redis.call('CONFIG', 'SET', 'latency-monitor-threshold', '100')
redis.call('CONFIG', 'SET', 'notify-keyspace-events', 'AKE')

redis.log(redis.LOG_NOTICE, 'Development utilities initialized successfully')

return 'OK'
