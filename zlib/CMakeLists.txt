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

cmake_minimum_required(VERSION 2.7)

set(SOURCES
    adler32.c
    crc32.c
    deflate.c
    gzclose.c
    gzlib.c
    gzread.c
    gzwrite.c
    inffast.c
    inflate.c
    inftrees.c
    trees.c
    zutil.c
)

set(HEADERS crc32.h
    deflate.h
    gzguts.h
    inffast.h
    inffixed.h
    inflate.h
    inftrees.h
    trees.h
    zconf.h
    zlib.h
    zutil.h
)

add_library(zlib STATIC
  ${SOURCES}
  ${HEADERS}
)

add_library(z ALIAS zlib)

target_include_directories(zlib PUBLIC . PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

macro(add_definition_if_have_one target definition)
    if (${definition})
	    target_compile_definitions(${target} PRIVATE "-D${definition}=${${definition}}")
	endif()
endmacro()

# We don't have auto generated config.h for zlib
add_definition_if_have_one(zlib HAVE_UNISTD_H)
add_definition_if_have_one(zlib HAVE_STDARG_H)
add_definition_if_have_one(zlib HAVE_VSNPRINTF)
