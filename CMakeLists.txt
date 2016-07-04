# ################################################################################
# ccache -- a fast C/C++ compiler cache
# 
# Copyright (C) 2002-2007 Andrew Tridgell
# Copyright (C) 2009-2016 Joel Rosdahl
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option)
# any later version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
# ################################################################################

project(ccache LANGUAGES C)

cmake_minimum_required(VERSION 2.7)

include(CheckIncludeFiles)
check_include_files("ctype.h"     HAVE_CTYPE_H    )
check_include_files("dirent.h"    HAVE_DIRENT_H   )
check_include_files("inttypes.h"  HAVE_INTTYPES_H )
check_include_files("locale.h"    HAVE_LOCALE_H   )
check_include_files("memory.h"    HAVE_MEMORY_H   )
check_include_files("ndir.h"      HAVE_NDIR_H     )
check_include_files("pwd.h"       HAVE_PWD_H      )
check_include_files("stdarg.h"    HAVE_STDARG_H   )
check_include_files("stdbool.h"	  HAVE_STDBOOL_H  )
check_include_files("stddef.h"    HAVE_STDDEF_H   )
check_include_files("stdint.h"    HAVE_STDINT_H   )
check_include_files("stdlib.h"    HAVE_STDLIB_H   )
check_include_files("string.h"    HAVE_STRING_H   )
check_include_files("strings.h"   HAVE_STRINGS_H  )
check_include_files("sys/dir.h"   HAVE_SYS_DIR_H  )
check_include_files("sys/mman.h"  HAVE_SYS_MMAN_H )
check_include_files("sys/ndir.h"  HAVE_SYS_NDIR_H )
check_include_files("sys/stat.h"  HAVE_SYS_STAT_H )
check_include_files("sys/time.h"  HAVE_SYS_TIME_H )
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)
check_include_files("sys/wait.h"  HAVE_SYS_WAIT_H )
check_include_files("termios.h"   HAVE_TERMIOS_H  )
check_include_files("unistd.h"    HAVE_UNISTD_H   )
check_include_files("varargs.h"   HAVE_VARARGS_H  )

include(CheckFunctionExists)
check_function_exists("asprintf" HAVE_ASPRINTF        )
check_function_exists("gethostname" HAVE_GETHOSTNAME  )
check_function_exists("getopt_long" HAVE_GETOPT_LONG  )
check_function_exists("getpwuid"    HAVE_GETPWUID     )
check_function_exists("gettimeofday" HAVE_GETTIMEOFDAY)
check_function_exists("mkstemp" HAVE_MKSTEMP          )
check_function_exists("realpath" HAVE_REALPATH        )
check_function_exists("snprintf" HAVE_SNPRINTF        )
check_function_exists("strndup" HAVE_STRNDUP          )
check_function_exists("strtok_r" HAVE_STRTOK_R        )
check_function_exists("unsetenv" HAVE_UNSETENV        )
check_function_exists("utimes" HAVE_UTIMES            )
check_function_exists("vasprintf" HAVE_VASPRINTF      )
check_function_exists("vsnprintf" HAVE_VSNPRINTF      )

include(CheckTypeSize)
check_type_size("long long"              HAVE_LONG_LONG             )
check_type_size("unsigned long long int" HAVE_UNSIGNED_LONG_LONG_INT)
check_type_size("_Bool"                  HAVE__BOOL                 )

set(CONFIG_H ${CMAKE_CURRENT_BINARY_DIR}/config.h)
configure_file(config.h.new ${CONFIG_H})

add_subdirectory(zlib)

set(SOURCES args.c
    ccache.c
    cleanup.c
    compopt.c
    conf.c		
    # confitems_lookup.c
    counters.c		
    # envtoconfitems_lookup.c
    execute.c
    exitfn.c
    getopt_long.c
    hash.c	
    hashtable.c
    hashtable_itr.c
    hashutil.c
    language.c
    lockfile.c
    main.c
    manifest.c
    mdfour.c	
    murmurhashneutral2.c
    snprintf.c	
    stats.c	util.c
    unify.c
    version.c
)

set(HEADERS ccache.h
	compopt.h
	conf.h
	counters.h
	getopt_long.h
	hashtable.h
	hashtable_itr.h
	hashtable_private.h
	hashutil.h
	language.h
	macroskip.h
	manifest.h
	mdfour.h
	murmurhashneutral2.h
	system.h
)

add_executable(ccache
    ${SOURCES}
    ${HEADERS}
)

target_include_directories(ccache PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_compile_definitions(ccache PRIVATE -DHAVE_CONFIG_H=1)
target_link_libraries(ccache zlib m)
