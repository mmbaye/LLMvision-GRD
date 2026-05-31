# GRD Severity Scoring VLM Benchmark

> **YOLO-Augmented Prompting Bridges the Gap Between General-Purpose Vision-Language Models and Expert GRD Severity Scoring: A Benchmark Study in West African Groundnut Breeding Trials**

A benchmark of four vision-language models (VLMs) for **Groundnut Rosette Disease (GRD)** severity scoring, compared against a YOLO segmentation reference on 107 field-trial images (Uganda).

**Institution:** ISRA — Institut Sénégalais de Recherches Agricoles (Breeding Informatics)
**Collaboration:** I. Chapu (Makerere University, Uganda)
**Target journal:** *Frontiers in Artificial Intelligence* — AI in Food, Agriculture and Water

---

## Key finding

**YOLO-augmented prompting (P03)** lifts 3 of 4 VLMs from no agreement (κw ≈ 0) to **almost-perfect** agreement (κw > 0.86) with the expert-calibrated reference. Claude is the exception: it stays negative across all conditions and never assigns the GRD5 class, even though GRD5 dominates the reference (70.1%) — a "resistance to YOLO evidence" / GRD5-avoidance behaviour.

| Model     | κw P02  | κw P03  | P03 interpretation |
|-----------|:-------:|:-------:|--------------------|
| Claude    | −0.150  | −0.169  | worse than chance  |
| Ministral | +0.011  | **0.903** | almost perfect   |
| Qwen3-VL  | −0.052  | **0.972** | almost perfect   |
| VIPS      | +0.004  | **0.860** | almost perfect   |

*κw = quadratic weighted Cohen's kappa, vs YOLO SEG-area reference (mean 4.42, 70.1% GRD5). n = 107.*

---

## Workflow

![workflow](https://github.com/mmbaye/LLMvision-GRD/blob/main/workflow/workflow.jpeg) 

---

## Models evaluated

| Model | Access | API / source | Status |
|-------|--------|--------------|--------|
| Claude Sonnet 4.6 | Proprietary (Anthropic) | `server_grd.js` | Included |
| Ministral (vision) | Local (Ollama) | `ollama / ministral` | Included |
| Qwen3-VL-8B | Local (Ollama) | `ollama / qwen3-vl:8b` | Included |
| VIPS plant analyzer | Plant-specialized | `vips analyzer` | Included |
| LLaVA-Llama3 | Local (Ollama) | `ollama / llava-llama3` | **Excluded** (83% parse failures, >2h compute) |

**YOLO reference** (non-VLM): YOLO11m-seg, 200 epochs, batch 16, imgsz 640. **Segmentation (SEG-area)** is the official reference (detection gave weaker results).

---

## Metrics

| Metric | Meaning |
|--------|---------|
| **κw** | Quadratic weighted Cohen's kappa — chance-corrected agreement, penalizing larger errors more (squared weights). Primary metric. |
| **r** | Pearson correlation — captures trend (same direction) but not absolute agreement or constant bias. |
| **Exact %** | Share of images where prediction equals the reference class exactly. |
| **±1 %** | Share of images where prediction is within one class of the reference (lenient, suited to an ordinal scale). |
| **Bias** | Mean predicted score − mean reference score (negative = under-scoring severity). |

κw interpretation (Landis & Koch): <0 chance · 0.21–0.40 fair · 0.41–0.60 moderate · 0.61–0.80 substantial · >0.80 almost perfect.

