import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class FoxAIPedagogyGamePage extends StatefulWidget {
  const FoxAIPedagogyGamePage({super.key});

  @override
  State<FoxAIPedagogyGamePage> createState() => _FoxAIPedagogyGamePageState();
}

enum LearningMode { generative, workflow, agentic }

class _FoxAIPedagogyGamePageState extends State<FoxAIPedagogyGamePage>
    with TickerProviderStateMixin {
  LearningMode mode = LearningMode.generative;

  int stars = 0;

  double foxX = 0.12;
  double foxY = 0.74;
  String foxMood = "🦊";
  String foxSpeech =
      "Salut. Je suis Fox. On va comprendre les grandes logiques de l’IA en jouant.";
  bool foxCrowned = false;

  late final AnimationController bounceController;
  late final Animation<double> bounceAnim;

  // ==================== GENERATIVE ====================
  final List<Map<String, String>> generativeExamples = const [
    {
      "title": "Réponse à un usager",
      "prompt":
          "Rédige une réponse polie à un habitant qui signale un nid-de-poule sur une route départementale. Le ton doit être institutionnel, clair et rassurant.",
      "output":
          "Bonjour,\n\nNous vous remercions pour votre signalement concernant la chaussée. Votre message a bien été transmis au service en charge de l’entretien des routes départementales afin qu’une évaluation soit réalisée dans les meilleurs délais.\n\nSelon le niveau de dégradation constaté et les contraintes de sécurité, une intervention pourra être programmée rapidement ou intégrée à une opération d’entretien plus large.\n\nNous vous remercions de votre vigilance, qui contribue à la sécurité de tous les usagers.\n\nCordialement,\nLe Conseil départemental"
    },
    {
      "title": "Synthèse d’un compte-rendu",
      "prompt":
          "Fais une synthèse claire et courte d’un compte-rendu de réunion sur la rénovation d’un collège : calendrier, budget, contraintes, prochaines étapes.",
      "output":
          "Synthèse proposée :\n- Le chantier de rénovation du collège est prévu en plusieurs phases afin de limiter l’impact sur les activités pédagogiques.\n- Le budget prévisionnel a été confirmé, avec un suivi renforcé des coûts liés aux matériaux.\n- Les principales contraintes concernent la sécurité des zones de circulation et la coordination avec les équipes éducatives.\n- Les prochaines étapes portent sur la validation du planning détaillé, la consultation des entreprises et l’organisation de la communication auprès des familles."
    },
    {
      "title": "Affiche prévention canicule",
      "prompt":
          "Propose le texte d’une affiche de prévention canicule destinée aux personnes âgées accompagnées par les services du département.",
      "output":
          "CANICULE : adoptez les bons réflexes\n\n• Buvez régulièrement de l’eau, même sans soif\n• Fermez volets et fenêtres aux heures chaudes\n• Évitez les sorties en début d’après-midi\n• Donnez régulièrement de vos nouvelles à un proche\n• En cas de malaise ou de forte fatigue, contactez rapidement un professionnel de santé\n\nLe Conseil départemental reste mobilisé pour accompagner les publics les plus fragiles."
    },
    {
      "title": "Aide à la reformulation administrative",
      "prompt":
          "Reformule de façon simple un texte administratif expliquant les conditions d’accès à une aide sociale départementale.",
      "output":
          "Version simplifiée :\nCette aide peut être accordée selon votre situation personnelle et vos ressources. Pour savoir si vous pouvez en bénéficier, vous devez déposer un dossier avec les pièces demandées. Le service compétent étudiera ensuite votre demande et vous informera de la décision."
    },
    {
      "title": "Post LinkedIn institutionnel",
      "prompt":
          "Propose un post LinkedIn valorisant l’ouverture d’une nouvelle maison départementale des solidarités, avec un ton professionnel et accessible.",
      "output":
          "Nous sommes heureux d’annoncer l’ouverture d’une nouvelle Maison départementale des solidarités, conçue pour rapprocher les services publics des habitants et faciliter l’accompagnement des familles, des jeunes et des personnes en situation de fragilité.\n\nCe nouveau lieu d’accueil traduit concrètement notre volonté d’offrir un service plus lisible, plus accessible et plus humain sur l’ensemble du territoire."
    },
    {
      "title": "Résumé d’un rapport insertion",
      "prompt":
          "Résume en 6 lignes un rapport sur l’insertion, l’accompagnement à l’emploi et les partenariats territoriaux menés par le département.",
      "output":
          "Le rapport met en avant une coordination renforcée entre les acteurs de l’insertion et de l’emploi. Il souligne l’importance de l’accompagnement individualisé, du lien avec les entreprises locales et du suivi de terrain. Plusieurs actions ont permis d’améliorer la visibilité des dispositifs existants. Le document recommande enfin un meilleur partage des données, une évaluation plus régulière des parcours et une coopération accrue entre partenaires institutionnels."
    },
    {
      "title": "Note interne numérique",
      "prompt":
          "Rédige l’ossature d’une note interne pour présenter un nouveau dispositif numérique aux agents départementaux.",
      "output":
          "Proposition d’ossature :\n1. Contexte et objectifs du dispositif\n2. Publics concernés\n3. Fonctionnalités principales\n4. Modalités de déploiement\n5. Accompagnement des agents et formation\n6. Appui technique et contacts utiles\n7. Calendrier de mise en œuvre"
    },
    {
      "title": "FAQ transport scolaire",
      "prompt":
          "Génère une petite FAQ sur les démarches liées au transport scolaire géré par le département.",
      "output":
          "FAQ proposée :\n1. Comment faire une demande de transport scolaire ?\nLa demande s’effectue en ligne ou via le formulaire prévu par le service compétent.\n\n2. Quels justificatifs fournir ?\nLes pièces demandées peuvent inclure un justificatif de domicile, un certificat de scolarité et, selon les cas, une photo d’identité.\n\n3. Quand reçoit-on la réponse ?\nLe délai dépend de la période de dépôt et du traitement des dossiers.\n\n4. Qui contacter en cas de difficulté ?\nLe service transport du département peut vous orienter et vous accompagner dans vos démarches."
    },
  ];

  int selectedGenIndex = 0;
  bool isGenerating = false;
  int genStage = -1;
  String visiblePrompt = "";
  String genOutput = "Choisis un cas d’usage puis lance la génération.";
  bool genHasStarted = false;

  // ==================== WORKFLOW ====================
  final List<String> workflowAvailableBlocks = const [
    "Recevoir une demande usager",
    "Classifier automatiquement la demande",
    "Extraire les informations avec l’IA",
    "Résumer le dossier pour l’agent",
    "Contrôler avec des règles métier",
    "Faire valider par un agent humain",
    "Envoyer une réponse ou une notification",
    "Archiver le dossier traité",
  ];

  final List<String?> workflowSlots = List<String?>.filled(4, null);
  String workflowLiveOutput =
      "Construis un workflow moderne avec 4 étapes. L’IA n’est qu’un maillon d’un système plus large.";
  String workflowInterpretation =
      "Dépose des blocs dans les 4 zones pour voir comment la chaîne se comporte.";
  int workflowAnimatedIndex = -1;
  bool workflowRunning = false;

  // ==================== AGENTIC ====================
  final List<String> agentGoals = const [
    "Préparer une réponse complète à un usager",
    "Analyser un dossier et signaler les anomalies",
    "Organiser une campagne d’information territoriale",
    "Préparer une synthèse multi-services",
  ];

  String selectedAgentGoal = "Préparer une réponse complète à un usager";
  List<_AgentLogEntry> agentEntries = [];
  bool agentRunning = false;
  bool agentSolved = false;
  int agentToolsUsed = 0;
  int agentSubAgentsUsed = 0;
  bool toolFlash = false;
  bool subAgentFlash = false;
  bool decisionFlash = false;
  String agentDecision =
      "L’agent n’a pas encore décidé de stratégie. Lance-le pour observer.";
  String agentFinalOutput =
      "Le résultat final apparaîtra ici avec la trace des décisions.";

  Completer<void>? _pendingConfirmationCompleter;

  @override
  void initState() {
    super.initState();

    bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    bounceAnim = Tween<double>(begin: 0, end: 7).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.easeInOut),
    );

    _setMode(LearningMode.generative);
  }

  @override
  void dispose() {
    bounceController.dispose();
    super.dispose();
  }

  void _addStars(int value) {
    setState(() {
      stars += value;
    });
  }

  Color _modeColor(LearningMode value) {
    switch (value) {
      case LearningMode.generative:
        return const Color(0xFF7C4DFF);
      case LearningMode.workflow:
        return const Color(0xFF00A896);
      case LearningMode.agentic:
        return const Color(0xFFFF8C42);
    }
  }

  String _modeTitle(LearningMode value) {
    switch (value) {
      case LearningMode.generative:
        return "Génératif";
      case LearningMode.workflow:
        return "Workflow";
      case LearningMode.agentic:
        return "Agentique";
    }
  }

  String _modeSubtitle(LearningMode value) {
    switch (value) {
      case LearningMode.generative:
        return "Prompt → réponse";
      case LearningMode.workflow:
        return "Chaîne moderne";
      case LearningMode.agentic:
        return "But → décision → action";
    }
  }

  void _setMode(LearningMode newMode) {
    setState(() {
      mode = newMode;
      foxCrowned = false;
      foxMood = "🦊";

      switch (newMode) {
        case LearningMode.generative:
          foxX = 0.12;
          foxY = 0.74;
          foxSpeech =
              "Ici, on donne une consigne et le modèle produit directement une sortie.";
          break;
        case LearningMode.workflow:
          foxX = 0.44;
          foxY = 0.64;
          foxSpeech =
              "Ici, l’IA s’insère dans une chaîne moderne : réception, analyse, contrôle, validation et action.";
          break;
        case LearningMode.agentic:
          foxX = 0.73;
          foxY = 0.51;
          foxSpeech =
              "Ici, le renard agit comme un agent : il choisit, utilise des outils, appelle d’autres agents et réajuste son plan.";
          break;
      }
    });
  }

  // ==================== GENERATIVE ====================

  Future<void> _typeText({
    required String fullText,
    required void Function(String text) onUpdate,
    Duration charDelay = const Duration(milliseconds: 22),
  }) async {
    String current = "";
    for (int i = 0; i < fullText.length; i++) {
      current += fullText[i];
      onUpdate(current);
      await Future.delayed(charDelay);
    }
  }

  Future<void> _runGenerative() async {
    if (isGenerating) return;

    final example = generativeExamples[selectedGenIndex];
    final prompt = example["prompt"]!;
    final output = example["output"]!;

    setState(() {
      isGenerating = true;
      genHasStarted = true;
      genStage = 0;
      visiblePrompt = "";
      genOutput = "Préparation de la génération...";
      foxMood = "✨🦊";
      foxSpeech =
          "On révèle d’abord le prompt, puis on montre le passage dans le modèle, puis la sortie finale.";
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    await _typeText(
      fullText: prompt,
      charDelay: const Duration(milliseconds: 24),
      onUpdate: (text) {
        if (!mounted) return;
        setState(() {
          visiblePrompt = text;
        });
      },
    );

    await Future.delayed(const Duration(milliseconds: 1300));

    setState(() {
      genStage = 1;
      genOutput =
          "Le modèle analyse la consigne, repère l’intention, le ton attendu et les éléments à produire avant de construire progressivement une réponse plausible.";
    });

    await Future.delayed(const Duration(milliseconds: 2800));

    setState(() {
      genStage = 2;
      genOutput = "";
    });

    await _typeText(
      fullText: output,
      charDelay: const Duration(milliseconds: 12),
      onUpdate: (text) {
        if (!mounted) return;
        setState(() {
          genOutput = text;
        });
      },
    );

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      foxMood = "🦊";
      foxSpeech =
          "Voilà : une consigne bien formulée, un passage dans le modèle, puis une sortie générée. C’est la logique générative.";
      foxCrowned = true;
      isGenerating = false;
    });

    _addStars(1);
  }

  // ==================== WORKFLOW ====================

  Future<void> _simulateWorkflow() async {
    if (workflowRunning) return;

    final steps = workflowSlots.whereType<String>().toList();

    setState(() {
      workflowRunning = true;
      workflowAnimatedIndex = -1;
      foxMood = "🧩🦊";
      foxCrowned = false;
      workflowLiveOutput = "Lancement du workflow...\n";
      workflowInterpretation =
          "On exécute la chaîne étape par étape pour observer le rôle de chaque bloc.";
      foxSpeech =
          "Observe bien : dans un workflow moderne, l’IA est un maillon d’un ensemble structuré.";
    });

    if (steps.isEmpty) {
      setState(() {
        workflowLiveOutput =
            "Aucun bloc n’a été placé. Le workflow ne peut rien exécuter.";
        workflowInterpretation =
            "Sans étapes définies, il n’y a ni orchestration, ni automatisation.";
        workflowRunning = false;
      });
      return;
    }

    final buffer = StringBuffer();
    bool hasReceive = false;
    bool hasClassify = false;
    bool hasExtract = false;
    bool hasSummarize = false;
    bool hasRules = false;
    bool hasHuman = false;
    bool hasSend = false;
    bool hasArchive = false;

    for (int i = 0; i < workflowSlots.length; i++) {
      final step = workflowSlots[i];
      if (step == null) continue;

      setState(() {
        workflowAnimatedIndex = i;
      });

      await Future.delayed(const Duration(milliseconds: 950));

      switch (step) {
        case "Recevoir une demande usager":
          hasReceive = true;
          buffer.writeln(
              "• Une nouvelle demande usager entre dans le workflow comme point de départ.");
          break;
        case "Classifier automatiquement la demande":
          hasClassify = true;
          if (hasReceive) {
            buffer.writeln(
                "• Le système tente de reconnaître la nature de la demande pour orienter le bon traitement.");
          } else {
            buffer.writeln(
                "• Une classification est lancée, mais elle intervient sans entrée claire au préalable.");
          }
          break;
        case "Extraire les informations avec l’IA":
          hasExtract = true;
          if (hasReceive || hasClassify) {
            buffer.writeln(
                "• L’IA extrait les informations clés, comme le sujet, les éléments utiles et les données importantes.");
          } else {
            buffer.writeln(
                "• L’IA tente d’extraire des informations, mais le contexte d’entrée reste trop faible.");
          }
          break;
        case "Résumer le dossier pour l’agent":
          hasSummarize = true;
          if (hasExtract || hasReceive) {
            buffer.writeln(
                "• Le contenu est condensé pour accélérer la compréhension par un agent humain.");
          } else {
            buffer.writeln(
                "• Un résumé est produit, mais il repose sur peu de matière utile.");
          }
          break;
        case "Contrôler avec des règles métier":
          hasRules = true;
          if (hasExtract || hasSummarize || hasReceive) {
            buffer.writeln(
                "• Des règles métier viennent fiabiliser le traitement et repérer les cas incomplets ou prioritaires.");
          } else {
            buffer.writeln(
                "• Les règles s’exécutent, mais sans données solides à contrôler.");
          }
          break;
        case "Faire valider par un agent humain":
          hasHuman = true;
          if (hasExtract || hasRules || hasSummarize) {
            buffer.writeln(
                "• Un agent humain reprend la main pour arbitrer, corriger ou valider le résultat.");
          } else {
            buffer.writeln(
                "• Une validation humaine intervient, mais sans vraie préparation en amont.");
          }
          break;
        case "Envoyer une réponse ou une notification":
          hasSend = true;
          if (hasHuman || hasRules || hasExtract || hasSummarize) {
            buffer.writeln(
                "• Une action de sortie est déclenchée : réponse à l’usager ou notification vers un service.");
          } else {
            buffer.writeln(
                "• Une notification est envoyée très tôt, avec un risque de message peu fiable.");
          }
          break;
        case "Archiver le dossier traité":
          hasArchive = true;
          buffer.writeln(
              "• Le dossier et ses résultats sont conservés pour traçabilité ou suivi.");
          break;
      }

      setState(() {
        workflowLiveOutput = buffer.toString().trim();
      });
    }

    await Future.delayed(const Duration(milliseconds: 700));

    final signature = workflowSlots.map((e) => e ?? "_").join(" > ");
    final result = _workflowSpecificAnalysis(
      signature: signature,
      hasReceive: hasReceive,
      hasClassify: hasClassify,
      hasExtract: hasExtract,
      hasSummarize: hasSummarize,
      hasRules: hasRules,
      hasHuman: hasHuman,
      hasSend: hasSend,
      hasArchive: hasArchive,
    );

    setState(() {
      workflowLiveOutput = result.$1;
      workflowInterpretation = result.$2;
      workflowAnimatedIndex = -1;
      workflowRunning = false;
      foxMood = "🦊";
      foxCrowned = true;
    });

    _addStars(2);
  }

  (String, String) _workflowSpecificAnalysis({
    required String signature,
    required bool hasReceive,
    required bool hasClassify,
    required bool hasExtract,
    required bool hasSummarize,
    required bool hasRules,
    required bool hasHuman,
    required bool hasSend,
    required bool hasArchive,
  }) {
    String actionSummary;
    String pedagogy;

    if (!hasReceive) {
      actionSummary =
          "Le workflow démarre sans vraie entrée formalisée. Certaines étapes peuvent s’exécuter, mais la chaîne repose sur une base fragile.";
      pedagogy =
          "Dans un workflow moderne, une entrée claire est essentielle. Sans elle, même une bonne IA ou de bonnes règles interviennent dans le vide.";
      return (actionSummary, pedagogy);
    }

    if (hasReceive && hasClassify && hasExtract && hasSend &&
        !hasRules && !hasHuman) {
      actionSummary =
          "La demande est reçue, classée, analysée par l’IA puis une réponse ou une notification est envoyée rapidement. Le flux est très automatisé.";
      pedagogy =
          "Cette disposition montre une chaîne efficace pour gagner du temps, mais peu sécurisée. Sans règles métier ni validation humaine, le système peut aller vite au détriment de la fiabilité.";
      return (actionSummary, pedagogy);
    }

    if (hasReceive && hasExtract && hasRules && hasHuman) {
      actionSummary =
          "La demande est reçue, l’IA extrait les informations utiles, les règles métier vérifient la cohérence, puis un agent humain valide avant diffusion éventuelle.";
      pedagogy =
          "C’est l’un des meilleurs schémas pour un contexte public : l’IA accélère la préparation, les règles réduisent le risque et l’humain garde le dernier mot.";
      return (actionSummary, pedagogy);
    }

    if (hasReceive && hasSummarize && hasHuman && hasSend) {
      actionSummary =
          "La demande entre, un résumé est préparé pour l’agent, celui-ci valide rapidement, puis une réponse ou notification est envoyée.";
      pedagogy =
          "Ici, l’IA sert surtout à alléger la charge cognitive de l’agent humain. Le gain n’est pas tant dans l’automatisation totale que dans l’assistance au traitement.";
      return (actionSummary, pedagogy);
    }

    if (hasReceive && hasClassify && hasRules && hasArchive && !hasExtract) {
      actionSummary =
          "La demande est reçue, triée automatiquement, contrôlée par des règles, puis conservée dans le système pour suivi ou traitement ultérieur.";
      pedagogy =
          "Ce workflow montre qu’un système moderne ne repose pas forcément sur un LLM. La valeur vient aussi du tri, du contrôle et de la traçabilité.";
      return (actionSummary, pedagogy);
    }

    if (hasReceive && hasExtract && hasSummarize && hasArchive) {
      actionSummary =
          "La demande est transformée par l’IA en informations plus lisibles et plus compactes, puis archivée avec une valeur ajoutée documentaire.";
      pedagogy =
          "Ici, l’IA agit comme moteur d’enrichissement documentaire. Le workflow sert moins à répondre qu’à structurer l’information pour un usage futur.";
      return (actionSummary, pedagogy);
    }

    if (hasReceive && hasRules && hasHuman && hasSend) {
      actionSummary =
          "La demande suit une chaîne de contrôle puis de validation avant d’aboutir à un envoi. L’accent est mis sur la maîtrise du risque.";
      pedagogy =
          "Cette composition montre un workflow prudent. Elle convient bien à des cas sensibles, mais exploite moins la puissance d’accélération de l’IA.";
      return (actionSummary, pedagogy);
    }

    if (hasExtract && hasSummarize && !hasRules && !hasHuman) {
      actionSummary =
          "L’IA extrait puis condense les informations pour produire un résultat rapide, mais sans réelle supervision ni garde-fou.";
      pedagogy =
          "Cette chaîne montre bien la puissance de l’IA pour traiter vite de l’information, mais elle souligne aussi pourquoi les workflows modernes ajoutent souvent règles ou validation humaine.";
      return (actionSummary, pedagogy);
    }

    if (hasSend && !hasExtract && !hasRules && !hasHuman) {
      actionSummary =
          "Une action de sortie est déclenchée très tôt, sans transformation ni contrôle suffisants.";
      pedagogy =
          "Cette disposition illustre un mauvais design de workflow : aller trop vite vers la sortie sans préparation augmente fortement le risque d’erreur.";
      return (actionSummary, pedagogy);
    }

    actionSummary =
        "Cette chaîne combine plusieurs briques de traitement, de contrôle et d’action. Selon l’ordre choisi, l’automatisation est soit plus rapide, soit plus sécurisée, soit plus utile pour l’humain.";
    pedagogy =
        "Ta disposition montre bien une idée centrale : un workflow moderne n’est pas qu’une IA. C’est une orchestration où chaque bloc modifie le rôle de l’IA, de l’humain et des règles.";
    return (actionSummary, pedagogy);
  }

  Widget _buildWorkflowSlot(int index) {
    final current = workflowSlots[index];

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        setState(() {
          workflowSlots[index] = details.data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final isActive = workflowAnimatedIndex == index;
        final color = _modeColor(LearningMode.workflow);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: 92,
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.30)
                : isHovering
                    ? color.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? color
                  : isHovering
                      ? color.withValues(alpha: 0.9)
                      : Colors.white12,
              width: isActive ? 1.8 : 1.3,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: current == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Étape ${index + 1}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          current,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            workflowSlots[index] = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        );
      },
    );
  }

  // ==================== AGENTIC ====================

  Future<void> _flashDecision() async {
    setState(() => decisionFlash = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => decisionFlash = false);
  }

  Future<void> _flashTool() async {
    setState(() => toolFlash = true);
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    setState(() => toolFlash = false);
  }

  Future<void> _flashSubAgent() async {
    setState(() => subAgentFlash = true);
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    setState(() => subAgentFlash = false);
  }

  Future<void> _addTypedAgentEntry(
    String fullText, {
    bool requiresConfirmation = false,
    String confirmationLabel = "Valider pour continuer",
  }) async {
    final entry = _AgentLogEntry(
      fullText: fullText,
      displayedText: "",
      requiresConfirmation: requiresConfirmation,
      confirmationLabel: confirmationLabel,
    );

    setState(() {
      agentEntries.add(entry);
    });

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      setState(() {
        entry.displayedText += fullText[i];
      });
    }

    if (requiresConfirmation) {
      _pendingConfirmationCompleter = Completer<void>();
      await _pendingConfirmationCompleter!.future;
      _pendingConfirmationCompleter = null;
    } else {
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  void _confirmPendingStep(_AgentLogEntry entry) {
    if (entry.confirmed) return;
    setState(() {
      entry.confirmed = true;
    });
    _pendingConfirmationCompleter?.complete();
  }

  Future<void> _runAgent() async {
    if (agentRunning) return;

    setState(() {
      agentRunning = true;
      agentSolved = false;
      agentEntries.clear();
      agentToolsUsed = 0;
      agentSubAgentsUsed = 0;
      foxMood = "🎯🦊";
      foxCrowned = false;
      decisionFlash = false;
      toolFlash = false;
      subAgentFlash = false;
      agentDecision = "L’agent reçoit l’objectif et commence à planifier.";
      agentFinalOutput = "L’agent commence sa mission...";
      foxSpeech =
          "Tu vas voir une différence clé : l’agent ne se contente pas de répondre, il choisit ce qu’il doit faire.";
    });

    Future<void> doDecision(String text) async {
      setState(() {
        agentDecision = text;
      });
      await _flashDecision();
    }

    Future<void> useTool(String explanation) async {
      agentToolsUsed++;
      if (mounted) setState(() {});
      await _flashTool();
      await _addTypedAgentEntry(explanation);
    }

    Future<void> useSubAgent(String explanation) async {
      agentSubAgentsUsed++;
      if (mounted) setState(() {});
      await _flashSubAgent();
      await _addTypedAgentEntry(explanation);
    }

    await _addTypedAgentEntry("1. Objectif reçu : $selectedAgentGoal");

    if (selectedAgentGoal == "Préparer une réponse complète à un usager") {
      await doDecision(
          "Décision : commencer par rechercher le contexte du dossier avant de rédiger.");
      await _addTypedAgentEntry(
          "2. L’agent estime qu’une réponse immédiate serait trop fragile sans contexte.");
      await useTool(
          "3. Outil utilisé : consultation des éléments utiles du dossier et des informations déjà disponibles.");
      await _addTypedAgentEntry(
          "4. Observation : les faits sont présents, mais la formulation doit rester institutionnelle et prudente.");
      await doDecision(
          "Nouvelle décision : déléguer la formulation à un sous-agent spécialisé en rédaction.");
      await useSubAgent(
          "5. Sous-agent sollicité : agent rédacteur institutionnel.");
      await _addTypedAgentEntry(
          "6. Le sous-agent produit une première version claire, mais encore un peu générique.");
      await doDecision(
          "Décision : demander une validation humaine avant d’ajouter une précision sur les délais.");
      await _addTypedAgentEntry(
        "7. L’agent souhaite vérifier avec l’utilisateur s’il peut intégrer une formulation plus engageante sur le délai de traitement.",
        requiresConfirmation: true,
        confirmationLabel: "Confirmer l’ajout de précision",
      );
      await _addTypedAgentEntry(
          "8. Après confirmation, l’agent révise la réponse et renforce la précision opérationnelle.");
      setState(() {
        agentFinalOutput =
            "Résultat de l’agent :\n- recherche préalable dans le dossier\n- décision de ne pas répondre trop tôt\n- appel d’un sous-agent de rédaction\n- validation intermédiaire par l’utilisateur\n- production d’une réponse plus robuste qu’une génération unique";
      });
    } else if (selectedAgentGoal == "Analyser un dossier et signaler les anomalies") {
      await doDecision(
          "Décision : lire la structure du dossier puis lancer un contrôle ciblé.");
      await _addTypedAgentEntry(
          "2. L’agent choisit d’abord de comprendre le dossier avant d’alerter.");
      await useTool(
          "3. Outil utilisé : lecture structurée des pièces et des champs disponibles.");
      await _addTypedAgentEntry(
          "4. Observation : plusieurs éléments semblent incomplets ou incohérents.");
      await doDecision(
          "Décision : déléguer la vérification détaillée à un sous-agent de contrôle.");
      await useSubAgent(
          "5. Sous-agent sollicité : agent contrôleur de conformité.");
      await _addTypedAgentEntry(
          "6. Le sous-agent renvoie une liste hiérarchisée d’anomalies.");
      await doDecision(
          "Décision : ne signaler que les écarts importants pour éviter de surcharger l’agent humain.");
      await _addTypedAgentEntry(
          "7. L’agent priorise les anomalies et prépare un signalement exploitable.");
      setState(() {
        agentFinalOutput =
            "Résultat de l’agent :\n- lecture outillée du dossier\n- détection d’écarts\n- appel à un sous-agent de contrôle\n- priorisation des anomalies\n- production d’un signalement utile pour l’humain";
      });
    } else if (selectedAgentGoal ==
        "Organiser une campagne d’information territoriale") {
      await doDecision(
          "Décision : orchestrer plusieurs sous-agents spécialisés par canal.");
      await _addTypedAgentEntry(
          "2. L’agent comprend qu’aucune sortie unique ne suffira pour tous les supports.");
      await useSubAgent(
          "3. Sous-agent sollicité : agent de rédaction web.");
      await useSubAgent(
          "4. Sous-agent sollicité : agent réseaux sociaux.");
      await useTool(
          "5. Outil utilisé : calendrier de diffusion pour ordonner les publications.");
      await _addTypedAgentEntry(
          "6. Observation : certains messages sont trop longs pour les formats courts.");
      await doDecision(
          "Décision : demander confirmation avant de lancer une adaptation multi-supports.");
      await _addTypedAgentEntry(
        "7. L’agent souhaite valider avec l’utilisateur le principe d’une reformulation spécifique pour chaque canal.",
        requiresConfirmation: true,
        confirmationLabel: "Valider l’adaptation par support",
      );
      await _addTypedAgentEntry(
          "8. Après validation, l’agent reformule et harmonise la campagne avant restitution finale.");
      setState(() {
        agentFinalOutput =
            "Résultat de l’agent :\n- stratégie multi-canal\n- appel à plusieurs sous-agents spécialisés\n- utilisation d’un outil de calendrier\n- validation intermédiaire par l’utilisateur\n- consolidation d’un plan cohérent";
      });
    } else {
      await doDecision(
          "Décision : collecter les informations de plusieurs services avant de synthétiser.");
      await _addTypedAgentEntry(
          "2. L’agent identifie un besoin d’agrégation avant toute rédaction.");
      await useTool(
          "3. Outil utilisé : collecte de contenus multi-services.");
      await _addTypedAgentEntry(
          "4. Observation : les formats sont hétérogènes et parfois redondants.");
      await doDecision(
          "Décision : normaliser les informations puis déléguer la synthèse.");
      await _addTypedAgentEntry(
          "5. L’agent homogénéise les contenus pour préparer un meilleur résumé.");
      await useSubAgent(
          "6. Sous-agent sollicité : agent synthétiseur.");
      await _addTypedAgentEntry(
          "7. La première synthèse est correcte, mais encore trop dense.");
      await doDecision(
          "Décision : condenser davantage et mieux hiérarchiser les points clés.");
      await _addTypedAgentEntry(
          "8. L’agent révise le livrable avant de le rendre final.");
      setState(() {
        agentFinalOutput =
            "Résultat de l’agent :\n- collecte de plusieurs sources\n- normalisation des contenus\n- appel à un sous-agent de synthèse\n- révision du premier résultat\n- production d’une synthèse hiérarchisée";
      });
    }

    await Future.delayed(const Duration(milliseconds: 900));

    setState(() {
      agentRunning = false;
      agentSolved = true;
      foxMood = "🦊";
      foxCrowned = true;
      foxSpeech =
          "Ici, l’IA ne fait pas qu’écrire : elle choisit une stratégie, utilise des outils, appelle d’autres agents et ajuste sa trajectoire.";
    });

    _addStars(3);
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1222),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151937),
        elevation: 0,
        centerTitle: true,
        title: const Text("Fox Lab — IA générative, workflow et agentique", style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _topHud(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    _worldScene(width),
                    const SizedBox(height: 16),
                    _modeSelector(),
                    const SizedBox(height: 16),
                    _speechBubble(),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _buildModePanel(),
                    ),
                    const SizedBox(height: 18),
                    _pedagogyCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHud() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171B39),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Fox te montre 3 façons d’utiliser l’IA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          /*
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "⭐ $stars",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )*/
        ],
      ),
    );
  }

  Widget _worldScene(double width) {
    final sceneHeight = min(320.0, width * 0.62);
    final foxLeft = (width - 32) * foxX;
    final foxTop = sceneHeight * foxY;

    return Container(
      height: sceneHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F2A5A), Color(0xFF11162F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WorldPainter(modeColor: _modeColor(mode)),
            ),
          ),
          _buildStation(
            leftFactor: 0.12,
            topFactor: 0.60,
            title: "Génératif",
            icon: Icons.bolt,
            color: _modeColor(LearningMode.generative),
            active: mode == LearningMode.generative,
          ),
          _buildStation(
            leftFactor: 0.54,
            topFactor: 0.45,
            title: "Workflow",
            icon: Icons.account_tree_rounded,
            color: _modeColor(LearningMode.workflow),
            active: mode == LearningMode.workflow,
          ),
          _buildStation(
            leftFactor: 0.90,
            topFactor: 0.30,
            title: "Agentique",
            icon: Icons.explore_rounded,
            color: _modeColor(LearningMode.agentic),
            active: mode == LearningMode.agentic,
          ),
          AnimatedBuilder(
            animation: bounceAnim,
            builder: (context, child) {
              return Positioned(
                left: foxLeft.clamp(8, width - 90),
                top: (foxTop - bounceAnim.value).clamp(20, sceneHeight - 96),
                child: child!,
              );
            },
            child: SizedBox(
              width: 72,
              height: 86,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 24,
                    child: Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: _modeColor(mode).withValues(alpha: 0.35),
                            blurRadius: 18,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Text(
                        foxMood,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  if (foxCrowned)
                    const Positioned(
                      top: 0,
                      child: Text(
                        "👑",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  const Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: 42,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.all(Radius.circular(99)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStation({
    required double leftFactor,
    required double topFactor,
    required String title,
    required IconData icon,
    required Color color,
    required bool active,
  }) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.70 * leftFactor,
      top: 270 * topFactor,
      child: GestureDetector(
        onTap: () {
          if (title == "Génératif") {
            _setMode(LearningMode.generative);
          } else if (title == "Workflow") {
            _setMode(LearningMode.workflow);
          } else {
            _setMode(LearningMode.agentic);
          }
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          scale: active ? 1.06 : 1.0,
          child: Container(
            width: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: active ? 0.95 : 0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active ? Colors.white70 : Colors.white24,
                width: active ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeSelector() {
    return Row(
      children: LearningMode.values.map((m) {
        final selected = m == mode;
        final color = _modeColor(m);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _setMode(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      selected ? color.withValues(alpha: 0.22) : const Color(0xFF171B39),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? color : Colors.white12,
                    width: 1.3,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _modeTitle(m),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _modeSubtitle(m),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 11.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _speechBubble() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF191E40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🦊", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              foxSpeech,
              style: const TextStyle(
                color: Colors.white,
                height: 1.35,
                fontSize: 14.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePanel() {
    switch (mode) {
      case LearningMode.generative:
        return _generativePanel(key: const ValueKey("generative"));
      case LearningMode.workflow:
        return _workflowPanel(key: const ValueKey("workflow"));
      case LearningMode.agentic:
        return _agenticPanel(key: const ValueKey("agentic"));
    }
  }

  Widget _generativePanel({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(_modeColor(LearningMode.generative)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1. IA générative",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ici, le joueur choisit un cas d'usage afin de découvrir comment on part d'un prompt vers une réponse satisfaisante",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.84)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: selectedGenIndex,
            dropdownColor: const Color(0xFF1D2348),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            items: List.generate(
              generativeExamples.length,
              (i) => DropdownMenuItem(
                value: i,
                child: Text(generativeExamples[i]["title"]!),
              ),
            ),
            onChanged: isGenerating
                ? null
                : (v) {
                    if (v != null) {
                      setState(() {
                        selectedGenIndex = v;
                        genStage = -1;
                        genHasStarted = false;
                        visiblePrompt = "";
                        genOutput =
                            "Cas d’usage sélectionné. Appuie sur Générer pour révéler le prompt et lancer le modèle.";
                      });
                    }
                  },
          ),
          const SizedBox(height: 16),
          if (genHasStarted) ...[
            _label("Prompt révélé"),
            const SizedBox(height: 8),
            _outputBox(
              visiblePrompt.isEmpty ? "Le prompt va apparaître..." : visiblePrompt,
            ),
            const SizedBox(height: 16),
          ],
          _animatedGenerationPipeline(),
          const SizedBox(height: 16),
          _label("Sortie / explication"),
          const SizedBox(height: 8),
          _outputBox(genOutput),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _runGenerative,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(isGenerating ? "Génération..." : "GÉNÉRER"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _modeColor(LearningMode.generative),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _animatedGenerationPipeline() {
    final color = _modeColor(LearningMode.generative);

    return Row(
      children: [
        Expanded(
          child: _animatedStageBox(
            title: "Prompt",
            icon: Icons.edit_note_rounded,
            active: genStage == 0,
            done: genStage > 0,
            color: color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded, color: color),
        ),
        Expanded(
          child: _animatedStageBox(
            title: "Modèle",
            icon: Icons.memory_rounded,
            active: genStage == 1,
            done: genStage > 1,
            color: color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded, color: color),
        ),
        Expanded(
          child: _animatedStageBox(
            title: "Sortie",
            icon: Icons.description_rounded,
            active: genStage == 2,
            done: false,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _animatedStageBox({
    required String title,
    required IconData icon,
    required bool active,
    required bool done,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.95)
            : done
                ? color.withValues(alpha: 0.34)
                : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active || done ? color : Colors.white10,
          width: 1.3,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workflowPanel({required Key key}) {
    final color = _modeColor(LearningMode.workflow);
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final slotWidth = max(130.0, (screenWidth - 64) / 4);

    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "2. Workflow IA moderne",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Construis une chaîne moderne à 4 étapes. Le but est de montrer comment l’IA s’insère dans un système plus large, avec entrée, traitement, contrôle, humain et sortie.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.84)),
          ),
          const SizedBox(height: 16),
          _label("Blocs disponibles"),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: workflowAvailableBlocks.map((block) {
              return Draggable<String>(
                data: block,
                feedback: Material(
                  color: Colors.transparent,
                  child: _draggableWorkflowBlock(block, dragging: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.30,
                  child: _draggableWorkflowBlock(block),
                ),
                child: _draggableWorkflowBlock(block),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _label("Chaîne à construire"),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final useWrap = constraints.maxWidth < 720;
              if (useWrap) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: (constraints.maxWidth - 10) / 2,
                      child: _buildWorkflowSlot(index),
                    );
                  }),
                );
              }
              return Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 3 ? 0 : 10),
                      child: _buildWorkflowSlot(index),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _simulateWorkflow,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(workflowRunning ? "Exécution..." : "EXÉCUTER LE WORKFLOW"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < workflowSlots.length; i++) {
                      workflowSlots[i] = null;
                    }
                    workflowAnimatedIndex = -1;
                    workflowLiveOutput =
                        "Construis un workflow moderne avec 4 étapes. L’IA n’est qu’un maillon d’un système plus large.";
                    workflowInterpretation =
                        "Dépose des blocs dans les 4 zones pour voir comment la chaîne se comporte.";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text("RESET"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label("Ce qu’il se passe"),
          const SizedBox(height: 8),
          _outputBox(workflowLiveOutput),
          const SizedBox(height: 12),
          _label("Lecture pédagogique"),
          const SizedBox(height: 8),
          _outputBox(workflowInterpretation),
        ],
      ),
    );
  }

  Widget _draggableWorkflowBlock(String title, {bool dragging = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dragging
            ? _modeColor(LearningMode.workflow)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dragging
              ? Colors.white70
              : _modeColor(LearningMode.workflow).withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _agenticPanel({required Key key}) {
    final color = _modeColor(LearningMode.agentic);

    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "3. Agent IA",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ici, le système poursuit un objectif. Il peut décider quoi faire, utiliser un outil, appeler un sous-agent spécialisé, puis réviser sa stratégie.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.84)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedAgentGoal,
            dropdownColor: const Color(0xFF1D2348),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            items: agentGoals
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: agentRunning
                ? null
                : (v) {
                    if (v != null) {
                      setState(() => selectedAgentGoal = v);
                    }
                  },
          ),
          const SizedBox(height: 16),
          _agentVisualRow(),
          const SizedBox(height: 16),
          _label("Décision actuelle"),
          const SizedBox(height: 8),
          _outputBox(agentDecision),
          const SizedBox(height: 14),
          _label("Journal d’exécution"),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 190, maxHeight: 360),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: agentEntries.isEmpty
                ? Center(
                    child: Text(
                      "Aucun plan lancé pour le moment.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  )
                : ListView.separated(
                    itemCount: agentEntries.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.white.withValues(alpha: 0.08)),
                    itemBuilder: (_, i) {
                      final entry = agentEntries[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.displayedText,
                            style: const TextStyle(color: Colors.white, height: 1.4),
                          ),
                          if (entry.requiresConfirmation &&
                              entry.displayedText == entry.fullText &&
                              !entry.confirmed) ...[
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _confirmPendingStep(entry),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(entry.confirmationLabel),
                            ),
                          ],
                          if (entry.confirmed)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Validation reçue.",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 14),
          _label("Résultat final"),
          const SizedBox(height: 8),
          _outputBox(agentFinalOutput),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _runAgent,
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: Text(agentRunning ? "Exécution..." : "LANCER L’AGENT"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _agentVisualRow() {
    final color = _modeColor(LearningMode.agentic);

    return Row(
      children: [
        Expanded(
          child: _agentSignalCard(
            title: "Décision",
            icon: Icons.psychology_alt_rounded,
            active: decisionFlash,
            accent: color,
            subtitle: "Choix de stratégie",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _agentSignalCard(
            title: "Outil",
            icon: Icons.build_circle_outlined,
            active: toolFlash,
            accent: color,
            subtitle: "$agentToolsUsed utilisé(s)",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _agentSignalCard(
            title: "Sous-agent",
            icon: Icons.hub_rounded,
            active: subAgentFlash,
            accent: color,
            subtitle: "$agentSubAgentsUsed appelé(s)",
          ),
        ),
      ],
    );
  }

  Widget _agentSignalCard({
    required String title,
    required IconData icon,
    required bool active,
    required Color accent,
    required String subtitle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? accent : Colors.white10,
          width: active ? 1.6 : 1.0,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 14.5,
      ),
    );
  }

  Widget _outputBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, height: 1.4),
      ),
    );
  }

  Widget _pedagogyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171B39),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Différences à retenir",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "• Génératif : on formule une consigne et le modèle produit une sortie.\n"
            "• Workflow : l’IA est un bloc parmi d’autres dans une chaîne orchestrée.\n"
            "• Agentique : le système poursuit un but, choisit des actions, utilise des outils, appelle des sous-agents et s’adapte.",
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.20),
          const Color(0xFF171B39),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: color.withValues(alpha: 0.55)),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.14),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

class _AgentLogEntry {
  _AgentLogEntry({
    required this.fullText,
    required this.displayedText,
    this.requiresConfirmation = false,
    this.confirmationLabel = "Valider pour continuer",
  });

  final String fullText;
  String displayedText;
  final bool requiresConfirmation;
  final String confirmationLabel;
  bool confirmed = false;
}

class _WorldPainter extends CustomPainter {
  final Color modeColor;
  _WorldPainter({required this.modeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF26356B),
          Color(0xFF11162F),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28)),
      sky,
    );

    final hillBack = Paint()..color = const Color(0xFF22315F);
    final hillMid = Paint()..color = const Color(0xFF1B244B);
    final pathPaint = Paint()..color = const Color(0xFFD3B178);
    final glow = Paint()
      ..color = modeColor.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    final backPath = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
          size.width * 0.2, size.height * 0.50, size.width * 0.42, size.height * 0.60)
      ..quadraticBezierTo(
          size.width * 0.72, size.height * 0.72, size.width, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final midPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.60, size.width * 0.48, size.height * 0.72)
      ..quadraticBezierTo(
          size.width * 0.74, size.height * 0.88, size.width, size.height * 0.64)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backPath, hillBack);
    canvas.drawPath(midPath, hillMid);

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.77)
      ..quadraticBezierTo(
          size.width * 0.35, size.height * 0.70, size.width * 0.48, size.height * 0.60)
      ..quadraticBezierTo(
          size.width * 0.62, size.height * 0.48, size.width * 0.78, size.height * 0.42);

    canvas.drawPath(
      path,
      pathPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.77), 28, glow);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.60), 28, glow);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.42), 28, glow);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (int i = 0; i < 24; i++) {
      final dx = (i * 37 % size.width.toInt()).toDouble();
      final dy = (18 + (i * 23 % (size.height * 0.32).toInt())).toDouble();
      canvas.drawCircle(Offset(dx, dy), i % 3 == 0 ? 2 : 1.2, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WorldPainter oldDelegate) {
    return oldDelegate.modeColor != modeColor;
  }
}