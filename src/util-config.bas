'    fb-get - Package Manager for FreeBASIC
'    Copyright (C) 2013  Ebben Feagan
'
'    This program is free software; you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation; either version 2 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program; if not, write to the Free Software
'    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#include once "fb-get.bi"

type config_
    key as string
    value as string
    declare constructor( byref as string, byref as string )
    declare constructor()
end type

constructor config_
end constructor

constructor config_( byref k as string, byref v as string )
    key = k
    value = v
end constructor

dim shared g_config() as config_

#define MAX_CONFIG 5

sub __init_config() constructor

    redim g_config(MAX_CONFIG)

    g_config(0) = type<config_>("CACHE_DIR","")
    g_config(1) = type<config_>("MANIFEST_DIR","")
    g_config(2) = type<config_>("INSTALL_DIR","")
    g_config(3) = type<config_>("REMOTE_URL","")
    g_config(4) = type<config_>("LOG_TO","")

    'load defaults
    #ifdef __FB_WIN32__
        set_config("CACHE_DIR",exepath & "\cache\")
        set_config("MANIFEST_DIR",exepath & "\packages\")
        set_config("INSTALL_DIR",exepath & "\")
    #else
        set_config("CACHE_DIR","/var/cache/freebasic/")
        set_config("MANIFEST_DIR","/usr/local/etc/freebasic/packages/")
        set_config("INSTALL_DIR","/usr/local/")
    #endif
    set_config("REMOTE_URL","http://ext.freebasic.net/dist/" & PLATFORM & "/")

    var ff = freefile
    if open( CONF_DIR & "fb-get.conf", for binary, access read, as #ff) = 0 then

        'we found a config file let's load it up
        'config files are really simple:
        '*BEGIN CONFIG FILE EXAMPLE NEXT LINE
        'CACHE_DIR /path/to/some/dir
        'MANIFEST_DIR /path/to/some/other/dir
        'INSTALL_DIR /path/to/install/dir
        'REMOTE_URL http://some.website.net/for/platform/
        '*END CONFIG FILE EXAMPLE
        'All directories given should be writable to a user able to install programs.
        'Any line that does not start with one of the keys is ignored at this time,
        'but for future proofing all comment lines should start with #
        var cur_line = ""
        while not eof(ff)
        line input #ff, cur_line
        for n as integer = 0 to MAX_CONFIG-1
            var lk = len(g_config(n).key)
            if left(cur_line,lk) = g_config(n).key then
                'found a key
                var v = trim(right(cur_line,len(cur_line)-lk))
                g_config(n).value = v
            end if
        next
        wend
    end if
    close #ff

end sub

function get_config(byref k as string) as string
    for n as integer = 0 to MAX_CONFIG - 1
        if k = g_config(n).key then return g_config(n).value
    next
    return ""
end function

sub set_config(byref k as string, byref v as string)
    for n as integer = 0 to MAX_CONFIG -1
        if k = g_config(n).key then
            g_config(n).value = v
            return
        end if
    next
end sub
