local RootDir = require('rootdir');

-- invalid arguments
ifTrue( isolate( RootDir.new ) );
for _, arg in ipairs({
    'str',
    1,
    true,
    false,
    {},
    function()end,
    coroutine.create(function()end)
}) do
    ifTrue( isolate( RootDir.new, arg ) );
end

-- invalid rootdir field
for _, arg in ipairs({
    1,
    true,
    false,
    {},
    function()end,
    coroutine.create(function()end)
}) do
    ifTrue( isolate( RootDir.new, {
        rootdir = arg
    }));
end

-- invalid followSymlinks field
for _, arg in ipairs({
    'str',
    1,
    {},
    function()end,
    coroutine.create(function()end)
}) do
    ifTrue( isolate( RootDir.new, {
        rootdir = 'test_dir',
        followSymlinks = arg
    }));
end


-- invalid ignoreRegex field
for _, arg in ipairs({
    'str',
    1,
    true,
    false,
    function()end,
    coroutine.create(function()end),
    { 'invalid regex[' }
}) do
    ifTrue(isolate( RootDir.new, {
        rootdir = 'test_dir',
        followSymlinks = false,
        ignoreRegex = arg
    }));
end

-- invalid mimetypes field
for _, arg in ipairs({
    1,
    true,
    false,
    {},
    function()end,
    coroutine.create(function()end)
}) do
    ifTrue(isolate( RootDir.new, {
        rootdir = 'test_dir',
        followSymlinks = false,
        mimetypes = arg
    }));
end


ifNotTrue(isolate( RootDir.new, {
    rootdir = 'test_dir',
    followSymlinks = false,
    ignoreRegex = {},
    mimetypes = ''
}));

