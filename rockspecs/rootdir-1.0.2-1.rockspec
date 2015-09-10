package = "rootdir"
version = "1.0.2-1"
source = {
    url = "git://github.com/mah0x211/lua-rootdir.git",
    tag = "v1.0.2"
}
description = {
    summary = "fixed directory access module",
    homepage = "https://github.com/mah0x211/lua-rootdir",
    license = "MIT/X11",
    maintainer = "Masatoshi Teruya"
}
dependencies = {
    "lua >= 5.1",
    "halo >= 1.1.7",
    "lrexlib-pcre >= 2.8.0",
    "magic >= 1.0.0",
    "mediatypes >= 1.0.0",
    "path >= 1.0.4",
    "process >= 1.4.3",
    "util >= 1.4.1"
}
build = {
    type = "builtin",
    modules = {
        rootdir = "rootdir.lua"
    }
}
