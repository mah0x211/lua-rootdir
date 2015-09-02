local RootDir = require('rootdir');
local rd = RootDir.new({
    rootdir = 'test_dir'
});

ifNotNil( rd:stat('empty.txta') );

local info = ifNil( rd:stat('empty.txt') );

-- check field definition
for _, k in pairs({
    'charset',
    'ctime',
    'ext',
    'mime',
    'mtime',
    'pathname',
    'rpath',
    'type'
}) do
    ifNil( info[k] );
end

-- check field value
ifNotEqual( info.type, 'reg' );
ifNotEqual( info.ext, '.txt' );
ifNotEqual( info.mime, 'text/plain' );
ifNotEqual( info.rpath, '/empty.txt' );
ifNil( info.pathname:find( '/test_dir/empty.txt$' ) );
