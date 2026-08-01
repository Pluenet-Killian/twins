#pragma once

#include <string_view>

#include "twins/asset/v1/asset.pb.h"

namespace twins::orchestrator {

[[nodiscard]] asset::v1::AssetIdentity load_canonical_asset(
    std::string_view database_url,
    std::string_view asset_id);

}  // namespace twins::orchestrator
