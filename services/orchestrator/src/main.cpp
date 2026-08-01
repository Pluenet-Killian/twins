#include <chrono>
#include <cstdlib>
#include <iostream>
#include <optional>
#include <stdexcept>
#include <string>

#include <google/protobuf/util/json_util.h>

#include "assets.hpp"
#include "state_fixture.hpp"

namespace {

[[nodiscard]] std::optional<std::string> read_environment_variable(
    const char* const name)
{
#ifdef _WIN32
    char* value = nullptr;
    std::size_t valueLength = 0;
    if (_dupenv_s(&value, &valueLength, name) != 0 || value == nullptr) {
        return std::nullopt;
    }

    std::string result{value};
    std::free(value);
    return result;
#else
    const char* const value = std::getenv(name);
    if (value == nullptr) {
        return std::nullopt;
    }
    return std::string{value};
#endif
}

}  // namespace

int main(const int argument_count, const char* const arguments[])
{
    using SimulationDuration = std::chrono::duration<double>;

    constexpr SimulationDuration initialSimulationTime{0.0};

    if (argument_count == 1) {
        std::cout << "twins-orchestrator ready at simulation time "
                  << initialSimulationTime.count() << " s\n";
        return 0;
    }

    if (std::string{arguments[1]} == "--serve-state-fixture") {
        if (argument_count > 3) {
            std::cerr << "Usage: twins-orchestrator --serve-state-fixture [ADDRESS]\n";
            return 2;
        }

        const std::string_view address = argument_count == 3
            ? std::string_view{arguments[2]}
            : std::string_view{"127.0.0.1:50051"};
        try {
            twins::orchestrator::run_state_fixture_server(address);
        }
        catch (const std::exception& error) {
            std::cerr << "Unable to run state fixture: " << error.what() << '\n';
            return 1;
        }
        return 0;
    }

    if (argument_count != 3 || std::string{arguments[1]} != "--asset-id") {
        std::cerr
            << "Usage: twins-orchestrator [--asset-id UUID | --serve-state-fixture [ADDRESS]]\n";
        return 2;
    }

    const auto databaseUrl = read_environment_variable("DATABASE_URL");
    if (!databaseUrl.has_value()) {
        std::cerr << "DATABASE_URL must be set before reading a canonical asset.\n";
        return 2;
    }

    try {
        const auto asset = twins::orchestrator::load_canonical_asset(
            *databaseUrl,
            arguments[2]);
        std::string json;
        const auto status = google::protobuf::util::MessageToJsonString(asset, &json);
        if (!status.ok()) {
            throw std::runtime_error{status.ToString()};
        }
        std::cout << json << '\n';
    }
    catch (const std::exception& error) {
        std::cerr << "Unable to read canonical asset: " << error.what() << '\n';
        return 1;
    }

    return 0;
}
