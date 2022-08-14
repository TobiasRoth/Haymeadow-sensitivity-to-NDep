# The Sensitivity of hay meadow species diversity to nitrogen deposition

This repository contains all the materials needed to reproduce the analyses in:

> Roth, T., Bergamini, A., Kohli, L., Meier, E., Rihm, B. (in Prep): Variation in sensitivity of grassland species communities to nitrogen deposition is mediated by soil properties. To be submitted to *Environmental Pollution*.

## Content of the repository

### Appendix

R-Markdown-Files to produce the appendices.

### Data-Original (excluded from public GitHub)

All data needed to prepare the data files with the raw data that is used for the analyses in the paper. The folder contains the following files:

- [Data_preparation.R](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/Data_preparation.R): To prepare the raw data files needed in the paper. Also makes figures used to document the data-collection process.
- [1775_Standorte_Monitoringprogramme_v1.xlsx](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/1775_Standorte_Monitoringprogramme_v1.xlsx): List of location of sampling sites from the three monitoring programs.
- [20210527.csv](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/20210527.csv): List mit survey-IDs from ALL-EMA
- [ndep_klim_v210611.xlsx](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/ndep_klim_v210611.xlsx): NDep data including pH provided by [[Beat Rihm]] .
- [sites-2020-10-01.xlsx](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/sites-2020-10-01.xlsx): Site-specific predictor variables provided by WSL.
- [description-2020-10-01.xlsx](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/description-2020-10-01.xlsx): Description of site-specific variables provided by WSL.
- [all_monit_vegetationtype_indvalue_20201130_all.txt](/Users/tobi/Library/CloudStorage/OneDrive-Hintermann+WeberAG/Schreibtisch_Ro/1775 Review Critical Load/10-Haymeadow-sensitivity-to-NDep/Data-Original/all_monit_vegetationtype_indvalue_20201130_all.txt): All monitoring data including habitat specification by WSL.

### Data-raw (not yet uploaded -==-> needs permission from data owner==)

- [Data_sites.csv](https://github.com/TobiasRoth/Haymeadow-sensitivity-to-NDep/tree/main/R/Data-Raw/Data_sites.csv): Site-specific data for alle sites from the three national monitoring programs
- [community_matrix.RData](https://github.com/TobiasRoth/Haymeadow-sensitivity-to-NDep/tree/main/R/Data-Raw/community_matrix.RData): Sites x species community matrix in R data format (`.RData`).

### Figures



Folder that contains figures with key results of the analyses. All the files in this folder are produced by one of the R-Skripts in folder [R](https://github.com/TobiasRoth/Haymeadow-sensitivity-to-NDep/tree/main/R).

### Modres

In this folder, the results of the applied models are temporarily stored as *brms* output.

### R

Scripts to reproduce all results from the MS. The folder contains the following R-Skripts:

- [Analysis_main.R](https://github.com/TobiasRoth/Haymeadow-sensitivity-to-NDep/tree/main/R/Analysis_main.R): R script to produce the main analyses as described in the paper including change-point analyses and SEM.
