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

include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckTypeSize)
include(TestBigEndian)

set(macro_list "")

macro(mk_perproc_macro str out_str)
    string(REPLACE " " "_" wo_spaces_str "${str}")
    string(REPLACE "." "_" wo_dots_str   "${wo_spaces_str}")
	string(REPLACE "/" "_" wo_seps_str   "${wo_dots_str}")
	string(TOUPPER "${wo_seps_str}" upper_str)
	set(${out_str} "HAVE_${upper_str}")
endmacro()

macro(check_include include_str)
    mk_perproc_macro(${include_str} macro_str)
	list(APPEND macro_list ${macro_str})
	check_include_files("${include_str}" ${macro_str})
endmacro()

macro(check_function func)
    mk_perproc_macro(${func} macro_str)
	list(APPEND macro_list ${macro_str})
	check_function_exists("${func}" ${macro_str})
endmacro()

macro(check_type type)
    mk_perproc_macro(${type} macro_str)
	list(APPEND macro_list ${macro_str})
	check_type_size("${type}" ${macro_str})
endmacro()

check_include("ctype.h")
check_include("dirent.h")
check_include("inttypes.h")
check_include("locale.h")
check_include("memory.h")
check_include("ndir.h")
check_include("pwd.h")
check_include("stdarg.h")
check_include("stdbool.h")
check_include("stddef.h")
check_include("stdint.h")
check_include("stdlib.h")
check_include("string.h")
check_include("strings.h")
check_include("sys/dir.h")
check_include("sys/file.h")
check_include("sys/mman.h")
check_include("sys/ndir.h")
check_include("sys/stat.h")
check_include("sys/time.h")
check_include("sys/types.h")
check_include("sys/wait.h")
check_include("termios.h")
check_include("unistd.h")
check_include("utime.h")
check_include("varargs.h")

check_function("asprintf")
check_function("gethostname")
check_function("getopt")
check_function("getopt_long")
check_function("getpwuid")
check_function("gettimeofday")
check_function("mkstemp")
check_function("pow")
check_function("realpath")
check_function("snprintf")
check_function("strndup")
check_function("strtok_r")
check_function("unsetenv")
check_function("utimes")
check_function("vasprintf")
check_function("vsnprintf")

check_type("long long")
check_type("unsigned long long int")
check_type("_Bool")
check_type("ssize_t")

include(TestBigEndian)
test_big_endian(VARIABLE WORDS_BIGENDIAN)
list(APPEND macro_list WORDS_BIGENDIAN)

set(CONFIG_H_IN "${GENERATED_FILES}/config.h.in")
set(CONFIG_H ${GENERATED_FILES}/config.h)

set(config_h_in_src "")
foreach(macro_str IN LISTS macro_list)
    set(config_h_in_src "${config_h_in_src} #cmakedefine ${macro_str} 1\n")
endforeach()
  
set(config_h_in_src "${config_h_in_src} #define _GNU_SOURCE 1\n")

file(WRITE ${CONFIG_H_IN} ${config_h_in_src})

configure_file(${CONFIG_H_IN} ${CONFIG_H})
