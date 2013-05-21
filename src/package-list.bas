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

function package_list.iter( byval f as pack_iter ) as integer

    var curnode = head
    while curnode <> NULL
        var ret = f(@(curnode->d))
        if ret = TRUE then
            DEBUG("Package List Iterator returned TRUE")
            return TRUE
        end if
        curnode = curnode->n
    wend

    return FALSE
end function

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

dim shared fnum as integer

private function fpr ( byval x as package_desc ptr ) as integer
    print #fnum, x->_name
    print #fnum, x->_desc
    print #fnum, x->_depends
    print #fnum, x->version
    print #fnum, ""

    return false
end function

function package_list.readFromFile( byref fname as const string ) as integer
    var fnum = freefile
    var ret = open(fname,for binary,access read,as #fnum)
    if ret = 0 then
        var curline = ""
        line input #fnum, curline
        var pcnt = valuint(curline)
        for n as uinteger = 0 to pcnt -1
                dim curpkg as package_desc
                line input #fnum, curpkg._name
                line input #fnum, curpkg._desc
                line input #fnum, curpkg._depends
                line input #fnum, curline
                curpkg.version = valuint(curline)
                line input #fnum, curline 'blank line seperating packages
                this.addItem(curpkg)
            next
        close #fnum
    end if
    return ret
end function

function package_list.writeToFile( byref fname as const string ) as integer
    var fnum = freefile
    var ret = open(fname,for output,access write,as #fnum)
    if ret = 0 then
        print #fnum, cnt
        this.iter(@fpr)
        close #fnum
    end if
    return ret
end function

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
