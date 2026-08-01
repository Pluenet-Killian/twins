#pragma once

#include <string_view>

namespace twins::orchestrator {

inline constexpr std::string_view kReferenceRunId =
    "00000000-0000-4000-8000-000000000101";
inline constexpr std::string_view kReferenceRackAssetId =
    "00000000-0000-4000-8000-000000000001";

void run_state_fixture_server(std::string_view listen_address);

}  // namespace twins::orchestrator
