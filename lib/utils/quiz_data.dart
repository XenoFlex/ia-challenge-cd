enum QuizCategory { fondamentaux, fonctionnement, usages, risques }

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuizCategory category;

  const Question({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });
}

class FlashQuestion {
  final String statement;
  final bool isTrue;
  final String explanation;

  const FlashQuestion({
    required this.statement,
    required this.isTrue,
    required this.explanation,
  });
}

enum ScenarioType { good, caution, forbidden }

class Scenario {
  final String title;
  final String description;
  final ScenarioType correctType;
  final String explanation;
  final String icon;

  const Scenario({
    required this.title,
    required this.description,
    required this.correctType,
    required this.explanation,
    required this.icon,
  });
}

class QuizData {
  static const List<Question> questions = [
    Question(
      question:
          "En quelle année l'IA Générative a-t-elle émergé comme une technologie grand public ?",
      options: ["1997", "2012", "2021", "2023"],
      correctIndex: 2,
      explanation:
          "L'IA Générative a émergé en 2021, après le Machine Learning (1997) et le Deep Learning (2012). Une évolution qui s'est fortement accélérée depuis.",
      category: QuizCategory.fondamentaux,
    ),
    Question(
      question: "Que signifie l'acronyme GPT dans « ChatGPT » ?",
      options: [
        "General Processing Technology",
        "Generative Pre-Trained Transformer",
        "Global Pattern Training",
        "Guided Processing Tool"
      ],
      correctIndex: 1,
      explanation:
          "GPT signifie Generative Pre-Trained Transformer. C'est une architecture de modèle qui utilise des mécanismes d'auto-attention pour comprendre le contexte.",
      category: QuizCategory.fondamentaux,
    ),
    Question(
      question:
          "En combien de temps ChatGPT a-t-il atteint 100 millions d'utilisateurs ?",
      options: ["6 mois", "1 an", "2 mois", "2 semaines"],
      correctIndex: 2,
      explanation:
          "ChatGPT a atteint les 100 millions d'utilisateurs en seulement 2 mois, un record sans précédent dans l'histoire des technologies grand public.",
      category: QuizCategory.fondamentaux,
    ),
    Question(
      question: "Qu'est-ce qu'un « token » dans un modèle d'IA générative ?",
      options: [
        "Un mot entier",
        "Une phrase complète",
        "Une unité représentant ~75 % d'un mot",
        "Un paragraphe"
      ],
      correctIndex: 2,
      explanation:
          "Un token est l'unité de base d'un modèle d'IA. Il représente en moyenne 75 % d'un mot. Les coûts d'utilisation des modèles sont calculés au nombre de tokens.",
      category: QuizCategory.fonctionnement,
    ),
    Question(
      question: "Comment fonctionne concrètement un LLM ?",
      options: [
        "Il recherche les réponses dans une base de données",
        "Il prédit la suite de mots la plus probable",
        "Il copie des textes de ses données d'entraînement",
        "Il accède à Internet en temps réel"
      ],
      correctIndex: 1,
      explanation:
          "Un LLM est un moteur prédictif : il produit la suite de mots lui semblant la plus probable. Il ne « comprend » pas le langage au sens humain.",
      category: QuizCategory.fonctionnement,
    ),
    Question(
      question:
          "Qu'est-ce qu'une « hallucination » dans le contexte de l'IA générative ?",
      options: [
        "Une erreur de traduction",
        "Le fait de générer des informations fausses avec une apparente confiance",
        "Un bug technique du serveur",
        "Une fonctionnalité expérimentale réservée aux développeurs"
      ],
      correctIndex: 1,
      explanation:
          "L'hallucination désigne la tendance d'un modèle à inventer des faits avec confiance. C'est un risque majeur qui impose une relecture humaine systématique.",
      category: QuizCategory.risques,
    ),
    Question(
      question: "Qu'est-ce que le RAG (Retrieval Augmented Generation) ?",
      options: [
        "Un type de robot industriel",
        "Une technique enrichissant les réponses avec des données externes fiables",
        "Un langage de programmation pour l'IA",
        "Un modèle d'IA spécifique aux administrations"
      ],
      correctIndex: 1,
      explanation:
          "Le RAG permet aux modèles de s'appuyer sur des documents fournis plutôt que sur leurs seules connaissances d'entraînement, réduisant ainsi les hallucinations.",
      category: QuizCategory.fonctionnement,
    ),
    Question(
      question:
          "Parmi ces tâches, laquelle est RECOMMANDÉE pour un agent d'un conseil départemental ?",
      options: [
        "Traiter un dossier social nominatif dans ChatGPT",
        "Laisser l'IA rédiger seule une décision administrative",
        "Résumer un compte-rendu de réunion sans données personnelles",
        "Utiliser l'IA comme validation juridique d'un marché public"
      ],
      correctIndex: 2,
      explanation:
          "Résumer un CR sans données personnelles est un usage recommandé. Les autres options impliquent des données sensibles ou une délégation de responsabilité inacceptable.",
      category: QuizCategory.usages,
    ),
    Question(
      question: "Quelle affirmation sur l'IA générative est VRAIE ?",
      options: [
        "Elle remplace le jugement humain",
        "Elle donne toujours la même réponse au même prompt",
        "Elle peut générer du texte, des images et du code",
        "Elle comprend le langage comme un humain"
      ],
      correctIndex: 2,
      explanation:
          "L'IA générative peut produire textes, images et code. Elle n'est pas déterministe, ne remplace pas le jugement humain et ne « comprend » pas réellement.",
      category: QuizCategory.fondamentaux,
    ),
    Question(
      question:
          "Pourquoi les biais dans les modèles d'IA sont-ils problématiques ?",
      options: [
        "Ils rendent les modèles plus lents",
        "Ils reproduisent les discriminations présentes dans les données d'entraînement",
        "Ils augmentent le coût des requêtes",
        "Ils empêchent de traiter le français correctement"
      ],
      correctIndex: 1,
      explanation:
          "Les modèles apprennent à partir de données humaines qui contiennent des biais. Ces discriminations peuvent donc se retrouver dans les réponses générées.",
      category: QuizCategory.risques,
    ),
    Question(
      question:
          "Qu'est-ce que le mécanisme d'« auto-attention » du Transformer ?",
      options: [
        "Un système de correction orthographique automatique",
        "Un mécanisme permettant au modèle de comprendre le contexte des mots entre eux",
        "Un outil de compression de données",
        "Un filtre de contenu inapproprié"
      ],
      correctIndex: 1,
      explanation:
          "L'auto-attention permet au modèle de relier les mots entre eux selon leur contexte. Ex : dans « la tortue est fatiguée », il sait que c'est la tortue, pas la route.",
      category: QuizCategory.fonctionnement,
    ),
    Question(
      question:
          "Dans un conseil départemental, que ne remplacera JAMAIS l'IA ?",
      options: [
        "La rédaction d'un premier brouillon de mail",
        "La création d'une trame de présentation",
        "La décision politique et la responsabilité juridico-administrative",
        "La synthèse d'un long document interne"
      ],
      correctIndex: 2,
      explanation:
          "L'IA ne remplacera pas le jugement humain, la responsabilité juridique, la décision politique, l'évaluation sociale/éducative/médicale, ni la relation avec les usagers.",
      category: QuizCategory.usages,
    ),
  ];

  static const List<FlashQuestion> flashQuestions = [
    FlashQuestion(
      statement:
          "ChatGPT a atteint 100 millions d'utilisateurs en seulement 2 mois.",
      isTrue: true,
      explanation: "Record absolu dans l'histoire des technologies grand public.",
    ),
    FlashQuestion(
      statement: "Un token correspond exactement à un mot entier.",
      isTrue: false,
      explanation:
          "Un token représente en moyenne 75 % d'un mot, pas un mot entier.",
    ),
    FlashQuestion(
      statement:
          "Un modèle d'IA générative peut « halluciner » des faits avec confiance.",
      isTrue: true,
      explanation:
          "C'est un risque majeur qui impose une relecture humaine systématique.",
    ),
    FlashQuestion(
      statement:
          "On peut copier-coller des dossiers nominatifs de bénéficiaires dans ChatGPT.",
      isTrue: false,
      explanation:
          "C'est strictement interdit pour des raisons de confidentialité et de RGPD.",
    ),
    FlashQuestion(
      statement: "GPT signifie Generative Pre-trained Transformer.",
      isTrue: true,
      explanation:
          "C'est l'architecture développée par OpenAI, basée sur les Transformers.",
    ),
    FlashQuestion(
      statement:
          "L'IA générative est née en 1997 avec le Machine Learning.",
      isTrue: false,
      explanation:
          "L'IA générative a émergé en 2021. Le Machine Learning date de 1997.",
    ),
    FlashQuestion(
      statement:
          "Un même modèle d'IA peut être utilisé par différentes applications.",
      isTrue: true,
      explanation:
          "Ex : GPT-4 est utilisé par ChatGPT, Microsoft Copilot et bien d'autres.",
    ),
    FlashQuestion(
      statement:
          "L'IA générative donne toujours la même réponse au même prompt.",
      isTrue: false,
      explanation:
          "Les LLMs ne sont pas déterministes : une même question peut donner des réponses différentes.",
    ),
    FlashQuestion(
      statement:
          "Les coûts d'utilisation des modèles d'IA sont calculés en nombre de tokens.",
      isTrue: true,
      explanation:
          "Le volume de données envoyé/reçu est compté en tokens, ce qui détermine le coût.",
    ),
    FlashQuestion(
      statement:
          "Le RAG permet de réduire les hallucinations en fournissant des données de référence.",
      isTrue: true,
      explanation:
          "Le RAG enrichit les réponses avec des sources fiables, limitant l'invention de faits.",
    ),
    FlashQuestion(
      statement:
          "L'impact environnemental de l'IA générative est négligeable.",
      isTrue: false,
      explanation:
          "L'impact énergétique et financier des modèles est un enjeu majeur reconnu.",
    ),
    FlashQuestion(
      statement:
          "L'AI Act est le règlement européen qui encadre l'usage de l'intelligence artificielle.",
      isTrue: true,
      explanation:
          "L'AI Act adopte une approche réglementaire graduelle basée sur les niveaux de risque.",
    ),
  ];

  static const List<Scenario> scenarios = [
    Scenario(
      title: "Reformuler un mail interne",
      description:
          "Vous devez informer vos collègues d'un changement de procédure pour les demandes de congés. Vous utilisez l'IA pour reformuler votre mail afin de le rendre plus clair et professionnel.",
      correctType: ScenarioType.good,
      explanation:
          "Usage recommandé : reformuler un mail interne sans données personnelles sensibles. L'IA aide à améliorer la clarté et le ton, la validation reste chez vous.",
      icon: "✉️",
    ),
    Scenario(
      title: "Dossier d'un mineur en protection de l'enfance",
      description:
          "Vous traitez le cas d'un mineur suivi par le service ASE. Pour gagner du temps, vous copiez-collez l'intégralité du dossier dans ChatGPT pour obtenir une synthèse rapide.",
      correctType: ScenarioType.forbidden,
      explanation:
          "Strictement interdit ! Les données nominatives de bénéficiaires, surtout les mineurs en protection de l'enfance, ne peuvent jamais être saisies dans un outil IA grand public.",
      icon: "👶",
    ),
    Scenario(
      title: "Plan d'une présentation de bilan",
      description:
          "Votre direction vous demande un bilan de l'activité de votre service. Vous demandez à l'IA de générer un plan structuré à partir de vos idées et de vos chiffres anonymisés.",
      correctType: ScenarioType.good,
      explanation:
          "Usage recommandé : générer un plan ou une trame de présentation est un excellent cas d'usage. L'IA structure vos idées, vous gardez le contrôle du contenu final.",
      icon: "📊",
    ),
    Scenario(
      title: "Validation juridique d'un marché public",
      description:
          "Votre service doit attribuer un marché public. Pour accélérer, vous demandez à l'IA de valider juridiquement les critères d'attribution et la conformité du CCTP.",
      correctType: ScenarioType.forbidden,
      explanation:
          "Interdit ! L'IA ne peut pas servir de validation juridique. La responsabilité administrative et juridique ne peut jamais être déléguée à une IA.",
      icon: "⚖️",
    ),
    Scenario(
      title: "Synthèse d'un compte-rendu de direction",
      description:
          "Après une réunion de direction de 3 heures, vous avez un CR de 15 pages. Vous utilisez l'IA pour en extraire les points clés et les décisions (le document ne contient pas de données personnelles).",
      correctType: ScenarioType.caution,
      explanation:
          "Usage possible avec précautions : vérifiez l'absence de données sensibles, relisez et validez la synthèse. L'IA peut nuancer ou omettre certaines décisions importantes.",
      icon: "📝",
    ),
    Scenario(
      title: "Envoi automatisé de décisions administratives",
      description:
          "Face à un volume important de demandes, vous configurez l'IA pour qu'elle rédige et envoie automatiquement des décisions administratives sans aucune relecture humaine.",
      correctType: ScenarioType.forbidden,
      explanation:
          "Strictement interdit ! Une décision administrative ne peut être rédigée et envoyée sans relecture humaine. La responsabilité reste toujours sur l'agent signataire.",
      icon: "🚫",
    ),
    Scenario(
      title: "Aide à la structuration d'une note de service",
      description:
          "Votre DGS vous demande une note d'aide à la décision sur le choix entre deux prestataires. Vous utilisez l'IA pour structurer la note et rédiger un premier jet à partir de vos éléments.",
      correctType: ScenarioType.caution,
      explanation:
          "Usage possible avec précautions : l'IA aide à structurer, mais vous devez vérifier chaque information, compléter avec vos analyses et valider tout le contenu avant envoi.",
      icon: "🔍",
    ),
    Scenario(
      title: "Création d'une FAQ interne",
      description:
          "Votre service reçoit souvent les mêmes questions des agents sur vos procédures. Vous utilisez l'IA pour générer une trame de FAQ interne à partir d'une liste de questions fréquentes.",
      correctType: ScenarioType.good,
      explanation:
          "Usage recommandé : générer une trame de FAQ est un excellent cas d'usage. Vous économisez du temps tout en gardant le contrôle total du contenu final.",
      icon: "❓",
    ),
  ];
}
