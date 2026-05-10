# CODEX.md — Projet e-Grimoire (Assembleur Amiga)

## 1. Contexte du projet

e-Grimoire est un projet en assembleur Motorola 68k pour Amiga.

Il est conçu pour fonctionner sur l’ensemble des CPU de la famille 68000 à 68060, avec optimisation spécifique via des librairies dédiées.

Le système repose sur une séparation stricte :

- Un programme principal universel (68000 pur)
- Des librairies optimisées par CPU
- Une sélection dynamique à l’exécution selon le matériel

L’environnement cible est AmigaOS, basé sur des bibliothèques dynamiques appelées à l’exécution :contentReference[oaicite:0]{index=0}.

---

## 2. Arborescence du projet

/assembler/  
→ Documentation DEVPAC

/docs/  
→ Documentation Motorola CPU (68000 → 68060)  
→ Documentation FPU 68881 / 68882

/src/c/  
→ Exécutables Amiga utilisés pour compiler le code

/src/coresrc/  
→ Code source principal e-Grimoire (68000 pur uniquement)

/src/includes/  
→ Includes AmigaOS SDK

/src/libsrc/  
→ Code source des librairies e-Grimoire  
→ Contient les variantes CPU spécifiques

/src/system/  
→ Librairies compilées Amiga (multi-CPU)

/src/templates/  
→ Templates assembleur utilisant e-Grimoire

/src/VampireIncludes/  
→ Includes pour CPU Vampire (prévu, non actif)

/logs/  
→ Logs de compilation et debug

---

## 3. Architecture CPU

### 3.1 Programme principal

Le programme principal :

- est **strictement en 68000 pur**
- doit rester compatible avec tous les Amiga (jusqu’au 68060)
- ne doit contenir :
  - aucune instruction 68020+
  - aucune instruction FPU

### 3.2 Librairies

Les optimisations CPU sont isolées dans `/src/libsrc/`.

Versions possibles :

- 68000
- 68020
- 68030
- 68040
- 68060
- FPU 68881 / 68882

Chaque version est compilée séparément et stockée dans `/src/system/`.

### 3.3 Sélection dynamique

Le programme principal :

- détecte le CPU via les flags système Amiga (ex : `ExecBase->AttnFlags`) :contentReference[oaicite:1]{index=1}  
- sélectionne et charge la librairie correspondante

---

## 4. Modèle multi-CPU

Le projet utilise :

- macros de compilation pour sélectionner du code CPU
- variantes de fonctions selon CPU
- librairies distinctes par architecture

### Important

- Une même fonction peut exister en plusieurs implémentations
- Ces variantes ne doivent pas être fusionnées
- Le système multi-CPU est volontaire et central

---

## 5. Règles strictes pour Codex

### 5.1 Respect global

- Ne pas modifier l’arborescence du projet
- Ne pas simplifier l’architecture multi-CPU
- Ne pas fusionner les variantes CPU
- Ne pas supprimer les macros de sélection CPU

---

### 5.2 Programme principal

Interdictions :

- instructions 68020+
- instructions FPU
- optimisations dépendantes CPU

Autorisé :

- code portable 68000
- logique de sélection de librairie

---

### 5.3 Librairies

- Les optimisations doivent être proposées **par CPU**
- Toute instruction doit être compatible avec la cible annoncée
- Toujours préciser la cible :

Exemple :

- "Optimisation 68020+"
- "Version 68000 compatible"
- "Version FPU"

---

### 5.4 Instructions CPU

Codex doit :

- signaler toute instruction non 68000
- distinguer :
  - 68000
  - 68020+
  - FPU

Exemple :

- `MOVEQ` → OK 68000
- `MULS.L` → 68020+
- `FSIN` → FPU uniquement

---

### 5.5 Compatibilité

Le 68000 a été conçu pour permettre une certaine compatibilité ascendante dans la famille 68k :contentReference[oaicite:2]{index=2}  
→ Mais cela ne garantit pas que toutes les instructions sont compatibles

Donc :

- ne jamais supposer compatibilité automatique
- toujours vérifier la génération CPU

---

## 6. Devpac et compilation

- Assembleur utilisé : DEVPAC
- Syntaxe spécifique à respecter
- Macros existantes à préserver

Codex ne doit pas :

- transformer le code en syntaxe GAS/NASM
- modifier les conventions Devpac

---

## 7. Documentation disponible

Codex peut utiliser :

- `/docs/` → documentation CPU officielle
- `/assembler/` → documentation Devpac
- `/src/includes/` → includes AmigaOS

### 7.1 Documentation technique interne obligatoire

Avant toute modification du core e-Grimoire, Codex doit lire et respecter :

- `/docs/internal-technical-rules.md`

Ce document decrit les invariants internes du moteur :

- registres reserves
- conventions variables globales/locales
- fonctionnement des macros Devpac en deux passes
- regles des procedures, erreurs, buffers et labels generes

Les commandes BASIC prevues sont suivies dans :

- `/docs/basic-commands-todo.md`

---

## 8. Logs et debug

- `/logs/` contient :
  - erreurs compilation
  - warnings
  - traces

Codex peut :

- analyser les erreurs
- proposer des corrections ciblées

---

## 9. Templates

- `/src/templates/` contient des exemples fonctionnels
- Doivent être utilisés comme référence de style

---

## 10. Extension future : Vampire

- `/src/VampireIncludes/` prévu pour extensions CPU Vampire
- Non actif actuellement

Codex :

- ne doit pas utiliser ces includes sans demande explicite

---

## 11. Objectifs de Codex

Codex doit :

- aider à comprendre le code
- détecter les bugs
- proposer des optimisations **compatibles**
- documenter les routines
- améliorer la structure sans casser l’architecture

---

## 12. Interdictions majeures

Codex ne doit jamais :

- convertir le projet vers un autre assembleur
- casser la compatibilité 68000 du core
- supprimer la logique multi-CPU
- proposer une optimisation sans préciser le CPU
- introduire du code incompatible silencieusement

---

## 13. Philosophie du projet

e-Grimoire repose sur :

- compatibilité maximale
- optimisation ciblée
- modularité par CPU
- séparation stricte des responsabilités

C’est une architecture volontaire, robuste et historique dans l’écosystème Amiga.

Codex doit s’y adapter, pas l’inverse.
