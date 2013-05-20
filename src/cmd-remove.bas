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

dim shared fbflag as integer

function remove( byval pkg_ as package_desc ptr ) as integer

    var rpkg = pkg_
    if rpkg <> NULL then
        var pkg = rpkg->_name
        INFO("Removing " & pkg)
        var ff = freefile
        if open(MANF_DIR & pkg & ".manifest",for binary, access read,as #ff) <> 0 then
            FATAL( "ERROR: unable to open manifest for " & pkg )
            return TRUE
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
                    DEBUG("Deleting file: " & INST_DIR & tinfo(ubound(tinfo)))
                    kill INST_DIR & tinfo(ubound(tinfo))
                end if
                line input #ff, tline
            wend
            close #ff
            DEBUG("Deleting " & pkg & " manifest")
            kill MANF_DIR & pkg & ".manifest"
            installed->removeItem(pkg)
        end if
    end if

end function

private function generate_remove_list ( byref p as string ) as integer

    if changes = NULL then changes = new package_list

    dim toremove() as string
    split(p,toremove()," ",0)

    for n as uinteger = 0 to ubound(toremove)
        var curpkgp = installed->findItem(toremove(n))
        if curpkgp = NULL then
            INFO(toremove(n) & " is not installed.")
        end if
        if curpkgp->_depends <> "none" andalso curpkgp->_depends <> "" then
            var ret = generate_remove_list( curpkgp->_depends )
            if ret = TRUE then return TRUE
        end if
        var curpkg = *curpkgp
        changes->addItem(curpkg)
    next

    return FALSE

end function

dim shared __curp as package_desc ptr

private function analyze_depends ( byval p as package_desc ptr ) as integer

    if instr(p->_depends,__curp->_name) then return TRUE
    return FALSE

end function

private function analyze_removals ( byval p as package_desc ptr ) as integer

    if p->_name = "fbc" and fbflag = FALSE then
        DEBUG("fbc wasn't specified for removal so we are going to skip it.")
        changes->removeItem("fbc")
        return TRUE
    end if

    __curp = p
    var ret = installed->iter(@analyze_depends)
    if ret = TRUE then
        WARN( p->_name & " is depended on by other packages and cannot be removed without first removing them." )
        return TRUE
    end if

    return FALSE
end function

sub removePackages( byref p as string )
    fbflag = FALSE
    if instr(p,"fbc") then fbflag = TRUE
    INFO("Analyzing dependencies for packages to be removed.")
    if generate_remove_list(p) = TRUE then end 5
    while changes->iter(@analyze_removals) = TRUE : wend

    if changes->cnt > 0 then
        INFO("Removing packages.")
        if changes->iter(@remove) = TRUE then end 38
    else
        WARN("After analysis no packages are being removed due to dependencies.")
    end if

end sub
