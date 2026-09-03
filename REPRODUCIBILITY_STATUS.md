# Reproducibility Status

This repository contains the MATLAB source files and analysis outputs for the breast-cancer bone-metastasis machine-learning study.

## Current status

The repository provides the source code, datasets, analysis outputs, and documentation associated with the study.

The MATLAB machine-learning scripts were developed using prepared input data/workspace variables. A clean-install, one-click execution workflow is still being documented and tested.

Therefore, this repository should not yet be described as a fully validated turnkey implementation.

## Study-level class totals

The study contains 316 samples:

- 232 comparator samples
- 84 BCa-BM samples

The cohort-level class distribution is:

| Dataset | BCa-BM / Positive | Comparator / Negative |
|---|---:|---:|
| GSE103357 | 3 | 2 |
| GSE137842 | 3 | 3 |
| GSE14776 | 6 MTC | 8 DTC |
| GSE55715 | 3 | 2 |
| GSE2034 | 69 | 217 |
| **Total** | **84** | **232** |

For GSE14776, the 6 MTC samples constitute the bone-metastatic class, while the 8 DTC samples are retained as the comparator class used in the binary machine-learning dataset. DTC samples should not be described as primary breast-cancer tissue.

For GSE2034, the study-level distribution is 69 bone-metastasis samples and 217 comparator samples. The exact per-sample labels should be verified against GEO phenotype metadata before generating a final sample-level label file.

## Machine-learning methods

The analysis evaluates:

- LASSO
- Minimum Redundancy Maximum Relevance (mRMR)
- Chi-square feature selection
- Principal Component Analysis (PCA)
- Bayesian hyperparameter optimization
- Supervised machine-learning classifiers including SVM, k-NN and neural-network approaches

## Reproducibility work remaining

The following steps are being documented for a clean reproducibility workflow:

1. Verify the exact sample-level labels for all five cohorts.
2. Reconstruct/document the prepared machine-learning input data.
3. Make the MATLAB scripts self-contained where possible.
4. Document the required MATLAB release and toolboxes.
5. Document the exact execution order and expected outputs.
6. Compare regenerated outputs with the analysis outputs associated with the manuscript.
7. Provide a versioned release corresponding to the manuscript.

## Important note

The repository is intended to provide transparent access to the source code, data-processing information, documentation, and analysis outputs. No claim of complete turnkey reproducibility is made until the clean-install workflow has been tested.
