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

find_program(UNCRUSTIFY uncrustify)

if (NOT TARGET uncrustify)
    add_custom_target(uncrustify)
endif()

function(uncrustify_files files)
    string(MD5 files_hash "${files}")
	set(files_ts "${files_hash}.ts")
	set(files_tg "uncrustify_${files_hash}")
    add_custom_command(OUTPUT ${files_ts}
        COMMAND ${UNCRUSTIFY} -c "${PROJECT_SOURCE_DIR}/uncrustify.cfg" --no-backup --replace ${files}
        COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/${files_ts}"
        DEPENDS ${files}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    add_custom_target(${files_tg} DEPENDS ${files_ts})
    add_dependencies(uncrustify ${files_tg})
endfunction()
	