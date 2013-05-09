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

sub doSearch( byref rcmd as const string )
    print "Search Results:"
    print
    var curnode = available->head
    for n as uinteger = 0 to available->cnt -1
        if instr(curnode->d._name,rcmd) orelse instr(curnode->d._desc,rcmd) then
            print curnode->d._name & ": ";
            var installed_is = 0
            var icn = installed->head
            for m as uinteger = 0 to installed->cnt -1
                if curnode->d._name = icn->d._name then
                    print "installed"
                    installed_is = 1
                    exit for
                end if
                icn = icn->n
            next
            if installed_is = 0 then print "not installed"
        end if
        curnode = curnode->n
    next
    print
end sub
