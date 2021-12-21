-- tarantoolctl rocks install http
-- или
-- luarocks install --local --server https://rocks.tarantool.org http

client = require('http.client')
fiber = require('fiber')
yaml = require('yaml')

local r = {}

local chan = fiber.channel()

local active = 0
for i=1,3 do
    fiber.create(function()
        active = active + 1
        print("Start request", i, "active", active)
        local res = client.get('http://httpbin.org/get')
        print("End request", i, res.status, "active", active)
        chan:put(res)
        active = active - 1
        if active == 0 then
            chan:close()
        end
    end)
end

repeat
    local result = chan:get()
    print("Got from chan", result and result.status)
until not result

os.exit()

-- Пример для консоли
--mkdir net/
--cd net/

--#Запустить два инстанса тарантула в разных директориях
--#1
--tarantool
--box.cfg{listen = 3301}
--box.schema.user.grant('guest','super', nil, nil, { if_not_exists = true })
--box.schema.create_space('test')
--box.space.test:format({
--{name = "id", type = "integer"},
--{name = "type", type = "string"},
--})
--box.space.test:create_index('primary')

--#2
--cd client/
--tarantool

-- Подключение модуля и получение connect (подключения)
--conn = require('net.box').connect('0.0.0.0:3301')

--Информация о подключении
--conn

---Печать (передача) текста в подключенный инстанс тарантула
--conn:eval('print("Hello, i am from other instanse of tarantool")')
--- Выборка данных из space др. инстанса ч/з конекшн
--conn:eval('return box.space.test:select()') -- []
--- Вставка данных из space др. инстанса ч/з конекшн
--conn:eval('box.space.test:insert({1, "abc"})')