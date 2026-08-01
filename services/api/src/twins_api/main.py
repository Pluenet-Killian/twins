from typing import Literal

from fastapi import FastAPI
from pydantic import BaseModel


class HealthStatus(BaseModel):
    service: Literal["twins-api"] = "twins-api"
    status: Literal["ready"] = "ready"


app = FastAPI(
    title="Twins API",
    description="Engineering gateway for the data center digital twin.",
    version="0.0.0",
)


@app.get("/health", response_model=HealthStatus, tags=["operations"])
def get_health() -> HealthStatus:
    return HealthStatus()
