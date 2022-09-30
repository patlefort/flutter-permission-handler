cmake_minimum_required(VERSION 3.20 FATAL_ERROR)
cmake_policy(VERSION 3.20)

project(netns-helper NONE)

option(NETNS_HELPER_MAN "Install manual." ON)
option(NETNS_HELPER_BASH_COMPLETIONS "Install bash completion script." ON)

set(PREFIX "${CMAKE_INSTALL_PREFIX}")

install(PROGRAMS "scripts/netns-helper" TYPE BIN)
install(PROGRAMS "scripts/netns-helperctl" DESTINATION "lib/netns-helper")
install(PROGRAMS "scripts/netns-dhclient-script-wrapper" DESTINATION "lib/netns-helper")

if(NETNS_HELPER_BASH_COMPLETIONS)
	install(FILES "scripts/bash-completion" DESTINATION "share/bash-completion/completions" RENAME "netns-helper")
endif()

file(GLOB unit_files LIST_DIRECTORIES false RELATIVE "${CMAKE_SOURCE_DIR}" "systemd/system/*")
foreach(unit IN LISTS unit_files)
	if(unit MATCHES ".*\.in")
		cmake_path(SET target_unit_file "${unit}")
		cmake_path(REMOVE_EXTENSION target_unit_file LAST_ONLY)
		cmake_path(GET target_unit_file FILENAME target_unit_file)
		
		configure_file("${unit}" "units/${target_unit_file}" @ONLY)
		install(FILES "${CMAKE_BINARY_DIR}/units/${target_unit_file}" DESTINATION "lib/systemd/system")
	else()
		install(FILES "${unit}" DESTINATION "lib/systemd/system")
	endif()
endforeach()

if(NETNS_HELPER_MAN)
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/man")
	
	set(man_names netns-helper.1 netns-helper-config.1 netns-helper-services.1)
	set(man_files)
	foreach(man_name IN LISTS man_names)
		list(APPEND man_files "${CMAKE_BINARY_DIR}/man/${man_name}")
		install(FILES "${CMAKE_BINARY_DIR}/man/${man_name}" DESTINATION "share/man/man1")
	endforeach()
	add_custom_target(${PROJECT_NAME}-man ALL DEPENDS ${man_files})
	
	find_program(XSLTPROC xsltproc REQUIRED)
	
	add_custom_command(
		OUTPUT ${man_files}
		COMMAND ${XSLTPROC}
			"http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl"
			"${CMAKE_SOURCE_DIR}/man/manual.xml"
			COMMENT "Building manual pages."
			WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/man"
			DEPENDS "${CMAKE_SOURCE_DIR}/man/manual.xml"
			VERBATIM)
endif()
