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
    if cmd = "" then
        print "fb-get - FreeBASIC Package Installer"
        showHelp()
        return 1
    end if

    if cmd = "--version" orelse cmd = "-version" then
    print COPYRIGHT
    end 0
    end if

    print "fb-get - FreeBASIC Package Installer"

    if cmd = "clear-lock" then
        WARN("Clearing lock.")
        end kill(CACHE_DIR & "fbget.lock")
    end if
#ifndef __FB_WIN32__
    if not fileexists(CACHE_DIR & "fbget.lock") then
    var ff = freefile
        if open (CACHE_DIR & "fbget.lock", for output, as #ff) <> 0 then
            FATAL("ERROR: unable to lock database, are you root or have write permissions?")
            end 2
        else
            print #ff, 1
            close #ff
        end if
        close #ff
    else
        FATAL("The package database is currently locked. Use clear-lock to change that if you know what you're doing.")
        end 2
    end if
#endif
    loadPackages()

    var xcmd = lcase(command())
    var rcmd = right(xcmd,len(xcmd)-len(cmd)-1)

    select case cmd
    case "update"
        print "Retrieving latest package list."
        DEBUG("Update requested.")
        get_file(CACHE_DIR & "packages.list.zip","packages.list.zip")
        get_file(CACHE_DIR & "packages.list.zip.sign","packages.list.zip.sign")
        unpack_files(CACHE_DIR & "packages.list.zip",CACHE_DIR)
        var v = verify_file(CACHE_DIR & "packages.list.zip.sign", CACHE_DIR & "keyring.gpg")
        if v = 0 then
            INFO("Package list verified.")
            unpack_files(CACHE_DIR & "packages.list.zip",CONF_DIR)
        else
            FATAL("Unable to verify package list.")
            end 30
        end if
    case "install"
        DEBUG("Install of package(s): " & rcmd & " requested.")
        installPackages( rcmd )
        var ff = freefile
        open INST_LIST FOR OUTPUT ACCESS WRITE AS #ff
        installed->writeTofile(ff)
        close #ff
    case "remove"
        DEBUG("Removal of package(s): " & rcmd & " requested.")
        removePackages(rcmd)
        var ff = freefile
        open INST_LIST FOR OUTPUT ACCESS WRITE AS #ff
        installed->writetoFile(ff)
        close #ff
        kill CACHE_DIR & "fbget.lock"
    case "list"
        DEBUG("Package listing requested.")
        showList(rcmd)
    case "search"
        DEBUG("Search requested.")
        doSearch(rcmd)
    case else
        DEBUG("Showing help.")
        showhelp(rcmd)
        return 1
    end select
    return 0
end function

sub loadPackages( )

    print "Loading package information."

    var ff = freefile

    if fileexists(PKG_LIST) then
        if open(PKG_LIST, for binary, access read, as #ff) <> 0 then
            WARN("Unable to read from package list.")
            var cdrv = shell( "mkdir -p " & CONF_DIR )
            if cdrv <> 0 then WARN(cdrv & ": Unable to create CONF_DIR")
            cdrv = shell( "mkdir -p " & CACHE_DIR )
            if cdrv <> 0 then WARN(cdrv & ": Unable to create CACHE_DIR")
            return
        else
            var cur_line = ""
            line input #ff, cur_line
            var num_pkgs = valuint(cur_line)
            INFO(num_pkgs & " packages in database.")
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
        WARN("Package list not available, please update.")
        shell "mkdir -p " & MANF_DIR
        var cdrv = shell( MK_DIR & CONF_DIR )
            if cdrv <> 0 then WARN( cdrv & ": Unable to create CONF_DIR")
            cdrv = shell( MK_DIR & CACHE_DIR )
            if cdrv <> 0 then WARN( cdrv & ": Unable to create CACHE_DIR")
        return
    end if

    ff = freefile

    if fileexists(INST_LIST) then
        if open(INST_LIST, for binary, access read, as #ff) <> 0 then
            WARN("Unable to read from package list.")
            return
        else
            var cur_line = ""
            line input #ff, cur_line
            var num_pkgs = valuint(cur_line)
            INFO(num_pkgs & " packages currently installed.")
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
        INFO("No packages installed.")
    end if

    close

end sub
