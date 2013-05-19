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

#define run_command(c,p) exec(c,p)

function get_file( byref destd as const string, byref f as const string ) as integer
    return run_command(BINDIR & "wget" & EXE_EXT, "-q -O " & destd & f & " " & REMOTE_URL & f)
end function

function verify_file( byref sig as const string, byref key as const string ) as integer
    return run_command(BINDIR & "gpgv" & EXE_EXT, "-q --keyring " & key & " " & sig)
end function

function unpack_files( byref f as const string, byref dest as const string ) as integer
    return run_command(BINDIR & "unzip" & EXE_EXT, "-q -o -d " & dest & " " & f)
end function

function generate_manifest( byref f as const string, byref dest as const string ) as integer
    return shell( BINDIR & "unzip" & EXE_EXT & " -l " & f & " > " & dest )
end function
