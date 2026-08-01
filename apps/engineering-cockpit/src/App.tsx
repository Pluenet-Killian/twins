import { useQuery } from "@tanstack/react-query";

import { getAsset, referenceAssetId } from "./api/assets";

export function App() {
  const assetQuery = useQuery({
    queryKey: ["asset", referenceAssetId],
    queryFn: () => getAsset(referenceAssetId),
    staleTime: Number.POSITIVE_INFINITY,
  });

  return (
    <main className="cockpit-shell">
      <header className="hero">
        <p className="eyebrow">Data Center Digital Twin</p>
        <h1>Engineering Cockpit</h1>
        <p className="summary">
          The first vertical slice reads one canonical asset from PostgreSQL
          through the engineering API. No visual placeholder owns this data.
        </p>
      </header>

      <section className="asset-panel" aria-labelledby="asset-panel-title">
        <div className="panel-heading">
          <div>
            <p className="panel-kicker">Canonical registry</p>
            <h2 id="asset-panel-title">Reference asset</h2>
          </div>
          <div className={`status status-${assetQuery.status}`} role="status">
            <span aria-hidden="true" />
            {assetQuery.isPending && "Connecting"}
            {assetQuery.isError && "Unavailable"}
            {assetQuery.isSuccess && "Registry connected"}
          </div>
        </div>

        {assetQuery.isPending && (
          <p className="panel-message">Reading the canonical identity…</p>
        )}

        {assetQuery.isError && (
          <div className="panel-message error" role="alert">
            <p>{assetQuery.error.message}</p>
            <button type="button" onClick={() => void assetQuery.refetch()}>
              Retry connection
            </button>
          </div>
        )}

        {assetQuery.data && (
          <dl className="asset-properties">
            <div className="primary-property">
              <dt>Canonical name</dt>
              <dd>{assetQuery.data.canonical_name}</dd>
            </div>
            <div>
              <dt>Registry UUID</dt>
              <dd>{assetQuery.data.asset_id}</dd>
            </div>
            <div>
              <dt>Semantic type</dt>
              <dd>{assetQuery.data.asset_type_uri}</dd>
            </div>
          </dl>
        )}
      </section>
    </main>
  );
}
