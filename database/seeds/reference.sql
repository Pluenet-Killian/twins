INSERT INTO asset (
    asset_id,
    canonical_name,
    asset_type_uri
)
VALUES (
    '00000000-0000-4000-8000-000000000001',
    'Reference Rack A01',
    'urn:twins:asset-type:compute-rack'
)
ON CONFLICT (asset_id) DO UPDATE
SET
    canonical_name = EXCLUDED.canonical_name,
    asset_type_uri = EXCLUDED.asset_type_uri;
