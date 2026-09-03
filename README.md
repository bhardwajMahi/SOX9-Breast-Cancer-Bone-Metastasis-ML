# SOX9 Breast Cancer Bone Metastasis – Machine Learning Analysis

This repository contains the MATLAB source code, transcriptomic datasets, analysis results, and supporting documentation used for the machine learning analysis described in the manuscript investigating molecular signatures associated with breast cancer bone metastasis.

## Overview

The study integrated transcriptomic datasets obtained from five Gene Expression Omnibus (GEO) datasets:

* GSE103357
* GSE137842
* GSE14776
* GSE2034
* GSE55715

The machine learning workflow involved feature selection followed by supervised classification and Bayesian hyperparameter optimization to identify molecular features associated with breast cancer bone metastasis.

## Machine Learning Workflow

Four feature-selection approaches were investigated:

* LASSO
* Minimum Redundancy Maximum Relevance (mRMR)
* Chi-square
* Principal Component Analysis (PCA)

Following feature selection, classification models were evaluated using model-performance metrics, receiver operating characteristic (ROC) analysis, and confusion matrices. Bayesian optimization was used for hyperparameter optimization.

The MATLAB scripts provided in this repository correspond to the machine-learning analyses reported in the manuscript.

## Repository Structure

```text
SOX9-Breast-Cancer-Bone-Metastasis-ML/
│
├── 01_Data/
│   ├── README.md
│   ├── 103357_matrix1.csv
│   ├── 137842_matrix1.csv
│   ├── 14776_matrix1.csv
│   ├── 2034_matrix1.csv
│   └── 55715_matrix1.csv
│
├── 02_Results/
│   ├── Bayesian_Optimization/
│   │   ├── ChiSquare_Bayesian_Optim_results.xlsx
│   │   ├── Lasso_Bayesian_Optim_results.xlsx
│   │   ├── PCA_Bayesian_Optim_results.xlsx
│   │   └── mRMR_Bayesian_Optim_results.xlsx
│   │
│   ├── Model_Performance/
│   │   ├── ChiSquare_Model_Performance.xlsx
│   │   ├── Lasso_Model_Performance.xlsx
│   │   └── PCA_Model_Performance.xlsx
│   │
│   ├── ROC/
│   │   ├── PCA_AUC_ROC.png
│   │   ├── auc_roc_lasso.png
│   │   ├── chi_auc_roc.png
│   │   ├── lasso_AUC_ROC.png
│   │   └── mrmr_aucroc.png
│   │
│   ├── Confusion_Matrices/
│   │   ├── Confusion_matrix.jpg
│   │   ├── PCA_confusion.png
│   │   ├── chi_confusion.png
│   │   ├── lasso_confusion.png
│   │   └── mrmr_confusion.png
│   │
│   └── Feature_Selection/
│       ├── Filtered_imp_feature.xlsx
│       ├── selected_features_PCA.png
│       ├── selected_features_chi_sqaure.png
│       ├── selected_features_corr_mrmr.png
│       └── selected_features_lasso_22.png
│
├── 03_Machine_Learning/
│   ├── chi_feature.m
│   ├── corr_feature_mrmr_updated.m
│   ├── lasso_plot.m
│   └── pca_feature.m
│
└── 05_Documentation/
    ├── README.md
    ├── Best_model.docx
    ├── Filtered Important Features.docx
    └── Read_Me.docx
```

## Data

The `01_Data` directory contains the five transcriptomic datasets used in the analysis.

The dataset files are provided in CSV format and correspond to the GEO datasets listed above. The `GSE2034` expression matrix is tracked using Git Large File Storage (Git LFS) because of its file size.

## Results

The `02_Results` directory contains the principal outputs generated during the machine learning analysis:

* **Bayesian Optimization:** Hyperparameter optimization results for the evaluated feature-selection approaches.
* **Model Performance:** Performance metrics for the evaluated classification models.
* **ROC:** Receiver operating characteristic curves and AUC-related results.
* **Confusion Matrices:** Classification confusion matrices.
* **Feature Selection:** Selected-feature outputs and feature-selection visualizations.

## MATLAB Source Code

The `03_Machine_Learning` directory contains the MATLAB scripts used for the machine-learning analyses:

* `chi_feature.m` – Chi-square-based feature selection and analysis.
* `corr_feature_mrmr_updated.m` – Correlation/mRMR feature-selection analysis.
* `lasso_plot.m` – LASSO-based feature selection and analysis.
* `pca_feature.m` – PCA-based feature-selection analysis.

The scripts should be interpreted together with the corresponding datasets and analysis outputs.

## Documentation

The `05_Documentation` directory contains supporting documents describing the analysis, selected features, and model-related findings.

## Reproducibility

To reproduce the analysis:

1. Clone or download this repository.
2. Ensure MATLAB and the required MATLAB toolboxes/functions are available.
3. Obtain the datasets from the `01_Data` directory.
4. Review the documentation in `05_Documentation`.
5. Run the relevant MATLAB scripts from `03_Machine_Learning`.
6. Compare the generated outputs with the corresponding results provided in `02_Results`.

## Note

This repository is intended to provide the data, source code, analysis outputs, and supporting documentation associated with the machine learning component of the study.
## Reproducibility and Code Availability

The source code, processed datasets, analysis outputs, and supporting documentation for this study are publicly available in this repository:

https://github.com/bhardwajMahi/SOX9-Breast-Cancer-Bone-Metastasis-ML

The repository contains the MATLAB analysis scripts used for feature selection and machine-learning analysis, together with the corresponding datasets, results, figures, and documentation.

The machine-learning workflow includes:

- LASSO feature selection
- Minimum Redundancy Maximum Relevance (mRMR)
- Chi-square feature selection
- Principal Component Analysis (PCA)
- Bayesian hyperparameter optimization
- Supervised machine-learning classification

The repository also includes a reproducibility-status document describing the current implementation status and the remaining validation steps.

### Important reproducibility note

The MATLAB scripts were developed using prepared input data and workspace variables. A clean-install, turnkey execution workflow is still being documented and tested. Therefore, the repository currently provides transparent access to the source code, data, analysis outputs, and documentation but should not yet be described as a fully validated one-click implementation.

For the study-level cohort composition and reproducibility details, see `REPRODUCIBILITY_STATUS.md`.
