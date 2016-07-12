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

set(input_file ${CMAKE_ARGV3})
set(output_file ${CMAKE_ARGV4})

get_filename_component(input_file_name "${input_file}" NAME_WE)
string(TOUPPER "${input_file_name}" var_prefix)

file(READ ${input_file} file_content)

#patching result to supress -Wstatic-in-inline
file(READ "${output_file}" output_file_content)
string(REGEX REPLACE "^(.*#ifdef __GNUC__.*)(#ifdef __GNUC__.*)$" "\\1\nstatic\n\\2" new_content "${output_file_content}")
file(WRITE "${output_file}" "${new_content}")

string(REPLACE "\n" ";" file_list "${file_content}")

set(total_items 0)
foreach(line IN LISTS file_list)
    if(line MATCHES "struct")
#        continue()
    elseif(line MATCHES "^[a-zA-Z]+")
        math(EXPR total_items "${total_items}+1")
    endif()
endforeach()

file(APPEND ${output_file} "static const size_t ${var_prefix}_TOTAL_KEYWORDS = ${total_items};\n")


