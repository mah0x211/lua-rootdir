local RootDir = require('rootdir');
local rd = RootDir.new({
    rootdir = 'test_dir'
});

local fh = ifNil( rd:open('subdir/world.txt') );
local ok, src = isolate( fh.read, fh, '*a' );

ifNotTrue( ok, src );
ifNotEqual( src, 'world' );
ifNotTrue( isolate( fh.close, fh ) );
