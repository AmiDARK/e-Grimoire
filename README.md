# e-Grimoire

**Author: Frédéric Cordier**  
Experimental project written in 100% Motorola 68000 assembler for Amiga computers.

---

## English Version

### Overview
e-Grimoire is an **experimental project** entirely coded in Motorola 68000 assembler, designed for Amiga computers.  
It demonstrates that, by using the **Devpac Macro Assembler** (HiSoft) and its **two-pass compilation process**, it is possible to create a **pseudo-BASIC language within assembler itself**.

This is achieved by:
- Using **conditional macros** as BASIC-like commands (`SetString`, `SetFloat`, `SetInteger`, etc.).
- Taking advantage of the **two-pass compilation**:
  - Pass 1: resolve values, initialize references, validate macro structure, and prepare generated code.
  - Pass 2: compile the fully expanded assembler code.

---

### Features
- **Dynamic variable management**
  - Integer, Float, and String variables
  - Global scope or local scope inside `Procedure` / `EndProcedure`
  - Static and dynamic String support
  - Runtime allocation and cleanup of dynamic String buffers
- **String commands**
  - `SetString` and `SetStaticString`
  - `BasicLEN`
  - `BasicLEFT`, `BasicRIGHT`, `BasicMID`
  - `BasicASC`, `BasicCHR`
  - Runtime error reporting for invalid String positions or lengths
- **Control structures**
  - `BasicFOR` / `BasicNEXT` loop system
  - `BasicIF` / `BasicTHEN` / `BasicELSE` / `BasicENDIF` condition blocks
  - Nested condition support
  - `BasicGOSUB` / `BasicRETURN` subroutines
  - `BasicGOTO` direct jumps
- **Procedures**
  - Local variable management
  - String values returned from procedures
  - Static or dynamic String return handling
- **System variables**
  - `grmProcessorModel`, `grmFpuModel`, `grmGraphicChipsetType`, etc.
- **Initialization & cleanup**
  - `grimoireStartupSequence` for memory allocation and library setup
  - `grimoireLeaveEngine` for resource cleanup

---

### Working With Codex
e-Grimoire is now also being evolved with the help of **Codex**, used as an AI technical copilot.

Codex is used to accelerate:
- Analysis of the existing Motorola 68000 / Devpac macro codebase
- Design and implementation of new BASIC-like macro commands
- Debugging of compilation and runtime issues
- Creation of focused validation programs
- Documentation of internal technical rules and command behavior

The project remains manually designed, reviewed, compiled, and tested on the Amiga side. Codex acts as a development accelerator: it helps reason about the codebase, propose implementations, iterate on errors, and keep documentation aligned with the evolving engine.

Recent work done with Codex includes improvements around static and dynamic String handling, procedure String returns, `BasicLEN`, the `BasicIF` / `BasicTHEN` / `BasicELSE` / `BasicENDIF` control block, String extraction commands, and runtime error reporting for invalid String operations.

---

### Dual Purpose: Two Complementary Axes
e-Grimoire has **two faces** that reinforce each other:

1. **Pedagogical Axis**
   - A learning bridge for beginners in assembler programming.
   - Start with BASIC-like macros, then progressively move toward system library calls and full Assembler mnemonics implementation/development.
   - Shows how assembler can be **approachable and structured** using Macro Assembler Devpac.

2. **Experimental / Demo-Scene Axis**
   - A technical curiosity that demonstrates the hidden potential of Devpac macros.
   - Proof that you can bend assembler to behave like a higher-level language.
   - Fits the spirit of the Amiga demo-scene: **pushing boundaries where no one looked before**.

By combining both, **e-Grimoire becomes both a teaching tool and a demo-scene statement**:  
a project that can inspire newcomers, while intriguing veterans.

---

### Repository Structure
- `src` → main engine source code, examples, and validation programs
- `src/coresrc` → core macro and engine sources
- `src/libsrc` → Amiga library sources
- `docs` → internal documentation and technical rules
- `assembler` → Devpac-related documentation and assembler references

Example validation sources include:
- `BasicChecking.asm`
- `BasicConditionsIF.asm`
- `BasicStringsSupport.asm`
- `BasicStringsSupportErrors.asm`
- `ConfigurationChecking.asm`
- `GraphicsChecking.asm`

---

## Version Française

### Présentation
e-Grimoire est un **projet expérimental** écrit à 100% en assembleur Motorola 68000, destiné aux micro-ordinateurs Amiga.  
Il démontre qu’en exploitant les fonctionnalités du **Macro Assembleur Devpac** (HiSoft) et le principe de **compilation en 2 passes**, on peut créer un **pseudo-langage BASIC directement dans l’assembleur**.

Le principe repose sur :
- L’utilisation de **macros conditionnelles** comme commandes BASIC-like (`SetString`, `SetFloat`, `SetInteger`, etc.).
- L’exploitation de la **compilation en 2 passes** :
  - Passe 1 : résolution des valeurs, initialisation des références, validation de la structure des macros et préparation du code généré.
  - Passe 2 : compilation du code assembleur entièrement développé.

---

### Fonctionnalités
- **Gestion dynamique de variables**
  - Variables Integer, Float et String
  - Portée globale ou locale dans `Procedure` / `EndProcedure`
  - Support des String statiques et dynamiques
  - Allocation et libération runtime des buffers de String dynamiques
- **Commandes String**
  - `SetString` et `SetStaticString`
  - `BasicLEN`
  - `BasicLEFT`, `BasicRIGHT`, `BasicMID`
  - `BasicASC`, `BasicCHR`
  - Remontée d’erreurs runtime pour les positions ou longueurs de String invalides
- **Structures de contrôle**
  - `BasicFOR` / `BasicNEXT` pour les boucles
  - `BasicIF` / `BasicTHEN` / `BasicELSE` / `BasicENDIF` pour les blocs conditionnels
  - Support des conditions imbriquées
  - `BasicGOSUB` / `BasicRETURN` pour les sous-programmes
  - `BasicGOTO` pour les sauts directs
- **Procédures**
  - Gestion des variables locales
  - Retour de valeurs String depuis les procédures
  - Gestion des retours String statiques ou dynamiques
- **Variables systèmes**
  - `grmProcessorModel`, `grmFpuModel`, `grmGraphicChipsetType`, etc.
- **Initialisation & libération**
  - `grimoireStartupSequence` pour l’allocation mémoire et l’ouverture des librairies
  - `grimoireLeaveEngine` pour la libération des ressources

---

### Travail Avec Codex
e-Grimoire évolue désormais également avec l’aide de **Codex**, utilisé comme copilote technique IA.

Codex est utilisé pour accélérer :
- L’analyse de la base de code Motorola 68000 / macros Devpac existante
- La conception et l’implémentation de nouvelles commandes BASIC-like
- Le debugging des erreurs de compilation et d’exécution
- La création de programmes de validation ciblés
- La documentation des règles techniques internes et du comportement des commandes

Le projet reste conçu, relu, compilé et testé manuellement côté Amiga. Codex agit comme un accélérateur de développement : il aide à raisonner sur la base de code, proposer des implémentations, itérer à partir des erreurs et garder la documentation alignée avec l’évolution du moteur.

Les travaux récents réalisés avec l’aide de Codex incluent l’amélioration de la gestion des String statiques et dynamiques, le retour de String depuis les procédures, `BasicLEN`, le bloc de contrôle `BasicIF` / `BasicTHEN` / `BasicELSE` / `BasicENDIF`, les commandes d’extraction de String, ainsi que la remontée d’erreurs runtime pour les opérations String invalides.

---

### Double Voie : Deux Axes Complémentaires
e-Grimoire possède **deux visages** qui se complètent :

1. **Axe Pédagogique**
   - Une passerelle pour les débutants en assembleur.
   - Commencer avec des macros BASIC-like, puis évoluer progressivement vers les appels système et l’implémentation/développement complet des instructions Assembleur.
   - Montre que l’assembleur peut être **accessible et structuré** grâce au Macro Assembleur Devpac.

2. **Axe Expérimental / Démo-Scene**
   - Une curiosité technique qui révèle la puissance cachée des macros Devpac.
   - Une preuve qu’on peut détourner l’assembleur pour en faire un langage plus haut niveau.
   - Fidèle à l’esprit de la scène Amiga : **explorer des territoires jamais foulés**.

En réunissant les deux axes, **e-Grimoire devient à la fois un outil pédagogique et une œuvre démo-scene** :  
un projet capable d’inspirer les nouveaux venus tout en interpellant les vétérans.

---

### Structure Du Dépôt
- `src` → code source principal du moteur, exemples et programmes de validation
- `src/coresrc` → sources du moteur et des macros principales
- `src/libsrc` → sources des librairies Amiga
- `docs` → documentation interne et règles techniques
- `assembler` → documentation Devpac et références assembleur

Exemples de sources de validation :
- `BasicChecking.asm`
- `BasicConditionsIF.asm`
- `BasicStringsSupport.asm`
- `BasicStringsSupportErrors.asm`
- `ConfigurationChecking.asm`
- `GraphicsChecking.asm`

---

## License
Experimental project — released as-is for educational and demonstration purposes.
