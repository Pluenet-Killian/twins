#include "assets.hpp"

#include <stdexcept>
#include <string>

#include <pqxx/pqxx>

namespace twins::orchestrator {

asset::v1::AssetIdentity load_canonical_asset(
    const std::string_view database_url,
    const std::string_view asset_id)
{
    pqxx::connection connection{std::string{database_url}};
    pqxx::read_transaction transaction{connection};
    const pqxx::result result = transaction.exec(
        R"(
        SELECT asset_id::text, canonical_name, asset_type_uri
        FROM asset
        WHERE asset_id = $1::uuid
        )",
        pqxx::params{std::string{asset_id}});

    if (result.empty()) {
        throw std::runtime_error{"Canonical asset not found."};
    }
    if (result.size() != 1) {
        throw std::runtime_error{"Canonical asset lookup returned multiple rows."};
    }

    const auto row = result.front();
    asset::v1::AssetIdentity identity;
    identity.set_asset_id(row["asset_id"].as<std::string>());
    identity.set_canonical_name(row["canonical_name"].as<std::string>());
    identity.set_asset_type_uri(row["asset_type_uri"].as<std::string>());
    transaction.commit();
    return identity;
}

}  // namespace twins::orchestrator
