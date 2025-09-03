execute_process(
  COMMAND which python3
  OUTPUT_VARIABLE PYTHON3_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(Python3_EXECUTABLE "${PYTHON3_PATH}")
set(Python3_INCLUDE_DIR "${QNX_TARGET}/usr/include/python3.11" "${QNX_TARGET}/usr/include/${CPUVARDIR}/python3.11")
set(Python3_LIBRARY "${QNX_TARGET}/${CPUVARDIR}/usr/lib/libpython3.11.so")
set(Python3_VERSION "3.11.13")
set(Python3_FOUND TRUE)

if (NOT TARGET Python3::Interpreter)
  add_executable(Python3::Interpreter IMPORTED GLOBAL)
  set_target_properties(Python3::Interpreter PROPERTIES
    IMPORTED_LOCATION "${Python3_EXECUTABLE}"
  )
endif()

# Define imported target
if (NOT TARGET Python3::Python)
  add_library(Python3::Python UNKNOWN IMPORTED)
  set_target_properties(Python3::Python PROPERTIES
    IMPORTED_LOCATION "${Python3_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${Python3_INCLUDE_DIR}"
  )
endif()

# Export variables for compatibility
set(Python3_INCLUDE_DIRS ${Python3_INCLUDE_DIR})
set(Python3_LIBRARIES ${Python3_LIBRARY})

# Set NumPy paths for QNX
set(NumPy_INCLUDE_DIR "${ROS2_HOST_INSTALLATION_PATH}/usr/lib/python3.11/site-packages/numpy/core/include")
set(NumPy_FOUND TRUE)

# Create NumPy::NumPy target
if (NOT TARGET NumPy::NumPy)
  add_library(NumPy::NumPy INTERFACE IMPORTED)
  set_target_properties(NumPy::NumPy PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${NumPy_INCLUDE_DIR}"
  )
endif()

# Create Python3::NumPy target (alias to NumPy::NumPy)
if (NOT TARGET Python3::NumPy)
  add_library(Python3::NumPy INTERFACE IMPORTED)
  set_target_properties(Python3::NumPy PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${NumPy_INCLUDE_DIR}"
  )
endif()

mark_as_advanced(NumPy_INCLUDE_DIR)
