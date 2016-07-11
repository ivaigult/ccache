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

add_library(ccache_core STATIC
    ${SOURCES}
	${OTHER_SOURCES}
    ${HEADERS}
	${OTHER_HEADERS}
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

install(TARGETS ccache
    RUNTIME DESTINATION bin
    PERMISSIONS
	    OWNER_READ OWNER_WRITE OWNER_EXECUTE
	    GROUP_READ             GROUP_EXECUTE
	    WORLD_READ             WORLD_EXECUTE
)

find_program(ASCIIDOC asciidoc)
find_program(XSLTPROC xsltproc)

set(MANPAGE_XSL "manpage.xsl")
find_path(MAN_STYLE_SHEET_PATH ${MANPAGE_XSL}
    "/usr/local/etc/asciidoc/docbook-xsl/"
    "/etc/asciidoc/docbook-xsl/")

  
if (ASCIIDOC AND XSLTPROC AND MAN_STYLE_SHEET_PATH)
    set(MANUAL_TXT "${CMAKE_CURRENT_SOURCE_DIR}/MANUAL.txt")
    set(MANUAL_XML "${GENERATED_FILES}/MANUAL.xml")
    set(CCACHE_1   "${CMAKE_CURRENT_BINARY_DIR}/ccache.1")
    add_custom_command(OUTPUT ${MANUAL_XML}
                       COMMAND ${ASCIIDOC} "-a" "revnumber=${CCACHE_VERSION}" "-d" "manpage" "-b" "docbook" "-o" ${MANUAL_XML} ${MANUAL_TXT} 
					   DEPENDS ${MANUAL_TXT}
					   COMMENT "Generating ${MANUAL_XML}")
    add_custom_command(OUTPUT ${CCACHE_1}
                       COMMAND ${XSLTPROC} "--nonet" "${MAN_STYLE_SHEET_PATH}/${MANPAGE_XSL}" ${MANUAL_XML}
	                   DEPENDS ${MANUAL_XML}
					   COMMENT "Generating ${CCACHE_1}")

    add_custom_target(man DEPENDS ${CCACHE_1})
	install(FILES ${CCACHE_1} DESTINATION man/man1)
endif()

set(DOCUMENT_FILES "")

macro(txt2html txt_file html_file)
    add_custom_command(OUTPUT ${html_file}
	    COMMAND ${ASCIIDOC} "-a" "revnumber=${CCACHE_VERSION}" -a toc -b xhtml11 "-o" ${html_file} "${CMAKE_CURRENT_SOURCE_DIR}/${txt_file}"
        DEPENDS ${txt_file}
		COMMENT "Generating ${html_file}")

	list(APPEND DOCUMENT_FILES ${html_file})
endmacro()

if (ASCIIDOC)
    txt2html(AUTHORS.txt "${CMAKE_CURRENT_BINARY_DIR}/AUTHORS.html")
    txt2html(HACKING.txt "${CMAKE_CURRENT_BINARY_DIR}/HACKING.html")
    txt2html(INSTALL.txt "${CMAKE_CURRENT_BINARY_DIR}/INSTALL.html")
    txt2html(LICENSE.txt "${CMAKE_CURRENT_BINARY_DIR}/LICENSE.html")
    txt2html(MANUAL.txt  "${CMAKE_CURRENT_BINARY_DIR}/MANUAL.html" )
    txt2html(NEWS.txt    "${CMAKE_CURRENT_BINARY_DIR}/NEWS.html"   )
    txt2html(README.txt  "${CMAKE_CURRENT_BINARY_DIR}/README.html" )
endif()

add_custom_target(docs DEPENDS ${DOCUMENT_FILES})

