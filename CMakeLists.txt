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

project(ccache)

cmake_minimum_required(VERSION 2.7)

option(ENABLE_TESTING  "Enable testing" ON)
if (ENABLE_TESTING)
    enable_testing()
endif()

option(DEVELOPER_BUILD "Enable developer build" ON)

execute_process(COMMAND "git" "describe"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	RESULT_VARIABLE   GIT_SUCCESS
	OUTPUT_VARIABLE   GIT_DESCRIBE
)

if (GIT_SUCCESS EQUAL 0)
    if (DEVELOPER_BUILD)
        string(REGEX REPLACE "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)\\-([0-9]+)\\-(.*)(.$)" "\\1.\\2.\\3+\\4_\\5" CCACHE_VERSION ${GIT_DESCRIBE})
	else()
        string(REGEX REPLACE "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)\\-([0-9]+)\\-(.*)" "\\1.\\2.\\3" CCACHE_VERSION ${GIT_DESCRIBE})
    endif()
else()
   set(CCACHE_VERSION "unknown")
endif()
  
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
check_include_files("sys/file.h"  HAVE_SYS_FILE_H )
check_include_files("sys/mman.h"  HAVE_SYS_MMAN_H )
check_include_files("sys/ndir.h"  HAVE_SYS_NDIR_H )
check_include_files("sys/stat.h"  HAVE_SYS_STAT_H )
check_include_files("sys/time.h"  HAVE_SYS_TIME_H )
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)
check_include_files("sys/wait.h"  HAVE_SYS_WAIT_H )
check_include_files("termios.h"   HAVE_TERMIOS_H  )
check_include_files("unistd.h"    HAVE_UNISTD_H   )
check_include_files("utime.h"     HAVE_UTIME_H    )
check_include_files("varargs.h"   HAVE_VARARGS_H  )

include(CheckFunctionExists)
check_function_exists("asprintf"     HAVE_ASPRINTF    )
check_function_exists("gethostname"  HAVE_GETHOSTNAME )
check_function_exists("getopt"       HAVE_GETOPT      )
check_function_exists("getopt_long"  HAVE_GETOPT_LONG )
check_function_exists("getpwuid"     HAVE_GETPWUID    )
check_function_exists("gettimeofday" HAVE_GETTIMEOFDAY)
check_function_exists("mkstemp"      HAVE_MKSTEMP     )
check_function_exists("pow"          HAVE_POW         )
check_function_exists("realpath"     HAVE_REALPATH    )
check_function_exists("snprintf"     HAVE_SNPRINTF    )
check_function_exists("strndup"      HAVE_STRNDUP     )
check_function_exists("strtok_r"     HAVE_STRTOK_R    )
check_function_exists("unsetenv"     HAVE_UNSETENV    )
check_function_exists("utimes"       HAVE_UTIMES      )
check_function_exists("vasprintf"    HAVE_VASPRINTF   )
check_function_exists("vsnprintf"    HAVE_VSNPRINTF   )

include(CheckTypeSize)
check_type_size("long long"              HAVE_LONG_LONG             )
check_type_size("unsigned long long int" HAVE_UNSIGNED_LONG_LONG_INT)
check_type_size("_Bool"                  HAVE__BOOL                 )
check_type_size("ssize_t"                HAVE_SSIZE_T               )

include(TestBigEndian)
test_big_endian(VARIABLE WORDS_BIGENDIAN)

set(GENERATED_FILES ${CMAKE_CURRENT_BINARY_DIR})
file(MAKE_DIRECTORY ${GENERATED_FILES})
set(CONFIG_H ${GENERATED_FILES}/config.h)
configure_file(config.h.new ${CONFIG_H})

option(USE_OWN_LIBZ "Compile own version of libz and link against it" OFF)

if (NOT USE_OWN_LIBZ)
    include(FindZLIB)

	if (NOT ZLIB_FOUND)
        set(USE_OWN_LIBZ YES)
	endif()
endif()

# Fallback to own libz
if (USE_OWN_LIBZ)
    add_subdirectory(zlib)
    set(ZLIB_INCLUDE_DIRS zlib)
	set(ZLIB_LIBRARIES    zlib)
endif()

include_directories(
    ${GENERATED_FILES}
	${CMAKE_CURRENT_LIST_DIR}
	${ZLIB_INCLUDE_DIRS}
)

add_definitions(-DHAVE_CONFIG_H=1 -DCCACHE_VERSION_VAR="${CCACHE_VERSION}")

add_subdirectory(test)

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
    manifest.c
    mdfour.c	
    murmurhashneutral2.c
    snprintf.c	
    stats.c	util.c
    unify.c
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

add_library(ccache_core STATIC
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries(ccache_core ${ZLIB_LIBRARIES})

if (NOT HAVE_POW)
    target_link_libraries(ccache_core m)
endif()

if(WIN32)
    target_link_libraries(ccache_core ws2_32 psapi)
endif()

add_executable(ccache main.c)
target_link_libraries(ccache ccache_core)
