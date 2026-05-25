cmake_minimum_required(VERSION 3.22.1)
project("guardian_llama" C CXX)

# ── Opciones de compilación ───────────────────────────────────────
set(CMAKE_C_STANDARD   11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE   Release)

# Optimizaciones de velocidad (crítico para inferencia en tiempo real)
add_compile_options(
    -O3
    -fvisibility=hidden
    -DNDEBUG
)

# El CMakeLists.txt está en android/ → subimos un nivel (..) para llegar a la raíz del proyecto
# Luego bajamos a native/ donde vive el código nativo
set(NATIVE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../native")
set(LLAMA_SRC   "${NATIVE_ROOT}/third_party/llama.cpp")

# ── Opciones de llama.cpp ─────────────────────────────────────────
set(LLAMA_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER   OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_COMMON   OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS    OFF CACHE BOOL "" FORCE)
set(GGML_USE_OPENMP      OFF CACHE BOOL "" FORCE)

# Verificar que llama.cpp fue descargado por setup_llama.sh
if(NOT EXISTS "${LLAMA_SRC}/CMakeLists.txt")
    message(FATAL_ERROR
        "llama.cpp no encontrado en ${LLAMA_SRC}.\n"
        "Ejecuta ./setup_llama.sh antes de compilar.")
endif()

# Incluir llama.cpp como subdirectorio
add_subdirectory(${LLAMA_SRC} llama_build)

# ── Librería compartida (.so) que Flutter cargará ─────────────────
add_library(
    guardian_llama        # Nombre de la .so → libguardian_llama.so
    SHARED
    ${NATIVE_ROOT}/llama_cpp/llama_bridge.cpp
)

# Includes necesarios para el bridge
target_include_directories(guardian_llama PRIVATE
    ${LLAMA_SRC}/include
    ${LLAMA_SRC}/common
    ${LLAMA_SRC}
)

# Linkear con llama.cpp y la librería de logging de Android
target_link_libraries(guardian_llama
    llama
    log        # Android logging
)
