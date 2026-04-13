import 'settings_provider.dart';

// ─── Data classes ────────────────────────────────────────────────

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuizCategory category;
  final Difficulty difficulty;

  const Question({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

class FlashQuestion {
  final String statement;
  final bool isTrue;
  final String explanation;
  final QuizCategory category;
  final Difficulty difficulty;

  const FlashQuestion({
    required this.statement,
    required this.isTrue,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

enum ScenarioType { good, caution, forbidden }

class Scenario {
  final String title;
  final String description;
  final ScenarioType correctType;
  final String explanation;
  final String icon;
  final QuizCategory category;
  final Difficulty difficulty;

  const Scenario({
    required this.title,
    required this.description,
    required this.correctType,
    required this.explanation,
    required this.icon,
    required this.category,
    required this.difficulty,
  });
}

class MatchPair {
  final String term;
  final String definition;

  const MatchPair(this.term, this.definition);
}

class MatchSet {
  final String title;
  final List<MatchPair> pairs;
  final QuizCategory category;
  final Difficulty difficulty;

  const MatchSet({
    required this.title,
    required this.pairs,
    required this.category,
    required this.difficulty,
  });
}

class OrderChallenge {
  final String title;
  final String instruction;
  final List<String> correctOrder;
  final String explanation;
  final QuizCategory category;
  final Difficulty difficulty;

  const OrderChallenge({
    required this.title,
    required this.instruction,
    required this.correctOrder,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

class WhoAmIRound {
  final List<String> clues;
  final String answer;
  final List<String> decoys;
  final String explanation;
  final QuizCategory category;
  final Difficulty difficulty;

  const WhoAmIRound({
    required this.clues,
    required this.answer,
    required this.decoys,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

// ─── Filtering helper ────────────────────────────────────────────

List<T> _filter<T>(
  List<T> items,
  SettingsProvider s,
  QuizCategory Function(T) getCat,
  Difficulty Function(T) getDiff,
) {
  return items.where((e) {
    return s.isCategoryEnabled(getCat(e)) && s.matchesDifficulty(getDiff(e));
  }).toList();
}

// ─── Public access ───────────────────────────────────────────────

class QuizData {
  static List<Question> getQuestions(SettingsProvider s) =>
      _filter(questions, s, (q) => q.category, (q) => q.difficulty);

  static List<FlashQuestion> getFlashQuestions(SettingsProvider s) =>
      _filter(flashQuestions, s, (q) => q.category, (q) => q.difficulty);

  static List<Scenario> getScenarios(SettingsProvider s) =>
      _filter(scenarios, s, (q) => q.category, (q) => q.difficulty);

  static List<MatchSet> getMatchSets(SettingsProvider s) =>
      _filter(matchSets, s, (q) => q.category, (q) => q.difficulty);

  static List<OrderChallenge> getOrderChallenges(SettingsProvider s) =>
      _filter(orderChallenges, s, (q) => q.category, (q) => q.difficulty);

  static List<WhoAmIRound> getWhoAmIRounds(SettingsProvider s) =>
      _filter(whoAmIRounds, s, (q) => q.category, (q) => q.difficulty);

  // ─── QCM Questions ───────────────────────────────────────────

  static const questions = <Question>[
    // ═══ IA Générative — Débutant ═══
    Question(
      question: "Qu'est-ce que l'IA générative ?",
      options: [
        "Un robot humanoïde",
        "Une IA capable de créer du contenu original (texte, image, code…)",
        "Un moteur de recherche amélioré",
        "Un logiciel de comptabilité automatisée",
      ],
      correctIndex: 1,
      explanation:
          "L'IA générative est une famille d'IA dédiée à la génération de contenus réalistes et originaux : texte, images, code, audio, vidéo.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "En quelle année l'IA générative a-t-elle émergé comme technologie grand public ?",
      options: ["1997", "2012", "2021", "2023"],
      correctIndex: 2,
      explanation:
          "L'IA générative a émergé en 2021, après le Machine Learning (1997) et le Deep Learning (2012).",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "En combien de temps ChatGPT a-t-il atteint 100 millions d'utilisateurs ?",
      options: ["6 mois", "1 an", "2 mois", "2 semaines"],
      correctIndex: 2,
      explanation:
          "Record absolu : 2 mois seulement, contre 9 mois pour TikTok et 5 ans pour Facebook.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "L'IA générative peut créer…",
      options: [
        "Uniquement du texte",
        "Du texte et des images",
        "Du texte, des images, du code et de l'audio",
        "Rien d'original, elle copie Internet",
      ],
      correctIndex: 2,
      explanation:
          "Les modèles génératifs produisent texte, images, code, audio et même vidéo. C'est une grande variété d'usages.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    // ═══ IA Générative — Intermédiaire ═══
    Question(
      question: "Que signifie l'acronyme GPT ?",
      options: [
        "General Processing Technology",
        "Generative Pre-Trained Transformer",
        "Global Pattern Training",
        "Guided Processing Tool",
      ],
      correctIndex: 1,
      explanation:
          "GPT = Generative Pre-Trained Transformer. Une architecture utilisant des mécanismes d'auto-attention.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Qu'est-ce qu'un « token » ?",
      options: [
        "Un mot entier",
        "Une phrase complète",
        "Une unité de base représentant ~75 % d'un mot",
        "Un paragraphe",
      ],
      correctIndex: 2,
      explanation:
          "Le token est l'unité de base des LLMs (~75 % d'un mot). Les coûts et la fenêtre de contexte se mesurent en tokens.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Comment un LLM génère-t-il du texte ?",
      options: [
        "Il recherche la réponse dans une base de données",
        "Il prédit la suite de mots la plus probable",
        "Il copie des passages de ses données d'entraînement",
        "Il se connecte à Internet pour trouver la réponse",
      ],
      correctIndex: 1,
      explanation:
          "Un LLM est un moteur prédictif : il produit le mot suivant le plus probable, sans « comprendre » au sens humain.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Quelle affirmation est VRAIE sur l'IA générative ?",
      options: [
        "Elle remplace le jugement humain",
        "Elle donne toujours la même réponse au même prompt",
        "Elle peut générer du texte, des images et du code",
        "Elle comprend le langage comme un humain",
      ],
      correctIndex: 2,
      explanation:
          "L'IA générative produit texte, images et code. Elle n'est PAS déterministe et ne « comprend » pas réellement.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    // ═══ IA Générative — Avancé ═══
    Question(
      question: "Qu'est-ce que le mécanisme d'« auto-attention » du Transformer ?",
      options: [
        "Un correcteur orthographique automatique",
        "Un mécanisme permettant de relier les mots entre eux selon leur contexte",
        "Un outil de compression de données",
        "Un filtre de contenu inapproprié",
      ],
      correctIndex: 1,
      explanation:
          "L'auto-attention relie les mots entre eux. Ex : dans « la tortue est fatiguée », il sait que c'est la tortue, pas la route.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce qu'un « embedding » ?",
      options: [
        "Un type de base de données",
        "Un vecteur numérique multidimensionnel représentant le sens d'un mot",
        "Un format de fichier pour l'IA",
        "Un plugin de navigateur web",
      ],
      correctIndex: 1,
      explanation:
          "Les embeddings encodent les tokens en vecteurs dans un espace à +12 000 dimensions (GPT-3), permettant de calculer la proximité sémantique.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Que contrôle le paramètre « température » d'un LLM ?",
      options: [
        "La vitesse de calcul du GPU",
        "Le degré de créativité/aléatoire des réponses",
        "La taille de la fenêtre de contexte",
        "Le coût de l'inférence",
      ],
      correctIndex: 1,
      explanation:
          "Température basse → réponses prévisibles et factuelles. Température haute → réponses plus créatives et variées.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    // ═══ IA Agentique — Débutant ═══
    Question(
      question: "Qu'est-ce qu'un « agent IA » ?",
      options: [
        "Un employé qui utilise l'IA",
        "Un système IA capable d'agir de manière autonome pour accomplir des tâches",
        "Un antivirus intelligent",
        "Un chatbot qui répond aux questions",
      ],
      correctIndex: 1,
      explanation:
          "Un agent IA peut planifier, décider et agir de manière autonome, contrairement à un simple chatbot qui ne fait que répondre.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Quelle est la différence principale entre un chatbot et un agent IA ?",
      options: [
        "Un agent est plus rapide",
        "Un agent peut planifier et exécuter des actions de manière autonome",
        "Un chatbot est plus intelligent",
        "Il n'y a pas de différence",
      ],
      correctIndex: 1,
      explanation:
          "Le chatbot répond à des questions. L'agent IA peut utiliser des outils, naviguer, écrire du code, planifier des étapes et agir.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Que signifie « tool use » dans le contexte des agents IA ?",
      options: [
        "L'IA fabrique des outils physiques",
        "L'IA peut appeler des outils externes (recherche web, API, calculs…)",
        "L'utilisateur doit configurer des outils manuellement",
        "L'IA remplace les développeurs",
      ],
      correctIndex: 1,
      explanation:
          "Le tool use permet au modèle d'interagir avec le monde : chercher sur le web, exécuter du code, interroger des bases de données, etc.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.beginner,
    ),
    // ═══ IA Agentique — Intermédiaire ═══
    Question(
      question: "Qu'est-ce que le MCP (Model Context Protocol) ?",
      options: [
        "Un modèle de langage concurrent de GPT",
        "Un protocole standard pour connecter des modèles IA à des outils externes",
        "Un certificat de conformité pour l'IA",
        "Un type de mémoire pour GPU",
      ],
      correctIndex: 1,
      explanation:
          "Le MCP est un standard ouvert permettant aux agents IA de se connecter à différents outils et sources de données de manière uniforme.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Qu'est-ce que la boucle « ReAct » utilisée par les agents ?",
      options: [
        "Un framework JavaScript",
        "Une alternance entre raisonnement (Reasoning) et action (Acting)",
        "Un système de réaction chimique simulée",
        "Un type de réseau neuronal récurrent",
      ],
      correctIndex: 1,
      explanation:
          "ReAct = Reasoning + Acting. L'agent réfléchit (analyse la situation) puis agit (utilise un outil), et recommence jusqu'à résolution.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Qu'est-ce qu'un système « multi-agents » ?",
      options: [
        "Un LLM avec plusieurs milliards de paramètres",
        "Plusieurs agents IA collaborant ou se spécialisant sur des sous-tâches",
        "Un réseau de serveurs GPU",
        "Un outil de visioconférence avec IA",
      ],
      correctIndex: 1,
      explanation:
          "Un système multi-agents fait collaborer plusieurs agents spécialisés (recherche, rédaction, vérification…) pour résoudre des tâches complexes.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    // ═══ IA Agentique — Avancé ═══
    Question(
      question: "Quel est le principal défi de sécurité des agents IA autonomes ?",
      options: [
        "Ils consomment trop d'énergie",
        "Ils peuvent exécuter des actions non voulues ou dépasser leur périmètre",
        "Ils ne parlent qu'anglais",
        "Ils ne fonctionnent pas hors ligne",
      ],
      correctIndex: 1,
      explanation:
          "Un agent autonome peut effectuer des actions irréversibles (envoi de mail, modification de fichier). Le contrôle humain et la validation restent essentiels.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Que signifie « function calling » dans l'API d'un LLM ?",
      options: [
        "Appeler le support technique du fournisseur",
        "La capacité du modèle à demander l'exécution d'une fonction externe structurée",
        "Programmer en Python à l'intérieur du modèle",
        "Créer des formules Excel automatiquement",
      ],
      correctIndex: 1,
      explanation:
          "Le function calling permet au modèle de générer un appel structuré (JSON) vers une fonction externe, qui est ensuite exécutée par l'application hôte.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.advanced,
    ),
    // ═══ Workflows IA — Débutant ═══
    Question(
      question: "Qu'est-ce qu'un « prompt » ?",
      options: [
        "Le résultat produit par l'IA",
        "L'instruction ou la question donnée à une IA",
        "Un type de modèle d'IA",
        "Un langage de programmation",
      ],
      correctIndex: 1,
      explanation:
          "Le prompt est l'entrée textuelle que vous envoyez au modèle. Sa qualité détermine la qualité de la réponse.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Pourquoi le « prompt engineering » est-il important ?",
      options: [
        "Parce que l'IA ne fonctionne pas sans code",
        "Parce qu'une bonne question donne une meilleure réponse",
        "Parce qu'il faut payer plus pour de meilleurs résultats",
        "Parce qu'il faut un diplôme d'ingénieur pour l'utiliser",
      ],
      correctIndex: 1,
      explanation:
          "L'art de bien formuler sa demande permet d'optimiser la qualité de la réponse. Contexte + instruction + format = meilleur résultat.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Qu'est-ce qu'un « system prompt » ?",
      options: [
        "Un message d'erreur du système",
        "L'instruction initiale qui définit le comportement et les contraintes du modèle",
        "Un prompt réservé aux administrateurs système",
        "Le nom du premier message envoyé par l'IA",
      ],
      correctIndex: 1,
      explanation:
          "Le system prompt cadre le modèle : ton, rôle, contraintes, limites. Tous les chatbots commerciaux en utilisent un.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.beginner,
    ),
    // ═══ Workflows IA — Intermédiaire ═══
    Question(
      question: "Qu'est-ce que le RAG (Retrieval Augmented Generation) ?",
      options: [
        "Un type de robot industriel",
        "Une technique enrichissant les réponses avec des données externes fiables",
        "Un langage de programmation",
        "Un modèle d'IA spécifique aux administrations",
      ],
      correctIndex: 1,
      explanation:
          "Le RAG cherche d'abord les informations pertinentes dans une base documentaire, puis les injecte dans le prompt pour générer une réponse sourcée.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Qu'est-ce que le « prompt chaining » ?",
      options: [
        "Enchaîner plusieurs prompts pour décomposer une tâche complexe",
        "Copier-coller le même prompt plusieurs fois",
        "Utiliser un prompt dans plusieurs langues",
        "Bloquer les prompts malveillants",
      ],
      correctIndex: 0,
      explanation:
          "Le prompt chaining décompose un problème complexe en étapes : chaque prompt traite un sous-problème et passe son résultat au suivant.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Qu'est-ce que le « fine-tuning » d'un modèle ?",
      options: [
        "Installer un modèle sur son ordinateur",
        "Ré-entraîner un modèle existant sur des données spécifiques à son domaine",
        "Ajuster la luminosité de l'interface",
        "Augmenter la taille du modèle",
      ],
      correctIndex: 1,
      explanation:
          "Le fine-tuning spécialise un modèle pré-entraîné sur vos données métier, améliorant ses performances sur votre domaine spécifique.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    // ═══ Workflows IA — Avancé ═══
    Question(
      question: "Dans une architecture RAG, que fait le « retriever » ?",
      options: [
        "Il génère la réponse finale",
        "Il recherche les passages pertinents dans le corpus documentaire",
        "Il traduit la question en anglais",
        "Il filtre les résultats par date",
      ],
      correctIndex: 1,
      explanation:
          "Le retriever transforme la question en embedding, recherche les passages les plus proches sémantiquement, puis les transmet au LLM pour la génération.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce que le « few-shot prompting » ?",
      options: [
        "Fournir quelques exemples dans le prompt pour guider le modèle",
        "Réduire le nombre de tokens utilisés",
        "Utiliser un modèle peu entraîné",
        "Tester un modèle avec peu de données",
      ],
      correctIndex: 0,
      explanation:
          "Le few-shot donne au modèle quelques exemples entrée→sortie dans le prompt, pour qu'il comprenne le format et le style attendus.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    // ═══ Risques & Éthique — Débutant ═══
    Question(
      question: "Qu'est-ce qu'une « hallucination » de l'IA ?",
      options: [
        "Une erreur de traduction",
        "Le fait de générer des informations fausses avec une apparente confiance",
        "Un bug d'affichage du serveur",
        "Une fonctionnalité expérimentale",
      ],
      correctIndex: 1,
      explanation:
          "L'hallucination est un risque majeur : le modèle invente des faits avec confiance. Toujours relire et vérifier les réponses de l'IA.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Pourquoi les biais dans les modèles d'IA sont-ils problématiques ?",
      options: [
        "Ils rendent les modèles plus lents",
        "Ils reproduisent les discriminations présentes dans les données d'entraînement",
        "Ils augmentent le coût des requêtes",
        "Ils empêchent le modèle de parler français",
      ],
      correctIndex: 1,
      explanation:
          "Les modèles apprennent à partir de données humaines contenant des biais (genre, origine, âge…). Ces discriminations se retrouvent dans les réponses.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Qu'est-ce que l'AI Act ?",
      options: [
        "Un film de science-fiction",
        "Le règlement européen pour encadrer l'usage de l'IA",
        "Un concours international de développement IA",
        "Un logiciel de sécurité informatique",
      ],
      correctIndex: 1,
      explanation:
          "L'AI Act est le premier cadre juridique mondial sur l'IA, adopté par l'UE. Il classe les systèmes IA selon leur niveau de risque.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.beginner,
    ),
    // ═══ Risques & Éthique — Intermédiaire ═══
    Question(
      question: "Qu'est-ce qu'un « deepfake » ?",
      options: [
        "Un réseau neuronal profond",
        "Un contenu audiovisuel réaliste mais entièrement généré ou manipulé par IA",
        "Un faux profil sur les réseaux sociaux",
        "Un virus informatique ciblant l'IA",
      ],
      correctIndex: 1,
      explanation:
          "Les deepfakes utilisent l'IA pour créer des vidéos/audios ultra-réalistes de personnes disant ou faisant des choses qu'elles n'ont jamais faites.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Qu'est-ce que le RLHF (Reinforcement Learning from Human Feedback) ?",
      options: [
        "Un langage de programmation",
        "Une technique pour aligner les modèles sur les préférences humaines",
        "Un réseau social pour chercheurs en IA",
        "Un benchmark de performance des GPU",
      ],
      correctIndex: 1,
      explanation:
          "Le RLHF utilise le feedback humain pour ré-entraîner le modèle, améliorant son « alignement » : refuser les contenus dangereux, être plus utile.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question: "Quel est l'impact environnemental principal de l'IA générative ?",
      options: [
        "La production de déchets électroniques uniquement",
        "La consommation massive d'énergie et d'eau pour l'entraînement et l'inférence",
        "La pollution sonore des centres de données",
        "L'impact est négligeable",
      ],
      correctIndex: 1,
      explanation:
          "L'entraînement de GPT-4 a nécessité l'équivalent de la consommation électrique de milliers de foyers. L'inférence quotidienne de millions d'utilisateurs s'y ajoute.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    // ═══ Risques & Éthique — Avancé ═══
    Question(
      question: "Qu'est-ce que le « prompt injection » ?",
      options: [
        "Écrire un prompt très long",
        "Manipuler un modèle en insérant des instructions cachées dans le contexte",
        "Injecter du code dans un GPU",
        "Traduire un prompt dans une autre langue",
      ],
      correctIndex: 1,
      explanation:
          "Le prompt injection est une attaque où des instructions malveillantes sont cachées dans les données fournies au modèle pour détourner son comportement.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question:
          "Dans la classification de l'AI Act, quel niveau de risque entraîne l'interdiction d'un système IA ?",
      options: [
        "Risque élevé",
        "Risque limité",
        "Risque inacceptable",
        "Risque minimal",
      ],
      correctIndex: 2,
      explanation:
          "L'AI Act définit 4 niveaux : minimal, limité, élevé et inacceptable. Ce dernier interdit les systèmes (ex : scoring social, manipulation subliminale).",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    // ═══ Usages CD — Débutant ═══
    Question(
      question:
          "Parmi ces tâches, laquelle est RECOMMANDÉE pour un agent de conseil départemental ?",
      options: [
        "Traiter un dossier social nominatif dans ChatGPT",
        "Laisser l'IA rédiger seule une décision administrative",
        "Résumer un compte-rendu de réunion sans données personnelles",
        "Utiliser l'IA comme validation juridique d'un marché public",
      ],
      correctIndex: 2,
      explanation:
          "Résumer un CR sans données personnelles est recommandé. Les autres impliquent des données sensibles ou une délégation de responsabilité.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Que ne remplacera JAMAIS l'IA au conseil départemental ?",
      options: [
        "La rédaction d'un premier brouillon de mail",
        "La création d'une trame de présentation",
        "Le jugement humain, la décision politique et la responsabilité juridique",
        "La synthèse d'un document interne",
      ],
      correctIndex: 2,
      explanation:
          "L'IA ne remplacera pas le jugement humain, la responsabilité juridique, la décision politique, l'évaluation sociale et la relation avec les usagers.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Question(
      question: "Pourquoi l'IA est-elle particulièrement utile dans un conseil départemental ?",
      options: [
        "Elle remplace les agents publics",
        "Le CD génère beaucoup de documents et l'IA aide à les traiter plus vite",
        "Elle permet de supprimer des postes",
        "Elle automatise les décisions politiques",
      ],
      correctIndex: 1,
      explanation:
          "Le CD a une activité très documentaire (mails, CR, notes, rapports). L'IA aide à gagner du temps sur les tâches répétitives pour laisser plus de place au jugement métier.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    // ═══ Usages CD — Intermédiaire ═══
    Question(
      question:
          "Laquelle de ces actions avec l'IA nécessite des PRÉCAUTIONS dans un CD ?",
      options: [
        "Reformuler un mail interne",
        "Résumer des offres fournisseurs contenant des données anonymisées",
        "Générer une FAQ interne",
        "Corriger l'orthographe d'un texte",
      ],
      correctIndex: 1,
      explanation:
          "Résumer des offres fournisseurs nécessite précautions : vérifier l'anonymisation, relire la synthèse, s'assurer qu'aucune donnée confidentielle n'est partagée.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.intermediate,
    ),
    Question(
      question:
          "Un agent du CD veut utiliser ChatGPT pour traiter un dossier MDPH nominatif. Que faire ?",
      options: [
        "C'est autorisé si on anonymise le nom",
        "C'est strictement interdit sur un outil IA grand public",
        "C'est autorisé si le responsable de service valide",
        "C'est autorisé si les données restent en France",
      ],
      correctIndex: 1,
      explanation:
          "Les données nominatives de bénéficiaires (MDPH, ASE, APA…) ne doivent JAMAIS être saisies dans un outil IA grand public, même anonymisées partiellement.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.intermediate,
    ),
    // ═══ IA Générative — Avancé (bonus) ═══
    Question(
      question: "Quelle fenêtre de contexte Gemini 1.5 Pro propose-t-il ?",
      options: ["128 000 tokens", "200 000 tokens", "1 million de tokens", "2 millions de tokens"],
      correctIndex: 3,
      explanation: "Gemini 1.5 Pro offre jusqu'à 2 millions de tokens de contexte, un record parmi les modèles commerciaux grand public fin 2024.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce que le « grounding » d'un modèle ?",
      options: [
        "Limiter l'accès internet du modèle",
        "Ancrer les réponses dans des sources factuelles vérifiables",
        "Réduire la température du modèle à 0",
        "Convertir le modèle en mode hors-ligne",
      ],
      correctIndex: 1,
      explanation: "Le grounding connecte le modèle à des sources fiables (web, base documentaire) pour réduire les hallucinations et apporter des preuves vérifiables.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce que la « distillation » d'un modèle IA ?",
      options: [
        "Filtrer les données toxiques avant entraînement",
        "Compresser un grand modèle en un modèle plus petit qui en reproduit le comportement",
        "Augmenter la précision en ajoutant des paramètres",
        "Exporter un modèle vers un autre framework",
      ],
      correctIndex: 1,
      explanation: "La distillation transfère le savoir d'un grand modèle (teacher) vers un modèle plus léger (student), réduisant les coûts d'inférence sans perte majeure de qualité.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    // ═══ IA Agentique — Avancé (bonus) ═══
    Question(
      question: "Selon OWASP LLM Top 10 2025, quelle est la vulnérabilité #1 des LLMs ?",
      options: ["Fuite de données d'entraînement", "Prompt Injection", "Déni de service", "Biais algorithmique"],
      correctIndex: 1,
      explanation: "OWASP classe le Prompt Injection en #1. Des instructions malveillantes insérées dans le contexte (indirect) ou par l'utilisateur (direct) détournent le comportement du modèle.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce que le « jailbreaking » d'un LLM, et en quoi diffère-t-il du prompt injection ?",
      options: [
        "Ils sont synonymes : tous deux injectent des instructions cachées",
        "Le jailbreak cible les filtres de sécurité ; le prompt injection détourne le comportement fonctionnel",
        "Le jailbreak est légal ; le prompt injection est illégal",
        "Le jailbreak nécessite un accès GPU direct",
      ],
      correctIndex: 1,
      explanation: "OWASP distingue les deux : le jailbreak contourne les garde-fous (ex : obtenir un contenu interdit), le prompt injection manipule le comportement applicatif (ex : exfiltrer des données).",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Dans un système multi-agents, quelle attaque exploite la confiance entre agents ?",
      options: [
        "RAG poisoning",
        "Inter-agent trust exploitation",
        "Model inversion",
        "Data exfiltration par embedding",
      ],
      correctIndex: 1,
      explanation: "82,4 % des LLMs sont vulnérables à l'inter-agent trust exploitation : un agent compromis peut propager des instructions malveillantes aux agents suivants.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.advanced,
    ),
    // ═══ Workflows IA — Avancé (bonus) ═══
    Question(
      question: "Combien de documents malveillants suffisent pour empoisonner un système RAG ?",
      options: ["50 documents", "20 documents", "5 documents", "1 seul document"],
      correctIndex: 2,
      explanation: "Des recherches ont montré que 5 documents soigneusement conçus suffisent à manipuler les réponses d'un système RAG dans 90 % des cas (RAG poisoning).",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce que le « chain-of-thought » prompting ?",
      options: [
        "Enchaîner plusieurs LLMs en série",
        "Demander au modèle d'expliquer son raisonnement étape par étape",
        "Utiliser un historique de conversation complet",
        "Connecter plusieurs bases vectorielles",
      ],
      correctIndex: 1,
      explanation: "Le chain-of-thought (« Let's think step by step ») guide le modèle à décomposer son raisonnement, améliorant significativement les performances sur des tâches complexes.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Quelle technique permet de générer plusieurs réponses et de voter pour la meilleure ?",
      options: ["Few-shot prompting", "Self-consistency", "Temperature = 0", "Retrieval Augmentation"],
      correctIndex: 1,
      explanation: "La self-consistency génère N réponses avec température > 0 puis sélectionne par vote majoritaire, améliorant la fiabilité sur les tâches de raisonnement.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    // ═══ Risques & Éthique — Avancé (bonus) ═══
    Question(
      question: "L'AI Act est entré en vigueur le 1er août 2024. Quand sera-t-il pleinement applicable ?",
      options: ["Immédiatement", "1er août 2025", "2 août 2026", "2027 uniquement pour les systèmes à risque élevé"],
      correctIndex: 2,
      explanation: "L'AI Act entre pleinement en vigueur le 2 août 2026, avec une dérogation pour les systèmes à haut risque jusqu'au 2 août 2027.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Selon la CNIL (recommandation jan. 2024), une AIPD est-elle obligatoire pour les systèmes IA traitant des données personnelles ?",
      options: [
        "Non, le RGPD ne s'applique pas à l'IA",
        "Seulement si le système est open source",
        "Quasi systématiquement : l'AIPD est quasi-obligatoire dans la plupart des cas IA",
        "Seulement pour les entreprises privées",
      ],
      correctIndex: 2,
      explanation: "La CNIL a précisé en 2024 que l'AIPD (Article 35 RGPD) est quasi systématiquement obligatoire pour les systèmes IA, compte tenu des risques élevés pour les droits et libertés.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Lequel de ces usages de l'IA est classé 'risque inacceptable' par l'AI Act ?",
      options: [
        "Filtrer des CV avec un outil IA",
        "Utiliser un chatbot de service client",
        "Notation sociale des citoyens par une autorité publique",
        "Recommander des formations aux agents",
      ],
      correctIndex: 2,
      explanation: "Le scoring social par une autorité publique est explicitement interdit par l'AI Act (risque inacceptable), aux côtés de la manipulation subliminale et de certaines biométries en temps réel.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    // ═══ Usages CD — Avancé ═══
    Question(
      question: "Le RGPD et l'AI Act s'appliquent-ils simultanément lorsqu'un CD utilise de l'IA sur des données personnelles ?",
      options: [
        "Non, l'AI Act remplace le RGPD pour l'IA",
        "Oui, les deux règlements s'appliquent cumulativement",
        "Seulement si le système est développé en interne",
        "Seulement pour les données de santé",
      ],
      correctIndex: 1,
      explanation: "La CNIL confirme que RGPD et AI Act s'appliquent en cumul dès lors que des données personnelles sont traitées par un système IA. Aucun règlement ne remplace l'autre.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Qu'est-ce que la 'délibération' IA interdite sans intervention humaine dans le service public ?",
      options: [
        "Rédiger un mail de relance",
        "Prendre une décision administrative individuelle entièrement automatisée",
        "Résumer un rapport de 50 pages",
        "Générer un compte-rendu de réunion",
      ],
      correctIndex: 1,
      explanation: "L'article 22 du RGPD interdit les décisions administratives individuelles entièrement automatisées sans intervention humaine, sauf exceptions. L'IA assiste, l'agent décide.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.advanced,
    ),
    Question(
      question: "Parmi ces actions, laquelle constitue un BON usage de l'IA dans un CD (niveau avancé) ?",
      options: [
        "Utiliser un LLM public pour analyser des offres avec données fournisseurs confidentielles",
        "Déployer un RAG sur la documentation interne anonymisée pour aider les agents",
        "Remplacer l'instruction du dossier APA par une recommandation IA directe",
        "Déléguer à un agent IA la signature électronique de courriers officiels",
      ],
      correctIndex: 1,
      explanation: "Un RAG sur documentation interne anonymisée est un usage avancé recommandé : il garde les données en interne, réduit les hallucinations et aide les agents sans traiter de données nominatives.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.advanced,
    ),
  ];

  // ─── Flash Questions (Vrai / Faux) ──────────────────────────────

  static const flashQuestions = <FlashQuestion>[
    FlashQuestion(
      statement: "ChatGPT a atteint 100 millions d'utilisateurs en seulement 2 mois.",
      isTrue: true,
      explanation: "Record absolu dans l'histoire des technologies grand public.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "Un token correspond exactement à un mot entier.",
      isTrue: false,
      explanation: "Un token représente en moyenne 75 % d'un mot.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "L'IA générative peut « halluciner » des faits avec confiance.",
      isTrue: true,
      explanation: "Risque majeur imposant une relecture humaine systématique.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "On peut copier-coller des dossiers nominatifs dans ChatGPT.",
      isTrue: false,
      explanation: "Strictement interdit pour des raisons de confidentialité et RGPD.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "GPT signifie Generative Pre-trained Transformer.",
      isTrue: true,
      explanation: "Architecture développée par OpenAI, basée sur les Transformers.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "L'IA générative est née en 1997 avec le Machine Learning.",
      isTrue: false,
      explanation: "L'IA générative a émergé en 2021. Le Machine Learning date de 1997.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "Un même modèle d'IA peut équiper différentes applications.",
      isTrue: true,
      explanation: "Ex : GPT-4 est utilisé par ChatGPT, Microsoft Copilot et bien d'autres.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "L'IA générative donne toujours la même réponse au même prompt.",
      isTrue: false,
      explanation: "Les LLMs ne sont pas déterministes : les réponses varient.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Les coûts des modèles sont calculés en nombre de tokens.",
      isTrue: true,
      explanation: "Entrée et sortie sont facturées au nombre de tokens consommés.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Le RAG permet de réduire les hallucinations.",
      isTrue: true,
      explanation: "Il enrichit les réponses avec des sources fiables.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "L'impact environnemental de l'IA générative est négligeable.",
      isTrue: false,
      explanation: "L'impact énergétique et hydrique est un enjeu majeur reconnu.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "L'AI Act est le règlement européen qui encadre l'IA.",
      isTrue: true,
      explanation: "Approche réglementaire graduelle basée sur les niveaux de risque.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "Un agent IA est la même chose qu'un chatbot classique.",
      isTrue: false,
      explanation: "Un agent peut planifier et agir de manière autonome, pas un chatbot.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "Le MCP est un protocole pour connecter des modèles IA à des outils.",
      isTrue: true,
      explanation: "Model Context Protocol : standard ouvert pour l'interopérabilité IA/outils.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Le prompt engineering consiste à écrire du code Python.",
      isTrue: false,
      explanation: "C'est l'art de bien formuler ses instructions en langage naturel.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.beginner,
    ),
    FlashQuestion(
      statement: "Le fine-tuning consiste à ré-entraîner un modèle sur des données spécifiques.",
      isTrue: true,
      explanation: "Cela spécialise un modèle généraliste sur un domaine métier précis.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Le prompt injection est une technique d'attaque contre les modèles IA.",
      isTrue: true,
      explanation: "Des instructions cachées dans le contexte peuvent détourner le comportement du modèle.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "L'AI Act européen est entré en vigueur en août 2024.",
      isTrue: true,
      explanation: "Entré en vigueur le 1er août 2024, il sera pleinement applicable le 2 août 2026.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Gemini 1.5 Pro propose une fenêtre de contexte de 2 millions de tokens.",
      isTrue: true,
      explanation: "C'est l'une des plus grandes fenêtres de contexte commerciales disponibles.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "Un LLM avec température = 0 donnera toujours exactement la même réponse.",
      isTrue: false,
      explanation: "Température 0 rend le modèle très déterministe mais des variations subsistent selon l'infrastructure matérielle.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "Le RGPD s'applique même si des données personnelles sont traitées par une IA.",
      isTrue: true,
      explanation: "La CNIL confirme que le RGPD s'applique sans réserve aux systèmes IA traitant des données personnelles.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Un agent IA peut exécuter des actions irréversibles sans supervision humaine.",
      isTrue: true,
      explanation: "C'est le principal risque des agents autonomes : envoi de mail, suppression de fichiers, transactions… La supervision reste cruciale.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Le chain-of-thought prompting améliore les performances des LLMs sur les tâches complexes.",
      isTrue: true,
      explanation: "Demander au modèle de raisonner étape par étape augmente significativement la fiabilité sur les tâches de raisonnement et de calcul.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "5 documents malveillants suffisent à compromettre un système RAG dans 90 % des cas.",
      isTrue: true,
      explanation: "Des recherches l'ont démontré : le RAG poisoning est une attaque réelle et efficace nécessitant de valider les sources documentaires.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "La distillation de modèle réduit la taille d'un LLM sans perte totale de performance.",
      isTrue: true,
      explanation: "Un modèle 'étudiant' entraîné sur les sorties d'un grand modèle reproduit ses capacités tout en étant beaucoup plus léger.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "Le scoring social des citoyens par une autorité publique est autorisé par l'AI Act si encadré.",
      isTrue: false,
      explanation: "C'est un usage à risque INACCEPTABLE, explicitement interdit par l'AI Act, sans exception possible pour les autorités publiques.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "L'article 22 du RGPD interdit les décisions administratives entièrement automatisées sans recours humain.",
      isTrue: true,
      explanation: "Toute décision individuelle prise uniquement par algorithme sans intervention humaine est prohibée, sauf exception légale explicite.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "Le jailbreaking et le prompt injection sont deux termes synonymes.",
      isTrue: false,
      explanation: "OWASP les distingue : le jailbreak cible les filtres de sécurité, le prompt injection détourne le comportement fonctionnel de l'application.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.advanced,
    ),
    FlashQuestion(
      statement: "Un modèle open source comme Llama peut être hébergé localement par un CD.",
      isTrue: true,
      explanation: "Les modèles open source (Llama, Mistral…) peuvent être déployés sur infrastructure interne, évitant l'envoi de données à des tiers.",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.intermediate,
    ),
    FlashQuestion(
      statement: "Un agent IA multi-agents fait collaborer plusieurs IA spécialisées.",
      isTrue: true,
      explanation: "Chaque agent a un rôle (recherche, rédaction, vérification) et ils collaborent.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.advanced,
    ),
  ];

  // ─── Scenarios ──────────────────────────────────────────────────

  static const scenarios = <Scenario>[
    Scenario(
      title: "Reformuler un mail interne",
      description:
          "Vous informez vos collègues d'un changement de procédure pour les congés. Vous utilisez l'IA pour reformuler votre mail.",
      correctType: ScenarioType.good,
      explanation: "Usage recommandé : aucune donnée sensible, l'IA améliore la clarté et le ton.",
      icon: "✉️",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Scenario(
      title: "Dossier d'un mineur (ASE)",
      description:
          "Vous traitez le cas d'un mineur suivi par le service ASE. Vous copiez-collez l'intégralité du dossier dans ChatGPT pour une synthèse.",
      correctType: ScenarioType.forbidden,
      explanation:
          "Strictement interdit ! Données nominatives de mineurs en protection de l'enfance = jamais dans un outil IA grand public.",
      icon: "👶",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Scenario(
      title: "Plan de présentation de bilan",
      description:
          "Votre direction demande un bilan d'activité. Vous demandez à l'IA un plan structuré à partir de vos idées et chiffres anonymisés.",
      correctType: ScenarioType.good,
      explanation: "Recommandé : l'IA structure vos idées, vous gardez le contrôle du contenu final.",
      icon: "📊",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Scenario(
      title: "Validation juridique d'un marché",
      description:
          "Vous demandez à l'IA de valider juridiquement les critères d'attribution d'un marché public et la conformité du CCTP.",
      correctType: ScenarioType.forbidden,
      explanation: "Interdit ! La responsabilité juridique ne peut jamais être déléguée à une IA.",
      icon: "⚖️",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.intermediate,
    ),
    Scenario(
      title: "Synthèse de compte-rendu",
      description:
          "Après une réunion de direction, vous utilisez l'IA pour extraire les points clés d'un CR de 15 pages (sans données personnelles).",
      correctType: ScenarioType.caution,
      explanation:
          "Avec précautions : vérifiez l'absence de données sensibles, relisez. L'IA peut omettre des nuances importantes.",
      icon: "📝",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Scenario(
      title: "Décisions administratives automatisées",
      description:
          "Face à un volume important de demandes, vous configurez l'IA pour rédiger et envoyer des décisions administratives sans relecture.",
      correctType: ScenarioType.forbidden,
      explanation: "Strictement interdit ! Toute décision administrative exige une validation et une signature humaine.",
      icon: "🚫",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Scenario(
      title: "Note d'aide à la décision",
      description:
          "Votre DGS demande une note sur le choix entre deux prestataires. Vous utilisez l'IA pour structurer un premier jet.",
      correctType: ScenarioType.caution,
      explanation:
          "Avec précautions : vérifiez chaque information, complétez avec vos analyses, validez le contenu final.",
      icon: "🔍",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.intermediate,
    ),
    Scenario(
      title: "FAQ interne",
      description:
          "Votre service reçoit souvent les mêmes questions. Vous utilisez l'IA pour générer une trame de FAQ sur vos procédures.",
      correctType: ScenarioType.good,
      explanation: "Recommandé : gain de temps important, vous gardez le contrôle du contenu final.",
      icon: "❓",
      category: QuizCategory.usagesCD,
      difficulty: Difficulty.beginner,
    ),
    Scenario(
      title: "Agent IA connecté à la base usagers",
      description:
          "La DSI propose de déployer un agent IA connecté directement à la base de données des usagers pour accélérer le traitement des demandes.",
      correctType: ScenarioType.caution,
      explanation:
          "Avec précautions : nécessite un cadre sécurité validé, anonymisation, audit, et conformité RGPD avant tout déploiement.",
      icon: "🤖",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    Scenario(
      title: "Deepfake dans une campagne de com",
      description:
          "Le service communication propose d'utiliser un deepfake vidéo du président du CD pour une campagne de sensibilisation.",
      correctType: ScenarioType.caution,
      explanation:
          "Avec précautions : le deepfake peut être un cas d'usage légitime (accessibilité, multilinguisme) mais nécessite le consentement explicite de la personne et une transparence totale.",
      icon: "🎬",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
  ];

  // ─── Match Sets ─────────────────────────────────────────────────

  static const matchSets = <MatchSet>[
    MatchSet(
      title: "Concepts & Définitions",
      pairs: [
        MatchPair("IA Générative", "Créer du contenu original et réaliste"),
        MatchPair("Machine Learning", "Apprendre des patterns à partir de données"),
        MatchPair("Deep Learning", "Réseaux de neurones multicouches"),
        MatchPair("Prompt", "Instruction donnée à une IA"),
        MatchPair("LLM", "Modèle de langage de grande taille"),
        MatchPair("Token", "Unité de base (~75 % d'un mot)"),
      ],
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    MatchSet(
      title: "Modèles & Créateurs",
      pairs: [
        MatchPair("ChatGPT", "OpenAI"),
        MatchPair("Claude", "Anthropic"),
        MatchPair("Mistral", "Mistral AI"),
        MatchPair("Gemini", "Google"),
        MatchPair("Copilot", "Microsoft"),
        MatchPair("LLaMA", "Meta"),
      ],
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.intermediate,
    ),
    MatchSet(
      title: "Risques & Définitions",
      pairs: [
        MatchPair("Hallucination", "Génération de fausses informations"),
        MatchPair("Biais", "Reproduction de discriminations des données"),
        MatchPair("Deepfake", "Contenu audiovisuel truqué par IA"),
        MatchPair("RGPD", "Réglementation sur la protection des données"),
        MatchPair("AI Act", "Règlement européen sur l'IA"),
        MatchPair("Prompt injection", "Manipulation malveillante d'un prompt"),
      ],
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
    MatchSet(
      title: "Vocabulaire des Agents IA",
      pairs: [
        MatchPair("Agent IA", "Système autonome capable d'agir"),
        MatchPair("Tool use", "Utiliser des outils externes (API, web…)"),
        MatchPair("MCP", "Protocole standard IA/outils"),
        MatchPair("Orchestrateur", "Coordonne plusieurs agents"),
        MatchPair("ReAct", "Alternance raisonnement et action"),
        MatchPair("Multi-agents", "Plusieurs IA qui collaborent"),
      ],
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    MatchSet(
      title: "Workflows & Techniques",
      pairs: [
        MatchPair("RAG", "Génération augmentée par la recherche"),
        MatchPair("Fine-tuning", "Ré-entraînement ciblé du modèle"),
        MatchPair("System prompt", "Instruction définissant le comportement"),
        MatchPair("Few-shot", "Exemples fournis dans le prompt"),
        MatchPair("Embedding", "Représentation vectorielle du sens"),
        MatchPair("Température", "Paramètre de créativité du modèle"),
      ],
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
  ];

  // ─── Order Challenges ───────────────────────────────────────────

  static const orderChallenges = <OrderChallenge>[
    OrderChallenge(
      title: "Chronologie de l'IA",
      instruction: "Du plus ancien au plus récent :",
      correctOrder: [
        "IA — le concept (1956)",
        "Machine Learning (1997)",
        "Deep Learning (2012)",
        "Transformers (2017)",
        "IA Générative grand public (2021)",
        "Lancement de ChatGPT (2022)",
      ],
      explanation:
          "L'IA est un domaine ancien (1956) qui s'est accéléré avec le Machine Learning, le Deep Learning, puis les Transformers qui ont rendu possible l'IA générative.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    OrderChallenge(
      title: "Pipeline RAG",
      instruction: "Ordonnez les étapes d'une architecture RAG :",
      correctOrder: [
        "Question de l'utilisateur",
        "Recherche dans le corpus documentaire",
        "Sélection des passages pertinents",
        "Injection dans le contexte du prompt",
        "Génération de la réponse par le LLM",
        "Vérification humaine",
      ],
      explanation:
          "Le RAG suit un flux précis : rechercher d'abord, puis injecter les résultats dans le prompt, et enfin générer la réponse.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    OrderChallenge(
      title: "Prompt efficace",
      instruction: "Dans quel ordre structurer un prompt efficace ?",
      correctOrder: [
        "Rôle / Persona",
        "Contexte de la tâche",
        "Instruction précise",
        "Format de sortie attendu",
        "Exemples (few-shot)",
        "Contraintes et limites",
      ],
      explanation:
          "Un bon prompt définit d'abord le rôle, pose le contexte, donne l'instruction, précise le format, fournit des exemples et fixe les contraintes.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.beginner,
    ),
    OrderChallenge(
      title: "Boucle d'un agent IA",
      instruction: "Ordonnez le cycle de travail d'un agent IA :",
      correctOrder: [
        "Réception de la tâche",
        "Planification des étapes",
        "Sélection de l'outil approprié",
        "Exécution de l'action",
        "Analyse du résultat",
        "Réponse finale à l'utilisateur",
      ],
      explanation:
          "Un agent IA suit une boucle : comprendre → planifier → agir → observer → conclure. C'est le principe ReAct.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.intermediate,
    ),
    OrderChallenge(
      title: "Niveaux de risque (AI Act)",
      instruction: "Du risque le plus faible au plus élevé :",
      correctOrder: [
        "Risque minimal (ex : filtres anti-spam)",
        "Risque limité (ex : chatbots — obligations de transparence)",
        "Risque élevé (ex : recrutement, santé — obligations strictes)",
        "Risque inacceptable (ex : scoring social — INTERDIT)",
      ],
      explanation:
          "L'AI Act utilise une approche graduée. Les systèmes à risque inacceptable sont interdits, les autres ont des obligations proportionnelles.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
  ];

  // ─── Who Am I ───────────────────────────────────────────────────

  static const whoAmIRounds = <WhoAmIRound>[
    WhoAmIRound(
      clues: [
        "J'ai été créé par OpenAI.",
        "J'ai été lancé en novembre 2022.",
        "J'ai atteint 100 millions d'utilisateurs en 2 mois.",
        "Mon nom contient les lettres GPT.",
      ],
      answer: "ChatGPT",
      decoys: ["Claude", "Gemini", "Mistral"],
      explanation:
          "ChatGPT, lancé par OpenAI fin 2022, est devenu le symbole de la révolution IA générative.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    WhoAmIRound(
      clues: [
        "Je suis un phénomène redouté des utilisateurs d'IA.",
        "Je surviens quand le modèle invente des informations.",
        "Je suis exprimé avec une grande apparente confiance.",
        "Le RAG aide à me réduire.",
      ],
      answer: "Hallucination",
      decoys: ["Biais", "Bug", "Overfitting"],
      explanation:
          "L'hallucination est la tendance du modèle à inventer des faits avec confiance. C'est pourquoi la relecture humaine est indispensable.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.beginner,
    ),
    WhoAmIRound(
      clues: [
        "Je suis une architecture hybride.",
        "Je combine recherche d'information et génération.",
        "Je réduis les hallucinations en apportant des sources.",
        "Mon nom signifie Retrieval Augmented Generation.",
      ],
      answer: "RAG",
      decoys: ["Fine-tuning", "Prompt chaining", "RLHF"],
      explanation:
          "Le RAG recherche d'abord des informations pertinentes puis les injecte dans le contexte du modèle pour une réponse sourcée.",
      category: QuizCategory.workflowIA,
      difficulty: Difficulty.intermediate,
    ),
    WhoAmIRound(
      clues: [
        "Je suis l'unité de base des modèles de langage.",
        "Je représente environ 75 % d'un mot en moyenne.",
        "La facturation des API est calculée grâce à moi.",
        "La fenêtre de contexte est mesurée en nombre de moi.",
      ],
      answer: "Token",
      decoys: ["Embedding", "Neurone", "Bit"],
      explanation:
          "Le token est l'atome des LLMs. Tout se mesure en tokens : coûts, contexte, entrée et sortie.",
      category: QuizCategory.iaGenerative,
      difficulty: Difficulty.beginner,
    ),
    WhoAmIRound(
      clues: [
        "Je suis plus qu'un simple chatbot.",
        "Je peux prendre des décisions de manière autonome.",
        "Je peux utiliser des outils externes pour agir.",
        "Je peux planifier et exécuter des tâches complexes.",
      ],
      answer: "Agent IA",
      decoys: ["LLM", "API", "Chatbot"],
      explanation:
          "L'agent IA se distingue du chatbot par sa capacité à planifier, utiliser des outils et agir de manière autonome.",
      category: QuizCategory.iaAgentique,
      difficulty: Difficulty.beginner,
    ),
    WhoAmIRound(
      clues: [
        "Je suis un texte réglementaire adopté en 2024.",
        "Je m'applique aux États membres de l'UE.",
        "Je classe les systèmes IA selon leur niveau de risque.",
        "Je suis le premier cadre juridique mondial sur l'IA.",
      ],
      answer: "AI Act",
      decoys: ["RGPD", "Directive NIS2", "Digital Services Act"],
      explanation:
          "L'AI Act est le règlement européen sur l'IA, premier cadre mondial, avec une approche graduée basée sur le risque.",
      category: QuizCategory.risquesEthique,
      difficulty: Difficulty.intermediate,
    ),
  ];
}
