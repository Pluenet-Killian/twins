# Baseline de toolchain et de dépendances

> Statut : décision de fondation normative
>
> Dernière vérification des versions : 1er août 2026
>
> Portée : environnement local Windows, monorepo, application Omniverse Kit, moteur C++, services Python, applications Web, données et solveurs

## Rôle de ce document

Ce document donne aux développeurs et aux agents IA le contexte de version exact dans lequel le projet doit être conçu. Il empêche qu'un agent choisisse une API à partir d'une documentation correspondant à une autre génération, adopte automatiquement la dernière version publiée sans considérer sa maturité, ou mélange des toolchains incompatibles.

Les valeurs marquées **sélectionnée** sont les versions à matérialiser dans les manifests et scripts de bootstrap. **Observée** décrit uniquement l'état actuel du poste et ne vaut pas adoption. **Candidate** désigne une version précise retenue pour une future tranche, mais qui doit encore réussir son smoke test d'intégration avant de devenir sélectionnée. **Bloquée** signale une décision préalable obligatoire. **Différée** signifie que le composant ne doit pas encore être ajouté.

Cette baseline exprime l'intention commune à toutes les piles. Les fichiers exécutables de verrouillage, lorsqu'ils existent, portent la résolution exacte : `vcpkg.json` et son `builtin-baseline`, `uv.lock`, `package.json` avec `packageManager`, `pnpm-lock.yaml`, les images de conteneurs référencées par digest, les fichiers `.kit` et leurs versions d'extensions, ainsi que les manifests de solveurs. Une divergence entre ce document et un verrou n'autorise pas un agent à choisir arbitrairement l'un des deux : les deux doivent être réconciliés dans le même changement, avec la justification et les vérifications correspondantes.

## Règles obligatoires pour les agents IA

Avant d'écrire du code, l'agent lit cette baseline puis consulte la documentation officielle correspondant à la version exacte ou à sa ligne majeure et mineure. Une recherche sur « la dernière API » ne suffit pas. Les release notes, guides de migration, matrices de compatibilité et dépôts officiels sont prioritaires sur les tutoriels, réponses de forum et exemples anciens.

Le mot `latest` est interdit dans les manifests reproductibles, les images de conteneurs, les dépendances et les instructions de CI. Une version majeure ou mineure n'est jamais relevée silencieusement. Les mises à jour de sécurité à l'intérieur d'une ligne explicitement maintenue peuvent être proposées, mais elles doivent mettre à jour le verrou, cette baseline et les preuves de smoke test dans un seul changement.

Une version plus récente n'est pas automatiquement meilleure pour ce projet. La sélection tient compte de la compatibilité Omniverse, des extensions natives, des bibliothèques scientifiques, de la stabilité, du support à long terme, de la licence et du coût de migration. Lorsqu'une fonctionnalité moderne n'existe pas dans la version sélectionnée, l'agent doit l'indiquer et proposer une migration explicite plutôt que d'écrire du code qui ne compile pas.

Les toolchains embarquées restent isolées. Le Python fourni par Kit n'est pas remplacé par le Python du workspace. L'OpenUSD fourni par Kit est l'autorité pour l'application Kit ; un OpenUSD autonome sert aux outils hors Kit seulement après validation. Les outils gérés par le Kit App Template restent sous l'autorité de ce template et ne sont pas forcés vers les versions racine du monorepo.

La politique du dépôt exclut les tests unitaires sauf demande explicite du propriétaire. Une mise à niveau se vérifie néanmoins par compilation, contrôle de schéma, smoke test, intégration réelle, scénario reproductible ou comparaison à une référence, selon le composant.

## Poste de développement de référence

| Élément | Baseline ou observation | Statut | Décision |
|---|---:|---|---|
| Système hôte | Windows 11 Pro x86-64 | observée | Hôte natif de Kit et du développement Windows. |
| CPU | Intel Core Ultra 9 275HX, 24 cœurs | observée | Suffisant pour le développement et les cas locaux raisonnables. |
| Mémoire | 64 Go | observée | Les fidélités maximales ne doivent pas toutes être chargées simultanément. |
| GPU | NVIDIA GeForce RTX 5090 Laptop, 24 463 MiB | observée | GPU Blackwell de développement et démonstration locale. |
| Pilote NVIDIA | 591.91 installé ; 595.97 ciblé | candidate | 595.97 est le pilote Windows GeForce Blackwell actuellement validé par NVIDIA pour les versions Omniverse récentes ; le changement exige le smoke test Kit complet. |
| WSL | WSL 2.6.3.0, noyau 6.6.87.2-1 | observée | Environnement Linux local pour OpenFOAM et outils qui le nécessitent. |
| Docker Engine | 29.2.1 | observée | Conservé comme baseline locale initiale jusqu'au premier bootstrap propre. |
| Docker Compose | 5.0.2 | observée | Les services sans GPU seront décrits dans une composition reproductible. |
| Git | 2.52.0.windows.1 | observée | Version locale actuellement utilisable. |
| Git LFS | 3.7.1 | observée | Réservé aux assets approuvés qui doivent réellement être versionnés par Git. |

La page NVIDIA des [exigences techniques Omniverse](https://docs.omniverse.nvidia.com/dev-overview/latest/common/technical-requirements.html) constitue la source de la matrice pilote–GPU. Le pilote installé reste inchangé tant que le passage à 595.97 n'a pas été demandé et vérifié ; ce document ne vaut pas autorisation implicite de modifier le pilote du poste.

## Toolchain C++ et système de build

| Composant | Version cible | État local | Statut | Justification |
|---|---:|---:|---|---|
| Standard C++ | C++20, extensions désactivées | non matérialisé | sélectionnée | Baseline du moteur, suffisamment moderne et compatible avec les dépendances prévues. |
| Visual Studio Build Tools | 2022 17.14.37, build 17.14.37516.0 | absent | sélectionnée | Version 2022 maintenue et explicitement compatible avec le C++ du Kit App Template. |
| Toolset MSVC | v143 | absent | sélectionnée | Toolset associé à Visual Studio 2022 ; ABI et intégration Kit connues. |
| Windows SDK | 10.0.26100.0 | installé | sélectionnée | SDK Windows 11 stable, maintenu et déjà présent ; la ligne 28000 plus récente n'apporte aucun besoin projet actuel. |
| CMake | 4.3.4 | 4.2.1 | sélectionnée | Dernière correction de la ligne 4.3 ; retenue plutôt que 4.4.0 publiée très récemment. |
| vcpkg | tag `2026.07.29` | absent du dépôt | sélectionnée | Snapshot reproductible récent du catalogue. |
| vcpkg `builtin-baseline` | `c76c06644034521fb761a39f8f52d8e87d1103d5` | absent | sélectionnée | SHA exact à inscrire dans `vcpkg.json`, sans suivi flottant de `master`. |
| Triplet Windows | `x64-windows` | absent | sélectionnée | Baseline dynamique native ; tout autre triplet doit être justifié par un besoin de packaging ou d'ABI. |

La version Visual Studio est figée à partir de l'[historique officiel Visual Studio 2022](https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history). Visual Studio 2026 n'est pas retenu pour la fondation : le [Kit App Template officiel](https://github.com/NVIDIA-Omniverse/kit-app-template) annonce encore Visual Studio 2019 ou 2022 pour ses extensions C++ Windows. Le SDK 10.0.26100.0 reste dans une ligne prise en charge selon la [documentation Windows SDK](https://learn.microsoft.com/en-us/windows/apps/windows-sdk/). CMake 4.3.4 provient des [téléchargements officiels CMake](https://cmake.org/download/) et vcpkg du [registre de releases Microsoft](https://github.com/microsoft/vcpkg/releases).

Le moteur utilisera `CMAKE_CXX_STANDARD=20`, `CMAKE_CXX_STANDARD_REQUIRED=ON` et `CMAKE_CXX_EXTENSIONS=OFF`. Les dépendances vcpkg seront déclarées uniquement dans le mode manifeste ; aucun `vcpkg install` global ne constituera une preuve de reproductibilité. Le build de l'application Kit continuera d'utiliser `repo.bat` et les outils gérés par le Kit App Template lorsque NVIDIA l'exige.

Les premières dépendances C++ prévues dans le snapshot vcpkg sélectionné sont mp-units 2.5.0 pour les quantités, gRPC 1.81.1 et Protobuf 6.33.4 port-version 2 pour les contrats internes, et OpenTelemetry C++ 1.28.0 pour l'observabilité. Elles sont **candidates** jusqu'à la création du manifeste et à la compilation du squelette vertical ; elles ne doivent pas être ajoutées avant le composant qui les utilise réellement.

## Python et outils scientifiques

| Composant | Version cible | État local | Statut | Justification |
|---|---:|---:|---|---|
| Python CPython | 3.13.14 | 3.13.13 | sélectionnée | Ligne moderne et corrigée, plus prudente que 3.14 pour l'écosystème scientifique et les extensions natives. |
| uv | 0.12.1 | 0.11.21 | sélectionnée | Gestionnaire unique des interpréteurs, environnements, workspace et verrou Python. |
| FastAPI | 0.141.1 | absent | candidate | Passerelle HTTP du premier squelette vertical. |
| Pydantic | 2.13.4 | absent | candidate | Validation des entrées de passerelle, sans devenir le modèle canonique interlangage. |
| Uvicorn | 0.52.0 | absent | candidate | Serveur local de la passerelle FastAPI. |
| IfcOpenShell | 0.8.5 | absent | candidate | Ingestion IFC ; cette version publie des wheels Windows pour Python 3.13. |
| NumPy | 2.5.1 | absent | candidate | Calcul et échanges tabulaires scientifiques. |
| pandas | 3.0.5 | absent | candidate | Traitement de données hors boucle autoritaire. |
| SciPy | 1.18.0 | absent | candidate | Algorithmes scientifiques utilisés seulement par les adaptateurs qui le justifient. |
| pandapower | 3.5.4 | absent | candidate | Route indépendante de vérification électrique sélectionnée. |
| RDFLib | 7.6.0 | absent | candidate | Projection RDF du profil sémantique. |
| pySHACL | 0.40.1 | absent | candidate | Validation SHACL de la projection sémantique. |
| PyArrow | 25.0.0 | absent | candidate | Échanges et archivage Parquet. |
| Zarr | 3.3.0 | absent | candidate | Tableaux multidimensionnels archivés au format Zarr v3. |
| VTK | 9.6.2 | absent | candidate | Données de champs et maillages de visualisation. |

La ligne Python est contrôlée par les [releases officielles CPython](https://www.python.org/downloads/) et uv par ses [instructions et versions officielles](https://docs.astral.sh/uv/getting-started/installation/). Les versions de paquets sont vérifiées sur [PyPI](https://pypi.org/) mais ne deviennent sélectionnées qu'au moment où leur adaptateur entre dans une tranche réelle et où `uv.lock` est produit.

Le workspace ne publiera pas plusieurs fichiers de dépendances concurrents. `pyproject.toml` décrit les intentions, `uv.lock` verrouille la résolution et la version de Python est déclarée à la racine. Les notebooks restent exploratoires. Le Python embarqué par Omniverse Kit conserve ses propres modules et ne reçoit pas directement l'environnement uv du monorepo.

## Web et interface

| Composant | Version cible | État local | Statut | Justification |
|---|---:|---:|---|---|
| Node.js | 24.18.0 LTS | 24.18.0 | sélectionnée | Ligne LTS actuelle ; Node 26 Current n'est pas retenu pour la fondation. |
| pnpm | 11.4.0 | 10.12.1 | sélectionnée | Gestionnaire du workspace, verrouillé par Corepack et `packageManager`. |
| npm | fourni avec Node, non utilisé pour résoudre le workspace | 11.16.0 | observée | npm reste disponible mais ne doit pas produire un second lockfile. |
| React / React DOM | 19.2.8 | absent | candidate | Base du cockpit et du site public. |
| TypeScript | 7.0.2 | absent | candidate | Version greenfield actuelle, soumise au smoke Vite et aux types React avant sélection finale. |
| Vite | 8.2.0 | absent | candidate | Développement et build des applications React. |
| `@vitejs/plugin-react` | 6.0.5 | absent | candidate | Intégration React avec la ligne Vite retenue. |
| Tailwind CSS | 4.3.3 | absent | candidate | Design system utilitaire du projet. |
| TanStack Query | 5.101.4 | absent | candidate | État serveur et cache du cockpit. |
| Apache ECharts | 6.1.0 | absent | candidate | Courbes, timelines et cartes de chaleur. |
| React Flow | `@xyflow/react` 12.11.2 | absent | candidate | Vues fonctionnelles complémentaires, jamais substitut à la 3D. |
| Three.js | 0.185.1 | absent | candidate | Renderer du dérivé Web public. |
| React Three Fiber | 9.7.0 | absent | candidate | Intégration React du renderer Web public. |
| Radix Dialog | 1.1.23 | absent | candidate | Première primitive accessible ; les autres packages Radix seront ajoutés à l'usage. |
| Zod | 4.4.3 | absent | candidate | Validation aux frontières TypeScript, sans recopier les contrats Protobuf. |

Le choix de Node suit la [politique officielle des releases Node.js](https://nodejs.org/en/about/previous-releases) et Vite les [releases officielles Vite](https://vite.dev/releases). Les versions de packages proviennent de leur registre npm officiel. Elles restent candidates jusqu'au premier workspace installable, au build de production et au smoke navigateur ; l'agent ne doit pas rétrograder vers une ancienne recette de React, Tailwind ou Vite sans démontrer une incompatibilité.

Le fichier racine `package.json` devra déclarer exactement `pnpm@11.4.0` dans `packageManager`. Un seul `pnpm-lock.yaml` couvrira le workspace. Aucun `package-lock.json` ou `yarn.lock` ne sera admis.

## Contrats, base de données et services locaux

| Composant | Version cible | État local | Statut | Justification |
|---|---:|---:|---|---|
| Buf CLI | 1.72.0 | absent | sélectionnée | Formatage, lint, génération et détection des ruptures Protobuf. |
| dbmate | 2.34.1 | absent | sélectionnée | Migrations SQL explicites et indépendantes d'un ORM. |
| PostgreSQL | 18.4 | absent | sélectionnée | Version stable actuelle, supportée jusqu'en novembre 2030. |
| TimescaleDB | 2.27.1 | absent | sélectionnée techniquement, édition bloquée | Version compatible PostgreSQL 18 ; le choix Apache 2 ou Community précède le choix d'image. |
| OpenTelemetry C++ | 1.28.0 | absent | candidate | Traces et métriques réelles du moteur. |
| OpenTelemetry Python | 1.44.0 | absent | candidate | Corrélation des services Python. |

Les sources de référence sont les [releases Buf](https://github.com/bufbuild/buf/releases), les [releases dbmate](https://github.com/amacneil/dbmate/releases), la [politique de versions PostgreSQL](https://www.postgresql.org/support/versioning/), les [notes PostgreSQL 18.4](https://www.postgresql.org/docs/release/18.4/) et les [releases TimescaleDB](https://github.com/timescale/timescaledb/releases). L'[édition et la licence TimescaleDB](https://docs.timescale.com/about/latest/timescaledb-editions/) restent une décision bloquante : aucune image de conteneur n'est figée avant l'ADR correspondant.

La génération Protobuf suivra une seule configuration `buf.yaml` et `buf.gen.yaml` verrouillant les plugins de génération. Les versions des runtimes C++ et Python peuvent différer, mais les combinaisons générateur–runtime doivent être compatibles et vérifiées par un échange C++–Python réel. Aucun agent ne doit appeler un `protoc` trouvé arbitrairement dans le `PATH`.

## Omniverse, OpenUSD et rendu

| Composant | Version cible | État local | Statut | Justification |
|---|---:|---:|---|---|
| Omniverse Kit SDK | 110.2 | autre prototype DSX présent | candidate prioritaire | Release actuelle comportant les mises à jour et corrections Kit récentes. |
| Kit App Template | commit exact à figer lors du scaffold | non intégré | bloquée par le scaffold | Le commit, sa licence et le bundle réellement résolu seront inscrits ensemble. |
| Extensions Kit | versions exactes du registre Kit 110.2 | non intégrées | bloquée par le scaffold | Une extension n'est ajoutée qu'avec usage, droit de redistribution et smoke test. |
| OpenUSD dans Kit | version embarquée par Kit 110.2 | non résolue | sélectionnée par héritage | Ne jamais remplacer indépendamment les bibliothèques USD internes de Kit. |
| OpenUSD autonome | 26.08 | absent | candidate | Référence et outils hors Kit seulement après essai d'ouverture aller-retour avec la scène de référence. |
| Pilote RTX Windows | 595.97 | 591.91 | candidate | Paire à valider avec Kit 110.2 sur le RTX 5090 Laptop. |

Kit 110.2 est documenté dans ses [release notes officielles](https://docs.omniverse.nvidia.com/dev-guide/latest/release-notes/110_2.html) et son [registre partagé](https://docs.omniverse.nvidia.com/kit/docs/kit-registry-reference/latest/110.2/shared.html). Le [Kit App Template](https://github.com/NVIDIA-Omniverse/kit-app-template) doit être référencé par un commit exact au moment du scaffold, car son dépôt évolue indépendamment du SDK résolu. OpenUSD autonome suit la [documentation de release OpenUSD 26.08](https://openusd.org/release/).

La promotion de la combinaison Kit exige, sur un environnement propre, le téléchargement des extensions, le build, le démarrage, l'ouverture de la scène de référence, le rendu RTX, la sélection d'un prim par UUID, un échange avec l'orchestrateur, la fermeture propre et, si activé, un smoke WebRTC. La consommation RAM, VRAM, le temps de démarrage, la version du pilote, les extensions et les paramètres de rendu sont conservés avec le résultat.

## Solveurs et formats d'ingénierie

Ces versions donnent un contexte précis aux recherches et prototypes, mais ne constituent pas toutes des dépendances immédiates du premier bootstrap.

| Composant | Version de travail | Statut | Usage prévu |
|---|---:|---|---|
| FMI | 2.0.5 | sélectionnée comme format | Baseline de production des FMU. |
| FMI | 3.0.2 | candidate | Promotion modèle par modèle après preuve exporteur–importeur. |
| SSP | 2.0.1 | sélectionnée comme format | Description des assemblages de co-simulation. |
| OpenDSS | 11.0.0.1 | candidate | Solveur électrique RMS autoritaire pendant le run. |
| OpenModelica | 1.26.3 | candidate | Compilation et exécution des modèles Modelica/FMUs. |
| Modelica Buildings | 13.0.0 | candidate | Thermique, hydraulique et régulations. |
| OpenFOAM Foundation | 14 | candidate | CFD détaillée hors ligne sous WSL2 ou Linux. |
| HELICS | 3.6.1 | candidate de prototype | Une des options du prototype de master temporel. |
| OMSimulator | 2.1.3 | candidate de prototype | Option SSP/FMI du prototype de master temporel. |

Chaque solveur recevra son propre manifeste comprenant l'édition, la version exacte, l'empreinte du binaire ou de l'image, la licence, la plateforme, les options numériques et le jeu de vérification. L'architecture ne doit pas être écrite autour d'une API de HELICS ou d'OMSimulator avant le résultat de l'ADR de co-simulation. PhysicsNeMo, FDS et les outils commerciaux restent différés jusqu'à la tranche qui justifie leurs données, leurs licences et leurs preuves.

## Procédure de promotion et de mise à jour

Une version candidate devient sélectionnée uniquement lorsque le composant réel existe dans le monorepo, que sa licence est acceptée, que sa résolution exacte est verrouillée et que son smoke test autorisé réussit depuis un environnement propre. Le résultat doit indiquer la machine, les commandes, les versions, les temps, les consommations utiles et les limites observées.

Les versions sont revues au début de la tranche qui les introduit, avant une livraison démontrée et lorsqu'un avis de sécurité pertinent apparaît. La revue commence par les sources officielles et compare les changements depuis la baseline. Une seule famille de dépendances est relevée à la fois lorsque cela permet d'isoler les régressions. Les migrations majeures de Kit, OpenUSD, CMake, C++, Python, Node, PostgreSQL, TimescaleDB ou d'un solveur exigent un ADR si elles changent un contrat, une autorité, une licence, un format persistant ou une hypothèse de déploiement.

L'état initial montre que CMake, Python, uv et pnpm doivent être alignés, que MSVC v143, Buf et dbmate manquent, et que Kit 110.2 n'est pas encore scaffoldé dans ce monorepo. Ces écarts sont attendus : la baseline précède volontairement l'installation. Aucun agent ne doit prétendre que la fondation est reproductible avant que les manifests, scripts de contrôle et smoke tests correspondants n'existent.
