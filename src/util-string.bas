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

'' :::::
Sub Replace (subject As String, oldtext As const String, newtext As const String)
  'replaces all occurances of oldtext in subject with newtext
  Dim As Integer n
  If subject <> "" And oldtext <> "" And oldtext <> newtext Then
    n = Instr(subject, oldtext)
    Do While n <> 0
      subject = Left(subject,n-1) & newtext & Right(subject,Len(subject)- n - Len(oldtext)+ 1)
      n = Instr(n + Len(newtext),subject, oldtext)
    Loop
  End if
End Sub

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
