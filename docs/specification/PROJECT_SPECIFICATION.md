# Spécification du jumeau numérique de data center

> Statut : cadrage consolidé et acté ; relecture finale requise avant attribution d'un numéro de version
> Dernière consolidation : 1er août 2026
> Nom de travail : Data Center Digital Twin

## Méthode de rédaction et de décision

Cette spécification doit permettre de reprendre le projet après plusieurs semaines ou plusieurs mois sans dépendre de la mémoire des échanges. Une décision n'est considérée comme actée que lorsqu'elle est inscrite explicitement dans ce document avec son objectif, sa justification, ses conséquences, ses limites et, lorsque cela est pertinent, les questions qui restent ouvertes.

Les décisions actées ne doivent pas être remplacées silencieusement. Toute modification importante devra préciser ce qui change et pourquoi. Les choix encore prématurés doivent rester identifiés comme étant à définir afin de ne pas transformer une hypothèse de travail en contrainte architecturale involontaire.

Pour les décisions techniques structurantes, la spécification pourra être complétée ultérieurement par des Architecture Decision Records dans un répertoire dédié. La spécification restera le document de synthèse et pointera vers ces décisions détaillées.

## 1. Vision du projet

Le projet consiste à construire un jumeau numérique calculé d'un data center. Il ne s'agit pas uniquement d'une maquette 3D, mais d'un système capable de représenter les équipements, de calculer leur comportement physique, d'injecter des pannes et d'observer leurs conséquences techniques et humaines dans le temps.

La visualisation 3D doit permettre d'inspecter un data center très détaillé, jusqu'aux équipements, câbles, tableaux, tuyauteries, baies et composants de refroidissement. Cette représentation doit rester liée à des modèles de simulation externes qui demeurent les sources de vérité de leur domaine.

L'objectif à long terme est de couvrir le cycle complet de fonctionnement d'un data center, depuis l'arrivée électrique et la production de froid jusqu'à la charge informatique, la sécurité du bâtiment, les automatismes et les interventions humaines.

## 2. Finalité et positionnement du projet

Le projet a pour finalité de créer un démonstrateur public de jumeau numérique professionnel prenant comme système de référence un data center complexe. Il doit prouver la capacité de l'entreprise à construire une représentation 3D détaillée et sémantiquement structurée d'un environnement technique, à intégrer plusieurs domaines physiques et opérationnels, à connecter des modèles de simulation spécialisés et à rendre compréhensibles les interactions, les données et la propagation des événements.

Le data center est retenu parce qu'il concentre dans un même système le bâtiment, l'électricité, l'hydraulique, la thermique, l'informatique, les automatismes, la sécurité, la maintenance et les interventions humaines. Il constitue un cas d'étude particulièrement exigeant permettant de démontrer des compétences transférables aux bâtiments intelligents, aux installations industrielles, aux infrastructures énergétiques et aux autres systèmes techniques de futurs clients.

La finalité commerciale n'est pas de vendre uniquement un produit spécialisé dans les data centers. Le projet doit constituer une pièce de référence pour positionner l'entreprise comme concepteur et intégrateur de jumeaux numériques professionnels auprès de PME, de bureaux d'études, d'exploitants, d'intégrateurs techniques et de fabricants d'équipements. Chaque capacité présentée devra être reliée à un bénéfice métier compréhensible : aide à la conception, compréhension d'une installation, analyse d'une défaillance, validation d'une procédure, maintenance, formation, optimisation ou aide à la décision.

Le projet ne doit pas être présenté comme une simple personnalisation du NVIDIA DSX Blueprint. DSX et Omniverse constituent des références et des composants technologiques, tandis que la valeur propre du projet doit résider dans son modèle métier, son architecture de données, ses actifs, ses simulations, son orchestration, son explicabilité, son expérience utilisateur et sa capacité à être transposé à d'autres domaines.

Tant que le système n'est pas synchronisé avec une installation physique réelle, il doit être décrit avec précision comme un démonstrateur de jumeau numérique multiphysique ou un jumeau numérique de référence. Les données synthétiques, pré-calculées et réelles devront toujours être distinguées. L'architecture doit néanmoins être conçue pour permettre ultérieurement l'instanciation et la synchronisation de jumeaux liés à des sites réels.

Le premier incrément est une tranche verticale du système de référence : une zone de data hall contenant des baies classiques et IA, une distribution électrique représentative, une branche de refroidissement par air, une branche liquide avec CDU, des automatismes, un cockpit et le scénario transversal de perte du réseau public. Cette tranche doit traverser l'ensemble de l'architecture cible avec une granularité initiale maîtrisée ; elle n'autorise pas la création de composants jetables ou incompatibles avec l'extension au site complet.

### 2.1 Principe de diffusion publique

**Décision actée :** le site public de l'entreprise et l'application d'ingénierie Omniverse sont deux surfaces distinctes. Le site public n'exécutera pas librement une instance complète d'Omniverse Kit pour chaque visiteur. Une session Kit haute fidélité nécessite un GPU serveur, une infrastructure de streaming et des ressources qui augmentent avec le nombre de sessions. L'accès anonyme à une session GPU par visiteur introduirait des coûts, des limites de capacité, des temps d'attente, des risques de disponibilité et une complexité d'exploitation disproportionnés pour une vitrine commerciale.

Cette séparation ne doit pas créer deux produits sans relation. L'application complète demeure la source de la géométrie de référence, des simulations, des captures et des résultats. Le site public en présente une dérivation légère, contrôlée et traçable. Les deux surfaces doivent partager la même identité des équipements, la même nomenclature, la même chronologie des scénarios et la même interprétation des résultats.

Le visiteur doit pouvoir comprendre la proposition de valeur et constater la profondeur du travail sans disposer d'un GPU NVIDIA, sans installer de logiciel et sans dépendre de la disponibilité d'un service de calcul. Une vidéo seule ne sera toutefois pas considérée comme suffisante : l'expérience publique doit conserver une part d'exploration et d'interaction.

### 2.2 Chaîne de publication d'une simulation

Les scénarios présentés publiquement seront calculés en amont par la plateforme d'ingénierie faisant autorité. Le moteur de co-simulation, les solveurs et l'application Omniverse produiront un run reproductible. Ce run sera transformé par un pipeline de publication en un artefact Web allégé que le site pourra rejouer sans relancer les calculs physiques.

Chaque scénario publié devra être associé à un manifeste contenant au minimum :

- un identifiant immuable du run ;
- le nom et la version du scénario ;
- la version du moteur, des solveurs, des modèles et des contrats de données ;
- la version de la scène ou de l'assemblage OpenUSD utilisé ;
- les paramètres initiaux et les hypothèses significatives ;
- l'origine des données, distinguant clairement données synthétiques, données mesurées, données constructeur et résultats calculés ;
- l'horloge simulée, la durée, les pas d'échantillonnage publiés et la graine aléatoire lorsqu'elle existe ;
- les contrôles de validation exécutés et leur résultat ;
- les limites d'interprétation connues ;
- une empreinte ou un mécanisme équivalent permettant de détecter une modification de l'artefact publié.

L'artefact Web contiendra uniquement les informations nécessaires au récit public : états des équipements, mesures sélectionnées, alarmes, événements, relations causales, courbes et transformations visuelles. Les données internes inutiles, sensibles, propriétaires ou trop volumineuses ne devront pas être publiées. Les données affichées sur le site devront rester rattachables au run d'origine.

Le lecteur Web rejouera ces résultats de façon déterministe. Il ne recalculera pas la physique et ne devra jamais présenter une interpolation graphique comme un nouveau résultat de simulation. Si une valeur est interpolée uniquement pour fluidifier l'animation, cette interpolation devra rester visuelle et ne pas altérer les valeurs techniques affichées.

### 2.3 Expérience attendue sur le site public

Le site public devra proposer deux niveaux de lecture complémentaires. Un parcours guidé expliquera rapidement le problème, le fonctionnement du jumeau, l'événement simulé, sa propagation et les décisions possibles. Un mode d'exploration permettra ensuite au visiteur d'inspecter librement les éléments rendus publics.

L'expérience publique devra progressivement permettre de :

- observer une représentation 3D optimisée du périmètre présenté ;
- lancer, arrêter, accélérer et déplacer la chronologie d'un scénario pré-calculé ;
- sélectionner un équipement et consulter son identité, sa fonction, ses connexions et les variables rendues publiques ;
- afficher ou masquer les principaux systèmes, notamment les couches électriques, thermiques, hydrauliques et informatiques lorsqu'elles existent dans le scénario ;
- suivre les événements, alarmes et changements d'état synchronisés avec la scène ;
- visualiser des courbes et indicateurs reliés aux équipements sélectionnés ;
- comprendre la chaîne causale d'un événement plutôt que de constater uniquement son effet final ;
- comparer, lorsque le scénario le permet, un état nominal, un état dégradé et l'effet d'une action corrective ;
- accéder à une explication de la méthode de calcul, de la provenance des données et des limites du modèle ;
- demander une démonstration complète ou prendre contact avec l'entreprise.

L'expérience devra rester utilisable lorsque la 3D avancée n'est pas disponible. Une vidéo, des captures, des schémas et les explications essentielles constitueront un mode de repli. L'absence de WebGL/WebGPU, un navigateur peu performant ou un appareil mobile ne devront pas rendre la page incompréhensible.

Le visualiseur Web 3D est un support marketing dérivé et non une nouvelle source de vérité. Il utilise React Three Fiber et Three.js pour charger des artefacts glTF/GLB produits depuis la scène OpenUSD, avec compression, instanciation, niveaux de détail et chargement progressif. Cette chaîne privilégie le temps de chargement, la stabilité, l'accessibilité et la compatibilité avant le photoréalisme maximal.

### 2.4 Démonstration haute fidélité

La démonstration complète sera exécutée sur le poste de développement ou sur une machine GPU dédiée. Elle conservera la scène OpenUSD complète, le rendu RTX, les outils d'inspection et, selon le cas présenté, l'accès aux moteurs de simulation ou à leurs résultats complets.

Elle pourra être montrée selon quatre modes : capture vidéo préparée, partage d'écran pendant un rendez-vous, démonstration locale sur une machine maîtrisée, ou session WebRTC temporaire créée à la demande. Le streaming ne constitue pas une dépendance de la vitrine publique. Il sera réservé aux prospects qualifiés, partenaires, évaluateurs ou démonstrations nécessitant une interaction directe avec l'application complète.

Une démonstration en direct devra disposer d'un scénario de repli enregistré afin qu'un problème réseau, GPU ou logiciel ne fasse pas échouer la présentation commerciale. Les démonstrations devront utiliser des données autorisées à être montrées et ne jamais exposer de secrets, jetons, chemins internes, informations client ou contenus dont les droits de diffusion ne sont pas établis.

### 2.5 Preuves de compétence et différenciation

La différenciation ne reposera pas uniquement sur la qualité graphique. Le projet devra apporter trois niveaux de preuve cohérents.

La preuve visuelle doit démontrer la qualité de la représentation, la lisibilité des systèmes, la cohérence de l'interface et la capacité à expliquer une installation complexe. La preuve technique doit montrer que les équipements possèdent une identité, des propriétés et des connexions, que les états proviennent de modèles identifiables et que les simulations sont reproductibles. La preuve métier doit expliquer quelle décision le jumeau permet de prendre, quel risque il réduit et comment la même méthode peut être transposée à une installation cliente.

Le site devra progressivement exposer une partie vérifiable du travail sous la forme de diagrammes d'architecture, extraits de modèles, contrats de données, hypothèses, tests, comparaisons, métriques de performance, contrôles de conservation, analyses d'incertitude et limites connues. Les informations présentées devront être suffisamment précises pour convaincre un interlocuteur technique sans livrer de propriété intellectuelle sensible.

La fonctionnalité distinctive prioritaire sera l'explicabilité de la propagation. Le système ne devra pas seulement afficher qu'une valeur est anormale ; il devra pouvoir relier l'événement initiateur, les dépendances traversées, les changements d'état, les délais, les conséquences physiques, les alarmes et les actions possibles. Cette chaîne devra être construite à partir des événements et relations du jumeau, et non uniquement ajoutée sous la forme d'un texte marketing indépendant du calcul.

### 2.6 Stratégie de contenu et construction de la réputation

Le projet ne doit pas rester invisible jusqu'à l'achèvement de sa vision complète. Chaque incrément techniquement cohérent pourra produire plusieurs supports : démonstration courte, article d'architecture, vidéo, capture commentée, extrait de code publiable, mesure de performance, retour d'expérience ou comparaison entre deux approches.

Ces contenus devront montrer la progression réelle du projet et expliquer les problèmes résolus : création d'un actif SimReady, structuration OpenUSD, optimisation géométrique, modèle électrique, modèle thermo-hydraulique, orchestration temporelle, publication d'un scénario, visualisation causale ou validation d'un résultat. Le contenu ne devra pas exagérer le niveau de maturité atteint.

Le dépôt public éventuel ne devra pas nécessairement contenir l'intégralité du produit. Une stratégie d'ouverture sera définie ultérieurement pour publier les éléments qui renforcent la crédibilité et facilitent les échanges avec les communautés OpenUSD, Omniverse, BIM et simulation, tout en conservant les composants constituant la valeur commerciale propre de l'entreprise.

### 2.7 Transférabilité vers de futurs clients

L'architecture et la communication devront distinguer les éléments propres au data center des capacités génériques de la plateforme. L'identité des actifs, les connexions, la chronologie, l'historisation, l'orchestration, la publication Web, l'inspection, l'explicabilité et les contrats de données doivent pouvoir être réutilisés pour d'autres installations.

Le data center constituera le projet phare démontrant la profondeur. Des démonstrateurs secondaires plus petits pourront ultérieurement prouver la largeur du positionnement, par exemple sur une chaufferie, un atelier, un bâtiment technique, une installation énergétique ou un équipement industriel. Ces démonstrateurs ne devront pas être lancés avant que le socle commun soit suffisamment stable pour éviter la dispersion.

### 2.8 Limites et engagements de communication

Le site ne devra pas qualifier de « temps réel », « prédictif », « validé », « physiquement exact » ou « connecté » une capacité qui ne répond pas effectivement à cette description. Les simulations pré-calculées devront être identifiées comme telles. Les données synthétiques ne devront pas être présentées comme des mesures provenant d'un site réel.

Le projet n'a pas pour objectif de reproduire toutes les fonctionnalités des plateformes de NVIDIA, Schneider Electric, ETAP, Cadence, Siemens, Dassault Systèmes ou d'autres éditeurs. Il doit démontrer une capacité d'intégration, de développement et de résolution de problèmes adaptée à des missions sur mesure. Les produits tiers doivent rester identifiables et leurs apports ne doivent pas être présentés comme des développements propriétaires.

La qualité professionnelle sera évaluée autant par la clarté des limites, la provenance des données, la validation et la maintenabilité que par le niveau de détail visuel.

### 2.9 Couverture obligatoire du cycle de vie

**Décision actée :** la vision finale doit couvrir toutes les phases pertinentes du cycle de vie d'une installation technique : conception, construction et intégration, vérification de l'installation, commissioning, exploitation nominale et dégradée, supervision, maintenance, formation, modification, extension, rénovation et fin de vie. Ces phases ne sont pas optionnelles dans la cible du projet.

La stratégie incrémentale déterminera uniquement l'ordre dans lequel ces capacités seront conçues, validées et rendues visibles. Elle ne devra pas transformer les phases livrées plus tard en simples intentions sans architecture prévue. Les identités d'actifs, les versions, les états de configuration, la provenance des données et les contrats d'intégration devront être pensés pour préserver la continuité entre les phases.

La notion de qualité parfaite ne sera pas utilisée comme une affirmation subjective. Pour chaque phase, la spécification devra définir les utilisateurs concernés, les décisions soutenues, les données nécessaires, les fonctions attendues, le niveau de fidélité, les méthodes de vérification et de validation, les limites admissibles et les critères d'acceptation. Une phase ne sera considérée comme professionnellement couverte que lorsque ces critères auront été satisfaits et documentés.

## 3. Offre, utilisateurs et ConOps commerciaux

### 3.1 Positionnement élargi de l'entreprise

**Décision actée :** l'offre de l'entreprise ne doit pas être limitée aux jumeaux numériques 3D multiphysiques. Elle couvre plus largement la création de couches numériques pour des produits, équipements, bâtiments et installations physiques. Le niveau de sophistication retenu doit dépendre du problème client et de la valeur recherchée, et non de la volonté d'utiliser systématiquement l'expression « jumeau numérique ».

La formulation de référence pour présenter l'activité est la suivante :

> Nous transformons les équipements, bâtiments et installations techniques en systèmes numériques connectés et interactifs. De la supervision cloud d'un produit industriel au jumeau numérique multiphysique complet, nous réunissons télémétrie, données, interfaces, géométrie 3D et simulation afin de comprendre un système, le surveiller, tester des situations et éclairer les décisions. Notre démonstrateur de data center montre jusqu'où cette approche peut être poussée.

Le data center constitue la preuve de profondeur technique et de capacité d'intégration. Il ne définit pas à lui seul le catalogue des prestations. Des missions sans représentation 3D ou sans simulation multiphysique peuvent constituer des prestations finales parfaitement adaptées lorsqu'elles résolvent le besoin du client.

### 3.2 Continuum des solutions numériques

Le projet reconnaît un continuum de solutions pouvant être proposées séparément ou progressivement : produit connecté, supervision cloud, digital shadow, diagnostic et analyse, simulation et prédiction, puis jumeau numérique multiphysique. Ce continuum sert à qualifier les capacités nécessaires ; il ne doit pas être utilisé pour dévaloriser une solution plus simple dont la valeur métier est suffisante.

Dans cette spécification, les termes sont employés de la manière suivante :

- un produit connecté est un équipement physique équipé d'une connectivité permettant d'échanger des données avec un système distant ;
- une plateforme de supervision cloud ingère, stocke et présente les états, mesures, événements, alarmes et historiques d'un équipement ou d'une flotte ;
- un digital shadow maintient automatiquement une représentation numérique à partir d'un flux allant du système physique vers le système numérique ;
- un jumeau numérique ajoute une représentation structurée synchronisée à une fréquence et une fidélité définies, ainsi que des services apportant une valeur de compréhension, de diagnostic, de simulation, de prédiction, de recommandation ou d'intervention ;
- un jumeau multiphysique combine plusieurs domaines calculés et leurs dépendances dans une représentation cohérente du système de systèmes.

La présence d'une visualisation 3D ne suffit pas à qualifier un système de jumeau numérique. Réciproquement, un jumeau utile n'a pas nécessairement besoin d'une représentation 3D photoréaliste. Le vocabulaire commercial devra décrire honnêtement le niveau de connexion, de synchronisation, de calcul et de contrôle réellement fourni.

### 3.3 Expérience de référence en produit connecté

Une mission antérieure réalisée pour CRE Technology constitue une expérience de référence pour la digitalisation d'un produit industriel. CRE Technology développe notamment des contrôleurs destinés aux groupes électrogènes et aux centrales d'énergie. L'architecture décrite pour cette mission associait des contrôleurs physiques, des box ou passerelles de communication, une transmission distante via Internet, une infrastructure VPS ou cloud et une interface Web permettant l'accès aux données à distance.

La contribution réalisée portait sur la partie cloud. Elle démontre une expérience concrète dans la prolongation numérique d'un produit physique : réception de télémétrie, représentation distante des équipements, stockage ou historisation selon le périmètre effectivement livré, conception d'une interface utilisateur et mise à disposition d'un accès distant. Le périmètre technique exact de la mission devra être documenté à partir des sources du projet avant toute publication afin de ne pas attribuer au développement des fonctions qui relevaient d'autres composants ou d'évolutions ultérieures du produit.

La mission devra être présentée comme une plateforme cloud de supervision de contrôleurs ou un digital shadow opérationnel si le flux était uniquement montant. Elle ne pourra être qualifiée de jumeau bidirectionnel que si des commandes, configurations ou interventions étaient effectivement transmises du cloud vers l'équipement dans le périmètre réalisé.

Le nom du client, les captures, l'architecture, les métriques et les détails techniques ne pourront être publiés qu'après vérification des obligations contractuelles, de la confidentialité, de la propriété intellectuelle et d'une éventuelle autorisation de communication. En l'absence d'autorisation, l'expérience sera décrite de façon anonymisée comme une plateforme cloud de supervision de contrôleurs pour centrales d'énergie.

### 3.4 Familles de prospects prioritaires

Deux familles de prospects sont retenues. La première regroupe les fabricants de machines, contrôleurs, capteurs ou équipements qui souhaitent connecter leurs produits, superviser une flotte, historiser les données, gérer les alarmes, fournir un accès distant ou enrichir leur offre par un service cloud. La seconde regroupe les exploitants, bureaux d'études et intégrateurs qui souhaitent représenter, comprendre, simuler ou optimiser une installation composée de plusieurs systèmes techniques.

Ces familles partagent un socle commun de compétences : acquisition de données, edge et passerelles, protocoles industriels, identité des actifs, backend, séries temporelles, droits d'accès, interfaces, cybersécurité, historisation et connaissance des systèmes physiques. La géométrie 3D, les modèles de simulation et la co-simulation viennent enrichir ce socle lorsque le cas d'usage le nécessite.

Pour la vitrine publique, l'utilisateur principal est le décideur ou responsable technique d'une PME possédant ou fabriquant des actifs physiques. L'utilisateur secondaire est l'ingénieur, le bureau d'études, l'intégrateur ou le responsable informatique chargé d'évaluer la crédibilité et l'intégrabilité de la solution.

### 3.5 ConOps C-01 — Découverte et qualification d'un prospect

**Décision actée :** le premier ConOps commercial décrit le parcours d'un prospect depuis son arrivée sur le site jusqu'à une demande de démonstration ou un échange qualifié. Le site n'est pas une galerie 3D ; il doit permettre au prospect d'identifier son propre problème dans le démonstrateur et de comprendre pourquoi l'entreprise peut l'aider.

Le prospect peut arriver depuis un moteur de recherche, un réseau professionnel, un dépôt de code, une publication technique, un événement ou une recommandation. Il ne doit pas être supposé connaître OpenUSD, Omniverse ou la définition d'un jumeau numérique. La première vue doit expliquer le bénéfice avant les technologies et présenter le data center comme le cas de référence d'une compétence transférable.

Le parcours nominal comporte une compréhension initiale rapide, un scénario guidé, une possibilité d'exploration, une preuve technique progressive, une explication de la transférabilité et un appel à l'action. Le scénario doit d'abord montrer un état compréhensible, puis un événement, sa propagation, ses conséquences et l'effet de décisions possibles. Le visiteur doit pouvoir mettre en pause, revenir en arrière et quitter le guidage pour inspecter les éléments rendus publics.

Un décideur doit pouvoir comprendre la proposition de valeur sans lire la documentation technique. Un évaluateur technique doit pouvoir approfondir l'identité des équipements, les connexions, la provenance des données, les modèles, les versions, les tests, les hypothèses et les limites. Ces deux niveaux de lecture doivent rester cohérents et ne pas produire deux discours contradictoires.

L'appel à l'action de référence est une invitation à discuter de l'installation du prospect et à identifier un premier cas d'usage. La prise de contact pourra mener à un rendez-vous de découverte ou à une démonstration haute fidélité. Les informations demandées devront rester limitées aux éléments utiles à la qualification, notamment le secteur, le type d'actif ou d'installation, le problème principal, les données disponibles et les coordonnées de contact.

La réussite ne sera pas évaluée uniquement par le trafic. Les indicateurs devront mesurer la compréhension et l'intention : lancement et achèvement du parcours, inspection d'un équipement, consultation des preuves techniques, exploration d'une application transférable, demande de démonstration et qualité des demandes reçues. Si les retours portent uniquement sur une « belle animation 3D », le ConOps sera considéré comme incomplet.

### 3.6 ConOps C-02 — Évaluation technique et démonstration haute fidélité

**Décision actée :** le second ConOps commercial commence lorsqu'un prospect qualifié ou son référent technique souhaite évaluer la profondeur du système. La démonstration est conduite sur une instance maîtrisée de l'application complète, localement, par partage d'écran ou par session WebRTC temporaire.

L'interlocuteur doit pouvoir observer la scène OpenUSD complète, inspecter les actifs, suivre les connexions, consulter les états et résultats, rejouer un scénario, examiner sa chaîne causale et comprendre le rôle des différents composants logiciels. Lorsque le périmètre le permet, la démonstration doit distinguer ce qui est calculé en direct, pré-calculé, synthétique ou issu d'une donnée réelle.

La démonstration doit être adaptée au problème du prospect sans prétendre être déjà un prototype de son installation. Elle doit se conclure par l'identification d'un cas d'usage candidat, des données nécessaires, du niveau de fidélité utile, des principales inconnues et de la prochaine étape possible. Une présentation enregistrée et des résultats pré-calculés doivent rester disponibles comme solution de repli en cas de problème technique.

## 4. Périmètre, environnement et domaines fonctionnels

### 4.1 Système d'intérêt et principe de complétude

**Décision actée :** le système d'intérêt est un data center de référence considéré comme un système de systèmes. Il comprend son site, ses bâtiments et zones techniques, ses équipements électriques, ses systèmes thermiques et hydrauliques, ses charges informatiques, ses réseaux internes, ses automatismes, sa supervision, sa sécurité, ses procédures et les acteurs humains nécessaires à son fonctionnement.

La complétude du jumeau ne signifie pas que tous les systèmes extérieurs doivent être reproduits sans limite. Elle signifie que tous les éléments nécessaires pour répondre aux usages et décisions définis doivent être représentés avec un niveau de fidélité justifié. Tout élément influent situé hors de cette frontière devra être identifié comme dépendance externe, condition aux limites ou service extérieur.

Un actif peut être présent géométriquement sans disposer immédiatement d'un modèle de comportement détaillé. La spécification et l'interface devront distinguer explicitement la fidélité géométrique, la richesse sémantique, la connectivité, la disponibilité des données et la fidélité physique. La présence visuelle d'un équipement ne devra jamais laisser entendre qu'il est calculé à un niveau qui n'existe pas.

### 4.2 Hiérarchie spatiale et fonctionnelle

Le système devra être organisé selon une hiérarchie stable permettant de raisonner et de charger la scène à plusieurs échelles. La hiérarchie de référence partira du site, puis des bâtiments et infrastructures extérieures, des zones et salles, des systèmes techniques, des équipements, des sous-équipements et, lorsque le cas d'usage le justifie, des composants.

Cette hiérarchie ne doit pas imposer qu'un même niveau de détail soit chargé partout. Les actifs devront pouvoir être représentés par plusieurs niveaux de détail géométrique et plusieurs niveaux de fidélité fonctionnelle. Une vue de site pourra manipuler des agrégats tandis qu'une analyse locale pourra charger la salle, la baie ou le composant concerné.

Les hiérarchies spatiale, fonctionnelle et organisationnelle ne seront pas confondues. Un équipement possède un emplacement physique, appartient à un ou plusieurs systèmes fonctionnels et relève d'une responsabilité d'exploitation. Ces relations devront être modélisées séparément afin de permettre les recherches, analyses de dépendance et contrôles d'accès.

### 4.3 Environnement et dépendances externes

Les éléments externes susceptibles d'influencer le data center devront être recensés et reliés au système par des interfaces explicites. Ils comprennent notamment le réseau électrique public, les conditions météorologiques, l'approvisionnement en eau, les livraisons de combustible, les réseaux de télécommunication, les services cloud externes, les prestataires, les secours publics et les chaînes d'approvisionnement pertinentes.

Une dépendance externe pourra être représentée par une donnée imposée, un profil temporel, un modèle de frontière, un service connecté ou un modèle simplifié. La méthode choisie devra correspondre au cas d'usage. Par exemple, le réseau public pourra fournir tension, fréquence, puissance disponible et événements de défaut sans imposer la simulation de toutes les centrales qui l'alimentent. La météo pourra être fournie par un fichier climatique, une série synthétique ou une source réelle sans être calculée par le jumeau.

Les éléments situés de part et d'autre d'une frontière devront être distingués. Le réservoir de carburant, son niveau et la consommation des groupes appartiennent au système ; l'entreprise qui le remplit reste externe, mais son délai d'intervention peut être modélisé. Le réseau informatique interne appartient au système ; Internet et les services tiers sont représentés par leurs propriétés de disponibilité, de capacité, de latence ou de panne lorsque cela est nécessaire.

### 4.4 Frontières de modélisation

La frontière physique définit les terrains, bâtiments, locaux, réseaux et équipements représentés. La frontière fonctionnelle définit les phénomènes et fonctions réellement calculés. La frontière des données précise les informations disponibles, leur source, leur qualité, leur fréquence, leurs droits d'utilisation et leur caractère synthétique, mesuré, constructeur ou calculé.

La frontière temporelle doit permettre de combiner plusieurs échelles : phénomènes électriques rapides, séquences d'automates, dynamiques thermiques, autonomie énergétique, interventions humaines, maintenance et évolution sur le cycle de vie. Aucun pas de temps unique ne sera supposé adapté à tous les domaines.

La frontière d'autorité définit la source de vérité de chaque information. OpenUSD pourra porter l'existence, la composition et la représentation spatiale d'un actif ; le registre d'actifs portera son identité métier ; les solveurs porteront les comportements physiques de leur domaine ; PostgreSQL et TimescaleDB porteront les configurations, événements et séries persistantes. Les règles de résolution des incohérences devront être définies avant toute synchronisation avec un site réel.

La frontière de sécurité sépare les données publiques, les informations d'ingénierie, les données opérationnelles sensibles et les commandes susceptibles d'affecter un équipement. Le site vitrine ne recevra qu'un sous-ensemble explicitement publié. Une future connexion OT devra appliquer des règles d'identité, d'autorisation, de journalisation et de segmentation adaptées à son niveau de risque.

### 4.5 Contexte géographique et normatif de référence

**Décision actée :** le démonstrateur représente un site fictif localisé en France métropolitaine. Il doit être techniquement cohérent avec un contexte français et européen, sans reproduire un site réel sensible. La plateforme devra rester paramétrable afin que de futurs jumeaux puissent utiliser d'autres localisations, climats, tensions, réglementations et pratiques d'ingénierie.

Le référentiel d'infrastructure s'appuiera sur la famille ISO/IEC 22237 et son pendant européen EN 50600, en sélectionnant explicitement les parties applicables au bâtiment, à l'alimentation, au contrôle environnemental, au câblage, à la sécurité et aux informations d'exploitation. Les systèmes électriques et équipements utiliseront les normes IEC pertinentes, dont IEC 60909 pour les études de court-circuit lorsqu'elle s'applique. ASHRAE 90.4-2025 et les guides TC 9.9 encadreront les hypothèses énergétiques et les enveloppes thermiques ; les publications Open Compute Project pourront compléter la conception du refroidissement liquide haute densité sans être présentées comme des normes réglementaires.

Les indicateurs énergétiques et environnementaux seront définis selon la famille ISO/IEC 30134, notamment PUE, CUE, WUE, CER et réutilisation d'énergie. Chaque indicateur devra déclarer sa frontière de mesure, sa période, ses compteurs, ses exclusions, son caractère simulé ou observé et sa méthode d'agrégation. Aucun « PUE instantané » ou indicateur comparable ne sera affiché comme une valeur universelle sans ces informations. ISO/IEC 30173:2023 fournira le vocabulaire de cadrage du jumeau numérique, de ses acteurs et de son cycle de vie ; elle ne remplacera pas les normes physiques ni les critères de validation propres aux domaines.

Les exigences réglementaires et pratiques françaises applicables au bâtiment, à l'électricité, à l'incendie, à l'environnement, à la sécurité et au travail devront être identifiées au fur et à mesure des domaines traités. Une matrice de conformité reliera chaque exigence réellement appliquée à son édition, son périmètre, son interprétation, sa preuve et son responsable.

Les normes constituent des références d'exigences et de terminologie ; leur simple mention ne vaudra pas déclaration de conformité. Toute affirmation de conformité devra préciser l'édition, le périmètre, les clauses évaluées, les preuves disponibles et l'autorité compétente. Les exigences contradictoires ou dépendantes d'une juridiction devront être isolées dans des profils configurables.

### 4.6 Contraintes structurantes connues

Le développement principal doit rester exécutable sur la machine actuelle, équipée de 64 Go de mémoire et d'un GPU NVIDIA RTX 5090 Laptop disposant d'environ 24 Go de VRAM. L'absence de RTX Pro 6000 ne doit pas empêcher le développement. Elle impose une architecture exploitant les payloads OpenUSD, l'instanciation, les niveaux de détail, le chargement partiel, l'optimisation des textures et la séparation des calculs lourds.

La machine actuelle permet le développement Kit, OpenDSS, Modelica, PostgreSQL et des cas CFD de taille moyenne, mais elle n'est pas la cible d'exécution simultanée de toutes les fidélités maximales. OpenFOAM sera exécuté sous WSL2 ou Linux et les campagnes volumineuses devront être exportables vers une station, un serveur ou un environnement HPC sans changer le manifeste de run. Le pilote NVIDIA, la version Kit et les extensions seront verrouillés sur une combinaison validée ; une mise à niveau sera précédée d'un smoke test de la scène, du rendu et du streaming. Hardware-Accelerated GPU Scheduling sera traité comme un paramètre contrôlé si Kit ou WebRTC présente des gels.

L'application Omniverse complète ne sera pas exécutée librement par chaque visiteur du site public. La diffusion Web reposera sur des résultats pré-calculés et une représentation dérivée légère ; les sessions GPU haute fidélité seront réservées aux démonstrations maîtrisées.

Le projet ne dispose pas initialement d'un data center physique instrumenté ni de l'ensemble des données constructeurs nécessaires. Le site de référence utilisera donc des données publiques, des hypothèses documentées, des profils synthétiques et des modèles ouverts ou autorisés. Chaque hypothèse devra pouvoir être remplacée ultérieurement par une donnée plus fiable sans casser l'identité de l'actif ni les contrats de simulation.

Les droits de diffusion des modèles CAD, assets OpenUSD, textures, données fabricants, contenus NVIDIA et résultats de logiciels commerciaux devront être vérifiés avant toute publication. Chaque ressource devra disposer d'une provenance et d'un statut d'utilisation connus. Une ressource sans droit de diffusion établi ne pourra pas être intégrée à l'artefact public.

### 4.7 Mission opérationnelle et services informatiques

**Décision actée :** le data center fictif de référence est orienté AI factory et calcul haute performance. Sa mission est de fournir une capacité de calcul, de réseau et de stockage à plusieurs catégories de services dont les exigences de continuité, de performance et de flexibilité sont différentes. La mission n'est pas liée définitivement à une génération ou une référence commerciale précise de GPU afin de permettre l'évolution du démonstrateur.

Le modèle informatique doit donner une cause physique aux consommations des baies. Les workloads déterminent l'utilisation des ressources CPU, GPU, mémoire, stockage et réseau ; cette utilisation produit une demande électrique et une charge thermique ; les capacités électriques et thermiques disponibles contraignent en retour le placement, la puissance et la continuité des workloads. Cette boucle doit être explicitement représentée et traçable.

La chaîne causale de référence est la suivante : workload, allocation des ressources informatiques, consommation électrique, production de chaleur, demande de refroidissement, contraintes physiques, puis éventuelle décision de maintien, déplacement, réduction, suspension ou arrêt contrôlé du workload.

### 4.8 Classes de workloads et criticité

Trois classes initiales de services sont retenues.

La première regroupe les entraînements IA et calculs batch intensifs. Ces tâches peuvent consommer une puissance élevée et fonctionner longtemps, mais certaines pourront être ralenties, suspendues ou interrompues selon des politiques définies. Leur état devra pouvoir être protégé au moyen de checkpoints ou d'un mécanisme abstrait équivalent lorsque le scénario le nécessite.

La deuxième regroupe les charges d'inférence ou services critiques. Elles possèdent des exigences plus strictes de disponibilité, de capacité et de latence. Une dégradation physique devra pouvoir être traduite en capacité de service perdue, en risque sur un objectif de niveau de service ou en nécessité de déplacer la charge.

La troisième regroupe les services d'infrastructure indispensables : contrôle, supervision, orchestration, réseau de gestion, stockage nécessaire à l'intégrité ou à la reprise, authentification et autres services permettant de maintenir le site dans un état exploitable. Leur consommation peut être plus faible, mais leur criticité fonctionnelle peut être supérieure à celle d'une partie du calcul utilisateur.

Chaque workload devra posséder au minimum une identité, une classe, une priorité, une demande de ressources, une localisation ou allocation courante, un profil de puissance, une production thermique dérivée, un état d'exécution, des conditions de réduction ou d'interruption, des exigences de reprise et les objectifs de service auxquels il contribue.

### 4.9 Objectifs de service et conséquences métier

Les objectifs devront progressivement couvrir la disponibilité du service, la capacité de calcul fournie, le débit, la latence lorsque pertinente, l'intégrité des données, le nombre et la nature des tâches interrompues, la durée de récupération, la consommation d'énergie et le respect des enveloppes physiques.

Une exigence de disponibilité ne pourra pas rester formulée de manière absolue. Elle devra préciser le service concerné, la proportion minimale de capacité attendue, la durée admissible de dégradation, les conditions de mesure et les conséquences lorsque la limite est dépassée.

Les résultats physiques devront être traduits en effets opérationnels. Une température, une puissance indisponible ou un débit insuffisant devra pouvoir être relié à une réduction de fréquence, une perte de capacité, un allongement de traitement, un risque sur un service, une suspension, une migration ou un arrêt sécurisé. Cette traduction entre physique et métier est une capacité structurante du démonstrateur.

Les valeurs numériques des objectifs de service ne sont pas encore actées. Elles devront être choisies après définition de l'architecture de référence, des scénarios, des données disponibles et des méthodes de validation. Aucune valeur arbitraire ne devra être présentée comme un SLA industriel réel.

### 4.10 Modes opérationnels et résilience

Le système devra représenter au minimum des régimes nominaux, des régimes de charge réduite, des maintenances planifiées, des états dégradés, des phases de récupération et des arrêts sécurisés. Les modes impliquant une autonomie vis-à-vis d'une dépendance externe, comme un fonctionnement électrique îloté, seront ajoutés lorsque l'architecture concernée aura été définie.

Les transitions entre modes sont des objets de simulation à part entière. Elles doivent intégrer les délais, séquences, interverrouillages, conditions de réussite, actions humaines et conséquences sur les workloads. Une capacité nominale suffisante ne garantit pas la continuité si la transition ou le redémarrage des dépendances échoue.

La résilience est définie comme la capacité à absorber une perturbation, conserver un niveau de service acceptable, maîtriser la dégradation, récupérer et revenir vers un état contrôlé. Elle dépend de la topologie physique, des automatismes, des capacités restantes, des workloads, des procédures, des personnes, des pièces, des prestataires et des dépendances externes.

Les référentiels de disponibilité ou de résilience, notamment ceux d'Uptime Institute et d'ISO/IEC 22237, pourront guider la conception et les critères. Le projet ne déclarera aucun Tier, aucune classe certifiée et aucune conformité globale sans évaluation formelle du périmètre et des preuves correspondantes.

### 4.11 Réseau électrique

Le jumeau doit représenter l'arrivée haute ou moyenne tension, les transformateurs, les tableaux, les protections, les ATS, les UPS, les batteries, les groupes électrogènes, le carburant, les PDU et les charges des baies.

Les calculs doivent progressivement couvrir les flux de puissance, les tensions, les courants, les pertes, les états des protections, l'autonomie, les délais de commutation, le délestage et la propagation des défauts.

### 4.12 Refroidissement et thermique

Le jumeau doit représenter les groupes froids, les pompes, les échangeurs, les réservoirs, les tuyauteries, les vannes, les CRAC/CRAH, les CDU, les boucles de refroidissement liquide et la circulation d'air dans la salle.

Les calculs doivent progressivement couvrir les débits, les pressions, les températures, les pertes de charge, les échanges thermiques, l'inertie du système et le redémarrage des équipements après une perturbation électrique.

### 4.13 Charge informatique

La consommation des baies doit dépendre des workloads simulés. Le modèle doit distinguer les baies conventionnelles et les baies IA à haute densité, ainsi que la part de puissance électrique transformée en chaleur.

À terme, le modèle pourra exploiter des profils synthétiques, des traces de scheduler et de la télémétrie réelle provenant notamment de NVIDIA DCGM.

### 4.14 Automatismes et supervision

Le projet doit représenter les états, consignes, interverrouillages, temporisations, alarmes et séquences de redémarrage des équipements. Une interface de supervision doit permettre de suivre l'état global, de sélectionner un équipement, de consulter ses mesures et de déclencher un scénario autorisé.

### 4.15 Sécurité du bâtiment

Le périmètre final doit intégrer le contrôle d'accès, la détection incendie, l'extinction, les alarmes techniques et leurs interverrouillages. Les premiers incréments pourront utiliser des modèles événementiels ; les calculs détaillés de fumée et de chaleur pourront être ajoutés ultérieurement.

### 4.16 Couche humaine et procédurale

Le jumeau doit représenter les habilitations, les procédures, les délais de diagnostic, les déplacements, les actions autorisées et les erreurs possibles des opérateurs. Ces éléments seront exécutés sous forme d'événements déterministes ou probabilistes contrôlés.

## 5. Modèle canonique des actifs et principes d'architecture

### 5.1 Registre canonique

**Décision actée :** PostgreSQL porte le registre canonique des actifs, positions fonctionnelles, systèmes, ports, connexions, versions et mappings vers les représentations spécialisées. Ce registre fournit l'identité commune et les contrats nécessaires à l'intégration ; il ne remplace pas les sources de vérité propres à la géométrie, à la physique ou aux mesures.

Le modèle doit distinguer au minimum le type d'actif, l'instance physique, la position fonctionnelle occupée dans une architecture, la configuration applicable, les modèles de comportement disponibles et les liaisons vers les représentations externes. Cette distinction doit permettre de remplacer un appareil physique sans perdre l'historique de sa fonction, ou de déplacer un appareil sans le recréer comme une nouvelle entité.

Les opérations du registre devront être contrôlées par des migrations de schéma, des contraintes d'intégrité, des validations de compatibilité et des historiques de changement. Les imports CAD, BIM, sémantiques ou solveurs ne devront pas créer silencieusement des doublons d'actifs.

### 5.2 Identités, noms et URI

Chaque entité canonique doit posséder un identifiant technique stable et non signifiant, fondé sur un UUID. Cet identifiant ne dépend ni du nom d'affichage, ni de l'emplacement, ni du chemin OpenUSD, ni d'un identifiant de solveur. Un code fonctionnel lisible, tel que `UPS-A-01`, pourra lui être associé et évoluer selon les conventions du projet.

Les entités exposées dans le graphe sémantique devront également disposer d'une URI stable dérivée d'un espace de noms contrôlé. L'URI et l'UUID devront être reliés de façon déterministe ou par un mapping explicite. Les identifiants provenant des fabricants, du BIM, du BMS, d'OpenDSS, de Modelica, de la CFD ou d'autres systèmes seront conservés comme identifiants externes qualifiés par leur source.

Un changement de nom, de chemin de prim, de pièce, de système applicatif ou de solveur ne doit pas changer l'identité canonique. Une fusion ou séparation d'actifs devra être une opération explicite, historisée et vérifiable.

### 5.3 Séparation des catégories d'information

Le modèle doit séparer la définition, la configuration, l'état, l'observation, le résultat simulé et la commande. La définition décrit la classe et les capacités d'un équipement. La configuration décrit l'instance installée, ses paramètres, ses raccordements et ses consignes. L'état décrit sa condition à un instant donné.

Une observation est une valeur reçue d'une source physique ou externe. Un résultat simulé est produit par un modèle identifié. Une estimation ou valeur dérivée doit indiquer sa méthode de calcul. Une commande représente une intention adressée à un système et doit rester distincte de l'état effectivement observé après son exécution.

Chaque valeur temporelle doit conserver son horodatage, son unité, son statut de qualité, sa provenance et, lorsqu'elle est simulée, le run et la version du modèle responsables. Un champ générique ambigu ne devra pas mélanger consigne, mesure, prédiction et état calculé.

### 5.4 Ports, connexions et topologie

Les dépendances fonctionnelles doivent être représentées par un graphe explicite et non déduites uniquement de la géométrie. Deux objets qui se touchent visuellement ne sont pas nécessairement raccordés. Deux objets éloignés peuvent appartenir au même circuit ou système.

Les actifs connectables déclareront des ports typés. Un port devra pouvoir indiquer son domaine, le médium ou signal transporté, sa direction lorsqu'elle existe, sa capacité, ses caractéristiques nominales et les contraintes nécessaires à la validation. Les connexions relieront des ports compatibles et pourront être des actifs à part entière, par exemple un câble, un bus, une conduite, une gaine ou une liaison de données.

La topologie devra couvrir l'électricité, les fluides, l'air, les réseaux informatiques, les signaux de mesure et les commandes, tout en maintenant leurs sémantiques distinctes. Les branches, jonctions, bypass, organes d'isolement, relations de secours et chemins alternatifs devront pouvoir être représentés sans les réduire à une simple relation `feeds`.

Le graphe constituera la base des analyses de dépendance et de propagation. Les moteurs spécialisés resteront responsables des lois physiques ; le graphe canonique indiquera quels actifs, ports et systèmes participent au calcul et comment leurs identifiants correspondent.

### 5.5 Sources de vérité et mappings

OpenUSD est la source de composition de la scène d'exécution : géométrie, transformations, apparence, hiérarchie spatiale, variantes, payloads et métadonnées nécessaires à la visualisation. PostgreSQL est la source du registre métier et des mappings. TimescaleDB porte les séries temporelles persistantes. Les solveurs spécialisés portent les paramètres et comportements physiques qui relèvent de leur domaine.

Chaque prim OpenUSD représentant un actif canonique devra porter son identifiant ou URI de liaison dans une métadonnée versionnée. Les composants OpenDSS, instances et variables Modelica, régions CFD, points BMS, séries TimescaleDB, procédures et documents devront être associés au même actif par des bindings explicites.

Une information pourra être répliquée pour la performance ou l'autonomie d'un outil, mais sa source autoritaire devra être déclarée. Les copies devront être générées, synchronisées ou contrôlées ; elles ne devront pas être modifiées indépendamment sans mécanisme de réconciliation. Les conflits devront produire un diagnostic plutôt qu'une résolution silencieuse.

### 5.6 Cycle de vie et configurations

Le registre doit préserver les états `as-designed`, `as-planned`, `as-built`, `as-commissioned` et `as-operated`, ainsi que les états de maintenance, de remplacement et de retrait lorsque pertinents. Ces vues ne devront pas être stockées comme des copies intégrales indépendantes qui divergent sans contrôle ; elles devront partager les identités et exprimer les différences de configuration ou de validité.

Chaque configuration publiée devra posséder une identité, une version, une période de validité, une provenance et un statut. Une simulation devra référencer une configuration immuable ou figée afin de rester reproductible. Une modification du site réel ne devra pas réécrire les résultats historiques d'une configuration antérieure.

La provenance devra permettre de déterminer si une propriété provient d'une intention de conception, d'un fichier BIM, d'un fabricant, d'une mise en service, d'une observation terrain, d'une correction manuelle ou d'une inférence. W3C PROV-O sera étudié comme vocabulaire compatible pour exprimer cette provenance dans la projection RDF.

### 5.7 Profil sémantique ASHRAE 223P, Brick et IFC

**Décision actée :** ASHRAE Standard 223P est retenu comme cible structurante pour la sémantique opérationnelle et la topologie des systèmes du bâtiment. Le projet utilisera ses concepts d'équipement, espace, système, propriété, `ConnectionPoint`, `Connection`, médium, composition et fonction lorsqu'ils correspondent au besoin.

ASHRAE 223P représente une topologie et le contexte de données ; il ne représente pas la géométrie détaillée, ne stocke pas les séries temporelles et ne remplace pas les algorithmes de contrôle ou les solveurs physiques. Les instances seront exprimées dans un graphe RDF et validées au moyen des contraintes SHACL applicables. Les requêtes sémantiques pourront utiliser SPARQL, directement ou derrière des services applicatifs.

Au 1er août 2026, ASHRAE 223 reste un projet de norme `223P` en évolution, avec une seconde publication de revue publique en 2026. Le projet ne déclarera donc pas une conformité définitive. Chaque profil utilisé devra figer la révision, les ontologies, les formes SHACL, les extensions et les conventions du projet. Un adaptateur séparera le modèle canonique interne du vocabulaire afin de permettre les mises à jour de 223P sans migration incontrôlée de tout le produit.

Brick complétera 223P pour son vocabulaire ouvert d'équipements, de points, de systèmes et de métadonnées de bâtiment, notamment pour relier les capteurs et données opérationnelles. Brick 1.4 et les versions suivantes disposent d'une extension s'appuyant sur ASHRAE 223P pour les connexions ; la version exacte sera figée lors de l'implémentation et validée avec le profil 223P retenu.

IFC 4.3 reste la référence ouverte d'échange BIM pour la géométrie, les espaces, les systèmes et les objets de conception. Une Information Delivery Specification, IDS, exprimera les entités, classifications, propriétés et relations exigées par chaque import. IfcOpenShell et IfcTester contrôleront le schéma IFC, les règles EXPRESS applicables et l'IDS avant création ou mise à jour d'actifs. bSDD pourra relier les propriétés à des dictionnaires et identifiants normalisés. Un fichier visuellement correct mais invalide, incomplet ou ambigu selon l'IDS ne sera pas accepté silencieusement.

IFC et 223P sont complémentaires : IFC fournit la couche produit et géométrique, tandis que 223P fournit la couche sémantique opérationnelle et la topologie destinée aux applications. En l'absence de mapping normatif universel entre les deux, les correspondances devront être explicites, contrôlées, versionnées et accompagnées d'un rapport d'import. Project Haystack pourra être pris en charge par un adaptateur pour intégrer des BMS existants, mais ne deviendra pas un modèle canonique concurrent. RealEstateCore et l'Asset Administration Shell ne seront ajoutés que lorsqu'un cas client de portefeuille immobilier, d'équipement industriel ou de passeport numérique le justifiera.

Le graphe RDF ne remplacera pas PostgreSQL ni TimescaleDB. Il constituera une projection sémantique interopérable du registre et des références vers les sources de données. La stratégie de stockage du graphe, dans PostgreSQL ou dans un moteur RDF séparé, reste à décider après un prototype et des mesures de performance.

### 5.8 Registre des modèles et niveaux de fidélité

Un actif ou un système pourra être associé à plusieurs modèles : état discret, équation analytique, courbe constructeur, modèle dynamique Modelica, réseau OpenDSS, domaine CFD, modèle réduit ou surrogate IA. Chaque modèle devra déclarer son domaine, ses entrées, ses sorties, ses unités, sa version, ses paramètres, son coût de calcul, ses hypothèses, son domaine de validité et ses preuves de validation.

Le choix d'un modèle dépendra du scénario, de l'échelle temporelle et de la décision recherchée. Le moteur ne devra pas sélectionner automatiquement le modèle le plus détaillé comme s'il était toujours le plus approprié. Les échanges entre fidélités devront préserver les bilans, unités et identités, et documenter les approximations introduites.

Un surrogate IA ne pourra être présenté comme remplaçant un modèle physique que dans son domaine de validité et après comparaison avec des données ou simulations de référence. Les extrapolations devront être détectées ou signalées.

### 5.9 Séparation des responsabilités

OpenUSD assemble la représentation du data center, mais ne remplace ni les solveurs ni la base de données. Omniverse Kit affiche et manipule la scène, mais n'est pas la source de vérité des calculs. React constitue le poste de contrôle, mais ne calcule pas la physique. Le moteur d'orchestration synchronise les domaines, mais ne réécrit pas les solveurs spécialisés.

Chaque domaine conserve sa propre source de vérité : OpenDSS pour le réseau électrique opérationnel RMS, Modelica pour les systèmes thermiques et les régulations, OpenFOAM pour la CFD, PostgreSQL et TimescaleDB pour les données persistantes, et le moteur C++ pour le cycle de vie des runs, les scénarios, les événements métier, l'audit et l'état global de la co-simulation. L'algorithme de synchronisation entre solveurs pourra être confié à une infrastructure spécialisée après décision d'architecture ; la responsabilité produit du moteur C++ ne suppose pas qu'il réimplémente seul toutes les fonctions d'un master de co-simulation.

### 5.10 Simulation déterministe et rejouable

Une simulation doit être reproductible à partir de sa configuration, de ses paramètres, de sa version de modèles et de sa graine aléatoire. Tous les événements importants doivent être horodatés sur l'horloge virtuelle et conservés afin de pouvoir rejouer et comparer un scénario.

### 5.11 Simulation multi-fidélité

Le projet doit accepter plusieurs niveaux de fidélité. Un modèle analytique ou agrégé doit permettre une exécution rapide. Un modèle Modelica doit apporter une dynamique plus réaliste. Une campagne CFD doit produire des résultats détaillés hors ligne. Un surrogate IA ne pourra être utilisé qu'après validation sur des résultats physiques fiables.

### 5.12 Modèles de domaine et contrats d'échange

**Décision actée :** le jumeau numérique ne sera pas développé comme un simulateur physique monolithique. Il sera composé de modèles de domaine spécialisés, vérifiables et remplaçables, coordonnés par le produit d'orchestration C++. La topologie canonique décrit les éléments et leurs relations ; les modèles de domaine calculent leur comportement.

Le découpage initial comprend le réseau électrique, les systèmes thermiques et hydrauliques, la circulation d'air, les ressources informatiques et leurs workloads, les automatismes, les systèmes de sécurité ainsi que les opérateurs et procédures. Ce découpage pourra être affiné, mais une même loi physique ne devra pas être implémentée simultanément dans plusieurs domaines sans source autoritaire et règle de synchronisation explicites.

Chaque domaine devra déclarer son périmètre, ses hypothèses, ses variables d'état, ses paramètres, ses entrées, ses sorties, ses unités, ses événements, son pas de calcul, son domaine de validité, ses critères de convergence et sa stratégie de validation. Il devra également préciser le comportement attendu lorsque ses données d'entrée sont absentes, périmées, incohérentes ou situées hors de son domaine de validité.

Les échanges entre domaines seront définis par des contrats versionnés. Un contrat devra identifier les actifs et ports canoniques concernés, la signification physique de chaque variable, son unité SI, son sens, son horodatage dans le temps simulé, sa qualité, sa provenance, sa fréquence de mise à jour et les conditions qui déclenchent un échange. Les conversions d'unités, agrégations et changements de résolution devront être explicites et testés.

Le couplage de référence suit la chaîne causale suivante : le modèle informatique calcule l'activité des ressources, leur consommation électrique et la chaleur dissipée ; le modèle électrique calcule la disponibilité et la qualité de l'alimentation ainsi que les limites imposées aux charges ; les modèles thermiques, hydrauliques et aérauliques calculent la capacité de refroidissement et les températures résultantes ; les automatismes et politiques informatiques réagissent en modifiant les consignes, les équipements actifs, le placement des workloads ou leur niveau de puissance. La nouvelle charge ferme alors la boucle de calcul.

Le moteur C++ est responsable du manifeste, du scénario, du cycle de vie du run, de la file d'événements métier, des reprises, des délais opérationnels, de la détection des erreurs d'intégration et de la traçabilité. Le mécanisme chargé d'accorder le temps aux modèles et de transporter leurs échanges sera choisi après un prototype comparant HELICS, OMSimulator avec SSP et une boucle C++ minimale. La décision mesurera le déterminisme, les événements simultanés, les pas variables, les boucles fortement couplées, les checkpoints, les diagnostics, la performance et la complexité de distribution. Le projet n'adoptera pas une infrastructure de co-simulation uniquement pour sa richesse fonctionnelle, mais n'écrira pas non plus un master propriétaire sans démontrer que les solutions existantes sont insuffisantes.

FMI 2.0.5 constitue la baseline de production pour les FMU tant que l'export et l'import FMI 3.0.2 ne sont pas démontrés stables sur le couple d'outils verrouillé. FMI 3.0.2 reste la cible pour les nouveaux modèles qui bénéficient de ses horloges, types et Scheduled Execution ; une FMU ne sera promue à cette cible qu'après validation de schéma, import réel et scénarios d'événements. SSP 2.0.1 décrira et empaquetera les composants, connexions, unités, paramètres et métadonnées d'un système de co-simulation. SSP reste un format d'échange et de reproduction : il ne remplace ni le registre canonique, ni le scénario métier, ni le manifeste de preuve.

Une exécution ne devra pas continuer silencieusement avec une valeur invalide ou un solveur défaillant. Selon le contrat concerné, le moteur devra interrompre le run, employer un mode dégradé explicitement autorisé, conserver la dernière valeur valide pendant une durée limitée ou produire un état indéterminé accompagné d'un diagnostic. Le choix devra être documenté par domaine et visible dans les résultats.

La validation portera à la fois sur chaque modèle isolé et sur les couplages. Les interfaces devront notamment respecter les bilans d'énergie et de masse applicables, la cohérence des unités, l'ordre causal des événements et la reproductibilité. Un scénario de bout en bout ne pourra être considéré crédible si ses domaines sont individuellement plausibles mais que leurs échanges créent ou détruisent silencieusement de l'énergie, ignorent un délai ou utilisent des états provenant de temps simulés incompatibles.

### 5.13 Modèle du domaine électrique

**Décision actée :** le domaine électrique représente et calcule la distribution triphasée complète depuis l'arrivée HTA du réseau public jusqu'aux alimentations des serveurs. Il doit permettre d'étudier le fonctionnement normal, les manœuvres, les limites de capacité, les défauts, le comportement des sources de secours, le délestage et la propagation des pertes d'alimentation.

Le périmètre fonctionnel comprend les arrivées du réseau public, cellules et jeux de barres HTA, transformateurs, tableaux, jeux de barres et câbles basse tension, disjoncteurs, sectionneurs, contacteurs, ATS, STS, groupes électrogènes, systèmes de démarrage, réserve de carburant, UPS, redresseurs, onduleurs, batteries, bypass, PDU, busways, rPDU et charges informatiques ou auxiliaires. Les phases, le neutre, la mise à la terre, les positions fonctionnelles, les chemins normaux, les chemins de secours et les possibilités de couplage devront être représentés lorsqu'ils influencent un calcul ou une décision.

Les valeurs nominales exactes, le nombre de chaînes, la redondance et le régime de neutre seront portés par une configuration du site de référence et non inscrits en dur dans le moteur. Le modèle devra accepter des architectures radiales, redondantes ou reconfigurables sans modifier ses principes d'intégration.

OpenDSS constitue la source de vérité du calcul de réseau électrique au niveau RMS. Il calculera, selon le cas d'étude, les tensions, courants, puissances actives et réactives, facteur de puissance, pertes, déséquilibres de phase, taux de charge, chutes de tension, surcharges et courants de défaut. Les identifiants des éléments OpenDSS devront être reliés explicitement aux actifs et ports canoniques.

Le moteur C++ porte les états discrets et la chronologie opérationnelle : positions des appareils de coupure, ordres et retours d'état, interverrouillages, temporisations, passage sur batterie, démarrage et montée en régime d'un groupe, autorisation de transfert, connexion des charges, échec d'une manœuvre, délestage, reprise progressive et retour au réseau. Après toute modification topologique ou importante variation de charge, il demandera un nouveau calcul électrique et utilisera le résultat pour accepter, refuser ou faire évoluer l'état du scénario.

Les protections devront posséder leurs seuils, temporisations, courbes applicables, zones protégées et relations de coordination. Un défaut devra pouvoir déclencher l'appareil approprié, isoler une branche et provoquer les conséquences aval. Les scénarios devront permettre de révéler les défauts de sélectivité ou les cascades de déclenchement. La logique de déclenchement opérationnelle sera exécutée de manière déterministe par le moteur C++ à partir des grandeurs calculées ; les études détaillées pourront être comparées à un outil d'ingénierie spécialisé.

Un UPS devra au minimum représenter son mode de fonctionnement, sa capacité nominale, son rendement en fonction de la charge, ses pertes, sa limite permanente, sa surcharge temporaire, son transfert, son bypass et ses alarmes. La batterie devra représenter l'énergie utilisable, l'état de charge, les limites de puissance, le rendement de charge et de décharge, le vieillissement ou déclassement configuré et les seuils de coupure. L'autonomie devra résulter de la charge réellement alimentée et de l'état du système, et non d'une durée fixe décorative.

Un groupe électrogène devra représenter sa disponibilité, son temps de démarrage, ses échecs possibles, sa montée en régime, sa stabilisation, ses limites de puissance, les conditions de connexion, ses protections, sa consommation de carburant et sa réserve. La puissance disponible et l'autonomie devront dépendre de l'état réel du groupe, de la charge et du carburant. Les dynamiques détaillées non nécessaires à l'exploitation pourront être remplacées par un modèle réduit documenté et validé.

Les charges devront être reliées à leur source fonctionnelle et classées selon leur nature, leur profil et leur priorité. Le modèle distinguera la puissance demandée de la puissance effectivement fournie. Il devra représenter les charges informatiques, le refroidissement, les pompes, ventilateurs, contrôles, auxiliaires et services indispensables, puis appliquer les politiques de délestage et de reprise définies par le scénario.

La simulation principale adopte une représentation RMS dynamique adaptée à l'exploitation d'un data center. Elle doit suivre les événements de commutation et de protection sur des échelles de quelques dizaines de millisecondes, puis les évolutions d'autonomie, de charge et de carburant jusqu'à plusieurs heures. Les transitoires électromagnétiques à l'échelle de la microseconde ne seront pas calculés en continu par le jumeau opérationnel ; une étude EMT spécialisée pourra être référencée lorsqu'une décision exige l'analyse interne de l'électronique de puissance ou des formes d'onde.

Le domaine électrique reçoit notamment les demandes de puissance des workloads et des auxiliaires, les commandes des automatismes, les disponibilités d'équipements et les éventuels déclassements dus aux conditions thermiques. Il transmet la puissance effectivement disponible et fournie, les pertes dissipées, les états d'alimentation, les marges, les surcharges, les défauts, les déclenchements, les autonomies et les alarmes. Ces sorties alimentent les modèles informatique, thermique, hydraulique, de contrôle et de procédure.

Omniverse ne calcule pas l'électricité. Il représente les états et résultats autoritaires du domaine électrique dans la scène : équipements alimentés, hors tension, en secours, surchargés ou défaillants, chemins actifs, alarmes, valeurs et chronologie. Une animation de flux ou une couleur ne devra jamais être interprétée comme une preuve de calcul si elle n'est pas reliée à un résultat identifié.

La validation du domaine électrique comprendra le contrôle de la topologie, des unités et des plaques signalétiques, des comparaisons à des calculs manuels ou cas de référence, la vérification des bilans de puissance et d'énergie, des courbes constructeur, des courants de défaut, de la coordination des protections, des séquences UPS-groupe-ATS et des règles de délestage. Les jeux de données, versions de modèles, tolérances et résultats de référence devront être conservés pour permettre les régressions.

OpenDSS demeure l'autorité du calcul RMS pendant le run, mais ne sera pas l'unique preuve d'une étude européenne de court-circuit ou de sélectivité. Des cas de référence seront recalculés indépendamment avec pandapower selon IEC 60909 lorsque cette méthode s'applique. Un écart entre les deux routes devra être expliqué par les hypothèses, conventions ou limites avant acceptation. Toute affirmation engageant la conception d'un site réel, le réglage de protections ou une conformité exigera en plus une revue par un professionnel compétent et, selon le projet, une comparaison avec ETAP, DIgSILENT PowerFactory ou un autre outil d'ingénierie reconnu.

### 5.14 Modèle des domaines thermique, hydraulique et aéraulique

**Décision actée :** le site de référence utilise une architecture de refroidissement hybride. Les baies informatiques classiques sont principalement refroidies par l'air de la salle, tandis que les baies IA à haute densité utilisent un refroidissement liquide direct-to-chip. Les deux branches sont intégrées au même bilan énergétique et peuvent partager une production frigorifique, des échangeurs ou des organes de rejet selon la configuration technique retenue.

Le périmètre fonctionnel s'étend du rejet ou de la source thermique extérieure jusqu'à l'air aspiré par les équipements informatiques et aux plaques froides des composants. Il comprend les groupes froids ou sources d'eau glacée, systèmes de free cooling lorsqu'ils existent, échangeurs, pompes, conduites, collecteurs, vannes, organes d'équilibrage, réservoirs ou volumes tampons, capteurs, CRAH, ventilateurs, plénums, faux planchers lorsqu'ils existent, confinements d'allées, CDU, boucles secondaires des baies, raccords, plaques froides et chemins de retour de la chaleur.

La topologie doit distinguer les boucles, branches, bypass, sens de circulation, jonctions, volumes, interfaces d'échange et limites de contrôle. Une proximité géométrique dans OpenUSD ne constitue pas une connexion hydraulique ou aéraulique ; les raccordements autoritaires sont définis par les ports et connexions du registre canonique et projetés dans les modèles spécialisés.

Modelica, avec la bibliothèque Buildings et les composants complémentaires validés par le projet, constitue la source de vérité dynamique des circuits thermiques, hydrauliques et de leurs régulations. Les modèles calculeront notamment les débits massiques, pressions, pertes de charge, températures, puissances échangées, capacités disponibles, rendements, consommations auxiliaires, inerties thermiques et transitions entre régimes de fonctionnement.

Les équipements ne devront pas être réduits à des interrupteurs produisant instantanément leur valeur nominale. Les groupes froids, pompes, ventilateurs, échangeurs et CDU devront utiliser des courbes, limites, rendements, capacités partielles, délais, rampes et volumes thermiques adaptés au niveau de fidélité retenu. Les régulations devront respecter leurs capteurs, consignes, bandes mortes, priorités, séquences, limites, alarmes et modes dégradés.

Le modèle aéraulique de la salle devra représenter l'apport d'air froid, le passage à travers les baies, le rejet d'air chaud, les confinements, recirculations, fuites, mélanges, zones mortes et points chauds. Il devra fournir au minimum une température d'entrée et une capacité de refroidissement cohérentes pour chaque baie ou groupe de baies, plutôt qu'une température uniforme arbitraire pour toute la salle.

OpenFOAM sera utilisé pour les campagnes CFD détaillées de la salle et des zones nécessitant une résolution spatiale fine. Ces campagnes seront exécutées hors ligne sur des configurations identifiées et conserveront leur maillage, conditions aux limites, paramètres, version du solveur, critères de convergence et résultats. La CFD complète ne sera pas exécutée en permanence dans la boucle interactive locale.

OpenFOAM sera exécuté comme un processus ou environnement séparé sous WSL2 ou Linux. Les résultats natifs du solveur, les logs, résidus, études de maillage et conditions aux limites seront conservés ; VTKHDF ou VTK XML servira aux échanges de visualisation lorsque pertinent. Sa licence GPLv3 fera l'objet d'une revue avant toute distribution propriétaire. Pour une affirmation d'ingénierie forte, au moins un cas représentatif sera confronté à une mesure, une référence indépendante, Ansys Icepak, Cadence DataCenter Design/Insight ou une expertise équivalente.

Les résultats CFD validés serviront à construire ou calibrer un modèle réduit capable de reproduire les phénomènes pertinents en temps interactif : distribution des températures d'entrée, recirculation, influence des débits et risque de point chaud. Ce modèle réduit devra annoncer ses variables d'entrée, son domaine de validité et son erreur par rapport aux cas CFD de référence. Une extrapolation hors de ce domaine devra être détectée et signalée.

PhysicsNeMo ne sera pas une étape automatique de cette chaîne. Il ne sera évalué qu'après constitution d'un corpus CFD suffisamment large, séparation d'un jeu de validation indépendant, définition d'une détection hors distribution et comparaison avec un modèle réduit non neuronal plus simple. FDS pourra ultérieurement calculer la fumée et la chaleur d'un incendie à partir de cas disposant d'une stratégie de vérification et validation. FDS+Evac étant abandonné, l'évacuation et l'intervention humaine resteront portées par le modèle procédural du projet ou par un outil distinct explicitement validé.

Le domaine reçoit la chaleur dissipée et sa localisation depuis le modèle informatique, l'état d'alimentation et les limitations depuis le domaine électrique, les commandes depuis les automatismes ainsi que les conditions extérieures du scénario. Il transmet les températures d'entrée et de sortie, débits, pressions, capacités disponibles, consommations électriques, marges, performances, points chauds, alarmes et conditions susceptibles d'imposer un throttling ou un arrêt informatique.

Les pertes électriques des transformateurs, UPS, câbles et autres équipements pourront alimenter le bilan thermique de leurs locaux lorsqu'elles sont incluses dans le périmètre. Réciproquement, les températures ambiantes ou de fluide pourront provoquer un déclassement des équipements électriques et informatiques. Chaque échange devra conserver sa localisation, son horodatage et son identité canonique afin d'éviter une double comptabilisation de la chaleur.

Les modes de panne comprennent au minimum l'arrêt ou le déclassement d'un groupe froid, la perte d'une pompe ou d'un ventilateur, une vanne bloquée ou mal positionnée, un filtre colmaté, une fuite, une perte de pression, un échangeur encrassé, une perte ou saturation de CDU, une rupture de confinement, une mesure erronée et une régulation incorrecte. Chaque panne devra modifier les équations, capacités ou commandes réelles du modèle et non seulement l'apparence de l'équipement.

La simulation devra suivre les réactions rapides des commandes et circulations ainsi que l'évolution thermique jusqu'à plusieurs heures. Les pas de calcul pourront différer entre l'hydraulique, les régulations et les masses thermiques, sous le contrôle de l'orchestrateur. Les bilans d'énergie et de masse devront rester cohérents lors des changements de pas, des échanges avec le modèle réduit CFD et des transitions de mode.

Omniverse représente les températures, gradients, circuits actifs, directions de circulation, états d'équipements, points chauds, fuites et alarmes à partir des résultats identifiés. Les animations de fluides, couleurs et champs visuels sont des moyens d'explication ; elles ne deviennent des résultats d'ingénierie que lorsqu'elles sont reliées à une variable, un run et un modèle validés.

La validation comprendra les bilans de masse et d'énergie, des comparaisons avec des calculs analytiques, courbes constructeur, cas Modelica et campagnes CFD de référence, ainsi que des scénarios de panne et de reprise. Les tolérances seront définies par grandeur et par niveau de fidélité. La température, le débit ou le rendement ne pourront être qualifiés de crédibles sans provenance, hypothèses, domaine de validité et preuve de comparaison appropriée.

### 5.15 Modèle du domaine informatique, des réseaux et des workloads

**Décision actée :** les charges informatiques ne sont pas représentées par des puissances fixes. Leur consommation électrique, leur dissipation thermique, leur trafic réseau et leur performance résultent des ressources réellement mobilisées par les workloads, de l'état des équipements et des politiques d'exploitation.

Le modèle physique comprend les baies, châssis, serveurs ou nœuds, CPU, GPU, accélérateurs, mémoire, stockage local, alimentations, interfaces réseau, switches, liens et autres composants qui influencent la puissance, la chaleur, la capacité ou la disponibilité. La granularité pourra varier selon le scénario, mais toute agrégation devra conserver son périmètre, ses hypothèses et la correspondance avec les actifs canoniques.

Le modèle logique représente les clusters, partitions, pools de ressources, files d'attente, allocations, tâches et services. Il devra relier une allocation logique aux nœuds physiques qui l'exécutent afin de transformer une décision d'ordonnancement en consommation, chaleur, trafic et risque opérationnel localisés.

Trois classes de mission sont obligatoires. Les entraînements IA et traitements batch sont flexibles, fortement consommateurs et peuvent, selon leur configuration, attendre, réduire leur puissance, effectuer un checkpoint, reprendre ou être déplacés. L'inférence critique répond à des objectifs de disponibilité, latence et débit plus stricts. Les services d'infrastructure indispensables maintiennent le contrôle, l'observabilité, l'ordonnancement, le stockage ou les communications nécessaires au fonctionnement du site et reçoivent une priorité adaptée à leur rôle.

Chaque workload devra déclarer son profil de ressources, ses dépendances, sa priorité, ses contraintes de placement, son heure d'arrivée, sa durée ou sa quantité de travail, ses objectifs de performance, son comportement au démarrage et à l'arrêt, ainsi que ses capacités de throttling, checkpoint, reprise et migration. Un même workload pourra disposer de plusieurs profils validés selon le matériel, la limite de puissance ou le degré de parallélisme.

L'ordonnanceur simulé attribue les workloads aux ressources disponibles en respectant les capacités informatiques, les dépendances réseau et stockage, les priorités, les politiques énergétiques, les contraintes thermiques et les états de panne. Ses décisions et leur justification devront être conservées dans le run. Les politiques d'ordonnancement seront séparées du cœur du moteur afin de pouvoir comparer plusieurs stratégies sur un scénario identique.

La puissance d'un composant devra être calculée à partir de son état et de son activité, au moyen de courbes constructeur, de mesures ou de modèles calibrés. Le modèle pourra utiliser l'utilisation, la fréquence, la tension, la limite de puissance, la température, le type d'opération et le rendement de l'alimentation lorsque ces variables sont pertinentes et disponibles. La puissance nominale de plaque ne devra pas être utilisée comme consommation permanente sans justification.

La puissance effectivement absorbée et la chaleur dissipée seront calculées par serveur, puis agrégées sans double comptage par baie, rangée, salle et site. Les pertes des alimentations devront être distinguées de l'énergie utile aux composants. Le modèle devra préserver le bilan entre énergie électrique reçue, travail représenté, pertes et chaleur transmise aux domaines thermiques.

Le réseau informatique est représenté au niveau nécessaire pour expliquer les performances et les défaillances des workloads : topologie, interfaces, capacité des liens, bande passante utilisée, latence, congestion, sursouscription, redondance et disponibilité des switches ou chemins. La boucle interactive ne simule pas chaque paquet. Elle utilise un modèle de flux ou de performance validé capable de montrer les effets d'une coupure, d'une saturation ou d'un chemin dégradé sur une tâche distribuée, un service ou une migration.

Le modèle informatique reçoit la puissance disponible et les états d'alimentation du domaine électrique, les températures d'entrée et capacités de refroidissement du domaine thermique, les états du réseau, les commandes et les politiques d'exploitation. Il transmet la demande de puissance, la chaleur localisée, l'utilisation des ressources, le trafic agrégé, la performance obtenue, les violations d'objectifs, les décisions de placement et les changements de mode.

Lorsqu'une contrainte apparaît, les réactions autorisées comprennent la limitation de puissance, la réduction de fréquence, le throttling, le report d'une tâche, le checkpoint, la migration, le délestage d'un workload flexible, la dégradation contrôlée d'un service et l'arrêt propre ou forcé. Les délais et conséquences de ces actions devront être modélisés ; une migration ou un checkpoint ne sera pas considéré instantané et gratuit.

Les modes de panne comprennent les pertes de nœud, GPU, alimentation, interface, switch, lien, stockage ou service d'infrastructure, ainsi que les dégradations de performance, erreurs de télémétrie et indisponibilités logicielles pertinentes. Une panne devra affecter les capacités et dépendances réelles du modèle, et non uniquement l'apparence de l'actif.

Le moteur C++ porte l'évolution des ressources, workloads, événements et politiques simulés. PostgreSQL porte les configurations et relations persistantes ; TimescaleDB porte les observations et résultats temporels. Des adaptateurs pourront ultérieurement importer des descriptions ou télémétries de plateformes réelles, par exemple depuis un ordonnanceur de cluster, Kubernetes, Slurm ou NVIDIA DCGM, sans confondre observation réelle et résultat simulé.

Omniverse représente les équipements, allocations, charges, flux agrégés, limites de puissance, températures et défaillances à partir d'états identifiés. Le cockpit React présente les files, priorités, objectifs de service, décisions de placement, performances et conséquences métier. La visualisation d'un workload devra permettre de retrouver les ressources physiques, séries temporelles et événements qui expliquent son état.

La validation reposera sur des profils de puissance et de performance mesurés ou documentés, des tests de conservation énergétique, des cas d'ordonnancement déterministes, des scénarios de saturation et de panne réseau, ainsi que la comparaison entre objectifs demandés et performance obtenue. Un modèle calibré sur un type de serveur, GPU ou workload ne pourra être appliqué silencieusement à un autre matériel ou domaine d'utilisation.

### 5.16 Automatismes, supervision, sécurité et intervention humaine

**Décision actée :** les automatismes, systèmes de supervision, dispositifs de sécurité et opérateurs sont des composants exécutables du jumeau. Ils ne sont pas réduits à des animations ou à une liste d'événements écrite à l'avance. Leurs décisions, délais, autorisations, échecs et effets doivent être reliés aux états calculés des domaines physiques.

Chaque boucle fonctionnelle doit pouvoir représenter la chaîne capteur, acquisition, traitement, logique, commande, actionneur et retour d'état. Une commande constitue une intention distincte de l'état effectivement obtenu. Le modèle devra conserver la qualité et l'horodatage des mesures, le délai de transmission ou d'exécution lorsqu'il est pertinent, ainsi que les défauts possibles du capteur, de la communication, de la logique et de l'actionneur.

Les régulations continues, notamment les boucles de température, pression, débit et vitesse, sont calculées avec les modèles dynamiques Modelica lorsqu'elles participent au comportement thermohydraulique. Les séquences discrètes, machines à états, autorisations, interverrouillages, temporisations, priorités, basculements, watchdogs et reprises sont exécutés par le moteur C++. Une même fonction ne devra pas être exécutée simultanément dans les deux environnements sans découpage et responsabilité explicites.

Les équipements et systèmes devront posséder des modes cohérents tels que arrêt, démarrage, normal, secours, dégradé, maintenance, test, défaut et urgence lorsque ces états sont pertinents. Les conditions d'entrée, de sortie et d'échec de chaque mode devront être définies. Les sécurités, positions de repli et comportements en perte de signal ou d'énergie devront produire des conséquences réelles sur les commandes et modèles physiques.

Le BMS représente la supervision des systèmes techniques du bâtiment, l'EPMS celle de la distribution et de la qualité électriques, et le DCIM la vue opérationnelle reliant capacité, énergie, environnement et infrastructure informatique. Ces fonctions agrègent des observations, produisent des alarmes, appliquent des consignes et soutiennent les décisions ; elles ne remplacent pas les solveurs électriques, thermiques ou informatiques qui restent autoritaires pour leurs calculs.

Une alarme doit conserver sa source, sa condition de déclenchement, sa priorité, son horodatage, son état actif ou revenu à la normale, son acquittement, sa suppression éventuelle, ses dépendances et sa conséquence opérationnelle. Les alarmes dérivées d'une même cause devront pouvoir être corrélées afin d'étudier les avalanches d'alarmes et la capacité de l'opérateur à identifier l'événement initiateur.

Une commande automatique ou humaine devra indiquer son émetteur, son autorité, sa cible, ses paramètres, ses préconditions, l'instant demandé, l'instant exécuté, le résultat et le retour d'état. Les overrides, commandes locales, commandes distantes, verrouillages et refus devront être distingués. Aucune interface ne devra modifier directement un état physique en contournant l'actionneur et la logique responsables.

La sécurité physique couvre les identités ou rôles, badges, lecteurs, portes, sas, zones, horaires, autorisations temporaires, refus d'accès et états de verrouillage pertinents. L'accès à une zone ou à une commande devra dépendre des droits, habilitations et conditions opérationnelles. La représentation devra permettre d'expliquer pourquoi une personne peut atteindre un équipement et effectuer une action donnée.

La sécurité incendie comprend les zones de détection, détecteurs, déclencheurs, centrales, alarmes, clapets, portes, ventilation de sécurité, systèmes d'extinction et procédures d'évacuation nécessaires aux cas d'usage. Les matrices de cause à effet devront pouvoir déclencher des actions coordonnées, par exemple l'arrêt d'un équipement, la fermeture d'un clapet, la modification de la ventilation, l'isolement d'une alimentation, l'extinction et l'évacuation. Un futur modèle FDS pourra calculer la fumée et la chaleur lorsque cette fidélité est exigée ; la logique de sécurité restera distincte de ce solveur physique.

Les opérateurs sont décrits par leur rôle, leurs habilitations, leurs compétences, leur localisation, leurs moyens de communication et leur disponibilité. Une intervention comprend la détection, la prise de connaissance, le diagnostic, la décision, les validations nécessaires, le déplacement, la mise en sécurité, l'action, la vérification et la clôture. Chaque étape peut posséder une durée, des préconditions, des ressources, des points d'arrêt et des résultats possibles.

Les procédures doivent être versionnées et reliées aux actifs, risques, rôles et situations auxquels elles s'appliquent. Les consignations, autorisations de travail, doubles contrôles ou interventions à plusieurs personnes devront être représentés lorsque nécessaires. Une étape ne devra pas être réputée achevée simplement parce que son délai théorique s'est écoulé si ses préconditions ou confirmations ne sont pas satisfaites.

Les erreurs, retards, diagnostics incorrects, oublis, indisponibilités et reprises humaines pourront être exécutés de façon déterministe ou probabiliste. Toute variabilité aléatoire devra utiliser une distribution documentée, une graine conservée et une provenance. Le projet ne présentera pas comme données réelles des probabilités choisies uniquement pour produire une démonstration spectaculaire.

React constitue le poste de supervision pour les états, alarmes, tendances, procédures, autorisations et commandes. Omniverse localise les actifs, zones, risques et opérateurs et montre les conséquences physiques des actions. Les deux interfaces consomment le même état autoritaire et ne doivent pas pouvoir faire diverger la simulation.

La validation reposera sur les descriptions fonctionnelles, tables de vérité, machines à états, matrices cause-effet, listes d'alarmes, procédures et cas de test approuvés. Les tests devront couvrir le fonctionnement nominal, les limites, pertes de signal ou d'énergie, commandes contradictoires, interverrouillages, refus, délais, retours d'état incorrects et interventions humaines. Chaque action devra être explicable à partir des entrées, règles, autorisations et versions applicables.

### 5.17 Scénarios, pannes et analyse de fiabilité

**Décision actée :** un scénario décrit les conditions initiales et les événements injectés, mais ne prescrit pas leurs conséquences. La propagation électrique, thermique, informatique, automatique et humaine doit résulter de l'exécution des modèles et de leurs contrats. Une séquence entièrement écrite à l'avance pourra servir de storyboard commercial, mais ne devra jamais être présentée comme une simulation calculée.

Un scénario versionné comprendra la configuration immuable du site, les modèles et niveaux de fidélité sélectionnés, les conditions extérieures, les workloads, les consignes, les politiques, les acteurs disponibles, la chronologie des événements initiateurs, les paramètres incertains, la graine aléatoire éventuelle, les conditions d'arrêt et les métriques à produire. Sa définition devra être indépendante de la vitesse de lecture et de l'affichage 3D.

Chaque famille d'actifs devra disposer d'un catalogue de modes de défaillance relié au registre canonique. Un mode précisera la cause ou condition d'activation, les paramètres altérés, les effets locaux, les mécanismes de détection, les alarmes attendues, les possibilités d'isolement, les moyens et durées de réparation ainsi que les données de fiabilité disponibles. Les probabilités, taux ou distributions sans source devront être identifiés comme hypothèses synthétiques.

Le catalogue devra représenter les défauts francs, dégradations progressives, pannes intermittentes, mauvaises configurations, pertes de communication, mesures fausses, actionneurs bloqués, erreurs logicielles et erreurs humaines pertinentes. Les défaillances communes ou corrélées, dépendances partagées et conditions environnementales devront pouvoir affecter plusieurs actifs sans être artificiellement transformées en pannes indépendantes.

Une cascade ne sera pas enregistrée comme une liste fixe. L'événement initiateur modifie un état ou un paramètre local ; les modèles calculent ensuite les surcharges, pertes d'alimentation, échauffements, limitations, alarmes, décisions et interventions qui peuvent produire d'autres événements. La timeline devra distinguer cause injectée, conséquence calculée, commande émise, action réussie ou refusée et observation reçue.

Les analyses comprendront des runs déterministes de type « what-if », des variantes paramétriques, des analyses de sensibilité et, lorsque les distributions sont justifiées, des campagnes probabilistes ou Monte-Carlo. Les exécutions probabilistes devront conserver leurs graines, distributions, corrélations, échantillons et échecs numériques afin que leurs résultats puissent être reproduits et audités.

Les méthodes FMEA/FMECA, arbres de défaillance et arbres d'événements pourront structurer les bibliothèques et campagnes. Elles ne remplacent pas la simulation dynamique : elles indiquent les combinaisons, barrières et conséquences à étudier, tandis que la co-simulation calcule leur déroulement temporel lorsque cela apporte une valeur décisionnelle.

Les métriques de référence comprennent la disponibilité des services, le temps de détection, le temps de réaction, le temps de récupération, l'énergie non distribuée, la durée d'alimentation sur batterie ou carburant, la marge électrique, les excursions thermiques, la perte de travail informatique, les violations d'objectifs de service, les alarmes, les actions humaines et l'état final du système. Toute métrique devra être définie avec son unité, son périmètre et sa méthode de calcul.

Chaque run sera immuable et recevra un identifiant. Il conservera le manifeste de versions, la configuration, les entrées, événements, commandes, résultats, diagnostics, avertissements, critères d'acceptation et liens vers les artefacts lourds. Une correction d'un modèle créera un nouveau run ; elle ne réécrira pas silencieusement l'historique.

Le scénario transversal de référence injecte la perte du réseau public pendant une charge informatique représentative. Le jumeau calcule le passage sur UPS, l'autonomie des batteries, le démarrage et la connexion des groupes, la disponibilité du refroidissement, la réponse thermique, les alarmes, les décisions sur les workloads et les interventions humaines. Des variantes introduisent notamment un échec de groupe, une batterie dégradée, une perte de pompe ou une erreur de diagnostic afin d'éprouver la résilience et l'explicabilité.

### 5.18 Vérification, validation, incertitude et dossier de crédibilité

**Décision actée :** aucune grandeur simulée ne sera qualifiée de crédible uniquement parce que son rendu paraît réaliste. Chaque modèle, couplage et scénario destiné à soutenir une affirmation technique devra posséder un dossier de crédibilité proportionné à son usage, inspiré des principes de NASA-STD-7009B et complété par les pratiques propres au domaine physique concerné.

Chaque dossier précisera l'usage prévu, les décisions soutenues, les questions auxquelles le modèle peut répondre, celles auxquelles il ne peut pas répondre, le système réel ou de référence représenté, les hypothèses, les simplifications, le domaine de validité, les données utilisées, les incertitudes, les critères d'acceptation, les preuves disponibles et la personne ou le rôle ayant approuvé l'usage.

La vérification établit que le logiciel et les équations ont été implémentés et intégrés correctement. Elle comprend selon le risque les compilations, analyses statiques, smoke tests, analyses dimensionnelles, bilans, tests de convergence, tests de contrats et d'intégration, scénarios reproductibles, comparaisons analytiques, cas manufacturiers ou académiques de référence et tests de régression de bout en bout.

Les travaux CFD et de transfert thermique appliqueront les principes pertinents d'ASME V&V 20. Ils distingueront vérification du code, vérification de solution, convergence de maillage et de pas, validation par rapport à une référence, incertitude de mesure, incertitude numérique et incertitude de modèle. L'accord entre deux logiciels utilisant les mêmes hypothèses ne constituera pas à lui seul une validation.

**Décision de méthode :** aucun test unitaire ne sera créé, complété ou exécuté par défaut, afin de préserver la vitesse de développement et d'éviter une infrastructure de tests isolés jugée peu utile au stade courant. Un test unitaire n'est autorisé que lorsque le propriétaire du projet le demande explicitement dans la requête concernée. Cette règle ne supprime pas l'obligation de vérifier les contrats, intégrations, scénarios, bilans physiques et affirmations de crédibilité par des moyens adaptés.

La validation établit dans quelle mesure le modèle représente suffisamment le comportement attendu pour son usage. Elle s'appuie, selon disponibilité, sur des données mesurées, essais, courbes constructeur, résultats d'outils reconnus, campagnes CFD, retours d'experts et comparaisons croisées. Une validation dans un régime de fonctionnement ne vaut pas validation universelle.

La validation conceptuelle doit intervenir avant la calibration numérique. Elle vérifiera les frontières, causalités, états, hypothèses et choix de fidélité afin d'éviter de calibrer correctement un modèle conceptuellement erroné. Les paramètres calibrés devront être séparés des données de validation afin de limiter les validations circulaires.

Les incertitudes de mesure, de paramètres, de modèle, de conditions initiales et de discrétisation devront être identifiées. Les analyses de sensibilité détermineront les paramètres qui influencent réellement une conclusion. Lorsqu'une sortie ne peut pas être défendue par un intervalle ou une tolérance appropriée, elle sera présentée comme qualitative ou exploratoire plutôt que comme une prédiction précise.

Chaque résultat exposé publiquement indiquera son niveau de preuve : démonstration fonctionnelle, résultat synthétique vérifié, modèle calibré, comparaison indépendante ou résultat lié à une mesure réelle. Le terme « validé » devra mentionner l'usage, le domaine et les preuves concernés. Le projet ne revendiquera aucune certification réglementaire ou ingénierie qu'il n'a pas effectivement obtenue.

Les surrogates et modèles réduits devront être comparés à un jeu de référence distinct, disposer de métriques d'erreur, détecter les entrées hors distribution ou hors domaine et permettre un retour au modèle de référence ou à un état indéterminé. Une animation fluide ne justifie jamais l'extrapolation silencieuse d'un modèle réduit.

Les revues de modèle, décisions, jeux de données, scripts de préparation, rapports et résultats de référence seront versionnés ou identifiés par empreinte. Le pipeline d'intégration continue devra rejouer les tests suffisamment courts ; les campagnes lourdes seront exécutées selon une politique planifiée et leurs artefacts seront rattachés aux versions testées.

### 5.19 Cybersécurité, sûreté des commandes et séparation IT/OT

**Décision actée :** la plateforme est conçue comme un système cyber-physique. La vitrine publique, les services métier, l'environnement de simulation, les outils d'ingénierie et toute future connexion à un réseau OT doivent être séparés en zones de confiance. Le site public ne disposera d'aucun chemin direct permettant de commander un équipement réel ou d'accéder à des données techniques non publiées.

L'architecture de sécurité s'appuiera sur une analyse de risques et sur les principes pertinents de NIST SP 800-82 Rev. 3 pour les environnements OT, de la famille IEC 62443 pour les systèmes d'automatisation et de contrôle, et du NIST Secure Software Development Framework. Ces références servent de guides ; le projet ne déclarera une conformité que si son périmètre, ses exigences et ses preuves ont fait l'objet d'une évaluation dédiée.

Les utilisateurs et services devront être authentifiés, les autorisations appliquées selon le moindre privilège et les opérations sensibles journalisées. Les rôles de consultation, configuration, lancement de simulation, commande, publication et administration devront être distincts. Les secrets ne seront pas stockés dans Git, les communications externes seront chiffrées et les données sensibles seront protégées au repos selon leur classification.

Les interfaces vers BACnet, OPC UA, BMS, EPMS, DCIM, ordonnanceurs ou équipements réels seront en lecture seule par défaut. Toute capacité de commande réelle exigera un projet client séparé, une passerelle explicitement autorisée, une analyse de risques, des limites, interverrouillages, modes manuels, tests et procédures de retour en sécurité. La simulation ne devra jamais pouvoir adresser accidentellement une commande à un équipement de production.

Les données synthétiques, publiques, internes, client, personnelles et sensibles seront classifiées et séparées. Les exports destinés au site public passeront par un pipeline d'autorisation qui ne copie que les champs explicitement publiables. Les détails de topologie, vulnérabilités, identifiants, procédures ou performances d'un site réel ne devront pas être exposés par défaut.

Le développement intégrera inventaire des dépendances, versions verrouillées, analyse de vulnérabilités, revue de code, tests, génération d'un SBOM pour les livrables, contrôle des licences, provenance des artefacts et traitement documenté des vulnérabilités. Les composants tiers, modèles téléchargés et assets 3D devront être considérés comme des entrées non fiables jusqu'à leur contrôle.

La préparation commerciale européenne intégrera une analyse d'applicabilité du Cyber Resilience Act, de NIS2, du Data Act et du RGPD. Sans préjuger d'une qualification juridique, le produit conservera un SBOM, la durée et la politique de support, un canal de signalement, la provenance des versions, les mises à jour et preuves de traitement des vulnérabilités. Une offre connectée devra permettre l'accès et l'export des données et métadonnées dans un format lisible par machine sans verrouillage artificiel. Les journaux, habilitations et interventions associés à une personne seront minimisés, séparés, protégés et soumis à une durée de conservation justifiée. Une revue juridique précédera toute distribution ou exploitation commerciale qui entre dans ces champs.

Les fichiers IFC, CAD, USD, textures, FMU, modèles et archives sont des entrées potentiellement actives ou malveillantes. Leur ingestion et l'exécution de convertisseurs ou FMU auront lieu dans des répertoires et processus isolés avec quotas, validation de type, empreinte et provenance. Le pipeline public ne consommera que des artefacts approuvés et ne disposera d'aucun accès à la zone OT ou aux sources d'ingénierie sensibles.

La disponibilité et l'intégrité sont prioritaires pour les fonctions opérationnelles. Les erreurs de réseau, messages dupliqués, retardés ou réordonnés, pertes de service, reprise après incident et sauvegardes devront être testés. L'horloge simulée restera séparée de l'horloge réelle afin qu'une accélération, pause ou reprise de simulation ne perturbe pas l'authentification, les journaux ou les éventuels connecteurs externes.

## 6. Architecture technologique cible

Les versions concrètes de cette architecture, l'état observé du poste, les arbitrages de compatibilité et la procédure de promotion sont définis dans `docs/toolchain/TOOLCHAIN_BASELINE.md`. Ce document est normatif pour les développeurs et agents IA : une dépendance n'est pas choisie à partir d'un numéro flottant ou d'une documentation visant une autre génération. Les manifests exécutables verrouillent la résolution exacte et doivent rester cohérents avec la baseline.

### 6.1 Visualisation 3D

- OpenUSD pour la composition, les références, les payloads, les variantes et les métadonnées de la scène ;
- NVIDIA Omniverse Kit pour le rendu RTX, le viewport et les interactions 3D ;
- application Kit native comme mode principal de développement et de démonstration locale haute fidélité ;
- WebRTC réservé aux démonstrations distantes temporaires et maîtrisées ;
- Omniverse CAD Converter et Scene Optimizer pour l'ingestion et l'optimisation des assets.

La scène sera découpée en couches, payloads et niveaux de détail chargeables à la demande. Les équipements répétés utiliseront l'instanciation, les petits détails non visibles seront masqués selon la distance et les textures disposeront de résolutions adaptées. L'objectif est de préserver l'identité et la précision utile sans charger simultanément toute la géométrie disponible.

L'application sera dérivée du Kit App Template moderne et non du Launcher Omniverse déprécié ni de l'application DSX. Le SDK Kit, les extensions, le pilote NVIDIA et les options de rendu seront verrouillés dans une matrice de compatibilité. Chaque extension redistribuée devra apparaître dans l'inventaire de licences et être autorisée pour ce mode de distribution. Une mise à niveau ne sera acceptée qu'après démarrage depuis un environnement propre, ouverture de la scène de référence, rendu, sélection, échange avec l'orchestrateur et, lorsqu'il est utilisé, test WebRTC.

### 6.2 Production des assets

- IFC 4.3 et Revit pour le bâtiment et les systèmes BIM ;
- STEP, JT et formats CAO constructeurs pour les équipements ;
- IDS, bSDD, IfcOpenShell et IfcTester pour spécifier, contrôler et extraire les données IFC ;
- Blender pour le nettoyage et les adaptations visuelles ;
- Substance 3D, optionnel, pour les matériaux PBR détaillés.

Les fichiers BIM et CAO restent les sources d'ingénierie. Les fichiers USD optimisés sont les assets d'exécution et de visualisation. Chaque ingestion conserve le fichier source par empreinte, sa licence, son unité, son repère, son propriétaire, ses paramètres de conversion, son rapport de contrôle, ses dépendances et ses bindings vers les UUID canoniques. Une fiche de provenance des assets et données complète le SBOM logiciel.

La chaîne IFC contrôle l'IDS avant conversion, extrait les propriétés et identités avec IfcOpenShell, puis génère la géométrie USD sans confondre représentation et sémantique. Blender travaille sur des branches géométriques ou dérivées : il ne doit pas ouvrir puis réexporter le stage racine en supposant préserver toutes les layers, références et variantes OpenUSD. Les conversions Omniverse CAD Converter seront automatisables et reproductibles ; une conversion réussie visuellement ne vaut pas validation de l'information d'ingénierie.

### 6.3 Poste de contrôle

- React avec TypeScript ;
- Vite pour le développement et le build ;
- Tailwind CSS ;
- Radix UI et éventuellement shadcn/ui pour les composants ;
- TanStack Query pour les appels et le cache des données serveur ;
- Apache ECharts pour les courbes, timelines et heatmaps ;
- React Flow uniquement pour les vues fonctionnelles ou schématiques complémentaires.

La vue 3D principale de l'application d'ingénierie est rendue par Omniverse et non par React, Three.js ou React Three Fiber. Le cockpit React et Kit échangent les sélections et états par identifiants canoniques ; ils ne maintiennent pas deux modèles métier indépendants.

Le site public utilisera React Three Fiber, renderer React de Three.js, pour afficher des artefacts glTF/GLB dérivés de la scène OpenUSD. Les maillages, matériaux, textures KTX2/Basis Universal, niveaux de détail et métadonnées publiables seront produits par un pipeline dédié avec instanciation, compression et chargement progressif. Cette représentation publique rejouera des résultats pré-calculés et ne réalisera aucun calcul physique faisant autorité.

La publication USD vers glTF étant une conversion avec perte, elle produira un manifeste canonique reliant chaque nœud publiable à son UUID, à la version de scène, au run, aux séries utiles, aux droits et aux empreintes des artefacts. Le nom d'un maillage ou le chemin d'un prim ne sera jamais utilisé seul comme identité. Les métadonnées glTF `extras` pourront accélérer la sélection mais le manifeste restera la preuve d'association et la liste d'autorisation des données publiques.

Le site public devra proposer une solution de repli pour les appareils ou navigateurs insuffisants : visite guidée allégée, images ou vidéo synchronisées aux mêmes événements et mesures. WebGL2 constitue la voie compatible de référence. WebGPU restera une amélioration progressive activée après détection et mesure tant que le renderer et les navigateurs concernés ne fournissent pas une stabilité suffisante. Une scène représentative comparera le temps de chargement, la mémoire, la sélection et la fluidité avant de figer les budgets et avant d'envisager un autre moteur Web.

### 6.4 Moteur de simulation

- C++20 pour l'horloge virtuelle, les événements, les scénarios, les automates et l'orchestration ;
- CMake pour le build ;
- vcpkg en mode manifeste pour les dépendances C++ ;
- mp-units pour exprimer les quantités physiques et contrôler les dimensions à la compilation ;
- aucun framework de test unitaire dans le socle initial ; GoogleTest ne pourra être ajouté que sur demande explicite du propriétaire ;
- unités SI obligatoires dans les contrats physiques.

Les grandeurs physiques ne circuleront pas comme des nombres nus. Le type de quantité, l'unité canonique, les règles de conversion et, pour les températures, la distinction entre valeur absolue et différence seront explicites dans le domaine C++ et dans les schémas sérialisés. Protocol Buffers transportera une représentation stable et documentée ; les contrôles dimensionnels resteront exécutés au plus près des modèles.

### 6.5 Adaptateurs et outils scientifiques

- Python pour intégrer les solveurs, traiter les données et automatiser les pipelines ;
- `uv` pour les environnements, dépendances et workspaces Python ;
- pytest uniquement comme exécuteur de vérifications Python d'intégration, de contrats, de pipelines scientifiques ou de scénarios ; il ne constitue pas une autorisation implicite de créer des tests unitaires ;
- aucun calcul physique critique ne doit dépendre d'un notebook non versionné.

### 6.6 Solveurs

- OpenDSS comme premier solveur du réseau électrique ;
- pandapower comme route indépendante de vérification IEC 60909 et de cas de protection sélectionnés ;
- Modelica Buildings avec OpenModelica pour le refroidissement, l'hydraulique et les régulations ;
- FMI 2.0.5 comme baseline de production des FMU ;
- FMI 3.0.2 comme cible promue modèle par modèle après preuve de compatibilité et de stabilité ;
- SSP 2.0.1 pour décrire et transporter les assemblages, connexions, unités et paramètres de co-simulation ;
- prototype comparatif HELICS, OMSimulator/SSP et boucle C++ minimale avant décision sur le master temporel ;
- OpenFOAM pour les campagnes CFD détaillées ;
- FDS, ultérieurement, pour la fumée et la chaleur liées aux incendies, sans FDS+Evac ;
- PhysicsNeMo seulement après constitution et validation d'un corpus CFD justifiant un surrogate neuronal ;
- ETAP ou DIgSILENT PowerFactory, Ansys Icepak ou Cadence comme outils commerciaux éventuels de comparaison et validation.

### 6.7 Communications

- API HTTP pour les commandes, les configurations et les données peu fréquentes ;
- WebSocket pour la télémétrie, les alarmes et la timeline en direct ;
- FastAPI comme première passerelle entre le frontend et les services ;
- gRPC et Protocol Buffers pour les contrats et les flux internes entre C++, Python et Kit ;
- Buf CLI pour formater, valider, générer et contrôler les ruptures de compatibilité des schémas Protocol Buffers ;
- WebRTC réservé au rendu vidéo et aux interactions avec le viewport.

Une architecture de messages distribuée telle que Kafka ne sera pas introduite au premier incrément. Les contrats resteront suffisamment indépendants du transport pour permettre cette évolution si des débits, sites ou besoins de découplage réels la justifient. Les appels devront propager l'identifiant du run, le temps simulé, la version du contrat, la qualité, la provenance et les diagnostics. Les paquets Protobuf seront versionnés, les numéros de champs retirés seront réservés et Buf vérifiera les changements contre la branche principale ou une image de référence. Une empreinte de preuve sera calculée sur un manifeste canonique, pas sur un encodage Protobuf supposé canonique.

Le premier contrat de flux d'état matérialise cette règle sans préjuger du futur master temporel. Une réponse porte l'UUID du run immuable, une séquence monotone reprenable dans ce run, le temps virtuel écoulé en nanosecondes entières, l'UUID canonique de l'actif, l'origine de l'état et une charge utile `oneof` extensible par domaine. Le serveur applique les filtres d'actifs et de reprise avant l'écriture et utilise l'API callback gRPC afin de ne pas immobiliser un thread par consommateur. Chaque client découple le réseau de son interface avec une file bornée et rejette les séquences non monotones. Kit résout localement l'UUID vers un prim et n'accepte jamais un chemin USD transmis par le moteur ; il applique les états dans la session layer, sans modifier l'asset source. La trajectoire initiale `OFF`–`STARTING`–`RUNNING` est marquée `SYNTHETIC_FIXTURE` et prouve uniquement le contrat, le transport et la projection visuelle.

### 6.8 Persistance

- PostgreSQL comme base relationnelle principale dès le début ;
- TimescaleDB comme extension temporelle dès le début ;
- stockage des équipements, topologies, scénarios, paramètres, événements, alarmes et mesures dans PostgreSQL/TimescaleDB ;
- stockage des métadonnées et des chemins des assets dans PostgreSQL ;
- dbmate et des migrations SQL explicites pour faire évoluer le schéma partagé sans le placer sous l'autorité d'un ORM ;
- conservation initiale des fichiers lourds CAD, USD, CFD et textures sur un système de fichiers adressé par contenu, derrière une interface pouvant cibler ensuite un stockage objet compatible S3 ;
- interdiction de stocker les gros binaires directement dans les tables PostgreSQL sans besoin justifié ;
- Git pour le code, les contrats et les fichiers texte ;
- Git LFS seulement pour les assets indispensables et maîtrisés.

DuckDB ne fait pas partie de l'architecture cible.

L'ADR 0001 retient l'édition Apache-only de TimescaleDB afin de préserver une future offre hébergée sans introduire de code sous Timescale License. Toute évolution vers une autre édition devra documenter les fonctions nécessaires, les restrictions applicables et faire l'objet d'une nouvelle décision et d'une revue juridique avant commercialisation. Les migrations ne seront pas exécutées implicitement au démarrage d'un service de production ; elles seront planifiées, sauvegardées et vérifiées sur une restauration représentative, y compris pour les hypertables, politiques et agrégats continus.

Le manifeste d'artefact conservera au minimum l'empreinte SHA-256, la taille, le type de média, la provenance, la licence, les dépendances, le statut de validation et l'emplacement. MinIO ne sera pas la dépendance locale par défaut en raison de l'archivage de son dépôt communautaire et de sa licence AGPLv3 ; la portabilité visera les propriétés nécessaires et l'API S3, pas un fournisseur précis. Parquet sera utilisé pour les exports tabulaires et séries archivées, Zarr v3 pour les tableaux multidimensionnels découpés, VTKHDF ou VTK XML pour les champs et maillages de visualisation, et les formats natifs des solveurs resteront les sources de calcul. NPZ pourra servir de cache temporaire mais pas de format autoritaire de long terme.

### 6.9 Sémantique et intégration future

- IFC 4.3, IDS et bSDD pour la structure BIM, les exigences d'information et les dictionnaires ;
- attributs OpenUSD nommés et versionnés pour relier les prims au modèle métier ;
- profil versionné ASHRAE 223P comme cible de sémantique opérationnelle et de topologie dès la conception du modèle canonique ;
- Brick comme vocabulaire complémentaire pour les équipements, points, systèmes et métadonnées opérationnelles ;
- projection RDF validée par SHACL, sans substituer le graphe sémantique à PostgreSQL, TimescaleDB, OpenUSD ou aux solveurs ;
- BACnet/SC comme cible des nouvelles intégrations BMS ; BACnet/IP uniquement via une passerelle segmentée pour l'existant ;
- OPC UA comme interface industrielle normalisée ;
- MQTT accompagné de Sparkplug lorsque la télémétrie edge nécessite un modèle d'état et de cycle de vie ;
- Project Haystack comme adaptateur possible pour les BMS existants, sans autorité canonique ;
- DCGM pour la future télémétrie des équipements NVIDIA.

Les connecteurs réels resteront hors du premier noyau, en lecture seule et isolés de la simulation. DCGM visera les GPU NVIDIA de data center ; la machine GeForce locale utilisera un contrat simulé ou le sous-ensemble réellement disponible. L'Asset Administration Shell, RealEstateCore, Slurm, Kubernetes et les autres écosystèmes ne seront ajoutés qu'avec un cas client et une frontière d'autorité définis.

### 6.10 Exécution locale, déploiement et observabilité

Le développement est local-first. Omniverse Kit s'exécute nativement sur le poste équipé du GPU. PostgreSQL/TimescaleDB, la passerelle FastAPI et les services sans GPU pourront être lancés par une composition de conteneurs reproductible. Le moteur C++ et les solveurs pourront fonctionner nativement ou dans des environnements isolés selon leurs contraintes de performance et de compatibilité.

Le premier environnement ne sera pas découpé en microservices indépendamment déployés sans nécessité. Les frontières logiques et Protocol Buffers permettront une séparation ultérieure, mais un déploiement simple, observable et reproductible est prioritaire. Un service lourd ou instable, notamment un solveur externe, devra pouvoir être isolé dans un processus afin qu'un échec produise un diagnostic sans corrompre le run ou l'interface.

Les logs seront structurés et corrélés par run, composant et temps simulé. Les métriques de santé, temps de calcul, mémoire, GPU, latence, pas rejetés et erreurs de solveur devront être observables. OpenTelemetry constitue la cible pour les traces et métriques applicatives ; les tableaux techniques pourront s'appuyer sur Prometheus et Grafana si leur utilité est démontrée. OpenTelemetry observe le logiciel dans le temps réel et ne devient pas le stockage autoritaire des températures, puissances ou débits simulés dans le temps virtuel.

Les environnements développement, test, démonstration privée et publication publique seront séparés par leurs configurations et secrets. Les migrations de base, versions de contrats, assets et modèles devront être contrôlées lors de chaque déploiement. Les sauvegardes et restaurations de PostgreSQL, TimescaleDB et des manifestes d'artefacts seront testées.

## 7. Cycle d'exécution d'une simulation

**Décision actée :** chaque simulation est un run immuable, isolé et reproductible. Le cockpit soumet une demande contenant le scénario et les paramètres autorisés. L'API authentifie l'appel, valide les schémas, vérifie les références et crée le manifeste du run dans PostgreSQL avant le démarrage de tout calcul.

L'initialisation charge la configuration canonique figée, les bindings vers OpenDSS, Modelica, OpenUSD et les autres modèles, le package SSP lorsqu'il existe, les conditions initiales, les workloads et la file d'événements. Les validations topologiques, sémantiques, dimensionnelles et de compatibilité doivent réussir. Une FMU passe les validateurs de schéma et un import réel avec le couple d'outils verrouillé ; un package SSP est contrôlé contre ses connexions, unités et paramètres. Une incohérence bloquante interrompt l'initialisation avec un diagnostic ; elle ne doit pas être corrigée silencieusement par une valeur par défaut.

Le produit maintient une horloge virtuelle indépendante du temps réel, directement ou par l'intermédiaire du master de co-simulation retenu. Les événements simultanés sont ordonnés par une notion de micro-étape afin de distinguer, à un même instant physique, la cause, le calcul, la commande et le retour d'état. L'exécution avance vers le prochain événement ou prochain rendez-vous d'un modèle plutôt que d'imposer un pas global inutilement fin à tous les domaines. Le moteur C++ conserve dans tous les cas l'autorité sur le scénario, le run et l'audit de cette progression.

À chaque échange, l'orchestrateur fournit aux modèles les entrées cohérentes avec le temps simulé, déclenche le calcul, vérifie les statuts et publie les sorties avec leurs unités, qualités et provenances. Les boucles fortement couplées pourront employer des itérations contrôlées avec tolérance et nombre maximal d'essais. Une absence de convergence produit un état diagnostiqué, un mode dégradé préautorisé ou l'arrêt du run selon le contrat ; elle ne produit pas une valeur présentée comme valide.

OpenDSS recalcule le réseau après les changements topologiques, défauts ou variations de charge significatives. Les FMU Modelica évoluent selon leurs pas et événements. Les automatismes, protections, procédures et workloads produisent des événements discrets. Les résultats CFD pré-calculés ou modèles réduits sont interrogés uniquement dans leur domaine de validité.

Des checkpoints pourront être créés aux frontières sûres afin de reprendre une exécution lourde ou explorer une variante sans rejouer toute l'histoire. Un checkpoint devra inclure tous les états nécessaires et rester compatible avec les versions exactes des modèles ; il ne sera jamais réutilisé après une modification incompatible.

TimescaleDB reçoit les séries et événements sélectionnés selon une politique d'échantillonnage qui conserve les changements d'état et transitoires utiles. Les fichiers lourds sont écrits dans le stockage d'artefacts puis référencés par le manifeste. React et Kit reçoivent une projection de lecture issue du même état autoritaire ; la fréquence d'affichage peut être différente de la fréquence de calcul.

À la fin, le moteur ferme le run, calcule ses métriques, exécute les contrôles d'acceptation et enregistre succès, avertissements ou échecs. Un pipeline distinct peut ensuite créer un artefact Web public expurgé et signé à partir d'un run accepté. Une pause, un replay ou une interpolation visuelle ne modifie jamais les résultats techniques historiques.

## 8. Cas d'usage et scénarios prioritaires

**Décision actée :** les cas d'usage sont ordonnés pour démontrer d'abord une chaîne causale multiphysique complète, puis élargir la profondeur et le cycle de vie. Chaque cas d'usage devra posséder un objectif décisionnel, des utilisateurs, des entrées, un niveau de fidélité, des sorties, des preuves et des limites.

### 8.1 Exploitation nominale et montée en charge

Le jumeau exécute une combinaison représentative d'entraînement IA, d'inférence et de services d'infrastructure. Il montre le placement des workloads, les puissances par baie, les flux électriques, la chaleur, les débits, températures, régulations et marges. Ce cas fournit l'état de référence auquel les scénarios dégradés sont comparés.

### 8.2 Perte du réseau public avec reprise réussie

Le réseau public est perdu sans préécrire la suite. Le modèle doit calculer la continuité par UPS, la décharge des batteries, le démarrage et la stabilisation des groupes, le transfert, les effets temporaires sur le refroidissement, les températures, alarmes, workloads et actions humaines, puis le retour contrôlé à un état stable.

### 8.3 Défaillance de la chaîne de secours

Une variante introduit un groupe indisponible, une batterie dégradée, un transfert refusé ou une surcharge. Le système doit appliquer les protections et priorités, décider du délestage, préserver les services indispensables et quantifier les pertes de service, marges, autonomies et conséquences thermiques.

### 8.4 Défaut électrique et sélectivité

Un défaut est injecté sur une branche identifiée. Les courants et protections déterminent l'isolement. Le cas vérifie qu'une protection correctement coordonnée limite la zone affectée et qu'une mauvaise configuration peut provoquer un déclenchement plus large, sans animer artificiellement le chemin attendu.

### 8.5 Perte ou dégradation du refroidissement

Un groupe froid, une pompe, un ventilateur, une vanne ou un CDU est perdu ou dégradé. Le modèle calcule les débits, inerties, températures d'entrée, points chauds, alarmes, déclassements et réactions informatiques. Les branches air et liquide doivent être observables séparément puis dans leur bilan commun.

### 8.6 Défaillance informatique ou réseau

Une ressource, un switch, un lien ou un service d'infrastructure devient indisponible. Le modèle calcule la perte de capacité, la congestion, les violations de service et les possibilités de reprise, migration ou replanification en tenant compte de leur coût énergétique et temporel.

### 8.7 Automatisme, capteur et intervention humaine

Un capteur dérive, un actionneur reste bloqué, une logique produit une alarme ou un opérateur reçoit une information incomplète. Le cas étudie la détection, la corrélation d'alarmes, les autorisations, le diagnostic, les déplacements, les procédures, les erreurs et la récupération. Il doit permettre de comparer plusieurs procédures ou niveaux de disponibilité des équipes.

### 8.8 Commissioning, maintenance et évolution du site

Le jumeau compare conception, état construit, état mis en service et état exploité. Il permet de tester une séquence de commissioning, une consignation, le remplacement d'un actif, une modification de consigne ou une extension avant application. Les écarts de configuration et leurs effets doivent rester traçables.

### 8.9 Sécurité incendie et évacuation

Un événement de détection déclenche la matrice cause-effet, les alarmes, l'isolement, les actions sur la ventilation ou les alimentations, l'extinction et l'évacuation. La propagation détaillée de fumée ou chaleur sera ajoutée par FDS lorsque des données et une validation adaptées sont disponibles ; la première couverture porte sur la logique, les dépendances et les procédures.

### 8.10 Démonstration commerciale et publication Web

Le parcours public rejoue un sous-ensemble accepté des scénarios avec 3D légère, courbes et explication causale. La démonstration privée permet d'explorer le même run dans Kit, de modifier des paramètres autorisés et de comparer des variantes. Les deux surfaces doivent raconter les mêmes faits et distinguer clairement résultat calculé, donnée synthétique et hypothèse.

## 9. Critères de réussite et d'acceptation

**Décision actée :** un incrément n'est terminé que lorsque son code, ses modèles, ses données, sa visualisation et sa documentation satisfont des critères mesurables. Le photoréalisme ou une démonstration sans erreur visible ne suffisent pas.

### 9.1 Intégrité canonique et sémantique

Tous les actifs du périmètre disposent d'identités stables et de bindings vérifiables vers leurs représentations. Les ports et connexions sont compatibles, les contraintes de base de données passent, chaque IFC importé satisfait le schéma et l'IDS applicables, et la projection ASHRAE 223P/Brick satisfait le profil SHACL figé. Aucun doublon ou mapping orphelin ne peut être ignoré dans un run accepté. Un export Web accepté conserve les UUID et la provenance au moyen de son manifeste USD–glTF.

### 9.2 Reproductibilité et traçabilité

Un scénario déterministe rejoué avec la même configuration et les mêmes versions produit le même ordre causal et des résultats égaux dans les tolérances numériques documentées. Chaque mesure, événement, commande et artefact publié est rattachable à son actif, son modèle, son run, son horodatage et sa provenance.

### 9.3 Crédibilité des modèles

Chaque modèle utilisé pour une affirmation technique possède son dossier de crédibilité, ses vérifications autorisées, son domaine de validité et ses critères d'acceptation. Les bilans de puissance, énergie et masse ferment dans les tolérances justifiées pour le cas. Les tolérances ne seront pas choisies pour faire réussir un modèle après observation du résultat ; elles seront établies à partir de l'usage, des données et des références avant l'acceptation. La CFD documente les incertitudes et convergences demandées par son plan ASME V&V 20 ; les études électriques sélectionnées disposent d'une comparaison indépendante et expliquée.

### 9.4 Couplage de bout en bout

Le scénario de perte réseau doit traverser au minimum l'électricité, le refroidissement, l'informatique, les automatismes, les alarmes et l'intervention humaine sans modification manuelle de l'état interne. Une cause injectée doit produire une timeline explicable et chaque conséquence importante doit pouvoir être reliée aux entrées et règles qui l'ont provoquée.

### 9.5 Robustesse logicielle

Les contrôles de build, Buf, contrats, IDS, SHACL, intégration, scénarios de référence et migrations passent dans l'intégration continue ou dans la campagne planifiée appropriée. Les tests unitaires en sont exclus sauf demande explicite du propriétaire. Les entrées invalides, échecs de solveur, pertes de service, timeouts, messages dupliqués et reprises ne créent pas de résultat silencieusement corrompu. Les sauvegardes et restaurations de PostgreSQL, TimescaleDB et des manifestes d'artefacts sont vérifiées, y compris après une migration représentative.

### 9.6 Performance de l'application d'ingénierie

La tranche verticale complète doit fonctionner sur la machine actuelle sans RTX Pro 6000 et sans épuiser la mémoire physique. Le budget de référence conserve au moins vingt pour cent de mémoire système disponible pendant une démonstration nominale, vise au minimum trente images par seconde dans le viewport de référence et maintient le cockpit réactif pendant le calcul. Les campagnes CFD complètes sont exclues de cette contrainte interactive et s'exécutent hors ligne.

Si une scène dépasse ce budget, le projet doit corriger les payloads, niveaux de détail, instances, textures, fréquence de télémétrie ou modèles actifs avant d'exiger un matériel supérieur. Les mesures seront enregistrées avec la scène, la résolution, le pilote, la configuration graphique, la version Kit et les extensions. La combinaison validée doit survivre à un redémarrage depuis un environnement propre avant d'être inscrite comme baseline.

### 9.7 Performance et accessibilité du site public

Le site doit rester compréhensible sans session GPU distante. Sur une connexion et un ordinateur grand public définis par le protocole de test, le contenu principal doit apparaître en moins de trois secondes, le parcours doit devenir interactif en moins de cinq secondes et la scène doit viser trente images par seconde sur la voie WebGL2 de référence. Le premier téléchargement 3D compressé est limité à vingt-cinq mégaoctets ; les détails supplémentaires sont chargés progressivement. WebGPU ne peut pas devenir une condition d'accès tant que la baseline de compatibilité ne l'autorise pas explicitement.

Le parcours essentiel doit rester utilisable au clavier, les informations critiques ne dépendront pas uniquement de la couleur et une alternative textuelle ou audiovisuelle sera disponible lorsque la 3D ne peut pas être rendue. Les budgets pourront être resserrés après mesure, mais pas élargis sans justification documentée.

### 9.8 Sécurité et confidentialité

Les accès, rôles, secrets, journaux, dépendances, licences et exports publics satisfont les règles de la section 5.19. Aucun contrôle public ne permet d'accéder aux services d'ingénierie ou à une future zone OT. Les données et assets publiés ont fait l'objet d'une revue de diffusion et les vulnérabilités critiques connues sont traitées ou formellement acceptées avant livraison. La distribution possède son SBOM, son registre de licences logicielles et d'assets, sa politique de support et son analyse d'applicabilité CRA, NIS2, Data Act et RGPD.

### 9.9 Qualité pédagogique et commerciale

Un prospect non spécialiste doit pouvoir comprendre le problème, la chaîne causale, la décision soutenue et la transférabilité vers son secteur. Un ingénieur doit pouvoir retrouver les hypothèses, variables, modèles, limites et preuves. Les termes jumeau numérique, temps réel, prédiction, validation et IA ne seront utilisés que dans le sens réellement démontré.

### 9.10 Définition de terminé

Une capacité est terminée lorsque ses exigences sont traçables, son code et ses données sont versionnés, ses vérifications autorisées passent, ses performances sont mesurées, sa sécurité et ses licences sont revues, sa documentation est à jour, son exemple reproductible fonctionne depuis un environnement propre et ses limites sont publiées. Une vidéo ou une capture ne remplace pas ces preuves.

## 10. Hors périmètre et limites

**Décision actée :** les limites suivantes évitent de confondre profondeur professionnelle et simulation universelle. Elles pourront évoluer par décision documentée, mais ne doivent pas être contournées implicitement.

Le projet n'est pas un outil certifié de dimensionnement, de sélectivité, de protection incendie ou de conformité réglementaire. Les résultats destinés à un site client devront être revus et, lorsque nécessaire, produits ou validés avec les outils, données et professionnels habilités appropriés.

Le jumeau interactif ne calcule pas en permanence les transitoires électromagnétiques à la microseconde, chaque paquet réseau, chaque instruction processeur, la combustion détaillée ou la CFD complète du bâtiment. Ces phénomènes peuvent être étudiés par des outils spécialisés puis référencés, agrégés ou réduits lorsqu'ils sont nécessaires à une décision.

FDS ne sera pas utilisé pour simuler l'évacuation et PhysicsNeMo ne sera pas ajouté pour produire artificiellement une couche IA. Le réseau informatique restera agrégé tant qu'un cas n'exige pas une étude paquet par paquet avec ns-3. Les connecteurs BACnet, OPC UA, MQTT, DCGM, Slurm ou Kubernetes ne seront pas inclus dans le noyau avant l'existence d'une source réelle, d'un contrat et d'un cas de décision.

Le site public ne lance pas de solveur autoritaire et n'offre pas une session Omniverse anonyme permanente. Il rejoue des artefacts contrôlés. La commande d'équipements réels, la connexion bidirectionnelle à une installation de production et le traitement de données client sensibles ne font pas partie du démonstrateur public.

Le projet ne reproduit pas un site réel sensible et n'utilise pas sans autorisation des plans, marques, modèles constructeurs, données de panne ou données d'exploitation propriétaires. Le site de référence reste fictif, même lorsque ses paramètres sont inspirés de documents publics ou de composants représentatifs.

Le projet ne remplace pas NVIDIA Omniverse, OpenDSS, Modelica, OpenFOAM, un BMS, un DCIM ou un outil d'ingénierie commercial. Sa valeur est l'intégration cohérente, la sémantique, l'orchestration, les modèles adaptés, l'explicabilité, la publication et l'expérience métier.

L'intégralité du bâtiment et tous les niveaux de détail ne seront pas chargés ni calculés simultanément sur le poste local. La couverture finale du cycle de vie est obligatoire, mais sa construction est incrémentale et chaque vue utilise la fidélité nécessaire à son usage.

## 11. Organisation du monorepo et gouvernance technique

**Décision actée :** le produit est développé dans le présent dépôt greenfield, distinct du clone NVIDIA DSX. Le clone DSX reste une référence en lecture seule pour étudier des patterns, assets autorisés et extensions. Aucun composant du produit ne dépendra de l'interface DSX ou d'un fichier présent uniquement dans ce clone.

Le nom commercial définitif reste un choix de marque sans effet sur l'architecture. Cette spécification est la référence du dépôt. Les composants NVIDIA réutilisés devront être identifiés avec leur licence, leur version et la raison de leur utilisation.

La structure cible est la suivante :

```text
apps/
  engineering-cockpit/    React, TypeScript et vues opérationnelles
  public-site/             vitrine et replay Web 3D
  omniverse-kit/           application et extensions Kit
services/
  orchestrator/            cœur C++ et horloge virtuelle
  api/                     passerelle FastAPI
  semantic/                projection RDF, SHACL et requêtes
adapters/
  opendss/ modelica/ openfoam/ fds/ telemetry/
packages/
  contracts/ domain-model/ scenario-schema/ semantic-profile/ ui/
models/
  electrical/ thermal/ hydraulic/ airflow/ compute/ controls/ human/
assets/
  source/ usd/ web/ materials/
data/
  reference/ synthetic/ validation/
database/
  migrations/ seeds/ policies/
infra/
  compose/ observability/ deployment/
tests/
  contract/ integration/ scenarios/ performance/ security/
docs/
  specification/ toolchain/ architecture-decisions/ models/ procedures/ reports/
tools/
  asset-pipeline/ publication/ validation/ cosimulation-spikes/
```

Les contrats Protocol Buffers, schémas de scénario, packages SSP, profil sémantique, IDS, manifestes d'artefacts et migrations sont des produits versionnés. Une modification incompatible nécessite une migration ou une nouvelle version ; elle ne doit pas être synchronisée manuellement dans plusieurs langages. Les générateurs seront privilégiés pour les types et clients dérivables. Buf contrôlera les contrats Protobuf, dbmate appliquera les migrations SQL et mp-units protégera les grandeurs C++.

Le code C++, Python, TypeScript, modèles Modelica, définitions OpenDSS, schémas, fichiers USDA et documentation textuelle seront revus et vérifiés par les moyens autorisés adaptés. Les assets binaires volumineux seront placés dans le stockage d'artefacts ou Git LFS seulement lorsqu'une révision Git est réellement nécessaire. Les sources, fichiers importés, dérivés d'exécution et artefacts publics ne devront pas être confondus.

Chaque décision architecturale structurante recevra un ADR. Chaque modèle recevra une fiche de crédibilité. Chaque scénario recevra une spécification et un rapport de référence. Les propriétaires de code peuvent être une même personne au départ, mais les responsabilités restent explicites afin de permettre une future équipe.

## 12. Stratégie d'incréments et feuille de route

**Décision actée :** le développement suit des tranches verticales démontrables et des portes de sortie explicites. Un incrément ne commence pas parce que le précédent paraît visuellement avancé ; il commence lorsque les contrats, artefacts et preuves dont il dépend sont disponibles. Aucun calendrier arbitraire n'est inscrit avant estimation du backlog et mesure des prototypes. L'ordre ci-dessous protège le chemin critique, mais autorise les travaux parallèles qui n'introduisent ni seconde source de vérité ni intégration fictive.

### 12.1 Gouvernance, décisions irréversibles et environnement reproductible

Le dépôt existe déjà et `docs/toolchain/TOOLCHAIN_BASELINE.md` fixe désormais la première sélection argumentée de C++, Visual Studio, CMake, vcpkg, Node, Python, PostgreSQL, TimescaleDB, Kit et des outils transverses. La première tranche d'implémentation matérialise cette baseline dans les manifests, verrous, scripts de contrôle et la matrice pilote–Kit–extensions, puis mesure les candidates avant leur promotion. Elle décide l'édition TimescaleDB, initialise dbmate, vcpkg, uv, Buf, les secrets locaux, le stockage adressé par contenu, le SBOM et le registre de licences des assets. Les ADR initiaux couvrent l'identité canonique, les formats et autorités, la licence TimescaleDB, le stockage d'artefacts, la stratégie Kit et la sécurité des zones.

La porte de sortie est un clone propre capable de vérifier les versions, lancer les services de fondation, appliquer puis rejouer les migrations, sauvegarder et restaurer une base vide, écrire et relire un artefact par empreinte, et produire les inventaires de dépendances sans secret ni étape manuelle non documentée.

### 12.2 Squelette vertical de bout en bout

Cette tranche crée un seul actif fictif et un seul run sans physique complexe, mais traverse déjà la future architecture. PostgreSQL porte l'UUID et sa configuration ; un contrat Protobuf validé par Buf atteint le moteur C++ ; FastAPI expose une projection ; Kit affiche un prim lié à l'UUID ; React sélectionne le même actif ; TimescaleDB reçoit une petite série ; le pipeline produit un GLB et un manifeste public contenant la même identité. OpenTelemetry corrèle l'exécution réelle au run sans remplacer ses séries simulées.

La porte de sortie est une démonstration reproductible depuis un environnement propre dans laquelle la sélection et la provenance sont cohérentes de la base jusqu'à Kit, React et l'export Web. Une rupture Protobuf, un mapping orphelin, une unité absente ou une migration invalide doit échouer avec un diagnostic. Cette tranche empêche de repousser l'intégration et la publication à la fin du projet.

### 12.3 Pipeline BIM, CAO, sémantique et assets

La chaîne d'ingestion traite un petit IFC 4.3 contrôlé par une IDS, extrait ses entités avec IfcOpenShell, produit un rapport IfcTester, crée ou associe les actifs canoniques et génère un dérivé USD. Elle ajoute un équipement STEP ou JT converti par le service CAD, les règles de repère et d'unité, les variantes et LOD, la fiche de provenance, les droits de publication et le premier profil ASHRAE 223P/Brick validé par SHACL. Le mapping IFC–registre–USD–RDF reste explicite et versionné.

La porte de sortie exige qu'une modification de nom, de hiérarchie visuelle ou de LOD ne change pas l'identité, qu'un IFC non conforme soit rejeté avant import, que chaque asset publié possède une licence et une empreinte, et que la sélection reste synchronisée après optimisation USD et export glTF.

### 12.4 Preuve de co-simulation et architecture temporelle

Un prototype minimal couple une source électrique simplifiée, une FMU thermique et un automate discret. Le même scénario est exécuté avec HELICS, OMSimulator/SSP et la boucle C++ minimale. FMI 2.0.5 est la baseline ; une FMU FMI 3.0.2 est évaluée seulement si l'exporteur et l'importeur verrouillés la supportent. Les essais couvrent rendez-vous temporels, événements simultanés, pas différents, convergence, timeout, état invalide, arrêt, reprise, checkpoint et déterminisme.

La porte de sortie est un ADR qui retient le mécanisme de synchronisation et documente les alternatives rejetées, les limites et le plan de repli. Le scénario rejoué doit conserver l'ordre causal et les résultats dans les tolérances, et son package SSP doit suffire à reconstruire les connexions et paramètres de modèles sans devenir une copie du registre métier.

### 12.5 Tranche électrique crédible

La tranche construit la chaîne HTA–BT–UPS–batterie–groupe–ATS/STS–PDU–baies et auxiliaires dans le registre, OpenDSS et C++. Elle introduit états, manœuvres, interverrouillages, courbes, protections, pertes, charge réellement fournie, carburant et délestage. Les valeurs sont synthétiques et sourcées ou clairement déclarées comme telles. Kit et React ne font qu'expliquer les résultats autoritaires.

La porte de sortie comprend le bilan électrique, des cas manuels, les séquences réseau–UPS–groupe, un défaut isolé et des points de court-circuit recalculés avec pandapower selon IEC 60909. Les écarts sont expliqués. Aucune revendication de réglage réel ou de conformité n'est faite sans revue compétente ou outil d'ingénierie approprié.

### 12.6 Tranche thermohydraulique, aéraulique et CFD

La tranche verrouille Modelica Buildings et OpenModelica, puis représente production frigorifique, pompes, échangeurs, branche air, CRAH, inerties, CDU et refroidissement direct-to-chip. Elle ferme le bilan entre puissance informatique, pertes électriques et chaleur évacuée. Un cas OpenFOAM limité mais représentatif est exécuté sous WSL2 ou Linux, avec maillage, résidus, conditions aux limites, convergence et export VTK. Un modèle réduit non neuronal est construit en premier pour l'interactivité.

La porte de sortie exige la conservation de la masse et de l'énergie, des comparaisons analytiques ou constructeur, un plan ASME V&V 20, une étude de sensibilité de maillage et un modèle réduit qui annonce son erreur et refuse ou signale les entrées hors domaine. PhysicsNeMo ne peut être envisagé qu'après cette preuve et après constitution d'un corpus séparant entraînement et validation.

### 12.7 Charge informatique, réseau et boucle cyber-physique

La tranche introduit les ressources physiques, les trois classes de workloads, les files, politiques de placement, profils de puissance, chaleur localisée, checkpoint, migration, throttling et un modèle agrégé de réseau. Elle ferme la boucle dans laquelle l'activité informatique crée charge et chaleur, tandis que l'alimentation et le refroidissement limitent la performance et modifient l'ordonnancement. Les contrats futurs de DCGM, Slurm ou Kubernetes peuvent être simulés, mais aucun connecteur réel n'est requis.

La porte de sortie est un run où un changement de workload modifie de manière traçable puissance, température et performance, puis où une contrainte physique provoque une décision informatique explicable. Un modèle paquet par paquet ou ns-3 ne sera ajouté que si une conclusion dépend de cette fidélité.

### 12.8 Automatismes, supervision, sécurité et humain

La tranche ajoute capteurs, actionneurs, régulations, machines à états, matrices cause-effet, BMS/EPMS/DCIM simulés, alarmes, modes, contrôle d'accès, détection incendie, rôles, habilitations et procédures. Elle distingue ordre, accusé, retour d'état, observation et état physique. Les délais de détection, diagnostic, déplacement et action restent sourcés ou synthétiques identifiés. La fumée et la chaleur détaillées peuvent ultérieurement utiliser FDS ; l'évacuation reste dans le modèle procédural, jamais dans FDS+Evac.

La porte de sortie vérifie les interverrouillages, bandes mortes, alarmes, droits, modes dégradés, erreur de capteur et intervention humaine sur une timeline causale. Aucun adaptateur OT réel n'est nécessaire ; les futures frontières BACnet/SC, BACnet/IP legacy, OPC UA et MQTT/Sparkplug sont testées par contrats et restent en lecture seule.

### 12.9 Scénario transversal de référence et dossier de crédibilité

Le scénario de perte du réseau public assemble tous les domaines sans modification manuelle de leur état interne. Il calcule UPS, batteries, démarrage et connexion des groupes, reprise ou perte du froid, températures, puissance disponible, workloads, alarmes et actions humaines. Ses variantes couvrent groupe indisponible, batterie dégradée, pompe perdue, capteur erroné et erreur de procédure. Les métriques ISO/IEC 30134 ou de disponibilité utilisées déclarent leurs frontières.

La porte de sortie comprend les dossiers NASA-STD-7009B, les preuves de domaine, les incertitudes, sensibilités, bilans, comparaisons indépendantes, limites et niveaux de preuve publics. Le run est immuable, rejouable, comparable et explique chaque conséquence importante. Aucun scénario ne passe à la publication commerciale avant cette acceptation.

### 12.10 Application d'ingénierie haute fidélité

Cette tranche transforme les surfaces minimales en outil cohérent : navigation, inspection, recherche, coupes, isolation de systèmes, overlays électriques et thermiques, courbes, alarmes, procédures, comparaison de runs, diagnostics de solveur et explication causale. La scène utilise payloads, instanciation, LOD et textures adaptées à la machine. La baseline pilote–Kit–extensions et les droits de redistribution sont figés pour la démonstration.

La porte de sortie reprend les budgets de mémoire, trente images par seconde et réactivité du cockpit sur la machine actuelle, avec mesures enregistrées. Une session Kit App Streaming/WebRTC privée est testée séparément ; son échec ne doit pas rendre le dossier d'ingénierie local inutilisable.

### 12.11 Publication Web et parcours commercial

La chaîne de publication transforme uniquement un run accepté et une scène autorisée en glTF/GLB optimisé, textures KTX2, LOD, séries agrégées et manifeste public. Le site propose parcours prospect, exploration libre, explication causale, hypothèses, niveau de preuve, transférabilité sectorielle et appel à action. WebGL2 reste la baseline ; WebGPU est une amélioration progressive et une alternative guidée, textuelle ou audiovisuelle couvre les appareils insuffisants.

La porte de sortie combine budgets de chargement et de fluidité, accessibilité, contrôle clavier, confidentialité, absence de lien vers l'ingénierie ou l'OT et vérification de chaque droit de publication. Le récit public et la démonstration Kit doivent décrire les mêmes faits sans transformer une donnée synthétique en mesure réelle ni une comparaison en certification.

### 12.12 Cycle de vie, télémétrie réelle et offres réutilisables

Après la preuve publique, le produit étend les configurations `as-designed`, `as-built`, `as-commissioned` et `as-operated`, puis les workflows de commissioning, exploitation, maintenance, formation, modification et fin de vie. Un premier connecteur réel en lecture seule pourra être choisi selon un cas client : BACnet/SC ou passerelle BACnet/IP, OPC UA, Haystack, MQTT/Sparkplug, DCGM, Slurm ou Kubernetes. L'offre est déclinée du produit connecté et jumeau télémétrique jusqu'au jumeau multiphysique.

La porte de sortie exige une analyse d'autorité et de sécurité du connecteur, la réconciliation entre données réelles et simulées, les exports Data Act applicables, la protection des données personnelles, la stratégie CRA/NIS2, les responsabilités client et les limites contractuelles. Les composants réutilisables sont extraits seulement après une seconde utilisation réelle ou démontrée, pas par anticipation.

### 12.13 Discipline d'exécution et prévention du slop

Chaque tranche commence par une exigence, une source de vérité, un contrat, une donnée d'entrée, un critère d'acceptation et un responsable identifiés. Elle se termine par une démonstration reproductible depuis un environnement propre, les vérifications autorisées, une mesure de performance, une revue des risques et licences, les artefacts de preuve et la documentation à jour. Les tests unitaires restent exclus sauf demande explicite du propriétaire ; cette règle ne permet pas d'omettre compilation, contrats, intégrations, scénarios, bilans, migrations ou comparaisons nécessaires.

Le backlog ne doit pas ouvrir simultanément plusieurs squelettes sans intégration. Un framework, microservice, bus, ontologie, connecteur ou modèle IA n'entre dans le produit qu'en réponse à une exigence de la tranche active et après comparaison avec l'existant. Aucun code généré, fausse donnée, écran vide, abstraction sans consommateur ou asset sans provenance ne compte comme progression. Une tranche bloquée produit un diagnostic et une décision explicite ; elle n'est pas contournée par une couche visuelle plus spectaculaire.

## 13. Décisions considérées comme actées

- OpenUSD est la colonne vertébrale de la scène d'ingénierie ; Omniverse Kit, construit depuis le Kit App Template moderne avec versions verrouillées, assure le rendu RTX et l'interaction haute fidélité.
- React assure le cockpit et le site public ; React Three Fiber, WebGL2 et glTF/GLB assurent la 3D publique dérivée, tandis que WebGPU reste une amélioration progressive.
- Kit desktop est le mode principal de développement ; WebRTC est réservé aux démonstrations distantes temporaires et dimensionnées.
- Le moteur produit est développé en C++20 avec mp-units et communique par gRPC/Protocol Buffers ; Buf contrôle l'évolution des contrats.
- `docs/toolchain/TOOLCHAIN_BASELINE.md` gouverne les versions, statuts de validation et compatibilités ; les verrous exécutables doivent lui rester cohérents et aucune mise à niveau majeure ne peut être silencieuse.
- FMI 2.0.5 est la baseline de production, FMI 3.0.2 est promu modèle par modèle après preuve et SSP 2.0.1 décrit les systèmes composés.
- Le master temporel sera choisi par ADR après comparaison HELICS, OMSimulator/SSP et boucle C++ minimale ; le C++ conserve scénarios, runs, audit et politiques.
- Les solveurs spécialisés restent les sources de vérité de leur domaine et l'orchestrateur ne réimplémente pas leurs lois physiques.
- PostgreSQL et TimescaleDB sont utilisés dès le début ; PostgreSQL porte le registre canonique, TimescaleDB les séries temporelles et dbmate les migrations SQL partagées.
- L'édition Apache-only de TimescaleDB est retenue par l'ADR 0001 ; une autre édition exige une nouvelle décision et aucune restriction de service ne sera ignorée dans une offre hébergée.
- Les fichiers lourds sont adressés par contenu dans un stockage local abstrait puis compatible S3 ; MinIO n'est pas une dépendance par défaut et Git porte le code, contrats et sources textuelles.
- Parquet porte les exports tabulaires, Zarr v3 les tableaux multidimensionnels, VTK les champs de visualisation, OpenUSD la scène, glTF le Web, FMI les composants et SSP leurs assemblages.
- ASHRAE 223P constitue la cible sémantique versionnée et Brick la complète ; IFC 4.3, IDS, bSDD, IfcOpenShell et IfcTester portent l'échange et le contrôle BIM.
- Project Haystack, Asset Administration Shell et RealEstateCore sont de futurs adaptateurs de cas client, pas des modèles canoniques concurrents.
- Le domaine électrique couvre la distribution triphasée depuis l'arrivée HTA jusqu'aux serveurs avec OpenDSS pour le run RMS et pandapower pour des vérifications indépendantes IEC 60909.
- La simulation électrique opérationnelle couvre quelques dizaines de millisecondes à plusieurs heures ; les études EMT et validations engageantes restent externes lorsqu'elles sont nécessaires.
- Le refroidissement de référence est hybride : air pour les baies classiques et liquide direct-to-chip pour les baies IA.
- Modelica Buildings avec OpenModelica porte la dynamique thermohydraulique ; OpenFOAM sous WSL2 ou Linux porte la CFD hors ligne et valide un modèle réduit interactif.
- FDS est réservé à la fumée et la chaleur ; FDS+Evac est exclu, et PhysicsNeMo attend un corpus validé et une valeur démontrée face à un modèle réduit plus simple.
- Les charges informatiques dépendent des workloads, ressources et états ; le réseau reste agrégé jusqu'à ce qu'un besoin justifie ns-3 ou une autre fidélité paquet.
- Les automatismes, BMS, EPMS, DCIM, dispositifs de sécurité et opérateurs sont exécutables, traçables et reliés aux modèles physiques.
- BACnet/SC est la cible des intégrations BMS modernes ; BACnet/IP reste derrière une passerelle legacy, OPC UA couvre les équipements industriels et MQTT utilise Sparkplug lorsqu'il est retenu.
- Les scénarios injectent des causes et laissent les modèles calculer les conséquences ; les runs sont immuables, rejouables et comparables.
- Chaque modèle et affirmation technique exige un dossier de crédibilité, un domaine de validité, des preuves et des limites ; NASA-STD-7009B et ASME V&V 20 structurent les dossiers concernés.
- Les tests unitaires sont exclus par défaut et ne peuvent être créés ou exécutés que sur demande explicite du propriétaire ; les vérifications de build, contrat, IDS, SHACL, intégration, scénario, migration et crédibilité restent obligatoires selon le risque.
- La plateforme sépare site public, services, simulation, ingénierie et OT ; les connecteurs réels sont en lecture seule et les obligations potentielles CRA, NIS2, Data Act et RGPD sont analysées avant commercialisation.
- Le premier produit fonctionne sur la machine actuelle sans RTX Pro 6000 grâce aux payloads, LOD, modèles réduits et calculs lourds hors ligne ; les grandes campagnes restent exportables vers Linux ou HPC.
- Le data center sert de démonstrateur de compétences transférables et non de spécialisation commerciale exclusive.
- Le site public n'exécute ni Omniverse ni solveur autoritaire ; il rejoue des artefacts acceptés, expurgés et manifestés, et reste utile sans GPU NVIDIA.
- La cible couvre tout le cycle de vie, mais sa construction suit la feuille de route à portes de sortie et sa discipline anti-slop.
- Le produit est développé dans ce monorepo greenfield distinct du clone NVIDIA DSX, conservé comme référence en lecture seule.

## 14. Paramètres contrôlés restant à établir

Les décisions d'architecture nécessaires à l'initialisation sont actées. Les éléments suivants ne doivent pas être inventés dans le code ; ils seront produits comme données ou documents d'ingénierie versionnés au cours des incréments correspondants.

- le nom commercial et l'éventuel renommage du dépôt existant ;
- le schéma unifilaire exact, les tensions nominales, puissances, redondances, protections et régimes de neutre du site fictif ;
- le schéma de principe hydraulique, les régimes de température, débits, puissances, courbes et stratégies de contrôle ;
- le plan, le nombre de baies, leurs densités et la géométrie détaillée de la tranche de référence ;
- les modèles précis de serveurs ou équipements représentatifs, leurs courbes de puissance et leurs licences de représentation ;
- les distributions de panne et de temps humain, qui devront être sourcées ou explicitement marquées synthétiques ;
- les tolérances numériques et physiques propres à chaque dossier de crédibilité ;
- la liste exacte des fonctions TimescaleDB Apache-only nécessaires et leur comportement mesuré sur les volumes de référence ;
- le résultat du prototype HELICS–OMSimulator/SSP–boucle C++ et le master temporel retenu par ADR ;
- la promotion après smoke test des versions candidates de Kit, de ses extensions, du pilote NVIDIA, de Modelica Buildings, d'OpenModelica, d'OpenDSS et d'OpenFOAM inscrites dans la baseline de toolchain ;
- les profils FMI réellement acceptés par chaque couple exporteur–importeur et les validateurs employés ;
- l'IDS initiale, le profil ASHRAE 223P/Brick et les mappings IFC–registre–USD–RDF ;
- la matrice des normes et clauses effectivement appliquées au site fictif ;
- les politiques initiales de rétention, compression et agrégation TimescaleDB, établies après mesure des débits ;
- les seuils de passage de TimescaleDB vers Parquet, Zarr ou VTK et les politiques de conservation des résultats natifs ;
- les budgets finaux de géométrie et de textures, resserrés après le prototype de performance ;
- les droits de publication relatifs à l'expérience CRE Technology et à tout asset ou donnée tiers.

Ces paramètres n'empêchent pas de créer le monorepo, les contrats, le registre, les composants minimaux et les pipelines. Ils deviennent bloquants uniquement avant l'acceptation du modèle ou de la capacité qui les utilise.

## 15. Validation de la spécification

**Décision actée :** le cadrage fonctionnel, l'architecture, les domaines, la méthode de simulation, la stratégie de crédibilité, la sécurité, les cas d'usage, les critères d'acceptation et la feuille de route décrits dans ce document constituent la référence de départ du projet. Cette spécification intègre les conclusions de la revue adversariale des outils, normes, licences, formats, contraintes matérielles et alternatives effectuée au 1er août 2026 ; aucun rapport d'architecture séparé n'est nécessaire pour interpréter les décisions courantes.

Le document ne reçoit pas encore de numéro de version. Une version formelle sera attribuée après la relecture globale, le choix du nom du produit et la correction des éventuelles contradictions résiduelles. Cette étape n'empêche pas le bootstrap technique du monorepo existant.

Toute modification future d'une décision actée devra être explicite, justifiée et reliée à un ADR lorsqu'elle affecte l'architecture, un modèle ou un engagement. Les valeurs d'ingénierie encore absentes seront ajoutées comme configurations et preuves versionnées, sans réécrire l'intention générale.

## 16. Références structurantes

Les références suivantes orientent la méthode sans impliquer automatiquement une conformité : OpenUSD et NVIDIA Omniverse pour la scène et l'application 3D ; ASHRAE 223P et Brick pour la sémantique opérationnelle ; IFC 4.3, IDS et bSDD pour l'échange et les exigences BIM ; FMI 2.0.5, FMI 3.0.2, SSP 2.0.1 et Modelica pour les modèles dynamiques et systèmes composés ; NASA-STD-7009B et ASME V&V 20 pour la crédibilité ; NIST SP 800-82 Rev. 3, NIST SSDF et IEC 62443 pour la cybersécurité ; glTF et KTX de Khronos pour la livraison 3D Web.

Les référentiels métier comprennent la famille ISO/IEC 22237 et EN 50600 pour les infrastructures de data centers, IEC 60909 pour les études de court-circuit applicables, ASHRAE 90.4-2025 et TC 9.9 pour l'énergie et la thermique, ISO/IEC 30134 pour les indicateurs et ISO/IEC 30173:2023 pour les concepts de jumeau numérique. Les obligations européennes à qualifier avant commercialisation comprennent le Cyber Resilience Act, NIS2, le Data Act et le RGPD.

Les éditions, profils et sous-parties applicables devront être figés dans les ADR ou dossiers de domaine au moment de leur implémentation. Les textes normatifs payants devront être acquis légalement si une conformité ou une application détaillée est requise.

Les sources publiques de scène et d'application comprennent l'[introduction OpenUSD](https://openusd.org/release/intro.html), le [Kit App Template](https://docs.omniverse.nvidia.com/services/latest/developer/app_template.html), le [packaging Kit](https://docs.omniverse.nvidia.com/kit/docs/kit-app-template/latest/docs/packaging_app.html), le [Kit App Streaming](https://docs.omniverse.nvidia.com/kit/docs/kit-app-template/latest/docs/streaming.html), les [exigences techniques Omniverse](https://docs.omniverse.nvidia.com/dev-overview/latest/common/technical-requirements.html), le [CAD Converter](https://docs.omniverse.nvidia.com/extensions/latest/ext_cad-converter/manual.html), [glTF](https://www.khronos.org/gltf/), [KTX](https://www.khronos.org/ktx/) et les pratiques de [performance React Three Fiber](https://r3f.docs.pmnd.rs/advanced/scaling-performance).

Les sources d'intégration et de calcul comprennent la documentation [FMI 3.0.2](https://fmi-standard.org/docs/3.0.2/), la [validation FMI](https://fmi-standard.org/validation/), [SSP](https://ssp-standard.org/docs/main/), le support [FMI d'OpenModelica](https://openmodelica.org/doc/OpenModelicaUsersGuide/latest/fmitlm.html), [OMSimulator](https://openmodelica.org/doc/OMSimulator/master/OMSimulator/UsersGuide/html/introduction.html), [HELICS](https://docs.helics.org/en/latest/user-guide/co-simulation_overview.html), [Modelica Buildings](https://simulationresearch.lbl.gov/modelica/), les [capacités OpenDSS](https://opendss.epri.com/AboutOpenDSSCapabilities.html), les calculs [IEC 60909 de pandapower](https://pandapower.readthedocs.io/en/latest/shortcircuit.html), [OpenFOAM](https://openfoam.org/download/), les [manuels FDS](https://pages.nist.gov/fds/manuals.html), [PhysicsNeMo](https://docs.nvidia.com/physicsnemo/index.html) et [DCGM](https://docs.nvidia.com/datacenter/dcgm/latest/).

Les sources de données et d'interopérabilité comprennent [IfcOpenShell et IfcTester](https://docs.ifcopenshell.org/introduction.html), l'[IDS buildingSMART](https://www.buildingsmart.org/standards/bsi-standards/information-delivery-specification-ids/), la documentation [ASHRAE 223P](https://docs.open223.info/overview/), les [connexions Brick fondées sur 223P](https://docs.brickschema.org/modeling/connections.html), les [éditions TimescaleDB](https://docs.timescale.com/about/latest/timescaledb-editions/), [Parquet](https://parquet.apache.org/docs/file-format/), [Zarr](https://zarr.readthedocs.io/en/main/user-guide/glossary/), les [formats VTK](https://docs.vtk.org/en/latest/vtk_file_formats/index.html), [BACnet/SC](https://bacnetinternational.org/bacnetsc/), [OPC UA](https://reference.opcfoundation.org/specs/OPC-10000-1/4), [Sparkplug](https://sparkplug.eclipse.org/specification/) et le contrôle de compatibilité [Buf](https://buf.build/docs/breaking/).

Les sources de crédibilité, sécurité et réglementation comprennent [NASA-STD-7009B](https://standards.nasa.gov/standard/nasa/nasa-std-7009), [ASME V&V 20](https://www.asme.org/codes-standards/find-codes-standards/standard-for-verification-and-validation-in-computational-fluid-dynamics-and-heat-transfer/2009), [NIST SP 800-82 Rev. 3](https://csrc.nist.gov/pubs/sp/800/82/r3/final), le [NIST Secure Software Development Framework](https://csrc.nist.gov/pubs/sp/800/218/final), le [Cyber Resilience Act](https://eur-lex.europa.eu/eli/reg/2024/2847/2024-11-20/eng), les [questions-réponses NIS2](https://digital-strategy.ec.europa.eu/en/faqs/directive-measures-high-common-level-cybersecurity-across-union-nis2-directive-faqs) et le [Data Act](https://eur-lex.europa.eu/eli/reg/2023/2854/oj).
