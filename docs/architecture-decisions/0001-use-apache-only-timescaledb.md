# ADR 0001 — Utiliser l'édition Apache-only de TimescaleDB

## Statut

Accepté le 1er août 2026.

## Contexte

Le produit utilise PostgreSQL comme registre canonique et TimescaleDB pour les séries temporelles. Sa finalité commerciale comprend la possibilité de fournir une plateforme hébergée à des clients. La Timescale Community Edition contient des fonctions sous Timescale License dont les restrictions doivent être évaluées avant toute offre de service. La première tranche n'a besoin que des fonctions temporelles disponibles dans le build open source.

Le dépôt officiel `timescale/timescaledb-docker-ha` publie des images `-oss` construites sans le code Timescale License. L'image correspondant aux versions sélectionnées existe pour les architectures amd64 et arm64.

## Décision

L'environnement local utilise PostgreSQL 18.4 et TimescaleDB 2.27.1 dans l'image Apache-only suivante :

```text
docker.io/timescale/timescaledb-ha:pg18.4-ts2.27.1-oss@sha256:d6f4290fc413dcb0b477c64fc0c50cc12c42e93a1fc242dfbfdc4c770d0d0553
```

Le tag documente les versions lisibles et le digest rend l'exécution reproductible. Les migrations ne peuvent utiliser que des fonctions présentes dans cette édition. Une fonction absente ne justifie pas l'emploi silencieux de l'image Community : elle déclenche une comparaison entre PostgreSQL natif, TimescaleDB Apache-only, archivage Parquet/Zarr et une offre Timescale commerciale, puis une nouvelle décision accompagnée d'une revue de licence.

## Conséquences

Cette décision préserve une base Apache 2.0 compatible avec l'ambition de distribution et d'hébergement du produit. Elle réduit le risque qu'un prototype local dépende involontairement d'une fonction impossible à proposer ensuite dans le modèle commercial visé.

Les fonctions avancées propres aux autres éditions ne font pas partie du contrat actuel. Les politiques de compression, de rétention et d'agrégation seront définies après mesure des volumes et contrôle de leur disponibilité dans l'édition sélectionnée.

## Vérification et sources

Le digest est vérifié avec `docker buildx imagetools inspect` avant son inscription. Les références sont le [dépôt officiel de l'image TimescaleDB HA](https://github.com/timescale/timescaledb-docker-ha), qui documente les builds `build-oss` et les tags `-oss`, les [éditions TimescaleDB](https://docs.timescale.com/about/latest/timescaledb-editions/) et la [release TimescaleDB 2.27.1](https://github.com/timescale/timescaledb/releases/tag/2.27.1).
