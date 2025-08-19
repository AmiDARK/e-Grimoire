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
  - Pass 1: Resolve values, initialize memory, and set up structures.  
  - Pass 2: Compile the fully expanded assembler code.  

---

### Features
- **Dynamic variable management**  
  - Integer, Float, and String variables  
  - Global scope or local scope inside `Procedure` / `EndProcedure`  
- **Control structures**  
  - `BasicFOR` / `BasicNEXT` (loop system)  
  - `BasicGOSUB` / `BasicRETURN` (subroutines)  
  - `BasicGOTO` (direct jumps)  
- **System variables**  
  - `grmProcessorModel`, `grmFpuModel`, `grmGraphicChipsetType`, etc.  
- **Initialization & cleanup**  
  - `grimoireStartupSequence` (memory allocation, library setup)  
  - `grimoireLeaveEngine` (resource cleanup)  

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
- `Source Engine v2` → main engine source code  
- `Source Engine v2/Amiga 68k` → examples and execution samples  
  - `BasicChecking.asm` and `ConfigurationChecking.asm` illustrate the BASIC-like macro system  

---

## Version Française

### Présentation
e-Grimoire est un **projet expérimental** écrit à 100% en assembleur Motorola 68000, destiné aux micro-ordinateurs Amiga.  
Il démontre qu’en exploitant les fonctionnalités du **Macro Assembleur Devpac** (HiSoft) et le principe de **compilation en 2 passes**, on peut créer un **pseudo-langage BASIC directement dans l’assembleur**.

---

### Fonctionnalités
- **Gestion dynamique de variables**  
  - Variables Integer, Float et String  
  - Portée globale ou locale (dans `Procedure` / `EndProcedure`)  
- **Structures de contrôle**  
  - `BasicFOR` / `BasicNEXT` (boucles)  
  - `BasicGOSUB` / `BasicRETURN` (sous-programmes)  
  - `BasicGOTO` (sauts directs)  
- **Variables systèmes**  
  - `grmProcessorModel`, `grmFpuModel`, `grmGraphicChipsetType`, etc.  
- **Initialisation & libération**  
  - `grimoireStartupSequence` (allocation mémoire, ouverture librairies)  
  - `grimoireLeaveEngine` (libération mémoire, fermeture librairies)  

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

## License
Experimental project — released as-is for educational and demonstration purposes.
