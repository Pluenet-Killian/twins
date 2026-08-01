#include "state_fixture.hpp"

#include <cstdint>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <unordered_set>
#include <utility>
#include <vector>

#include <grpcpp/grpcpp.h>

#include "twins/state/v1/state.grpc.pb.h"

namespace twins::orchestrator {
namespace {

using StateResponse = state::v1::WatchAssetStatesResponse;
using StateRequest = state::v1::WatchAssetStatesRequest;

[[nodiscard]] StateResponse make_operational_state(
    const std::uint64_t sequence,
    const std::int64_t simulation_time_ns,
    const state::v1::AssetOperationalState::Mode mode)
{
    StateResponse response;
    response.set_run_id(kReferenceRunId);
    response.set_sequence(sequence);
    response.set_simulation_time_ns(simulation_time_ns);
    response.set_asset_id(kReferenceRackAssetId);
    response.set_origin(state::v1::STATE_ORIGIN_SYNTHETIC_FIXTURE);
    response.mutable_operational()->set_mode(mode);
    return response;
}

[[nodiscard]] const std::vector<StateResponse>& reference_timeline()
{
    static const std::vector<StateResponse> timeline{
        make_operational_state(1, 0, state::v1::AssetOperationalState::MODE_OFF),
        make_operational_state(
            2,
            2'000'000'000,
            state::v1::AssetOperationalState::MODE_STARTING),
        make_operational_state(
            3,
            5'000'000'000,
            state::v1::AssetOperationalState::MODE_RUNNING),
    };
    return timeline;
}

[[nodiscard]] bool includes_asset(
    const std::unordered_set<std::string>& requested_assets,
    const std::string& asset_id)
{
    return requested_assets.empty() || requested_assets.contains(asset_id);
}

class StateStreamReactor final : public grpc::ServerWriteReactor<StateResponse> {
public:
    explicit StateStreamReactor(const StateRequest& request)
    {
        if (request.run_id().empty()) {
            Finish(grpc::Status{
                grpc::StatusCode::INVALID_ARGUMENT,
                "run_id must be a canonical UUID"});
            return;
        }
        if (request.run_id() != kReferenceRunId) {
            Finish(grpc::Status{
                grpc::StatusCode::NOT_FOUND,
                "the requested immutable run is not available"});
            return;
        }

        const std::unordered_set<std::string> requested_assets{
            request.asset_ids().begin(),
            request.asset_ids().end()};
        for (const auto& state : reference_timeline()) {
            if (state.sequence() > request.after_sequence()
                && includes_asset(requested_assets, state.asset_id())) {
                states_.push_back(state);
            }
        }

        write_next();
    }

    void OnWriteDone(const bool ok) override
    {
        if (!ok) {
            Finish(grpc::Status{grpc::StatusCode::CANCELLED, "client disconnected"});
            return;
        }

        ++next_state_;
        write_next();
    }

    void OnDone() override
    {
        delete this;
    }

private:
    void write_next()
    {
        if (next_state_ == states_.size()) {
            Finish(grpc::Status::OK);
            return;
        }

        StartWrite(&states_[next_state_]);
    }

    std::vector<StateResponse> states_;
    std::size_t next_state_{0};
};

class StateService final : public state::v1::AssetStateService::CallbackService {
    grpc::ServerWriteReactor<StateResponse>* WatchAssetStates(
        grpc::CallbackServerContext* /*context*/,
        const StateRequest* request) override
    {
        return new StateStreamReactor{*request};
    }
};

}  // namespace

void run_state_fixture_server(const std::string_view listen_address)
{
    StateService service;
    grpc::ServerBuilder builder;
    builder.SetMaxReceiveMessageSize(1024 * 1024);
    builder.AddListeningPort(
        std::string{listen_address},
        grpc::InsecureServerCredentials());
    builder.RegisterService(&service);

    std::unique_ptr<grpc::Server> server = builder.BuildAndStart();
    if (!server) {
        throw std::runtime_error{
            "unable to bind the asset state service to " + std::string{listen_address}};
    }

    std::cout << "TWINS_STATE_SERVER_READY address=" << listen_address
              << " run_id=" << kReferenceRunId
              << " asset_id=" << kReferenceRackAssetId << std::endl;
    server->Wait();
}

}  // namespace twins::orchestrator
