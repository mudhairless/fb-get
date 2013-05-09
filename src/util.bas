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

sub loadPackages( )

    print "Loading package information."

    var ff = freefile

    if fileexists(PKG_LIST) then
        if open(PKG_LIST, for binary, access read, as #ff) <> 0 then
            print "ERROR: unable to read from package list."
            var cdrv = shell( "mkdir -p " & CONF_DIR )
            if cdrv <> 0 then print cdrv & ": Unable to create CONF_DIR"
            cdrv = shell( "mkdir -p " & CACHE_DIR )
            if cdrv <> 0 then print cdrv & ": Unable to create CACHE_DIR"
            return
        else
            var cur_line = ""
            line input #ff, cur_line
            var num_pkgs = valuint(cur_line)
            print num_pkgs & " packages in database."
            if available = NULL then
                available = new package_list
            end if
            for n as uinteger = 0 to num_pkgs -1
                dim curpkg as package_desc
                line input #ff, curpkg._name
                line input #ff, curpkg._desc
                line input #ff, curpkg._depends
                line input #ff, cur_line
                curpkg.version = valuint(cur_line)
                line input #ff, cur_line 'blank line seperating packages
                available->addItem(curpkg)
            next
            close #ff
        end if
    else
        print "ERROR: package list not available, please update."
        shell "mkdir -p " & MANF_DIR
        var cdrv = shell( "mkdir -p " & CONF_DIR )
            if cdrv <> 0 then print cdrv & ": Unable to create CONF_DIR"
            cdrv = shell( "mkdir -p " & CACHE_DIR )
            if cdrv <> 0 then print cdrv & ": Unable to create CACHE_DIR"
        return
    end if

    ff = freefile

    if fileexists(INST_LIST) then
        if open(INST_LIST, for binary, access read, as #ff) <> 0 then
            print "ERROR: unable to read from package list."
            return
        else
            var cur_line = ""
            line input #ff, cur_line
            var num_pkgs = valuint(cur_line)
            print num_pkgs & " packages currently installed."
            if installed = NULL then
                installed = new package_list
            end if
            for n as uinteger = 0 to num_pkgs -1
                dim curpkg as package_desc
                line input #ff, curpkg._name
                line input #ff, curpkg._desc
                line input #ff, curpkg._depends
                line input #ff, cur_line
                curpkg.version = valuint(cur_line)
                line input #ff, cur_line 'blank line seperating packages
                installed->addItem(curpkg)
            next
            close #ff
        end if
    else
        print "INFO: No packages installed."
    end if

    close

end sub


    '' :::::
    function split (byref s as const string, result() as string, byref delimiter as const string, byval limit as integer) as integer

        type substr__
                as integer start, length
        end type

        const max_substrings__ = 100000
        static dt(0 to max_substrings__ - 1) as substr__
        if 0 = len(delimiter) then return false
        function = true
        var ss_count = 0
        var it = strptr(s)
        do while it <> strptr(s) + len(s)
            var found_delim = true
            ' try to match first delimiter char..
            if *it <> delimiter[0] then
                found_delim = false
            ' try to match rest of delimiter..
            elseif len(delimiter) > 1 then
                var it2 = it + 1
                for j as integer = 1 to len(delimiter) - 1
                    if *it2 <> delimiter[j] then
                        found_delim = false : exit for
                    end if
                    it2 += 1
                next
            end if
            if not found_delim then
                it += 1
            else
                ' returning a maximum number of substrings ?
                if 0 < limit then
                    if ss_count = limit - 1 then exit do
                end if
                var index = it - strptr(s)
                dt(ss_count).length = index - dt(ss_count).start
                ss_count += 1
                dt(ss_count).start = index + len(delimiter)
                it += len(delimiter)
            end if
        loop
        ' last substring is the remaining string..
        dt(ss_count).length = len(s) - dt(ss_count).start + 1
        ss_count += 1
        ' returning all but a number of remaining substrings ?
        if 0 > limit then ss_count -= -limit
        ' fill result array..
        redim result(0 to ss_count - 1) as string
        for ss as integer = 0 to ss_count - 1
            result(ss) = mid(s, dt(ss).start + 1, dt(ss).length)
        next
        function = ss_count
    end function
