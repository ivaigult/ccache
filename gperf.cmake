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

find_program(GPERF gperf)

if (GPERF)
    set(GPERF_FOUND YES)
endif()

if (NOT TARGET gperf)
    add_custom_target(gperf)
endif()
  
function(gperf2c input output)
    if (NOT GPERF_FOUND)
        return()
    endif()
	  
	get_filename_component(file_name "${input}" NAME_WE)

	add_custom_command(OUTPUT "${output}"
                       COMMAND ${GPERF} "${CMAKE_CURRENT_SOURCE_DIR}/${input}" "--output-file=${output}"
					   COMMAND ${CMAKE_COMMAND} -P "${PROJECT_SOURCE_DIR}/count_confitems.cmake" "${CMAKE_CURRENT_SOURCE_DIR}/${input}" ${output}
					   DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${input}"
					   COMMENT "Generating ${output}")
    add_custom_target("gperf_${file_name}" DEPENDS ${output})
	add_dependencies(gperf "gperf_${file_name}")
endfunction()