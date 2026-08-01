add_executable(twins-orchestrator
    src/assets.cpp
    src/assets.hpp
    src/main.cpp
)

find_package(libpqxx CONFIG REQUIRED)

target_compile_features(twins-orchestrator PRIVATE cxx_std_20)

target_link_libraries(twins-orchestrator
    PRIVATE
        libpqxx::pqxx
        twins-contracts
)

if(MSVC)
    target_compile_options(twins-orchestrator PRIVATE /W4 /permissive- /EHsc)
else()
    target_compile_options(twins-orchestrator PRIVATE -Wall -Wextra -Wpedantic)
endif()
