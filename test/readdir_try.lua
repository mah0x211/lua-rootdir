local RootDir = require('rootdir');
local rd = RootDir.new({
    rootdir = 'test_dir'
});

ifNotNil( rd:readdir('/noent') );


local entries = ifNil( rd:readdir('/') );
ifNotEqual( #entries.dir, 1 );
ifNotEqual( #entries.reg, 2 );

local files = {
    ['empty.txt'] = true,
    ['hello.txt'] = true
};
for _, item in ipairs( entries.reg ) do
    ifNil( files[item.entry], 'unknown entry:' .. item.rpath );
    files[item.entry] = nil;
end


local dirs = {
    ['subdir'] = true,
};
for _, item in ipairs( entries.dir ) do
    ifNil( dirs[item.entry], 'unknown entry:' .. item.rpath );
    dirs[item.entry] = nil;
end
