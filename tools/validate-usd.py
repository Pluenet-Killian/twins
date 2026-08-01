from __future__ import annotations

import argparse
from pathlib import Path

from pxr import Usd


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate the canonical identity bound to an OpenUSD prim."
    )
    parser.add_argument("stage", type=Path)
    parser.add_argument("prim_path")
    parser.add_argument("asset_id")
    parser.add_argument("asset_type_uri")
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    stage = Usd.Stage.Open(str(arguments.stage.resolve()))
    if stage is None:
        raise RuntimeError(f"Unable to open OpenUSD stage: {arguments.stage}")

    prim = stage.GetPrimAtPath(arguments.prim_path)
    if not prim.IsValid():
        raise RuntimeError(f"OpenUSD prim does not exist: {arguments.prim_path}")

    twins_metadata = prim.GetCustomDataByKey("twins")
    if not isinstance(twins_metadata, dict):
        raise RuntimeError("The prim has no versioned twins customData dictionary.")
    if twins_metadata.get("schemaVersion") != 1:
        raise RuntimeError("The prim uses an unsupported twins metadata schema.")
    if twins_metadata.get("assetId") != arguments.asset_id:
        raise RuntimeError("The prim assetId does not match the canonical registry UUID.")
    if twins_metadata.get("assetTypeUri") != arguments.asset_type_uri:
        raise RuntimeError("The prim assetTypeUri does not match the canonical type URI.")

    print(
        f"Validated {arguments.prim_path} -> {arguments.asset_id} "
        f"({arguments.asset_type_uri})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
