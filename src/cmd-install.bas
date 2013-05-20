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

function install( byval pkg as package_desc ptr ) as integer

    if pkg = NULL then
        FATAL("The package pointer passed to the install function turned out to be null.")
        return TRUE
    end if

    var pkgname = pkg->_name

    INFO("Installing " & pkgname)
    var ret = get_file(CACHE_DIR & pkgname & ".zip", pkgname & ".zip")
    DEBUG("Get: " & pkgname & " (" & ret & ")")
    if ret <> 0 then
        FATAL("Unable to retrieve package: " & pkgname)
        return TRUE
    end if
    ret = get_file(CACHE_DIR & pkgname & ".zip.sign", pkgname & ".zip.sign")
    DEBUG("Get: " & pkgname & " signature (" & ret & ")")
    if ret <> 0 then
        FATAL("Unable to retrieve package signature for: " & pkgname)
        return TRUE
    end if
    ret = verify_file(CACHE_DIR & pkgname & ".zip.sign", CONF_DIR & "keyring.gpg")
    DEBUG("Verify: " & pkgname & " (" & ret & ")")
    if ret <> 0 then
        FATAL("Unable to verify package: " & pkgname)
        return TRUE
    end if
    ret = unpack_files(CACHE_DIR & pkgname & ".zip", INST_DIR)
    DEBUG("Unpack: " & pkgname & " (" & ret & ")")
    if ret <> 0 then
        FATAL("Unable to unpack package: " & pkgname)
        return TRUE
    end if
    ret = generate_manifest(CACHE_DIR & pkgname & ".zip", MANF_DIR & pkgname & ".manifest")
    DEBUG("Manifest: " & pkgname & " (" & ret & ")")
    if ret <> 0 then
        FATAL("Unable to generate manifest package: " & pkgname & ". The package is installed but most likely in an inconsistent state and cannot be uninstalled with this tool.")
        return TRUE
    end if
    installed->addItem( *pkg )
    return FALSE

end function

private function generate_install_list( byref p as string ) as integer

    if changes = NULL then changes = new package_list

    dim cmdline() as string
    split(p,cmdline()," ",0)

    for n as uinteger = 0 to ubound(cmdline)
        var curpkgp = available->findItem(cmdline(n))
        if curpkgp = NULL then
            FATAL(cmdline(n) & " was not found in the database.")
            return TRUE
        end if
        if installed->findItem(cmdline(n)) <> NULL then
            INFO( cmdline(n) & " is already installed." )
        else
            if curpkgp->_depends <> "none" andalso curpkgp->_depends <> "" then
                var ret = generate_install_list(curpkgp->_depends)
                if ret = TRUE then return TRUE
            end if
            var curpkg = *curpkgp
            changes->addItem(curpkg)
        end if
    next

    return FALSE

end function

sub installPackages( byref p as string )

    INFO("Checking dependencies...")
    if generate_install_list(p) = TRUE then end 4
    INFO("Processing requested changes...")
    if changes->iter(@install) = TRUE then end 37

end sub
