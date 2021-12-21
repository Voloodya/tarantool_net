--Установить модуль http server
--tarantoolctl rocks install http
--или
--luarocks install --local --server https://rocks.tarantool.org http

box.cfg{ listen = '127.0.0.1:3301' }
box.schema.user.grant('guest','super', nil, nil, { if_not_exists = true })

box.schema.space.create('counters',{ if_not_exists = true })
box.space.counters:format({
    {name='time', type='integer'},
    {name='count', type='integer'},
})
box.space.counters:create_index('pri', { if_not_exists = true })

local fiber = require 'fiber'

-- Создание сервера
local s = require('http.server').new('0.0.0.0', 8080, { log_requests = true })
--local r = require('http.router').new()

-- Назначение серверу роутера с callback
-- path - путь запроса
-- function(req) - callback function
--r:route({ path = '/' }, function(req)
s:route({ path = '/' }, function(req)
    local now = math.floor(fiber.time()/60)
    local rec = box.space.counters:get{ now }
    if rec then
        rec = box.space.counters:update({ now }, { {'+', 'count', 1} })
    else
        rec = box.space.counters:insert{ now, 1 }
    end

    return {
        status = 200,
        body = string.format("Hello, you are %d", rec.count),
    }
end)

--s:set_router(r)

-- Запуск сервера
s:start()

-- Запуск консоли
require('console').start()
--
os.exit()

--Запустить инстанс tarantool server.lua
--Зайти в отдельном окне браузера на свой адрес и порт :8080