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

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

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

set(GENERATED_FILES ${CMAKE_CURRENT_BINARY_DIR}/gen)
file(MAKE_DIRECTORY ${GENERATED_FILES})

include(check_features)

option(USE_OWN_LIBZ "Compile own version of libz and link against it" OFF)

if (NOT USE_OWN_LIBZ)
    include(FindZLIB)

	if (NOT ZLIB_FOUND)
        message("Zlib is not found, fallback to own zlib")
	    set(USE_OWN_LIBZ YES)
	endif()
endif()

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
    counters.c		
    execute.c
    exitfn.c
    hash.c	
    hashutil.c
    language.c
    lockfile.c
    manifest.c
    mdfour.c	
    murmurhashneutral2.c
    stats.c
	util.c
    unify.c)

set(HEADERS ccache.h
	compopt.h
	conf.h
	counters.h
	hashutil.h
	language.h
	macroskip.h
	manifest.h
	mdfour.h
	murmurhashneutral2.h
	system.h)

set(OTHER_SOURCES
    hashtable.c
    hashtable_itr.c
    snprintf.c
    getopt_long.c)
set(OTHER_HEADERS
	hashtable.h
	hashtable_itr.h
	hashtable_private.h
	getopt_long.h)
  
include(uncrustify)
uncrustify_files("${SOURCES}")
uncrustify_files("${HEADERS}")

include(gperf)
if (GPERF_FOUND)
    gperf2c(envtoconfitems.gperf "${GENERATED_FILES}/envtoconfitems_lookup.c")
    gperf2c(confitems.gperf      "${GENERATED_FILES}/confitems_lookup.c")
endif() # otherwise, fallback to pregenerated

add_library(ccache_core STATIC
    ${SOURCES}
	${OTHER_SOURCES}
    ${HEADERS}
	${OTHER_HEADERS}
)

add_dependencies(ccache_core gperf)

target_link_libraries(ccache_core ${ZLIB_LIBRARIES})

if (NOT HAVE_POW)
    target_link_libraries(ccache_core m)
endif()

if(WIN32)
    target_link_libraries(ccache_core ws2_32 psapi)
endif()

add_executable(ccache main.c)
target_link_libraries(ccache ccache_core)

install(TARGETS ccache
    RUNTIME DESTINATION bin
    PERMISSIONS
	    OWNER_READ OWNER_WRITE OWNER_EXECUTE
	    GROUP_READ             GROUP_EXECUTE
	    WORLD_READ             WORLD_EXECUTE
)

include(docs_tools)

txt2man(MANUAL.txt ccache.1 ${CCACHE_VERSION})

txt2html(AUTHORS.txt AUTHORS.html ${CCACHE_VERSION})
txt2html(HACKING.txt HACKING.html ${CCACHE_VERSION})
txt2html(INSTALL.txt INSTALL.html ${CCACHE_VERSION})
txt2html(LICENSE.txt LICENSE.html ${CCACHE_VERSION})
txt2html(MANUAL.txt  MANUAL.html  ${CCACHE_VERSION})
txt2html(NEWS.txt    NEWS.html    ${CCACHE_VERSION})
txt2html(README.txt  README.html  ${CCACHE_VERSION})

set(CPACK_PACKAGE_VERSION ${CCACHE_VERSION})
set(CPACK_STRIP_FILES bin/ccache)
set(CPACK_PACKAGE_CONTACT "ccache@lists.samba.org")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
include(CPack)