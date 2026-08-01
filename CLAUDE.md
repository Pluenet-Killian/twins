# CLAUDE.md

Ce fichier s'adresse à Claude Code. Les règles de `AGENTS.md` sont obligatoires et constituent la référence commune avec les autres agents. Lire intégralement `AGENTS.md` et `docs/specification/PROJECT_SPECIFICATION.md` avant toute modification importante.

## Contexte essentiel

Le produit est un jumeau numérique multiphysique de data center construit dans un monorepo greenfield. Le dépôt NVIDIA DSX voisin est uniquement une référence externe. Le produit doit démontrer une compétence professionnelle transférable à d'autres bâtiments, installations industrielles et produits connectés.

OpenUSD et Omniverse Kit assurent la scène et la visualisation d'ingénierie, pas la physique. React assure le cockpit et la vitrine. Le moteur C++ orchestre le temps et les événements. OpenDSS, Modelica et OpenFOAM restent responsables de leurs domaines. PostgreSQL porte les identités et configurations ; TimescaleDB porte les séries temporelles.

## Protocole avant modification

Commencer par identifier la décision de spécification concernée, le composant propriétaire de la donnée, les contrats traversés et le test qui prouvera le résultat. Si l'un de ces éléments est ambigu, inspecter le dépôt et documenter l'hypothèse avant d'étendre le périmètre.

Ne pas remplacer une décision actée sans proposition explicite et ADR. Ne pas inventer de données physiques pour débloquer une implémentation. Utiliser un fixture clairement synthétique lorsque nécessaire et empêcher sa confusion avec une mesure ou une courbe constructeur.

Respecter les changements déjà présents dans le worktree. Éviter les réécritures massives, dépendances supplémentaires et architectures distribuées prématurées. Préférer une tranche verticale testée à plusieurs squelettes non intégrés.

## Exigences de livraison

Le code et les identifiants sont en anglais ; les documents produit et l'explication au propriétaire sont en français. Les unités internes sont SI, les contrats sont versionnés et les runs sont immuables.

Ne jamais écrire, compléter ou exécuter de tests unitaires sauf si le propriétaire les demande explicitement dans la requête en cours. Une demande générique de test ou de vérification ne suffit pas. Vérifier plutôt par compilation, smoke test, contrat, intégration, scénario ou comparaison de référence selon le risque, puis mettre à jour la documentation ou l'ADR lorsque l'architecture change. Ne déclarer terminé, validé, sécurisé ou conforme que si les preuves correspondantes existent.

Toute réponse finale doit distinguer clairement les changements réalisés, les vérifications effectuées, les limites connues et la prochaine action utile. Ne pas masquer un échec de solveur, un test non exécuté ou une hypothèse derrière une formulation positive.
