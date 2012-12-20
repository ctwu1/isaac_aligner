################################################################################
##
## Isaac Genome Alignment Software
## Copyright (c) 2010-2012 Illumina, Inc.
##
## This software is provided under the terms and conditions of the
## Illumina Open Source Software License 1.
##
## You should have received a copy of the Illumina Open Source
## Software License 1 along with this program. If not, see
## <https://github.com/downloads/sequencing/licenses/>.
##
## The distribution includes the code libraries listed below in the
## 'redist' sub-directory. These are distributed according to the
## licensing terms governing each library.
##
################################################################################
##
## file cxxConfigure.cmake
##
## CMake configuration file for c++ executables
##
## author Come Raczy
##
################################################################################
include ("${iSAAC_MACROS_CMAKE}")


INCLUDE(TestBigEndian)
TEST_BIG_ENDIAN(iSAAC_IS_BIG_ENDIAN)

INCLUDE(CheckFunctionExists)

isaac_find_header_or_die(HAVE_INTTYPES_H inttypes.h)
isaac_find_header_or_die(HAVE_MALLOC_H malloc.h)
isaac_find_header_or_die(HAVE_MCHECK_H mcheck.h)
isaac_find_header_or_die(HAVE_MEMORY_H memory.h)
isaac_find_header_or_die(HAVE_SIGNAL_H signal.h)
isaac_find_header_or_die(HAVE_STDINT_H stdint.h)
isaac_find_header_or_die(HAVE_STDLIB_H stdlib.h)
isaac_find_header_or_die(HAVE_STRING_H string.h)
isaac_find_header_or_die(HAVE_STRINGS_H strings.h)
isaac_find_header_or_die(HAVE_TIME_H time.h)
isaac_find_header_or_die(HAVE_UNISTD_H unistd.h)

# Math functions that might be missing in some flavors of c++
set (CMAKE_REQUIRED_LIBRARIES m)
check_function_exists(floorf HAVE_FLOORF)
check_function_exists(round  HAVE_ROUND)
check_function_exists(roundf HAVE_ROUNDF)
check_function_exists(powf HAVE_POWF)
check_function_exists(erf HAVE_ERF)
check_function_exists(erf HAVE_ERFF)
check_function_exists(erfc HAVE_ERFC)
check_function_exists(erfc HAVE_ERFCF)

# Systems calls
check_function_exists(sysconf HAVE_SYSCONF)
check_function_exists(clock HAVE_CLOCK)

# Support for static linking
# Note that this implies that all libraries must be found with the
# exact file name (libXXX.a or libXXX.so)
if    (iSAAC_FORCE_STATIC_LINK)
    message(STATUS "All libraries will be statically linked")
    set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "-static")
    set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "-static")
    # ensure that even if cmake decides to allow for dynamic libs resolution,
    # this gets overriden into static...
    set(CMAKE_EXE_LINK_DYNAMIC_CXX_FLAGS ${CMAKE_EXE_LINK_STATIC_CXX_FLAGS})
    set(iSAAC_LIBRARY_PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX})
    set(iSAAC_LIBRARY_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
else  (iSAAC_FORCE_STATIC_LINK)
    set(iSAAC_LIBRARY_PREFIX "")
    set(iSAAC_LIBRARY_SUFFIX "")
endif (iSAAC_FORCE_STATIC_LINK)

# optional support for gzip compression
isaac_find_library(NUMA numa.h numa)
if    (HAVE_NUMA)
    message(STATUS "NUMA supported")
    include_directories(BEFORE SYSTEM ${NUMA_INCLUDE_DIR})
    set(iSAAC_ADDITIONAL_LIB ${iSAAC_ADDITIONAL_LIB} "${NUMA_LIBRARY}")
else  (HAVE_NUMA)
    message(STATUS "No support for NUMA")
endif (HAVE_NUMA)

# optional support for gzip compression
isaac_find_library(ZLIB zlib.h z)
if    (HAVE_ZLIB)
    set  (iSAAC_ADDITIONAL_LIB ${iSAAC_ADDITIONAL_LIB} z)
    message(STATUS "gzip compression supported")
else  (HAVE_ZLIB)
    message(FATAL_ERROR "No support for gzip compression")
endif (HAVE_ZLIB)

# optional support for bzip2 compression
#isaac_find_library(BZIP2 bzlib.h bz2)
#if    (HAVE_BZIP2)
#    set(HAVE_BZLIB HAVE_BZIP2)
#    set(iSAAC_ADDITIONAL_LIB ${iSAAC_ADDITIONAL_LIB} bz2)
#    message(STATUS "bzip2 compression supported")
#else  (HAVE_BZIP2)
#    message(FATAL_ERROR "No support for bzip2 compression")
#endif (HAVE_BZIP2)

isaac_find_boost(${iSAAC_BOOST_VERSION} "${iSAAC_BOOST_COMPONENTS}")

isaac_find_library(CPGPLOT cpgplot.h cpgplot)
isaac_find_library(PGPLOT cpgplot.h pgplot)

isaac_find_library(LIBEXSLT libexslt/exslt.h exslt)
if    (NOT HAVE_LIBEXSLT)
    message (FATAL_ERROR "libexslt was not found")
else (NOT HAVE_LIBEXSLT)
    set(LIBXSLT_LIBRARIES ${LIBXSLT_LIBRARIES} "${LIBEXSLT_LIBRARY}")
endif (NOT HAVE_LIBEXSLT)

isaac_find_library(LIBGCRYPT gcrypt.h gcrypt)
if    (NOT HAVE_LIBGCRYPT)
    message (FATAL_ERROR "libgcrypt was not found")
endif (NOT HAVE_LIBGCRYPT)
include_directories(BEFORE SYSTEM ${LIBGCRYPT_INCLUDE_DIR})
set(LIBXSLT_LIBRARIES ${LIBXSLT_LIBRARIES} "${LIBGCRYPT_LIBRARY}")

isaac_find_library(LIBGGPGERROR gpg-error.h gpg-error)
if    (NOT HAVE_LIBGGPGERROR)
    message (FATAL_ERROR "libgpg-error was not found")
endif (NOT HAVE_LIBGGPGERROR)
include_directories(BEFORE SYSTEM ${LIBGGPGERROR_INCLUDE_DIR})
set(LIBXSLT_LIBRARIES ${LIBXSLT_LIBRARIES} "${LIBGGPGERROR_LIBRARY}")

isaac_find_library(LIBXSL libxslt/xslt.h xslt)
if    (NOT HAVE_LIBXSL)
    message (FATAL_ERROR "libxslt was not found")
endif (NOT HAVE_LIBXSL)
include_directories(BEFORE SYSTEM ${LIBXSLT_INCLUDE_DIR})
set(LIBXSLT_LIBRARIES ${LIBXSLT_LIBRARIES} "${LIBXSL_LIBRARY}")

# this ensures the proper include path is added
include (FindLibXml2)
if    (NOT LIBXML2_FOUND)
    message (FATAL_ERROR "libxml2 was not found")
endif (NOT LIBXML2_FOUND)
include_directories(BEFORE SYSTEM ${LIBXML2_INCLUDE_DIR})

#this bit is to support --static builds
isaac_find_library(LIBXML2 libxml2/libxml/xpath.h xml2)
if    (NOT HAVE_LIBXML2)
    message (FATAL_ERROR "libxml2 was not found")
endif (NOT HAVE_LIBXML2)
include_directories(BEFORE SYSTEM ${LIBXML2_INCLUDE_DIR})
#set(iSAAC_ADDITIONAL_LIB ${iSAAC_ADDITIONAL_LIB} xml2)
set(LIBXSLT_LIBRARIES ${LIBXSLT_LIBRARIES} "${LIBXML2_LIBRARY}")

isaac_find_library(LIBDL dlfcn.h dl)
if    (NOT HAVE_LIBDL)
    message (FATAL_ERROR "libdl was not found")
endif (NOT HAVE_LIBDL)
include_directories(BEFORE SYSTEM ${LIBDL_INCLUDE_DIR})
set(LIBXSLT_LIBRARIES ${LIBXSLT_LIBRARIES} "${LIBDL_LIBRARY}")



#    message (FATAL_ERROR "${iSAAC_ADDITIONAL_LIB} tada")

isaac_find_library(CPPUNIT "cppunit/Test.h" cppunit${CPPUNIT_DEBUG})

set (CMAKE_CXX_FLAGS "$ENV{CXX_FLAGS} $ENV{CXXFLAGS} -fopenmp -msse2 -Wall -Wextra -Wunused -Wno-long-long -Wsign-compare -Wpointer-arith " CACHE STRING "g++ flags" FORCE)
#set (CMAKE_CXX_FLAGS_DEBUG "-O0 -g -pg -fprofile-arcs -ftest-coverage -D_GLIBCXX_DEBUG" CACHE STRING "g++ flags" FORCE)
set (CMAKE_CXX_FLAGS_DEBUG "-O0 -g -pg -fprofile-arcs -ftest-coverage" CACHE STRING "g++ flags" FORCE)
set (CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG" CACHE STRING "g++ flags" FORCE)
set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -g" CACHE STRING "g++ flags" FORCE)
set (CMAKE_CXX_FLAGS_MINSIZEREL "-Os -DNDEBUG" CACHE STRING "g++ flags" FORCE)

# Force static linking
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE version)
    string(STRIP ${version} version)
    
    string(REGEX REPLACE "^([0-9])\\.[0-9]\\.[0-9]" "\\1" major_version ${version})
    string(REGEX REPLACE "^[0-9]\\.([0-9])\\.[0-9]" "\\1" minor_version ${version})
    string(REGEX REPLACE "^[0-9]\\.[0-9]\\.([0-9])" "\\1" patch_version ${version})
    if    (major_version LESS 4 OR (major_version EQUAL 4 AND (minor_version LESS 6 OR (minor_version EQUAL 6 AND patch_version LESS 1) ) ) )
        message (FATAL_ERROR "Unsupported GNU C++ compiler: g++ version ${version}: "
                             "only g++ versions >= 4.6.1 are supported")
    endif (major_version LESS 4 OR (major_version EQUAL 4 AND (minor_version LESS 6 OR (minor_version EQUAL 6 AND patch_version LESS 1) ) ) )

    set("${CMAKE_CXX_COMPILER_ID}${major_version}" true)
    set("${CMAKE_CXX_COMPILER_ID}${major_version}${minor_version}" true)
    set("${CMAKE_CXX_COMPILER_ID}${major_version}${minor_version}${patch_version}" true)
    message (STATUS "using compiler: gcc version ${version}")

endif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

##
## Suppress spurious warnings in less recent compilers
##
if    (NOT GNU42)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-parameter ")
endif (NOT GNU42)

if    (GNU412 OR GNU42 OR GNU43)
    ## Before 4.1.2, pedantic breaks on boost lambda expressions
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic ")
endif (GNU412 OR GNU42 OR GNU43)

if (CMAKE_SYSTEM_PROCESSOR MATCHES "^i[67]86$")
    ##
    ## Use scalar floating point instructions from the SSE instruction set.
    ## Note: Pentium3 SSE supports only single precision arithmetics
    ##
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse -mfpmath=sse")
endif (CMAKE_SYSTEM_PROCESSOR MATCHES "^i[67]86$")
if (CMAKE_SYSTEM_PROCESSOR MATCHES "^i[345]86$")
    ##
    ## Prevent using 80bits registers (more consistent rounding)
    ##
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffloat-store")
endif (CMAKE_SYSTEM_PROCESSOR MATCHES "^i[345]86$")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/lib/common/config.h.in ${iSAAC_CXX_CONFIG_H_DIR}/config.h)
