--[[

  Copyright (C) 2015 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  rootdir.lua
  lua-rootdir
  Created by Masatoshi Teruya on 15/08/31.

--]]

-- modules
local getcwd = require('process').getcwd;
local typeof = require('util.typeof');
local tblCopy = require('util.table').copy;
local MediaTypes = require('mediatypes');
local path = require('path');
local normalize = path.normalize;
local exists = path.exists;
local readdir = path.readdir;
local stat = path.stat;
local extname = path.extname;
local lrex = require('rex_pcre');
local concat = table.concat;
-- constants
-- regular expressions - PCRE
local IGNORE_PATTERNS = {
    '^[.].*$'
};
-- init for libmagic
local MAGIC;
do
    local mgc = require('magic');
    MAGIC = mgc.open(
        mgc.MIME_ENCODING, mgc.NO_CHECK_COMPRESS, mgc.SYMLINK
    );
    MAGIC:load();
end


-- class
local RootDir = {};


function RootDir:stat( rpath )
    local pathname, info, err;

    -- convert relative-path to absolute-path
    pathname, rpath = self:realpath( rpath );
    info, err = stat( pathname, self.followSymlinks );
    if err then
        return nil, ('failed to stat: %s - %s'):format( rpath, err );
    end

    -- regular file
    if info.type == 'reg' then
        local ext = extname( rpath );

        return {
            ['type'] = info.type,
            pathname = pathname,
            rpath = rpath,
            size = info.size,
            ctime = info.ctime,
            mtime = info.mtime,
            ext = ext,
            charset = MAGIC:file( pathname ),
            mime = ext and self.mime:getMIME( ext:gsub('^.', '' ) ),
        };
    end

    -- other
    return {
        ['type'] = info.type,
        pathname = pathname,
        rpath = rpath,
        ctime = info.ctime,
        mtime = info.mtime
    };
end


function RootDir:realpath( rpath )
    rpath = normalize( rpath );
    return self.rootdir .. rpath, rpath;
end


function RootDir:open( rpath )
    return io.open( ({self:realpath( rpath )})[1] );
end


function RootDir:read( rpath )
    local fh, err = self:open( rpath );
    local src;

    if err then
        return nil, err;
    end

    src, err = fh:read('*a');
    fh:close();
    if err then
        return nil, err;
    end

    return src;
end


function RootDir:readdir( rpath )
    local pathname, dirpath = self:realpath( rpath );
    local entries, err = readdir( pathname );

    if not err then
        local result = {};
        local entry, tbl, info;

        -- list up
        for i = 1, #entries do
            -- not ignoring files
            if not self.ignoreRegex:match( entries[i] ) then
                entry = entries[i];
                info, err = self:stat( normalize( dirpath, entry ) );
                -- error: stat
                if err then
                    return nil, err;
                elseif not typeof.table( result[info.type] ) then
                    result[info.type] = {
                        info
                    };
                else
                    tbl = result[info.type];
                    tbl[#tbl + 1] = info;
                end

                -- remove type field
                info.type = nil;
                -- add entry field
                info.entry = entry;
            end
        end

        return result;
    end

    return nil, ('failed to readdir %s - %s'):format( rpath, err );
end


local function new( cfg )
    local self = {};
    local ignorePattern = tblCopy( IGNORE_PATTERNS );
    local rootdir, info, err;


    -- check arguments
    if not typeof.table( cfg ) then
        error( 'cfg must be table' );
    elseif not typeof.string( cfg.rootdir ) then
        error( 'cfg.rootdir must be string' );
    elseif cfg.followSymlinks ~= nil and
           not typeof.boolean( cfg.followSymlinks ) then
        error( 'cfg.followSymlinks must be boolean' );
    elseif cfg.ignoreRegex ~= nil and
           not typeof.table( cfg.ignoreRegex ) then
        error( 'cfg.ignoreRegex must be table' );
    elseif cfg.mimetypes ~= nil and
           not typeof.string( cfg.mimetypes ) then
        error( 'cfg.mimetypes must be string' );
    elseif type( cfg.rootdir ) ~= 'string' then
        error( 'cfg.rootdir must be string' );
    end

    -- set follow symlinks option
    self.followSymlinks = cfg.followSymlinks == true;

    -- change relative-path to absolute-path
    rootdir, err = exists(
        cfg.rootdir:sub( 1, 1 ) == '/' and
        cfg.rootdir or
        normalize( getcwd(), cfg.rootdir )
    );
    -- set rootdir
    if err then
        error( ('cfg.rootdir: %q - %s'):format( cfg.rootdir, err ) );
    elseif not rootdir then
        error( ('cfg.rootdir %q not found'):format( cfg.rootdir ) );
    end

    -- stat
    info, err = stat( rootdir );
    if err then
        error( ('cfg.rootdir: %q - %s'):format( cfg.rootdir, err ) );
    elseif info.type ~= 'dir' then
        error( ('cfg.rootdir: %q is not directory'):format( self.rootdir ) );
    end
    self.rootdir = rootdir;

    -- set ignoreRegex list
    if cfg.ignoreRegex then
        for i = 1, #cfg.ignoreRegex do
            if not typeof.string( cfg.ignoreRegex[i] ) then
                error( ('cfg.ignoreRegex#%d pattern must be string'):format( i ) );
            end
            ignorePattern[#ignorePattern + 1] = cfg.ignoreRegex[i];
        end
    end
    -- compile patterns
    self.ignoreRegex = lrex.new(
        '(?:' .. concat( ignorePattern, '|' ) .. ')',
        'i'
    );

    -- create mediatypes
    self.mime = MediaTypes.new( cfg.mimetypes );

    return setmetatable( self, {
        __index = RootDir
    });
end


return {
    new = new
};
