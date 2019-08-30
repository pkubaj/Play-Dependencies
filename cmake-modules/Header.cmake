if(CMAKE_CURRENT_SOURCE_DIR STREQUAL "${CMAKE_SOURCE_DIR}")
	option(TARGET_IOS "Enable building for iOS" OFF)

	if(ANDROID)
		message("-- Generating for Android --")
		set(TARGET_PLATFORM_ANDROID TRUE)
	elseif(APPLE AND TARGET_IOS)
		message("-- Generating for iOS --")
		set(TARGET_PLATFORM_IOS TRUE)
	elseif(APPLE)
		message("-- Generating for macOS --")
		set(TARGET_PLATFORM_MACOS TRUE)
	elseif(WIN32)
		message("-- Generating for Win32 --")
		string(FIND ${CMAKE_GENERATOR} "Win64" HASWIN64)
		if(NOT HASWIN64 EQUAL -1)
			message("-- Arch: x64 --")
			set(TARGET_PLATFORM_WIN32_X64 TRUE)
		else()
			message("-- Arch: x86 --")
			set(TARGET_PLATFORM_WIN32_X86 TRUE)
		endif()
		set(TARGET_PLATFORM_WIN32 TRUE)
	else()
		message("-- Generating for Unix compatible platform --")
		set(TARGET_PLATFORM_UNIX TRUE)
		if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "^(aarch64.*|AARCH64.*)")
			message("-- Arch: aarch64 --")
			set(TARGET_PLATFORM_UNIX_AARCH64 TRUE)
		endif()

	endif()
	
	set(CMAKE_CXX_STANDARD 17)
	set(CMAKE_CXX_STANDARD_REQUIRED ON)
	if(TARGET_PLATFORM_WIN32)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /MP")
	endif()

	if(NOT CMAKE_BUILD_TYPE)
		set(CMAKE_BUILD_TYPE Release CACHE STRING
			"Choose the type of build, options are: None Debug Release"
			FORCE)
	endif()

	MESSAGE("-- Build type: ${CMAKE_BUILD_TYPE}")

	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")

	if(TARGET_PLATFORM_WIN32)
		add_definitions(-D_CRT_SECURE_NO_WARNINGS)
		add_definitions(-D_SCL_SECURE_NO_WARNINGS)
		add_definitions(-D_UNICODE)
		add_definitions(-DUNICODE)
		add_definitions(-D_ENABLE_EXTENDED_ALIGNED_STORAGE)

		if(DEFINED VTUNE_ENABLED)
			add_definitions(-DVTUNE_ENABLED)
			list(APPEND PROJECT_LIBS libittnotify jitprofiling)
			if(DEFINED VTUNE_PATH)
				if(TARGET_PLATFORM_WIN32_X86)
					link_directories($(VTUNE_PATH)\lib32)
				else()
					link_directories($(VTUNE_PATH)\lib64)
				endif()
				include_directories($(VTUNE_PATH)\include)
			else()
				MESSAGE(FATAL_ERROR "VTUNE_PATH was not defined")
			endif()
		endif()
	endif()
endif()
