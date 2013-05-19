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

sub showhelp( byref hc as const string = "" )

    select case hc
    case "update"
        print "Update the available packages listing."
    case "install"
        print "Install the specified package(s)."
    case "remove"
        print "Remove the specified package(s)."
    case "list"
        print "List all installed packages."
        print "use list -all to list available packages."
        print "use list -updates to list only updated packages."
    case "search"
        print "Search for the specified string in the available package names."
    case else
        print "Usage: fb-get update|install [package]|remove [package]|list|search"
    end select

    print

end sub
