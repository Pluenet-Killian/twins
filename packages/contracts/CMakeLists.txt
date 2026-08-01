find_package(Protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)

set(TWINS_PROTO_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/proto")
set(TWINS_GENERATED_ROOT "${CMAKE_CURRENT_BINARY_DIR}/generated")

function(twins_generate_protobuf TARGET_NAME PROTO_RELATIVE_PATH)
    get_filename_component(PROTO_DIRECTORY "${PROTO_RELATIVE_PATH}" DIRECTORY)
    get_filename_component(PROTO_NAME "${PROTO_RELATIVE_PATH}" NAME_WE)

    set(PROTO_FILE "${TWINS_PROTO_ROOT}/${PROTO_RELATIVE_PATH}")
    set(PROTO_SOURCE "${TWINS_GENERATED_ROOT}/${PROTO_DIRECTORY}/${PROTO_NAME}.pb.cc")
    set(PROTO_HEADER "${TWINS_GENERATED_ROOT}/${PROTO_DIRECTORY}/${PROTO_NAME}.pb.h")

    add_custom_command(
        OUTPUT
            "${PROTO_SOURCE}"
            "${PROTO_HEADER}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${TWINS_GENERATED_ROOT}/${PROTO_DIRECTORY}"
        COMMAND protobuf::protoc
            --cpp_out=${TWINS_GENERATED_ROOT}
            --proto_path=${TWINS_PROTO_ROOT}
            "${PROTO_FILE}"
        DEPENDS
            "${PROTO_FILE}"
            protobuf::protoc
        VERBATIM
    )

    add_library(${TARGET_NAME} STATIC
        "${PROTO_SOURCE}"
        "${PROTO_HEADER}"
    )
    target_include_directories(${TARGET_NAME} PUBLIC "${TWINS_GENERATED_ROOT}")
    target_link_libraries(${TARGET_NAME} PUBLIC protobuf::libprotobuf)
    target_compile_features(${TARGET_NAME} PUBLIC cxx_std_20)
endfunction()

twins_generate_protobuf(twins-asset-contracts "twins/asset/v1/asset.proto")
add_library(twins::asset-contracts ALIAS twins-asset-contracts)

set(TWINS_STATE_PROTO_RELATIVE_PATH "twins/state/v1/state.proto")
set(TWINS_STATE_PROTO "${TWINS_PROTO_ROOT}/${TWINS_STATE_PROTO_RELATIVE_PATH}")
set(TWINS_STATE_GENERATED_DIRECTORY "${TWINS_GENERATED_ROOT}/twins/state/v1")
set(TWINS_STATE_PROTO_SOURCE "${TWINS_STATE_GENERATED_DIRECTORY}/state.pb.cc")
set(TWINS_STATE_PROTO_HEADER "${TWINS_STATE_GENERATED_DIRECTORY}/state.pb.h")
set(TWINS_STATE_GRPC_SOURCE "${TWINS_STATE_GENERATED_DIRECTORY}/state.grpc.pb.cc")
set(TWINS_STATE_GRPC_HEADER "${TWINS_STATE_GENERATED_DIRECTORY}/state.grpc.pb.h")

add_custom_command(
    OUTPUT
        "${TWINS_STATE_PROTO_SOURCE}"
        "${TWINS_STATE_PROTO_HEADER}"
        "${TWINS_STATE_GRPC_SOURCE}"
        "${TWINS_STATE_GRPC_HEADER}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${TWINS_STATE_GENERATED_DIRECTORY}"
    COMMAND protobuf::protoc
        --cpp_out=${TWINS_GENERATED_ROOT}
        --grpc_out=${TWINS_GENERATED_ROOT}
        --plugin=protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
        --proto_path=${TWINS_PROTO_ROOT}
        "${TWINS_STATE_PROTO}"
    DEPENDS
        "${TWINS_STATE_PROTO}"
        protobuf::protoc
        gRPC::grpc_cpp_plugin
    VERBATIM
)

add_library(twins-state-contracts STATIC
    "${TWINS_STATE_PROTO_SOURCE}"
    "${TWINS_STATE_PROTO_HEADER}"
    "${TWINS_STATE_GRPC_SOURCE}"
    "${TWINS_STATE_GRPC_HEADER}"
)
target_include_directories(twins-state-contracts PUBLIC "${TWINS_GENERATED_ROOT}")
target_link_libraries(twins-state-contracts
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc++
)
target_compile_features(twins-state-contracts PUBLIC cxx_std_20)
add_library(twins::state-contracts ALIAS twins-state-contracts)
