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

sub remove( byref pkg as string )

    var rpkg = installed->findItem( pkg )
    if rpkg <> NULL then
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
                installed->removeItem(pkg)
            end if
    else
        print "ERROR: " & pkg & " is not installed."
        end 5
    end if

end sub

sub removePackages( byref p as string )

    dim toremove() as string
    split(p,toremove()," ",0)

    for n as uinteger = 0 to ubound(toremove)
        remove(toremove(n))
    next

end sub
