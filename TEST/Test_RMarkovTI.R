# ===================================================================================
# RDMMProp = R Drug Markov Mean Properties
# ===================================================================================
# Calculate Markov Mean Properties (molecular descriptors) using SMILES drug formulas
# enanomapper.net
# ----------------------------------------------------------------------------------------------
# AUTHORS: 
# ----------------------------------------------------------------------------------------------
# Cristian R. Munteanu: RNASA-IMEDIR, University of A Coruna, Spain, muntisa@gmail.com
# Carlos Fernandez-Lozano: RNASA-IMEDIR, University of A Coruna, Spain, carlos.fernandez@udc.es 
# Georgia Tsiliki: ChemEng - NTUA, Greece, g_tsiliki@hotmail.com
# Haralambos Sarimveis: ChemEng - NTUA, Greece, hsarimv@central.ntua.gr
# Humberto Gonzalez-Diaz, IKERBASQUE / University of Basque Country, Spain, gonzalezdiazh@yahoo.es
# Egon Willighagen: BiGCaT - Maastricht University, Netherlands, egon.willighagen@gmail.com
# ----------------------------------------------------------------------------------------------

# if you downloaded a source distribution, you can also use the version in the package:
library(ChemmineR)
library(base)
library(expm)
library(MASS)
source("../RMarkovTI/R/RMarkovTI_functions.R")


RDMarkovMeans_results <- RDMarkovMeans()
# RDMarkovMeans_results <- RDMarkovMeans(SFile="SMILES_500.txt")
# RDMarkovMeans_results <- RDMarkovMeans(SFile="SMILES.txt", sResultFile="myResults.csv")

RDMarkovSingulars_results <- RDMarkovSingulars()
