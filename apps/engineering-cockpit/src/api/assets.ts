import { z } from "zod";

export const referenceAssetId = "00000000-0000-4000-8000-000000000001";

const assetSchema = z.object({
  asset_id: z.string().uuid(),
  canonical_name: z.string().min(1),
  asset_type_uri: z.string().min(1),
});

export type Asset = z.infer<typeof assetSchema>;

export async function getAsset(assetId: string): Promise<Asset> {
  const response = await fetch(`/api/v1/assets/${encodeURIComponent(assetId)}`);

  if (!response.ok) {
    throw new Error(`Asset request failed with HTTP ${response.status}.`);
  }

  return assetSchema.parse(await response.json());
}
