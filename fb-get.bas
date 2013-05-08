#ifdef __FB_WIN32__
#define PKG_LIST exepath & "/packages.list"
#define INST_LIST exepath & "/installed.list"
#define CACHE_DIR exepath & "/cache/"
#define CONF_DIR exepath & "/"
#define MANF_DIR exepath & "/packages/"
#define PLATFORM "win32"
#define INST_DIR CONF_DIR
#define RM "rm"
#else
#define PKG_LIST "/usr/local/etc/freebasic/packages.list"
#define CONF_DIR "/usr/local/etc/freebasic/"
#define INST_LIST "/usr/local/etc/freebasic/installed.list"
#define CACHE_DIR "/var/cache/freebasic/"
#define PLATFORM "linux"
#define INST_DIR "/usr/local/"
#define MANF_DIR "/usr/local/etc/freebasic/packages/"
#define RM "del"
#endif


#define REMOTE_URL "http://ext.freebasic.net/dist/" & PLATFORM & "/"
#define WGETCMD(packagen) "wget -q -O " & CACHE_DIR & packagen & ".zip" & " " & REMOTE_URL & packagen & ".zip"
#define UNZIPCMD(filen) "unzip -q -o -d . " & CACHE_DIR & filen
#define MANIFEST(filen) "unzip -l " & CACHE_DIR & filen & ".zip > " & MANF_DIR & filen & ".manifest"
#define GPGVCMD(filen) "gpgv -q --keyring " & CONF_DIR & "keyring.gpg " & CACHE_DIR & filen & ".zip.sign"

#include once "vbcompat.bi"

#ifndef FALSE
    #define FALSE 0
#endif
#ifndef TRUE
    #define TRUE (not false)
#endif

type package_desc
    as string _name, _desc, _depends
    as uinteger version
end type

dim shared available() as package_desc
dim shared installed() as package_desc

declare function split (byref s as const string, result() as string, byref delimiter as const string, byval limit as integer) as integer
declare sub showHelp( byref hc as const string = "" )
declare sub loadPackages( )
declare sub showList( byref opts as const string = "" )
declare sub installPackages( byref p as string )
declare sub removePackages( byref p as string )

scope 'main

var cmd = lcase(command(1))
if cmd = "" then
    print "fb-get - FreeBASIC Package Installer"
    showHelp()
    end 1
end if

print "fb-get - FreeBASIC Package Installer"

print "Loading package information."

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
    print #ff, ubound(installed) + 1
    for m as uinteger = 0 to ubound(installed)
        print #ff, installed(m)._name
        print #ff, installed(m)._desc
        print #ff, installed(m)._depends
        print #ff, installed(m).version
        print #ff, ""
    next
    close #ff
case "remove"
    removePackages(rcmd)
    var ff = freefile
    open INST_LIST FOR OUTPUT ACCESS WRITE AS #ff
    print #ff, ubound(installed) + 1
    for m as uinteger = 0 to ubound(installed)
        print #ff, installed(m)._name
        print #ff, installed(m)._desc
        print #ff, installed(m)._depends
        print #ff, installed(m).version
        print #ff, ""
    next
    close #ff
    kill CACHE_DIR & "fbget.lock"
case "list"
    showList(rcmd)
case "search"
    print "Search Results:"
    print
    for n as uinteger = 0 to ubound(available)
        if instr(available(n)._name,rcmd) orelse instr(available(n)._desc,rcmd) then
            print available(n)._name & ": ";
            var installed_is = 0
            for m as uinteger = 0 to ubound(installed)
                if available(n)._name = installed(m)._name then
                    print "installed"
                    installed_is = 1
                    exit for
                end if
            next
            if installed_is = 0 then print "not installed"
        end if
    next
    print
case else
    showhelp(rcmd)
    end 1
end select

end scope

kill CACHE_DIR & "fbget.lock"

#macro errorout(r,l)
if r <> 0 then
    print "ERROR: " & l
    end 42
end if
#endmacro

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
    case "search"
        print "Search for the specified string in the available package names."
    case else
        print "Usage: fb-get update|install [package]|remove [package]|list|search"
    end select

    print

end sub

sub loadPackages( )

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
            redim available(0 to num_pkgs - 1)
            for n as uinteger = 0 to num_pkgs -1
                line input #ff, cur_line
                available(n)._name = cur_line
                line input #ff, cur_line
                available(n)._desc = cur_line
                line input #ff, cur_line
                available(n)._depends = cur_line
                line input #ff, cur_line
                available(n).version = valuint(cur_line)
                line input #ff, cur_line
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
            redim installed(0 to num_pkgs - 1)
            for n as uinteger = 0 to num_pkgs -1
                line input #ff, cur_line
                installed(n)._name = cur_line
                line input #ff, cur_line
                installed(n)._desc = cur_line
                line input #ff, cur_line
                installed(n)._depends = cur_line
                line input #ff, cur_line
                installed(n).version = valuint(cur_line)
                line input #ff, cur_line
            next
            close #ff
        end if
    else
        print "INFO: No packages installed."
    end if

    close

end sub

sub showList( byref opts as const string = "" )
    if opts = "-all" then
        print "Full package listing:"
        for n as uinteger = 0 to ubound(available)
            print available(n)._name
        next
    else
        print "Installed packages:"
        for n as uinteger = 0 to ubound(installed)
            print installed(n)._name
        next
    end if
    print
end sub

sub install( byref pkgname as string )

    for n as uinteger = 0 to ubound(available)
        if available(n)._name = pkgname then
            for m as uinteger = 0 to ubound(installed)
                if installed(m)._name = pkgname then
                    print pkgname & " is already installed."
                    return
                end if
            next
            'not already installed, let's do this
            if available(n)._depends <> "none" then
                installPackages( available(n)._depends )
            end if
            print "Installing " & pkgname
            var ret = shell (WGETCMD(pkgname))
            errorout(ret,__LINE__)
            ret = shell (WGETCMD(pkgname & ".sign"))
            errorout(ret,__LINE__)
            ret = name(CACHE_DIR & pkgname & ".sign" & ".zip", CACHE_DIR & pkgname & ".zip" & ".sign")
            errorout(ret,__LINE__)
            ret = shell( GPGVCMD(pkgname) )
            errorout(ret,__LINE__)
            chdir INST_DIR
            ret = shell (UNZIPCMD(pkgname & ".zip"))
            errorout(ret,__LINE__)
            redim preserve installed(ubound(installed))
            installed(ubound(installed)) = available(n)
            shell MANIFEST(pkgname)
            return
        end if
    next
    print "ERROR: " & pkgname & " was not found in the database."
    end 4

end sub

sub installPackages( byref p as string )

    dim toinstall() as string
    split(p,toinstall()," ",0)

    for n as uinteger = 0 to ubound(toinstall)
        install(toinstall(n))
    next

end sub

sub remove( byref pkg as string )

    var removed = 0
    var cnt = 0
    dim newinstalled(0 to ubound(installed) -1) as package_desc
    for n as uinteger = 0 to ubound(installed)
        if installed(n)._name = pkg then
            print "Removing " & pkg
            var ff = freefile
            if open(MANF_DIR & pkg & ".manifest",for binary, access read,as #ff) <> 0 then
                print "ERROR: unable to open manifest for " & pkg
                exit sub
            else
                var tline = ""
                line input #ff, tline
                line input #ff, tline
                line input #ff, tline
                line input #ff, tline
                while left(tline,1) <> "-"
                    dim tinfo() as string
                    split(tline,tinfo()," ",0)
                    if right(tinfo(ubound(tinfo)),1) <> "/" or right(tinfo(ubound(tinfo)),1) <> "\" then
                        kill INST_DIR & tinfo(ubound(tinfo))
                    end if
                    line input #ff, tline
                wend
                close #ff
                kill MANF_DIR & pkg & ".manifest"
                removed = 1
            end if

        else
            if cnt > ubound(newinstalled) then exit for
            newinstalled(cnt) = installed(n)
            cnt += 1
        end if
    next

    if removed = 0 then
        print "ERROR: " & pkg & " is not installed."
        end 5
    else
        redim installed(0 to ubound(newinstalled))
        for n as uinteger = 0 to ubound(installed)
            installed(n) = newinstalled(n)
        next
    end if
end sub

sub removePackages( byref p as string )

    dim toremove() as string
    split(p,toremove()," ",0)

    for n as uinteger = 0 to ubound(toremove)
        remove(toremove(n))
    next

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
