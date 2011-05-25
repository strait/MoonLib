package = "MoonLib"
version = "0.2-1"

source = {
    url = "git://github.com/strait/MoonLib.git"
}

description = {
    summary = "Useful libraries for Lua.",
    detailed = [[
        This is an example for the LuaRocks tutorial.
        Here we would put a detailed, typically
        paragraph-long description.
    ]],
    homepage = "https://github.com/strait/MoonLib",
    license = "MIT/X11" 
}

dependencies = {
    "lua >= 5.1",
    "luafilesystem >= 1.5.0",
}

build = {
    type = "none",
    install = {
        lua = {
            ['moonlib.list'] = 'list.lua',
            ['moonlib.stringAux'] = 'stringAux.lua',
            ['moonlib.tableAux'] = 'tableAux.lua',
            ['moonlib.util'] = 'util.lua',
            ['moonlib.htmlify'] = 'htmlify.lua',
            ['moonlib.hutil'] = 'hutil.lua',
        }
    }
    
}
