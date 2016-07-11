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

find_program(ASCIIDOC asciidoc)
find_program(XSLTPROC xsltproc)

if (ASCIIDOC)
    set(ASCIIDOC_FOUND 1)
endif()

if (XSLTPROC)
    set(XSLTPROC_FOUND 1)
endif()


if(NOT TARGET man)
    add_custom_target(man)
endif()

if(NOT TARGET docs)
    add_custom_target(docs)
endif()

set(MANPAGE_XSL "manpage.xsl")
find_path(MAN_STYLE_SHEET_PATH ${MANPAGE_XSL}
    "/usr/local/etc/asciidoc/docbook-xsl/"
    "/etc/asciidoc/docbook-xsl/")

macro(txt2man txt_file man_file version)
    if (NOT ASCIIDOC_FOUND OR NOT XSLTPROC_FOUND OR NOT MANPAGE_XSL)
        return()
    endif()

	get_filename_component(file_name "${txt_file}" NAME_WE)
	set(xml_file "${CMAKE_CURRENT_BINARY_DIR}/${file_name}.xml")
	add_custom_command(OUTPUT ${xml_file}
                       COMMAND ${ASCIIDOC} -a "revnumber=${version}" -d manpage -b docbook -o "${xml_file}" "${CMAKE_CURRENT_SOURCE_DIR}/${txt_file}"
					   DEPENDS ${txt_file}
					   COMMENT "Generating ${xml_file}")

    add_custom_command(OUTPUT ${man_file}
                       COMMAND ${XSLTPROC} "--nonet" "${MAN_STYLE_SHEET_PATH}/${MANPAGE_XSL}" ${xml_file}
	                   DEPENDS ${xml_file}
					   COMMENT "Generating ${man_file}")

    set(target_name "man_${file_name}")
    add_custom_target(${target_name} DEPENDS ${man_file})
    add_dependencies(man ${target_name})

	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${man_file} DESTINATION ${CMAKE_INSTALL_PREFIX}/man/man1)
endmacro()

macro(txt2html txt_file html_file version)
    if (NOT ASCIIDOC)
        return()
	endif()
    add_custom_command(OUTPUT ${html_file}
	    COMMAND ${ASCIIDOC} "-a" "revnumber=${version}" -a toc -b xhtml11 "-o" ${html_file} "${CMAKE_CURRENT_SOURCE_DIR}/${txt_file}"
        DEPENDS ${txt_file}
		COMMENT "Generating ${html_file}")

    get_filename_component(file_name "${txt_file}" NAME_WE)
	set(target_name "docs_${file_name}")
    add_custom_target(${target_name} DEPENDS ${html_file})
    add_dependencies(docs ${target_name})
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${html_file} DESTINATION ${CMAKE_INSTALL_PREFIX}/docs/html)
endmacro()
