#ifndef __FB_GET_UTIL_BI__
#define __FB_GET_UTIL_BI__ 1

''log module is based on BSD licensed code.
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

type log_custom_sub as sub( byval as LOGLEVEL, byref _msg_ as const string, byref _filen_ as const string, byval _linen_ as integer, byval _data_ as any ptr )
type custom_data_free as sub ( byval as any ptr )

''Returns TRUE on error, invalid arg or memory allocation failure, existing channel(s) not changed on error
declare function set_num_channels( byval c as uinteger ) as integer

declare sub set_log_method overload ( byval as l_m, byval as any ptr = 0, byval as any ptr = 0, byval as any ptr = 0 )
declare sub set_log_method( byval channel as uinteger, _
                            byval as l_m, _
                            byval func_or_filen as any ptr = 0, _
                            byval func_data as any ptr = 0, _
                            byval fdata_free as any ptr = 0 _
                            )

declare sub set_log_level overload ( byval as LOGLEVEL )
declare sub set_log_level( byval channel as uinteger, byval as LOGLEVEL )

declare sub __log( byval as LOGLEVEL, _
            byref _msg_ as const string, _
            byref _file_ as const string, _
            byval _line_number_ as integer, _
            byval channel as uinteger = 0 _
            )

#define DEBUG(m) _LOG(_DEBUG,m,0)
#define DEBUGto(c,m) _LOG(_DEBUG,m,(c))

#define INFO(m) _LOG(_INFO,m,0)
#define INFOto(c,m) _LOG(_INFO,m,(c))

#define WARN(m) _LOG(_WARN,m,0)
#define WARNto(c,m) _LOG(_WARN,m,(c))

#define FATAL(m) _LOG(_FATAL,m,0)
#define FATALto(c,m) _LOG(_FATAL,m,(c))

#define _LOG(l,m,c) __log( (l), (m), __FILE__, __LINE__, (c) )

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
