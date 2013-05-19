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
            INFO("Installing " & pkgname)
            var ret = get_file(CACHE_DIR & pkgname & ".zip", pkgname & ".zip")
            DEBUG("Get: " & pkgname & " (" & ret & ")")
            ret = get_file(CACHE_DIR & pkgname & ".zip.sign", pkgname & ".zip.sign")
            DEBUG("Get: " & pkgname & " signature (" & ret & ")")
            ret = verify_file(CACHE_DIR & pkgname & ".zip.sign", CONF_DIR & "keyring.gpg")
            DEBUG("Verify: " & pkgname & " (" & ret & ")")
            ret = unpack_files(CACHE_DIR & pkgname & ".zip", INST_DIR)
            DEBUG("Unpack: " & pkgname & " (" & ret & ")")
            ret = generate_manifest(CACHE_DIR & pkgname & ".zip", MANF_DIR & pkgname & ".manifest")
            DEBUG("Manifest: " & pkgname & " (" & ret & ")")
            installed->addItem( *apkg )
            return
        else
            INFO(pkgname & " is already installed.")
        end if
    else
        FATAL(pkgname & " was not found in the database.")
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
