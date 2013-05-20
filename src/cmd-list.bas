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

declare function printList( byval x as package_desc ptr ) as integer

function build_updates_list ( byval p as package_desc ptr ) as integer
    var ap = available->findItem(p->_name)
    if ap <> NULL then
        if ap->version > p->version then
            changes->addItem(*p)
        end if
    else
        INFO("Package is only available locally: " & p->_name)
    end if
    return FALSE
end function

private function print_updates_list ( byval p as package_desc ptr ) as integer
    var ap = available->findItem(p->_name)
    DEBUG("Package: " & p->_name & " Remote: " & ap->version & " Local: " & p->version)
    print p->_name & " " & ap->version & " (" & p->version & ")"
    return FALSE
end function

sub showList( byref opts as const string = "" )
    if opts = "-all" then
        if available <> NULL then
            print "Available packages:"
            available->iter(@printList)
        else
            FATAL("No available packages to list.")
        end if
    elseif opts = "-updates" then
        if changes = NULL then changes = new package_list
        if installed <> NULL then
            installed->iter(@build_updates_list)
            changes->iter(@print_updates_list)
        end if
    else
        if installed <> NULL then
            print "Installed packages:"
            installed->iter(@printList)
        else
            FATAL("There are no installed packages to list.")
        end if
    end if
    print
end sub

function printList( byval x as package_desc ptr ) as integer
    print x->_name
    return FALSE
end function
