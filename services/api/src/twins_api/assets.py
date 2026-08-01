import os
from dataclasses import dataclass
from uuid import UUID

import psycopg
from psycopg.rows import class_row


@dataclass(frozen=True, slots=True)
class AssetRecord:
    asset_id: UUID
    canonical_name: str
    asset_type_uri: str


def get_asset(asset_id: UUID) -> AssetRecord | None:
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL must be set before reading canonical assets.")

    with psycopg.connect(database_url) as connection:
        with connection.cursor(row_factory=class_row(AssetRecord)) as cursor:
            return cursor.execute(
                """
                SELECT asset_id, canonical_name, asset_type_uri
                FROM asset
                WHERE asset_id = %s
                """,
                (asset_id,),
            ).fetchone()
