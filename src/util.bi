#ifndef __FB_GET_UTIL_BI__
#define __FB_GET_UTIL_BI__ 1

''log
enum LOGLEVEL
    _DEBUG
    _INFO
    _WARN
    _FATAL
end enum

enum l_m
    LOG_NULL
    LOG_PRINT
    LOG_FILE
    LOG_CUSTOM
end enum

type log_custom_sub as sub( byval as LOGLEVEL, byref as const string, byref as const string, byval as integer )

declare sub set_log_method( byval as l_m, byval as any ptr )
declare sub set_log_level( byval as LOGLEVEL )

declare sub __log( byval as LOGLEVEL, _
            byref _msg_ as const string, _
            byref _file_ as const string, _
            byval _line_number_ as integer _
            )

#define DEBUG(m) _LOG(_DEBUG,m)
#define INFO(m) _LOG(_INFO,m)
#define WARN(m) _LOG(_WARN,m)
#define FATAL(m) _LOG(_FATAL,m)

#define _LOG(l,m) __log( (l), (m), __FILE__, __LINE__ )

''command utilities
declare function get_file( byref destd as const string, byref f as const string ) as integer
declare function verify_file( byref sig_file as const string, byref key_f as const string ) as integer
declare function unpack_files( byref f as const string, byref dest as const string ) as integer
declare function generate_manifest( byref f as const string, byref dest as const string ) as integer

''config utilities
declare function get_config(byref k as string) as string
declare sub set_config(byref k as string, byref v as string)

''string utilities
declare function split (byref s as const string, result() as string, byref delimiter as const string, byval limit as integer) as integer

#endif
