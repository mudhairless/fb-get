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

sub package_list.addItem( byref x as package_desc )
    if findItem(x._name) = NULL then
        if tail = NULL then
            if head = NULL then
                head = new pnode
                head->d = x
                cnt += 1
            else
                tail = new pnode
                tail->d = x
                head->n = tail
                cnt += 1
            end if
        else
            tail->n = new pnode
            tail = tail->n
            tail->d = x
            cnt += 1
        end if
    end if
end sub

sub package_list.removeItem( byref n as const string )
    var curnode = head
    var lastnode = curnode
    while curnode <> NULL
        if curnode->d._name = n then
            lastnode->n = curnode->n
            curnode->n = NULL
            delete curnode
            cnt -= 1
            return
        end if
        lastnode = curnode
        curnode = curnode->n
    wend
end sub

sub package_list.writeToFile( byval ff as integer )
    print #ff, cnt
    var curnode = head
    while curnode <> NULL
        print #ff, curnode->d._name
        print #ff, curnode->d._desc
        print #ff, curnode->d._depends
        print #ff, curnode->d.version
        print #ff, ""
        curnode = curnode->n
    wend
end sub

function package_list.findItem( byref n as const string ) as package_desc ptr
    var curnode = head
    while curnode <> NULL
        if curnode->d._name = n then
            return @(curnode->d)
        end if
        curnode = curnode->n
    wend
    return NULL
end function

destructor package_list ()
    if head <> NULL then delete head
end destructor

destructor pnode()
    if n <> NULL then delete n
end destructor
