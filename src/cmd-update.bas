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

function updatePackageList( byref opts as const string ) as integer
        var ret = 0
        print "Retrieving latest package list."
        DEBUG("Update requested.")
        ret = get_file(CACHE_DIR & "packages.list.zip","packages.list.zip")
        if ret <> FALSE then
            FATAL("Unable to retrieve packages update.")
            return ret
        end if
        ret = get_file(CACHE_DIR & "packages.list.zip.sign","packages.list.zip.sign")
        if ret <> FALSE then
            FATAL("Unable to retrieve packages signature update.")
            return ret
        end if
        ret = unpack_files(CACHE_DIR & "packages.list.zip",CACHE_DIR)
        if ret <> FALSE then
            FATAL("Unable to unpack packages update.")
            return ret
        end if
        var v = verify_file(CACHE_DIR & "packages.list.zip.sign", CACHE_DIR & "keyring.gpg")
        if v = 0 then
            INFO("Package list verified.")
            unpack_files(CACHE_DIR & "packages.list.zip",CONF_DIR)
        else
            FATAL("Unable to verify package list.")
            return v
        end if
        return ret
end function
