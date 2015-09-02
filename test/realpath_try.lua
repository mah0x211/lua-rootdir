local RootDir = require('rootdir');
local rd = RootDir.new({
    rootdir = 'test_dir'
});

ifNil( rd:realpath('empty.txt'):find('/test_dir/empty.txt$') );
ifNil( rd:realpath('./foo/bar/empty.txt'):find('/test_dir/foo/bar/empty.txt$') );
ifNil( rd:realpath('./foo/bar/../empty.txt'):find('/test_dir/foo/empty.txt$') );
ifNil( rd:realpath('./foo/bar/../../../../empty.txt'):find('/test_dir/empty.txt$') );
