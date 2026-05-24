cmake_minimum_required(VERSION 3.22.1)
project("guardian_llama" C CXX)

# ── Opciones de compilación ───────────────────────────────────────
set(CMAKE_C_STANDARD   11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE   Release)

# Optimizaciones de velocidad (crítico para inferencia en tiempo real)
add_compile_options(
    -O3
    -ffast-math
    -fvisibility=hidden
    -DNDEBUG
)

# Ruta al código fuente de llama.cpp (clonado como submódulo)
set(LLAMA_SRC "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/llama.cpp")

# ── Opciones de llama.cpp ─────────────────────────────────────────
set(LLAMA_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER   OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS    OFF CACHE BOOL "" FORCE)

# Incluir llama.cpp como subdirectorio
add_subdirectory(${LLAMA_SRC} llama_build)

# ── Librería compartida (.so) que Flutter cargará ─────────────────
add_library(
    guardian_llama        # Nombre de la .so → libguardian_llama.so
    SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/llama_bridge.c
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
    common
    log        # Android logging
)
