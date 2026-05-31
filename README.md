# GRD Severity Scoring — VLM Benchmark

> **YOLO-Augmented Prompting Bridges the Gap Between General-Purpose Vision-Language Models and Expert GRD Severity Scoring: A Benchmark Study in West African Groundnut Breeding Trials**

Benchmark de quatre modèles vision-langage (VLM) pour la notation de sévérité de la **maladie de la rosette de l'arachide (GRD)**, comparés à une référence YOLO de segmentation sur 107 images d'essais de terrain (Ouganda).

**Institution :** ISRA — Institut Sénégalais de Recherches Agricoles (Breeding Informatics)
**Collaboration :** I. Chapu (Makerere University, Ouganda)
**Revue cible :** *Frontiers in Artificial Intelligence* — AI in Food, Agriculture and Water

---

## Résultat principal

Le **prompting augmenté par contexte YOLO (P03)** fait passer 3 VLM sur 4 d'un accord nul (κw ≈ 0) à un accord **presque parfait** (κw > 0.86) avec la référence experte. Claude fait exception : il reste négatif dans toutes les conditions et n'attribue jamais la classe GRD5, alors qu'elle domine la référence (70.1 %) — un comportement de « résistance à l'évidence YOLO » / aversion au GRD5.

| Modèle    | κw P02  | κw P03  | Interprétation P03 |
|-----------|:-------:|:-------:|--------------------|
| Claude    | −0.150  | −0.169  | pire que le hasard |
| Ministral | +0.011  | **0.903** | presque parfait  |
| Qwen3-VL  | −0.052  | **0.972** | presque parfait  |
| VIPS      | +0.004  | **0.860** | presque parfait  |

*κw = kappa de Cohen à pondération quadratique, vs référence YOLO SEG-area (moyenne 4.42, 70.1 % GRD5). n = 107.*

---

## Workflow

![Workflow](workflow_diagram.png)

---

## Modèles évalués

| Modèle | Accès | API / source | Statut |
|--------|-------|--------------|--------|
| Claude Sonnet 4.6 | Propriétaire (Anthropic) | `server_grd.js` | Inclus |
| Ministral (vision) | Local (Ollama) | `ollama / ministral` | Inclus |
| Qwen3-VL-8B | Local (Ollama) | `ollama / qwen3-vl:8b` | Inclus |
| VIPS plant analyzer | Spécialisé plantes | `vips analyzer` | Inclus |
| LLaVA-Llama3 | Local (Ollama) | `ollama / llava-llama3` | **Exclu** (83 % d'échecs, >2h calcul) |

**Référence YOLO** (non-VLM) : YOLO11m-seg, 200 epochs, batch 16, imgsz 640. La **segmentation (SEG-area)** est la référence officielle (la détection donnait de moins bons résultats).

---

## Arborescence

```
GRD_study/
├── 00_data/
│   ├── predictions_P02/      4 CSV — prompt GRD, image seule
│   ├── predictions_P03/      4 CSV — prompt augmenté contexte YOLO
│   └── yolo_reference/       grd_yolo_seg_results.csv (référence par image)
├── 01_scripts/
│   ├── grd_compute_kappa.R              # métriques → 03_results/  (LANCER EN 1er)
│   ├── grd_figure6_distributions.R      # Fig 6 — distributions P02
│   ├── grd_figure7_mean_kappa.R         # Fig 7 — moyenne + κw  (lit le CSV)
│   ├── grd_figure8_heatmaps_P02.R       # Fig 8 — heatmaps P02
│   ├── grd_figure8bis_heatmaps_P03.R    # Fig 8-bis — heatmaps P03
│   ├── grd_figure9_trajectory.R         # Fig 9 — trajectoire κw (lit le CSV)
│   └── make_tables_1_2.js               # Tableaux Word (lit le CSV)
├── 02_figures/               5 figures PNG 300 dpi
├── 03_results/               kappa_results_all_SEGarea.csv (4 P02 + 4 P03)
├── 04_paper/                 GRD_Tables_1_2_draft.docx
├── workflow_diagram.png
├── README.md                 (ce fichier)
└── README.xlsx               (version classeur, 6 onglets)
```

---

## Reproduire l'analyse

> **Ordre obligatoire :** `grd_compute_kappa.R` doit être lancé **en premier** — il génère le CSV que les figures 7 et 9 lisent ensuite.

```bash
cd 01_scripts/
Rscript grd_compute_kappa.R              # 1. métriques (κw, r, biais, moyennes)
Rscript grd_figure6_distributions.R      # Fig 6
Rscript grd_figure7_mean_kappa.R         # Fig 7  (lit kappa_results_all_SEGarea.csv)
Rscript grd_figure8_heatmaps_P02.R       # Fig 8
Rscript grd_figure8bis_heatmaps_P03.R    # Fig 8-bis
Rscript grd_figure9_trajectory.R         # Fig 9  (lit kappa_results_all_SEGarea.csv)
node make_tables_1_2.js                  # Tableaux 1 & 2 Word
```

**Paquets R :** `ggplot2`, `dplyr`, `tidyr`, `readr`, `scales`, `cowplot`.
**Pas de dépendance à `irr`** — le κw quadratique est calculé directement (validé identique à `psych::cohen.kappa`).

Pour changer de référence (SEG-area / SEG-count / DET) : modifier `REF_COL` en tête des scripts, puis relancer.

---

## À vérifier avant soumission

- **Qwen P02** : identification GRD = 72.9 % (pas 100 %) — colonne `disease_type` vide sur plusieurs images.
- **κw P03 vs SEG-area (0.86–0.97)** plus élevés que les valeurs DET d'origine (0.60–0.69) → mettre à jour texte et tableaux du manuscrit.
- **P03 évalué contre la même référence (segmentation) qui alimente le prompt** → à formuler prudemment dans la discussion.

## Reste à produire

- Figure 5 (montage d'annotation) — script Python, re-run YOLO requis
- 4 références bibliographiques manquantes
- Insertion des Tableaux 1 & 2 dans le manuscrit
