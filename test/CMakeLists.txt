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

set(SOURCES main.c
    framework.c
    test_args.c
    test_argument_processing.c
    test_argument_processing.c
    test_compopt.c
    test_compopt.c
    test_conf.c
    test_counters.c
    test_hash.c
    test_hashutil.c
    test_lockfile.c
    test_stats.c
    test_util.c
    util.c
)

set(HEADERS util.h)

add_executable(ccache_ut
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries(ccache_ut ccache_core)
target_include_directories(ccache_ut PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

add_test(ccache_ut ccache_ut)

if(UNIX)
    add_test(NAME ccache_test
	    COMMAND ${PROJECT_SOURCE_DIR}/test.sh
	    WORKING_DIRECTORY $<TARGET_FILE_DIR:ccache>
	)
endif()