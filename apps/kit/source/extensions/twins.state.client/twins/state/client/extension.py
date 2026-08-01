import asyncio
from collections import deque
from queue import Empty, Full, Queue
from threading import Event, Thread
import time

import carb
import carb.settings
import grpc
import omni.ext
import omni.kit.app
import omni.usd
from pxr import Gf, Sdf, Usd, UsdGeom

from twins.state.v1 import state_pb2
from twins.state.v1 import state_pb2_grpc


SETTINGS_ROOT = "/exts/twins.state.client"
NANOSECONDS_PER_SECOND = 1_000_000_000


class AssetStateSubscriber:
    def __init__(
        self,
        endpoint: str,
        run_id: str,
        asset_id: str,
        queue_capacity: int,
    ) -> None:
        self._endpoint = endpoint
        self._run_id = run_id
        self._asset_id = asset_id
        self._states: Queue[state_pb2.WatchAssetStatesResponse] = Queue(
            maxsize=queue_capacity
        )
        self._stop = Event()
        self._thread: Thread | None = None
        self._channel: grpc.Channel | None = None
        self._last_sequence = 0
        self._last_simulation_time_ns = -1

    @property
    def states(self) -> Queue[state_pb2.WatchAssetStatesResponse]:
        return self._states

    def start(self) -> None:
        if self._thread is not None:
            return
        self._thread = Thread(
            target=self._receive,
            name="twins-state-subscriber",
            daemon=True,
        )
        self._thread.start()

    def stop(self) -> None:
        self._stop.set()
        if self._channel is not None:
            self._channel.close()
        if self._thread is not None:
            self._thread.join(timeout=2.0)
        self._thread = None
        self._channel = None

    def _receive(self) -> None:
        retry_delay_seconds = 0.25
        while not self._stop.is_set():
            try:
                self._channel = grpc.insecure_channel(
                    self._endpoint,
                    options=(
                        ("grpc.max_receive_message_length", 1024 * 1024),
                        ("grpc.keepalive_time_ms", 30_000),
                    ),
                )
                stub = state_pb2_grpc.AssetStateServiceStub(self._channel)
                grpc.channel_ready_future(self._channel).result(timeout=10.0)
                request = state_pb2.WatchAssetStatesRequest(
                    run_id=self._run_id,
                    asset_ids=[self._asset_id],
                    after_sequence=self._last_sequence,
                )
                for state in stub.WatchAssetStates(request):
                    if self._stop.is_set():
                        return
                    if state.sequence <= self._last_sequence:
                        continue
                    if state.simulation_time_ns < self._last_simulation_time_ns:
                        carb.log_error(
                            "TWINS_STATE_REJECTED reason=non_monotonic_simulation_time "
                            f"sequence={state.sequence} "
                            f"simulation_time_ns={state.simulation_time_ns}"
                        )
                        continue
                    if not self._put_state(state):
                        return
                    self._last_sequence = state.sequence
                    self._last_simulation_time_ns = state.simulation_time_ns

                carb.log_info(
                    "TWINS_STATE_STREAM_COMPLETE "
                    f"endpoint={self._endpoint} sequence={self._last_sequence}"
                )
                return
            except (grpc.FutureTimeoutError, grpc.RpcError) as error:
                if self._stop.is_set():
                    return
                code = (
                    error.code().name
                    if isinstance(error, grpc.RpcError)
                    else "CONNECTION_TIMEOUT"
                )
                carb.log_warn(
                    "TWINS_STATE_STREAM_RETRY "
                    f"endpoint={self._endpoint} code={code} "
                    f"delay_s={retry_delay_seconds}"
                )
                self._stop.wait(retry_delay_seconds)
                retry_delay_seconds = min(retry_delay_seconds * 2.0, 5.0)
            finally:
                if self._channel is not None:
                    self._channel.close()
                    self._channel = None

    def _put_state(self, state: state_pb2.WatchAssetStatesResponse) -> bool:
        while not self._stop.is_set():
            try:
                self._states.put(state, timeout=0.1)
                return True
            except Full:
                continue
        return False


class StateSessionAuthor:
    _MODE_NAMES = {
        state_pb2.AssetOperationalState.MODE_OFF: "OFF",
        state_pb2.AssetOperationalState.MODE_STARTING: "STARTING",
        state_pb2.AssetOperationalState.MODE_RUNNING: "RUNNING",
        state_pb2.AssetOperationalState.MODE_STOPPING: "STOPPING",
        state_pb2.AssetOperationalState.MODE_FAULTED: "FAULTED",
    }
    _MODE_COLORS = {
        state_pb2.AssetOperationalState.MODE_OFF: Gf.Vec3f(0.16, 0.18, 0.17),
        state_pb2.AssetOperationalState.MODE_STARTING: Gf.Vec3f(1.0, 0.48, 0.06),
        state_pb2.AssetOperationalState.MODE_RUNNING: Gf.Vec3f(0.12, 0.85, 0.32),
        state_pb2.AssetOperationalState.MODE_STOPPING: Gf.Vec3f(0.25, 0.48, 1.0),
        state_pb2.AssetOperationalState.MODE_FAULTED: Gf.Vec3f(1.0, 0.08, 0.05),
    }

    def __init__(self, prim_path: str, asset_id: str, run_id: str) -> None:
        self._prim_path = prim_path
        self._asset_id = asset_id
        self._run_id = run_id

    def apply(self, state: state_pb2.WatchAssetStatesResponse) -> bool:
        if state.asset_id != self._asset_id:
            carb.log_error(
                "TWINS_STATE_REJECTED reason=asset_id_mismatch "
                f"expected={self._asset_id} actual={state.asset_id}"
            )
            return False
        if state.run_id != self._run_id:
            carb.log_error(
                "TWINS_STATE_REJECTED reason=run_id_mismatch "
                f"expected={self._run_id} actual={state.run_id}"
            )
            return False
        if state.WhichOneof("payload") != "operational":
            carb.log_warn(
                "TWINS_STATE_IGNORED reason=unsupported_payload "
                f"sequence={state.sequence}"
            )
            return False

        mode = state.operational.mode
        mode_name = self._MODE_NAMES.get(mode)
        color = self._MODE_COLORS.get(mode)
        if mode_name is None or color is None:
            carb.log_warn(
                "TWINS_STATE_IGNORED reason=unsupported_operational_mode "
                f"mode={mode} sequence={state.sequence}"
            )
            return False

        stage = omni.usd.get_context().get_stage()
        if stage is None:
            return False
        rack_prim = stage.GetPrimAtPath(self._prim_path)
        beacon_prim = stage.GetPrimAtPath(f"{self._prim_path}/IdentityBeacon")
        if not rack_prim.IsValid() or not beacon_prim.IsValid():
            carb.log_error(
                "TWINS_STATE_REJECTED reason=visual_prim_missing "
                f"prim_path={self._prim_path}"
            )
            return False

        with Usd.EditContext(stage, stage.GetSessionLayer()):
            rack_prim.CreateAttribute(
                "twins:state:operational",
                Sdf.ValueTypeNames.Token,
                custom=True,
            ).Set(mode_name)
            rack_prim.CreateAttribute(
                "twins:state:runId",
                Sdf.ValueTypeNames.String,
                custom=True,
            ).Set(state.run_id)
            rack_prim.CreateAttribute(
                "twins:state:sequence",
                Sdf.ValueTypeNames.UInt64,
                custom=True,
            ).Set(state.sequence)
            rack_prim.CreateAttribute(
                "twins:state:simulationTimeNs",
                Sdf.ValueTypeNames.Int64,
                custom=True,
            ).Set(state.simulation_time_ns)
            rack_prim.CreateAttribute(
                "twins:state:origin",
                Sdf.ValueTypeNames.Token,
                custom=True,
            ).Set(state_pb2.StateOrigin.Name(state.origin))
            UsdGeom.Gprim(beacon_prim).GetDisplayColorAttr().Set([color])

        carb.log_info(
            "TWINS_STATE_APPLIED "
            f"asset_id={state.asset_id} mode={mode_name} "
            f"sequence={state.sequence} simulation_time_ns={state.simulation_time_ns}"
        )
        return True


class Extension(omni.ext.IExt):
    def on_startup(self, _ext_id: str) -> None:
        self._subscriber: AssetStateSubscriber | None = None
        self._playback_task = asyncio.ensure_future(self._run())

    async def _run(self) -> None:
        settings = carb.settings.get_settings()
        if not settings.get_as_bool(f"{SETTINGS_ROOT}/enabled"):
            carb.log_info("TWINS_STATE_CLIENT_DISABLED")
            return

        endpoint = settings.get_as_string(f"{SETTINGS_ROOT}/endpoint")
        run_id = settings.get_as_string(f"{SETTINGS_ROOT}/run_id")
        asset_id = settings.get_as_string(f"{SETTINGS_ROOT}/asset_id")
        prim_path = settings.get_as_string(f"{SETTINGS_ROOT}/reference_prim_path")
        playback_rate = settings.get_as_float(f"{SETTINGS_ROOT}/playback_rate")
        queue_capacity = settings.get_as_int(f"{SETTINGS_ROOT}/queue_capacity")
        if not endpoint or not run_id or not asset_id or not prim_path:
            carb.log_error("TWINS_STATE_CLIENT_FAILED reason=missing_setting")
            return
        if playback_rate <= 0.0 or queue_capacity <= 0:
            carb.log_error("TWINS_STATE_CLIENT_FAILED reason=invalid_capacity_or_rate")
            return

        app = omni.kit.app.get_app()
        stage = await self._wait_for_reference_prim(app, prim_path, asset_id)
        if stage is None:
            return

        author = StateSessionAuthor(prim_path, asset_id, run_id)
        self._subscriber = AssetStateSubscriber(
            endpoint,
            run_id,
            asset_id,
            queue_capacity,
        )
        self._subscriber.start()
        carb.log_info(
            "TWINS_STATE_CLIENT_READY "
            f"endpoint={endpoint} run_id={run_id} asset_id={asset_id}"
        )

        pending: deque[state_pb2.WatchAssetStatesResponse] = deque()
        wall_time_anchor: float | None = None
        simulation_time_anchor = 0
        while True:
            self._drain_states(self._subscriber.states, pending)
            if wall_time_anchor is None and pending:
                wall_time_anchor = time.monotonic()
                simulation_time_anchor = pending[0].simulation_time_ns

            if wall_time_anchor is not None:
                elapsed_ns = int(
                    (time.monotonic() - wall_time_anchor)
                    * playback_rate
                    * NANOSECONDS_PER_SECOND
                )
                due_time_ns = simulation_time_anchor + elapsed_ns
                while pending and pending[0].simulation_time_ns <= due_time_ns:
                    author.apply(pending.popleft())

            await app.next_update_async()

    @staticmethod
    async def _wait_for_reference_prim(app, prim_path: str, asset_id: str):
        for _ in range(600):
            stage = omni.usd.get_context().get_stage()
            if stage is not None:
                prim = stage.GetPrimAtPath(prim_path)
                if prim.IsValid():
                    actual_asset_id = prim.GetCustomData().get("twins", {}).get("assetId")
                    if actual_asset_id != asset_id:
                        carb.log_error(
                            "TWINS_STATE_CLIENT_FAILED reason=stage_asset_id_mismatch "
                            f"expected={asset_id} actual={actual_asset_id}"
                        )
                        return None
                    return stage
            await app.next_update_async()

        carb.log_error(
            "TWINS_STATE_CLIENT_FAILED reason=reference_prim_timeout "
            f"prim_path={prim_path}"
        )
        return None

    @staticmethod
    def _drain_states(
        states: Queue[state_pb2.WatchAssetStatesResponse],
        pending: deque[state_pb2.WatchAssetStatesResponse],
    ) -> None:
        while True:
            try:
                state = states.get_nowait()
            except Empty:
                return
            if pending and state.sequence <= pending[-1].sequence:
                carb.log_warn(
                    "TWINS_STATE_IGNORED reason=non_monotonic_sequence "
                    f"sequence={state.sequence}"
                )
                continue
            pending.append(state)

    def on_shutdown(self) -> None:
        if self._subscriber is not None:
            self._subscriber.stop()
        self._subscriber = None
        if self._playback_task and not self._playback_task.done():
            self._playback_task.cancel()
        self._playback_task = None
