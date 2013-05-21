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

dim shared available as package_list ptr
dim shared installed as package_list ptr
dim shared changes as package_list ptr

var log_s = get_config("LOG_TO")
if log_s <> "" then
    set_log_level(_DEBUG)
    set_log_method(LOG_FILE, strptr(log_s) )
    DEBUG("Program started.")
else
    set_log_level(_INFO)
end if
var ret = fbget_main
#ifndef __FB_WIN32__
kill CACHE_DIR & "fbget.lock"
#endif
if available <> NULL then delete available
if installed <> NULL then delete installed
if changes <> NULL then delete changes
DEBUG("Program complete.")
end ret

function fbget_main ( ) as integer

    var cmd = lcase(command(1))
    var xcmd = lcase(command())
    var rcmd = right(xcmd,len(xcmd)-len(cmd)-1)

    if cmd = "" orelse cmd = "help" orelse cmd = "halp" then
        print "fb-get - FreeBASIC Package Installer"
        showHelp(rcmd)
        return 1
    end if

    if cmd = "--version" orelse cmd = "-version" then
    print COPYRIGHT
    end 0
    end if

    print "fb-get - FreeBASIC Package Installer"

    #ifndef __FB_WIN32__
    if cmd = "clear-lock" then
        WARN("Clearing lock.")
        end kill(CACHE_DIR & "fbget.lock")
    end if

    if not fileexists(CACHE_DIR & "fbget.lock") then
    var ff = freefile
        if open (CACHE_DIR & "fbget.lock", for output, as #ff) <> 0 then
            FATAL("ERROR: unable to lock database, are you root or have write permissions?")
            end 2
        else
            print #ff, 1
            close #ff
        end if
    else
        FATAL("The package database is currently locked. Use clear-lock to change that if you know what you're doing.")
        end 2
    end if
    #endif

    var ret = loadPackages()
    if ret <> FALSE then return ret

    select case cmd
    case "update"
        ret = updatePackageList(rcmd)

    case "install"
        DEBUG("Install of package(s): " & rcmd & " requested.")
        ret = installPackages( rcmd )
        if ret = FALSE then
            ret = installed->writeTofile(INST_LIST)
        end if

    case "remove"
        DEBUG("Removal of package(s): " & rcmd & " requested.")
        ret = removePackages(rcmd)
        if ret = FALSE then
            ret = installed->writeTofile(INST_LIST)
        end if

    case "list"
        DEBUG("Package listing requested.")
        ret = showList(rcmd)

    case "search"
        DEBUG("Search requested.")
        doSearch(rcmd)

    case else
        DEBUG("Showing help.")
        showhelp(rcmd)
        ret = 1
    end select
    return ret
end function

function loadPackages( ) as integer

    print "Loading package information."

    var ff = freefile
    var ret = 0

    if available = NULL then available = new package_list
    if fileexists(PKG_LIST) then
        ret = available->readFromFile(PKG_LIST)
        if ret <> FALSE then
            WARN("Unable to read from package list.")
            ret = shell( MK_DIR & MANF_DIR )
            if ret <> 0 then
                WARN(ret & ": Unable to create MANF_DIR")
                return ret
            end if
            ret = shell( MK_DIR & CONF_DIR )
            if ret <> 0 then
                WARN(ret & ": Unable to create CONF_DIR")
                return ret
            end if
            ret = shell( "mkdir -p " & CACHE_DIR )
            if ret <> 0 then
                WARN(ret & ": Unable to create CACHE_DIR")
                return ret
            end if
            return ret
        end if
        INFO("Found " & available->cnt & " packages.")
    else
        WARN("Package list not available, please update.")
        WARN("Unable to read from package list.")
            ret = shell( MK_DIR & MANF_DIR )
            if ret <> 0 then
                WARN(ret & ": Unable to create MANF_DIR")
                return ret
            end if
            ret = shell( MK_DIR & CONF_DIR )
            if ret <> 0 then
                WARN(ret & ": Unable to create CONF_DIR")
                return ret
            end if
            ret = shell( "mkdir -p " & CACHE_DIR )
            if ret <> 0 then
                WARN(ret & ": Unable to create CACHE_DIR")
                return ret
            end if
            return ret
    end if

    if installed = NULL then installed = new package_list
    if fileexists(INST_LIST) then
        ret = installed->readFromFile(INST_LIST)
        if ret <> FALSE then
            WARN("Unable to read from installed package list.")
        end if
        INFO(installed->cnt & " packages are installed.")
    else
        INFO("No packages are currently installed.")
    end if

    close
    return ret
end function
