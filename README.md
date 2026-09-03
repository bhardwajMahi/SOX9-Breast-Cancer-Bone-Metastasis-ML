# SOX9 Breast Cancer Bone Metastasis – Machine Learning Analysis

This repository contains the MATLAB source code and supporting data used for the machine learning analysis described in the manuscript investigating molecular signatures associated with breast cancer bone metastasis.

## Overview

The study integrated transcriptomic datasets from five GEO datasets:

- GSE103357
- GSE137842
- GSE14776
- GSE2034
- GSE55715

The machine learning workflow included feature-selection approaches and supervised classification models for distinguishing breast cancer samples from breast cancer bone-metastasis samples.

## Machine Learning Workflow

The analysis includes the following feature-selection approaches:

- LASSO
- mRMR
- Chi-square
- Principal Component Analysis (PCA)

Classification models were evaluated following feature selection, with hyperparameter optimization performed using Bayesian optimization.

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
├── chi_feature.m
├── corr_feature_mrmr_updated.m
├── lasso_plot.m
└── pca_feature.m
