-- migrate:up

CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE TABLE asset (
    asset_id uuid PRIMARY KEY,
    canonical_name text NOT NULL,
    asset_type_uri text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT asset_canonical_name_not_blank CHECK (btrim(canonical_name) <> ''),
    CONSTRAINT asset_type_uri_not_blank CHECK (btrim(asset_type_uri) <> '')
);

CREATE TABLE simulation_run (
    run_id uuid PRIMARY KEY,
    scenario_ref text NOT NULL,
    random_seed bigint NOT NULL,
    status text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT simulation_run_scenario_ref_not_blank CHECK (btrim(scenario_ref) <> ''),
    CONSTRAINT simulation_run_status_valid CHECK (
        status IN ('created', 'running', 'completed', 'failed', 'cancelled')
    )
);

CREATE TABLE simulation_sample (
    run_id uuid NOT NULL REFERENCES simulation_run (run_id),
    asset_id uuid NOT NULL REFERENCES asset (asset_id),
    simulation_time_ns bigint NOT NULL,
    quantity_kind text NOT NULL,
    value_si double precision NOT NULL,
    unit_symbol text NOT NULL,
    model_ref text NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (run_id, asset_id, quantity_kind, simulation_time_ns),
    CONSTRAINT simulation_sample_time_non_negative CHECK (simulation_time_ns >= 0),
    CONSTRAINT simulation_sample_quantity_not_blank CHECK (btrim(quantity_kind) <> ''),
    CONSTRAINT simulation_sample_unit_not_blank CHECK (btrim(unit_symbol) <> ''),
    CONSTRAINT simulation_sample_model_ref_not_blank CHECK (btrim(model_ref) <> '')
);

SELECT create_hypertable(
    'simulation_sample',
    by_range('simulation_time_ns', 60000000000),
    if_not_exists => TRUE
);

-- migrate:down

DROP TABLE IF EXISTS simulation_sample;
DROP TABLE IF EXISTS simulation_run;
DROP TABLE IF EXISTS asset;
