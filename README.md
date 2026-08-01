# Data Center Digital Twin

> Statut : fondation en cours — les premiers socles C++, Python, React, Protobuf et PostgreSQL/TimescaleDB sont reproductibles.

Ce dépôt construit un jumeau numérique multiphysique professionnel d'un data center fictif français orienté AI/HPC. Le produit associera une scène 3D OpenUSD très détaillée, des solveurs spécialisés, une orchestration temporelle, un cockpit d'exploitation et une expérience Web publique légère.

Le data center est un démonstrateur de profondeur technique. La finalité commerciale est plus large : montrer la capacité à numériser, connecter, superviser et simuler des équipements, bâtiments et installations complexes pour de futurs clients.

La référence fonctionnelle et architecturale est la [spécification du projet](docs/specification/PROJECT_SPECIFICATION.md). Les versions exactes, leurs statuts de validation et les règles destinées aux agents sont définis dans la [baseline de toolchain](docs/toolchain/TOOLCHAIN_BASELINE.md). Les instructions obligatoires pour les agents et contributeurs sont dans [AGENTS.md](AGENTS.md). Claude Code doit également lire [CLAUDE.md](CLAUDE.md).

## Ce que le produit doit prouver

Le jumeau doit relier une représentation spatiale et sémantique aux comportements réels des systèmes. Il doit calculer l'électricité depuis l'arrivée HTA jusqu'aux baies, le refroidissement par air et liquide, la charge informatique issue des workloads, les automatismes, les alarmes, la sécurité et les interventions humaines.

Une panne ne sera pas une animation préparée. Le scénario injectera une cause, puis les modèles calculeront la propagation, les délais, les protections, les réactions automatiques et les conséquences sur les services informatiques.

## Architecture de référence

```mermaid
flowchart LR
    Cockpit["Cockpit React"] --> API["API FastAPI"]
    Public["Site public React + glTF"] --> Published["Artefacts de runs publiés"]
    API <--> Engine["Orchestrateur C++20"]
    Kit["Omniverse Kit + OpenUSD"] <--> Engine
    Engine <--> CoSim["Master temporel après prototype"]
    CoSim <--> Electrical["OpenDSS — électricité RMS"]
    CoSim <--> Thermal["Modelica/FMU + SSP — thermique et hydraulique"]
    Electrical -. vérification .-> IEC["pandapower — IEC 60909"]
    Engine <--> CFD["OpenFOAM — CFD hors ligne"]
    Engine <--> Compute["Workloads, réseau et automatismes"]
    Engine <--> Data["PostgreSQL + TimescaleDB"]
    Data --> Semantic["ASHRAE 223P + Brick"]
    Engine --> Artifacts["Stockage des artefacts"]
    Artifacts --> Published
```

OpenUSD compose la scène et Omniverse Kit l'affiche avec le rendu RTX. Ils ne calculent pas la physique. Le moteur C++ porte les runs, scénarios, événements métier et l'audit. Le master temporel sera choisi après un prototype comparant HELICS, OMSimulator/SSP et une boucle C++ minimale. OpenDSS calcule le réseau électrique RMS, pandapower vérifie des cas IEC 60909 sélectionnés, Modelica les dynamiques thermohydrauliques et OpenFOAM les campagnes CFD détaillées. FMI 2.0.5 est la baseline de production, FMI 3.0.2 une cible promue après preuve et SSP 2.0.1 décrit les systèmes composés. PostgreSQL conserve les identités et configurations canoniques, tandis que TimescaleDB conserve les séries temporelles.

Le site public ne lancera ni Kit ni les solveurs. Il chargera une scène glTF/GLB optimisée et rejouera des résultats pré-calculés, validés et expurgés. Les démonstrations haute fidélité utiliseront Kit desktop ou une session WebRTC temporaire.

## Principes non négociables

La 3D n'est jamais la source de vérité d'un raccordement ou d'un calcul. Chaque actif possède une identité canonique stable et chaque représentation externe s'y rattache explicitement.

Les données synthétiques, observations réelles, commandes, états et résultats simulés restent séparés. Une courbe, probabilité, tolérance ou mesure ne doit jamais être inventée ou présentée avec un niveau de preuve qu'elle ne possède pas.

Chaque modèle déclare son usage, ses hypothèses, son domaine de validité et ses preuves. Chaque run est immuable et reproductible. Chaque conséquence importante doit être explicable par une cause, un état, une commande ou une règle identifiée.

Le site public, l'ingénierie, la simulation et toute future connexion OT sont séparés. Les connecteurs réels sont en lecture seule par défaut et aucune commande réelle ne peut provenir d'un scénario de démonstration.

## Surfaces du produit

L'application d'ingénierie associera Omniverse Kit à un cockpit React pour inspecter les actifs, systèmes, résultats, alarmes, procédures et timelines causales. Elle fonctionnera d'abord localement sur le poste actuel avec des payloads, niveaux de détail et modèles réduits adaptés.

La vitrine publique présentera un parcours guidé et une exploration libre avec React Three Fiber, glTF/GLB, courbes et explications. Elle conservera une alternative accessible si la 3D avancée n'est pas disponible.

## Organisation cible

```text
apps/          cockpit d'ingénierie, site public et application Kit
services/      orchestrateur C++, API et service sémantique
adapters/      OpenDSS, Modelica, OpenFOAM et futures télémétries
packages/      contrats, schémas et composants partagés
models/        modèles électriques, thermiques, IT, contrôle et humains
assets/        sources, USD, dérivés Web et matériaux
data/          données de référence, synthétiques et de validation
database/      migrations, seeds et politiques
infra/         environnement local, observabilité et déploiement
tests/         contrats, intégration, scénarios, performance et sécurité
docs/          spécification, ADR, dossiers de modèles et rapports
tools/         pipelines d'assets, publication et validation
```

Cette arborescence sera créée progressivement. Un dossier ne sera ajouté que lorsqu'un premier contenu réel le justifie.

## Première tranche verticale

La première tranche représentera une zone de data hall avec baies classiques et IA, une chaîne électrique représentative, une branche de refroidissement par air, une branche liquide avec CDU, les automatismes essentiels et un cockpit minimal.

Le scénario de référence injectera la perte du réseau public pendant une charge informatique représentative. Le système calculera le passage sur UPS, l'évolution des batteries, le démarrage des groupes, la disponibilité du refroidissement, la température, les alarmes, les réactions des workloads et l'intervention humaine.

## Ordre de construction

La feuille de route commence par verrouiller les versions, licences, contrats, migrations et artefacts, puis construit immédiatement un trajet complet UUID–PostgreSQL–C++–Kit/React–GLB public. Elle enchaîne avec le pipeline IFC/IDS–USD–223P, la décision de co-simulation par prototype, les tranches électrique, thermohydraulique, informatique et automatismes/humains, le scénario transversal crédible, l'application d'ingénierie, la publication commerciale, puis le cycle de vie et les connecteurs réels. Chaque tranche possède une porte de sortie mesurable et aucune couche visuelle ne masque une intégration manquante.

La feuille de route détaillée et les critères d'acceptation se trouvent dans la spécification. Aucun calendrier n'est annoncé avant l'estimation du backlog et la mesure des premiers prototypes.

## Démarrage du développement

La première exécution prépare CMake et vcpkg dans `.tools`, puis contrôle les versions sélectionnées. Le contrôle signale actuellement l'écart documenté entre Visual Studio Build Tools 17.14.31 installé et la cible de maintenance 17.14.37 ; le toolset MSVC v143 installé compile néanmoins le socle.

```powershell
.\tools\bootstrap-cmake.ps1
.\tools\bootstrap-vcpkg.ps1
.\tools\check-toolchain.ps1
```

Le moteur C++20 se configure et se compile avec le CMake exact du dépôt :

```powershell
.\tools\cmake.ps1 --preset windows-msvc-debug
.\tools\cmake.ps1 --build --preset windows-msvc-debug
.\build\windows-msvc-debug\services\orchestrator\Debug\twins-orchestrator.exe
```

Le service Python utilise exclusivement l'interpréteur et le verrou uv du workspace :

```powershell
uv sync --frozen
$env:PYTHONPATH = (Resolve-Path "services\api\src").Path
uv run --frozen uvicorn twins_api.main:app --app-dir services/api/src
```

Le cockpit React utilise pnpm par Corepack afin d'exécuter exactement la version inscrite dans `packageManager` :

```powershell
corepack pnpm install --frozen-lockfile
corepack pnpm build
corepack pnpm dev:cockpit
```

La base locale demande un secret non committé. Copier `.env.example` vers `.env`, remplacer le mot de passe d'exemple, puis démarrer et migrer depuis la racine :

```powershell
.\tools\database.ps1 -Command Up
$env:DATABASE_URL = "postgres://twins:YOUR_LOCAL_PASSWORD@127.0.0.1:5432/twins?sslmode=disable"
.\tools\database.ps1 -Command Migrate
.\tools\database.ps1 -Command Status
.\tools\database.ps1 -Command Stop
```

Les contrats se contrôlent sans génération implicite :

```powershell
buf format --diff --exit-code
buf lint
```

Avant de contribuer, lire la spécification et `AGENTS.md`, vérifier l'état Git, identifier la source de vérité affectée et définir la vérification qui prouvera le changement. Les tests unitaires sont exclus par défaut et ne sont réalisés que sur demande explicite du propriétaire. Une capacité n'est terminée que lorsque son code, ses vérifications autorisées, ses migrations, sa documentation, ses performances et ses limites sont cohérents.

## Relation avec NVIDIA DSX

Le dépôt `omniverse-dsx-blueprint-for-ai-factories` reste séparé et sert uniquement de référence technique. Ce projet ne dépendra pas de son interface et ne copiera pas ses assets ou son code sans vérification explicite de la licence et de la nécessité.

## Sécurité, confidentialité et licences

Ne jamais committer de secret, donnée client, plan sensible, résultat propriétaire ou asset sans licence. Les données du site de référence sont fictives ou publiquement justifiables et leur provenance doit être conservée.

La licence du nouveau projet n'est pas encore choisie. En l'absence de fichier `LICENSE`, aucun droit de réutilisation publique ne doit être supposé.
