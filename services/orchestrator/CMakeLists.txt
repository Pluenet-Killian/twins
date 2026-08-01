add_executable(twins-orchestrator
    src/main.cpp
)

target_compile_features(twins-orchestrator PRIVATE cxx_std_20)

if(MSVC)
    target_compile_options(twins-orchestrator PRIVATE /W4 /permissive- /EHsc)
else()
    target_compile_options(twins-orchestrator PRIVATE -Wall -Wextra -Wpedantic)
endif()
