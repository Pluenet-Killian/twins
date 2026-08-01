from typing import Literal
from uuid import UUID

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from twins_api.assets import get_asset


class HealthStatus(BaseModel):
    service: Literal["twins-api"] = "twins-api"
    status: Literal["ready"] = "ready"


class AssetResponse(BaseModel):
    asset_id: UUID
    canonical_name: str
    asset_type_uri: str


app = FastAPI(
    title="Twins API",
    description="Engineering gateway for the data center digital twin.",
    version="0.0.0",
)


@app.get("/health", response_model=HealthStatus, tags=["operations"])
def get_health() -> HealthStatus:
    return HealthStatus()


@app.get(
    "/api/v1/assets/{asset_id}",
    response_model=AssetResponse,
    tags=["assets"],
)
def read_asset(asset_id: UUID) -> AssetResponse:
    asset = get_asset(asset_id)
    if asset is None:
        raise HTTPException(status_code=404, detail="Canonical asset not found.")

    return AssetResponse.model_validate(asset, from_attributes=True)
