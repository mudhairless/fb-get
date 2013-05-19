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

#define PKG_LIST CONF_DIR & "packages.list"
#define INST_LIST CONF_DIR & "installed.list"
#define CACHE_DIR get_config("CACHE_DIR")
#define MANF_DIR get_config("MANIFEST_DIR")
#define INST_DIR get_config("INSTALL_DIR")
#define REMOTE_URL get_config("REMOTE_URL")

#ifdef __FB_WIN32__
    #define PLATFORM "win32"
    #define BINDIR CONF_DIR "bin\win32\"
    #define MK_DIR "mkdir "
    #define EXE_EXT ".exe"
    #define CONF_DIR exepath & "\"
#else
    #define PLATFORM "linux"
    #define BINDIR
    #define MK_DIR "mkdir -p "
    #define EXE_EXT ""
    #define CONF_DIR "/usr/local/etc/freebasic/"
#endif

#include once "vbcompat.bi"

#ifndef FALSE
    #define FALSE 0
#endif
#ifndef TRUE
    #define TRUE (not false)
#endif
#ifndef NULL
    #define NULL 0
#endif


type package_desc
    as string _name, _desc, _depends
    as uinteger version
end type

type pnode
    d as package_desc
    n as pnode ptr
    declare destructor()
end type

type package_list
    public:
    declare sub addItem( byref x as package_desc )
    declare sub removeItem( byref n as const string )
    declare function findItem( byref n as const string ) as package_desc ptr
    declare destructor()
    declare sub writeToFile( byval ff as integer )
    'private:
    head as pnode ptr
    tail as pnode ptr
    cnt as uinteger
end type

extern available as package_list ptr
extern installed as package_list ptr

declare sub showHelp( byref hc as const string = "" )
declare sub loadPackages( )
declare sub showList( byref opts as const string = "" )
declare sub installPackages( byref p as string )
declare sub removePackages( byref p as string )
declare function fbget_main ( ) as integer
declare sub doSearch( byref rcmd as const string )

#include once "util.bi"
