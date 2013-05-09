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

sub install( byref pkgname as string )

    var apkg = available->findItem(pkgname)
    if apkg <> NULL then
        if installed->findItem(pkgname) = NULL then
            'not already installed, let's do this
            if apkg->_depends <> "none" then
                installPackages( apkg->_depends )
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
            shell MANIFEST(pkgname)
            installed->addItem( *apkg )
            return
        else
            print "INFO: " & pkgname & " is already installed."
        end if
    else
        print "ERROR: " & pkgname & " was not found in the database."
        end 4
    end if
end sub

sub installPackages( byref p as string )

    dim toinstall() as string
    split(p,toinstall()," ",0)

    for n as uinteger = 0 to ubound(toinstall)
        install(toinstall(n))
    next

end sub
