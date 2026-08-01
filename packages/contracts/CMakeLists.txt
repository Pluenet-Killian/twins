find_package(Protobuf CONFIG REQUIRED)

set(TWINS_PROTO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/proto")
set(TWINS_GENERATED_ROOT "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(TWINS_ASSET_PROTO "${TWINS_PROTO_ROOT}/twins/asset/v1/asset.proto")
set(TWINS_ASSET_PROTO_SOURCE "${TWINS_GENERATED_ROOT}/twins/asset/v1/asset.pb.cc")
set(TWINS_ASSET_PROTO_HEADER "${TWINS_GENERATED_ROOT}/twins/asset/v1/asset.pb.h")

add_custom_command(
    OUTPUT
        "${TWINS_ASSET_PROTO_SOURCE}"
        "${TWINS_ASSET_PROTO_HEADER}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${TWINS_GENERATED_ROOT}/twins/asset/v1"
    COMMAND protobuf::protoc
        --cpp_out=${TWINS_GENERATED_ROOT}
        --proto_path=${TWINS_PROTO_ROOT}
        "${TWINS_ASSET_PROTO}"
    DEPENDS
        "${TWINS_ASSET_PROTO}"
        protobuf::protoc
    VERBATIM
)

add_library(twins-contracts STATIC
    "${TWINS_ASSET_PROTO_SOURCE}"
    "${TWINS_ASSET_PROTO_HEADER}"
)

target_include_directories(twins-contracts
    PUBLIC
        "${TWINS_GENERATED_ROOT}"
)

target_link_libraries(twins-contracts
    PUBLIC
        protobuf::libprotobuf
)

target_compile_features(twins-contracts PUBLIC cxx_std_20)
