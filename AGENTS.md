# AGENTS.md

## Portée

Ces instructions s'appliquent à l'ensemble du monorepo. Un fichier `AGENTS.md` placé plus profondément pourra ajouter des règles propres à un composant, mais ne devra pas contredire les principes définis ici.

Ce projet est un jumeau numérique multiphysique professionnel de data center. Il ne s'agit ni d'un jeu, ni d'une simple maquette 3D, ni d'une adaptation cosmétique du NVIDIA DSX Blueprint.

## Sources de vérité obligatoires

Avant toute modification significative, lire dans cet ordre :

1. `docs/specification/PROJECT_SPECIFICATION.md` pour l'intention, le périmètre et les décisions actées ;
2. le présent fichier ;
3. les ADR applicables dans `docs/architecture-decisions/` lorsqu'ils existent ;
4. la fiche de crédibilité du modèle concerné lorsqu'elle existe ;
5. le `AGENTS.md` le plus proche du fichier modifié lorsqu'il existe.

Une décision marquée comme actée dans la spécification ne doit jamais être remplacée silencieusement. Si une meilleure solution apparaît, documenter le problème, les preuves, les conséquences et proposer un ADR avant d'effectuer une migration incompatible.

## Langue et conventions générales

La documentation produit et les explications destinées au propriétaire du projet sont rédigées en français clair. Le code, les identifiants, noms de fichiers, schémas, messages de protocole et commentaires techniques réutilisables sont rédigés en anglais. Ne pas traduire les noms officiels de normes, bibliothèques, classes ou protocoles.

Utiliser UTF-8, les fins de ligne LF et une ligne finale. Les unités internes sont SI. Une valeur physique ne doit jamais circuler sans type, unité ou contrat explicite. L'horloge virtuelle de simulation doit rester distincte de l'heure réelle et des horodatages UTC de la plateforme.

## Frontières architecturales non négociables

OpenUSD compose la scène d'ingénierie et ses références. Omniverse Kit rend et manipule la 3D haute fidélité. Aucun des deux ne devient la source de vérité des calculs physiques.

React fournit le cockpit d'ingénierie et le site public. Le site public utilise des artefacts glTF/GLB dérivés et rejoue des runs acceptés ; il ne lance ni Omniverse Kit ni un solveur autoritaire.

Le moteur C++20 possède l'horloge virtuelle, la file d'événements, les états discrets, l'orchestration et la reproductibilité. Il ne doit pas réimplémenter une loi physique déjà placée sous l'autorité d'un solveur spécialisé.

OpenDSS est la source du calcul électrique RMS. Modelica et les FMU portent la dynamique thermohydraulique et les régulations continues. OpenFOAM porte les campagnes CFD détaillées hors ligne. Les modèles réduits ne sont utilisables que dans un domaine de validité documenté.

PostgreSQL porte le registre canonique, les identités, configurations et mappings. TimescaleDB porte les séries temporelles. Les fichiers lourds sont des artefacts référencés et non des blobs ajoutés arbitrairement aux tables ou à Git.

ASHRAE 223P et Brick fournissent une projection sémantique versionnée. IFC conserve son rôle BIM. Le graphe RDF, OpenUSD, TimescaleDB et les solveurs ne doivent pas dupliquer l'autorité de PostgreSQL sur les identités canoniques.

Les contrats interprocessus utilisent Protocol Buffers et gRPC. Les nouveaux modèles dynamiques ciblent FMI 3.0.2 tout en préservant l'import FMI 2.0 lorsque nécessaire.

## Règles de modélisation

Séparer systématiquement définition, configuration, commande, état, observation, estimation et résultat simulé. Ne jamais utiliser un champ générique qui mélange ces catégories.

Chaque actif possède une identité stable indépendante de son nom, de son chemin OpenUSD, de sa position et de l'identifiant d'un solveur. Toute représentation externe se relie à cette identité par un binding explicite et testable.

Chaque port et connexion doit déclarer son domaine, son médium ou signal, sa direction lorsque pertinente, ses unités et ses contraintes de compatibilité. La proximité géométrique ne prouve jamais une connexion fonctionnelle.

Tout modèle doit déclarer son usage prévu, ses entrées, sorties, paramètres, hypothèses, limites, coût, version, domaine de validité et preuves. Ne pas présenter une sortie comme validée sans dossier de crédibilité et critère d'acceptation applicables.

Ne jamais inventer une courbe constructeur, une probabilité de panne, une durée humaine, une tolérance ou une donnée mesurée. Lorsqu'une donnée synthétique est nécessaire, l'identifier explicitement, conserver sa provenance et empêcher sa présentation comme donnée réelle.

Les bilans d'énergie, de puissance et de masse doivent être conservés aux interfaces. Éviter tout double comptage entre consommation informatique, pertes d'alimentation et chaleur injectée dans les modèles thermiques.

Un scénario injecte des causes, pas une liste prédéterminée de conséquences. Les événements calculés, commandes, observations et actions humaines doivent rester distinguables dans la timeline.

Un run est immuable. Une correction de code, de donnée ou de modèle produit un nouveau run avec un nouveau manifeste ; elle ne réécrit jamais les résultats historiques.

## Méthode de travail attendue

Inspecter l'état Git avant de modifier des fichiers. Les modifications existantes appartiennent à l'utilisateur tant que leur origine n'est pas établie. Ne pas les écraser, les reformater globalement ou les inclure dans une opération destructive sans demande explicite.

Avant de coder, identifier le domaine responsable, la source de vérité, le contrat affecté et le critère d'acceptation. Pour une modification transversale, décrire brièvement le flux de données et les migrations nécessaires.

Faire le changement minimal qui complète réellement la capacité demandée. Ne pas introduire de microservice, bus distribué, framework ou abstraction générique sans besoin actuel démontré. Toute nouvelle dépendance doit être maintenue, compatible avec les licences du projet et justifiée par rapport à une solution déjà présente.

Privilégier les schémas et la génération de code pour les contrats partagés. Ne pas modifier manuellement un fichier généré. Une évolution incompatible exige une version ou une migration explicite.

Les notebooks peuvent explorer une idée, mais aucun calcul faisant autorité ne doit dépendre d'un notebook non versionné ou d'étapes manuelles non reproductibles.

Les documents et sources techniques externes doivent être primaires et, lorsque l'information peut évoluer, vérifiés dans leur version actuelle. Conserver l'édition d'une norme ou d'une spécification dans l'ADR ou le dossier qui l'utilise.

## Vérifications et politique de tests

Par décision explicite du propriétaire, ne jamais créer, compléter ou exécuter de tests unitaires par défaut. Les tests unitaires ne sont autorisés que lorsque le propriétaire les demande explicitement dans la requête en cours. Une demande générique de vérification, de qualité, de correction ou de test ne constitue pas une autorisation implicite de produire des tests unitaires.

Cette règle vise à préserver la vitesse de développement et prévaut sur toute recommandation générale en faveur des tests unitaires. Ne pas contourner la règle en donnant un autre nom à un test isolé qui exerce artificiellement une fonction ou une classe.

Chaque changement doit néanmoins être vérifié proportionnellement à son risque par les moyens les plus directs : compilation, analyse statique, smoke test, test de contrat, intégration réelle, scénario reproductible, comparaison à une référence ou inspection ciblée. Ne pas créer une infrastructure de test plus volumineuse que la capacité vérifiée.

Les vérifications physiques doivent couvrir les unités, bilans, signes, bornes, conservation, convergence ou comparaison à une référence appropriée. Les scénarios de vérification doivent contrôler l'ordre causal et les invariants, pas seulement une capture finale.

Les résultats déterministes doivent être reproductibles dans les tolérances documentées. Toute utilisation d'aléatoire doit accepter une graine explicite et la conserver dans le manifeste du run.

Une régression de performance doit être mesurée sur la scène ou le jeu de données de référence. Ne pas résoudre une surcharge locale en exigeant silencieusement davantage de RAM ou de VRAM ; examiner d'abord payloads, LOD, instanciation, fréquences, agrégations et modèles actifs.

Un changement n'est pas terminé si les vérifications autorisées, migrations, exemples, documentation, limites ou diagnostics nécessaires manquent. Ne jamais annoncer qu'un modèle est validé, sécurisé, conforme ou prêt pour la production sans les preuves correspondantes.

## Sécurité et données

Le site public, les services, la simulation, l'ingénierie et toute future zone OT sont des zones de confiance distinctes. Aucun code public ne doit disposer d'un accès direct à des services d'ingénierie ou à un équipement réel.

Les connecteurs vers une installation réelle sont en lecture seule par défaut. Toute commande réelle nécessite un projet, une analyse de risques, une autorisation et des interverrouillages dédiés. Les tests de simulation ne doivent jamais utiliser les adresses ou identifiants d'un site de production.

Ne jamais ajouter de secret, token, mot de passe, certificat privé, donnée client ou plan sensible dans Git, les logs, les fixtures ou les captures. Utiliser des exemples neutralisés et des variables d'environnement documentées.

Contrôler les licences et la provenance des modèles 3D, textures, données, bibliothèques, normes et extraits de code. Le clone NVIDIA DSX est une référence externe en lecture seule ; ne pas copier son contenu dans ce dépôt sans vérifier le droit et la nécessité.

## Git et revue

Préserver des commits cohérents et limités à une intention. Utiliser de préférence les préfixes `feat`, `fix`, `docs`, `test`, `refactor`, `build`, `ci` et `chore`. Ne pas mélanger un reformatage global à une modification fonctionnelle.

Ne pas committer les sorties de build, caches, environnements, logs, runs, résultats CFD, secrets ou assets lourds non approuvés. Les exceptions doivent être documentées et, si nécessaire, gérées par le stockage d'artefacts ou Git LFS.

Lors d'une livraison, résumer ce qui a changé, les tests exécutés, les preuves produites, les limites restantes et les fichiers de décision mis à jour. Signaler explicitement ce qui n'a pas pu être vérifié.
