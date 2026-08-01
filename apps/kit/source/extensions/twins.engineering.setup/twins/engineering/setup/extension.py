import asyncio
from pathlib import Path

import carb
import carb.settings
import omni.ext
import omni.kit.app
import omni.usd


SETTINGS_ROOT = "/exts/twins.engineering.setup"


class Extension(omni.ext.IExt):
    def on_startup(self, _ext_id: str) -> None:
        self._task = asyncio.ensure_future(self._open_reference_stage())

    async def _open_reference_stage(self) -> None:
        settings = carb.settings.get_settings()
        stage_path = settings.get_as_string(f"{SETTINGS_ROOT}/stage_path")
        if not stage_path:
            carb.log_error("TWINS_REFERENCE_STAGE_FAILED reason=missing_stage_path")
            return

        resolved_stage_path = Path(stage_path).resolve()
        if not resolved_stage_path.is_file():
            carb.log_error(
                f"TWINS_REFERENCE_STAGE_FAILED reason=stage_not_found stage_path={resolved_stage_path}"
            )
            return

        app = omni.kit.app.get_app()
        for _ in range(5):
            await app.next_update_async()

        usd_context = omni.usd.get_context()
        for _ in range(100):
            if usd_context.can_open_stage():
                break
            await app.next_update_async()
        else:
            carb.log_error("TWINS_REFERENCE_STAGE_FAILED reason=open_stage_timeout")
            return

        success, error = await usd_context.open_stage_async(
            str(resolved_stage_path),
            omni.usd.UsdContextInitialLoadSet.LOAD_ALL,
        )
        if not success:
            carb.log_error(
                f"TWINS_REFERENCE_STAGE_FAILED reason=open_stage_error error={error}"
            )
            return

        reference_prim_path = settings.get_as_string(
            f"{SETTINGS_ROOT}/reference_prim_path"
        )
        expected_asset_id = settings.get_as_string(
            f"{SETTINGS_ROOT}/reference_asset_id"
        )
        stage = usd_context.get_stage()
        reference_prim = stage.GetPrimAtPath(reference_prim_path)
        if not reference_prim.IsValid():
            carb.log_error(
                "TWINS_REFERENCE_STAGE_FAILED "
                f"reason=reference_prim_missing prim_path={reference_prim_path}"
            )
            return

        twins_metadata = reference_prim.GetCustomData().get("twins", {})
        actual_asset_id = twins_metadata.get("assetId")
        if actual_asset_id != expected_asset_id:
            carb.log_error(
                "TWINS_REFERENCE_STAGE_FAILED "
                f"reason=asset_id_mismatch expected={expected_asset_id} actual={actual_asset_id}"
            )
            return

        usd_context.get_selection().set_selected_prim_paths(
            [reference_prim_path],
            True,
        )
        carb.log_info(
            "TWINS_REFERENCE_STAGE_READY "
            f"asset_id={actual_asset_id} prim_path={reference_prim_path} "
            f"stage_path={resolved_stage_path}"
        )

    def on_shutdown(self) -> None:
        if self._task and not self._task.done():
            self._task.cancel()
        self._task = None
