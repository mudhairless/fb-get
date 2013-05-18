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

var ret = fbget_main
kill CACHE_DIR & "fbget.lock"
if available <> NULL then delete available
if installed <> NULL then delete installed
end ret

function fbget_main ( ) as integer

    var cmd = lcase(command(1))
    if cmd = "" then
        print "fb-get - FreeBASIC Package Installer"
        showHelp()
        return 1
    end if

    print "fb-get - FreeBASIC Package Installer"

    if cmd = "clear-lock" then
        print "Clearing lock."
        end kill(CACHE_DIR & "fbget.lock")
    end if

    if not fileexists(CACHE_DIR & "fbget.lock") then
        if open (CACHE_DIR & "fbget.lock", for output, as #1) <> 0 then
            print "ERROR: unable to lock database, are you root or have write permissions?"
            end 2
        else
            print #1, 1
            close #1
        end if
    else
        print "The package database is currently locked. Use clear-lock to change that if you know what you're doing."
        end 2
    end if

    loadPackages()

    var xcmd = lcase(command())
    var rcmd = right(xcmd,len(xcmd)-len(cmd)-1)

    select case cmd
    case "update"
        print "Retrieving latest package list."
        shell WGETCMD("packages.list")
        shell WGETCMD("keyring.gpg")
        chdir CONF_DIR
        shell UNZIPCMD("packages.list.zip")
        shell UNZIPCMD("keyring.gpg")
    case "install"
        installPackages( rcmd )
        var ff = freefile
        open INST_LIST FOR OUTPUT ACCESS WRITE AS #ff
        installed->writeTofile(ff)
        close #ff
    case "remove"
        removePackages(rcmd)
        var ff = freefile
        open INST_LIST FOR OUTPUT ACCESS WRITE AS #ff
        installed->writetoFile(ff)
        close #ff
        kill CACHE_DIR & "fbget.lock"
    case "list"
        showList(rcmd)
    case "search"
        doSearch(rcmd)
    case else
        showhelp(rcmd)
        return 1
    end select
    return 0
end function

