local RootDir = require('rootdir');
local rd = RootDir.new({
    rootdir = 'test_dir'
});

local content = ifNil( rd:read('/hello.txt') );
ifNotEqual( content, 'hello' );
