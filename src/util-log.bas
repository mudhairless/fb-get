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

#include once "vbcompat.bi"
#include once "util.bi"

dim shared __log_method as l_m
dim shared __log_data as any ptr
dim shared __log_level as LOGLEVEL

sub set_log_level( byval l as LOGLEVEL )

    __log_level = l

end sub

sub set_log_method( byval m as l_m, byval d as any ptr )

    __log_method = m
    __log_data = d

end sub

private function lstr( byval l as LOGLEVEL ) as string
    select case l
    case _DEBUG
        return "DEBUG"
    case _INFO
        return "INFO"
    case _WARN
        return "WARN"
    case _FATAL
        return "FATAL"
    end select
    return "LLAMA"
end function

sub __init_log () constructor
    __log_method = LOG_PRINT
    __log_level = _INFO
end sub

function iso_datetime( byval t as double ) as string

    return format(t,"yyyy-mm-ddThh:mm:ss")

end function

sub __log( byval lvl as LOGLEVEL, _
            byref _msg_ as const string, _
            byref _file_ as const string, _
            byval _line_number_ as integer _
            )

    if lvl < __log_level then return

    select case __log_method
    case LOG_NULL
        return
    case LOG_PRINT
        print lstr(lvl) & ": " & _msg_
    case LOG_FILE
        var fname_ = cast(zstring ptr,__log_data)
        var fname = ""
        if fname_ <> 0  then
            fname = *fname_
        else
            fname = command(0) & ".log"
        end if
        var isodate = ""

        var ff = freefile
        open fname for append access write as #ff
        print #ff, iso_datetime(now) & " " & lstr(lvl) & " " & _msg_ & " -> " & _file_ & ":" & _line_number_
        close #ff
    case LOG_CUSTOM
        var csub = cast(log_custom_sub,__log_data)
        csub(lvl,_msg_,_file_,_line_number_)
    end select
end sub

#ifdef __FB_MAIN__
    sub my_custom_log( byval l as loglevel, byref m as const string, byref f as const string, byval l_ as integer )
        print m
    end sub

    INFO("This is a test log message.") 'print this one
    set_log_method(LOG_FILE,0) 'direct log output to a file, should be writable by the process or will silently fail
    DEBUG("This is a test log message.") 'debug not printed by default
    sleep(3000,1)
    set_log_level(_WARN) 'The default level is INFO, only print this level and above
    INFO("This is also a test log message.") 'not printed
    WARN("Only one entry should be written to the log.") 'printed
    set_log_method(LOG_CUSTOM,@my_custom_log) 'change it up a bit
    WARN("Whoa dude, we can do anything with this!") 'whoa!
#endif
