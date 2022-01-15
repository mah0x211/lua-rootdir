lua-rootdir
==

**MODULE HAS BEEN RENAMED TO https://github.com/mah0x211/lua-basedir**

fixed directory access module.


## Installation

```
luarocks install rootdir --from=http://mah0x211.github.io/rocks/
```

## Creating a RootDir Object

### rd = rootdir.new( cfg:table )

**Parameters**

- `cfg:table`
    - `rootdir:string`: root directory path
    - `followSymlinks:boolean`: following symbolic link if true. (default: `false`)
    - `ignoreRegex:table`: regular expressions for ignore filename. (default: `{ '^[.].*$' }`)
    - `mimetypes:string`: mime types definition string. (default: `mediatype.default`)


**Returns**

1. `rd:table`: rootdir object

**Example**

```lua
local RootDir = require('rootdir');
local mt = RootDir.new({
    rootdir = 'test_dir'
});
```

## Methods

### apath, rpath = rd:realpath( rpath:string )

returns absolute pathname and normalized rpath.

**Parameters**

- `rpath:string`: pathname string.

**Returns**

- `apath:string`: absolute pathname on filesystem.
- `rpath:string`: normalized rpath.

**Example**

```lua
print( rd:realpath('empty.txt') );
```

### fh, err = rd:open( rpath:string )

open a file-handle of rpath.

**Parameters**

- `rpath:string`: pathname string.

**Returns**

- `fh:file`: file-handle on success, or nil on failure.
- `err:string`: error string.

**Example**

```lua
local fh = assert( rd:open('subdir/world.txt') );
print( fh:read('*a') );
fh:close();
```

### str, err = rd:read( rpath:string )

read a file of rpath.

**Parameters**

- `rpath:string`: pathname string.

**Returns**

- `str:string`: file contents on success, or nil on failure.
- `err:string`: error string.

**Example**

```lua
local str = assert( rd:read('subdir/world.txt') );
print( str );
```

### entries, err = rd:readdir( rpath:string )

returns a directory contents of rpath.

**Parameters**

- `rpath:string`: pathname string.

**Returns**

- `entries:table`: directory contents on success, or nil on failure.
- `err:string`: error string.

