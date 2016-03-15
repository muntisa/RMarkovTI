\name{RDMarkovSingulars}
\alias{RDMarkovSingulars}
\title{
R Drug Markov Singular Values of Transition Probabilities.
}
\description{
Calculate Drug Markov Singular Values of Transition Probabilities (molecular graph descriptors/topological indices) based on the SMILES formulas. 
}
\usage{
RDMarkovSingulars(SFile,sResultFile,kPower,fAllKs)}
\arguments{
 \item{SFile}{A string specifiyng the input file with drug SMILES formulas. Each row contains a SMILES formula. The default value is "SMILES.txt"}
 \item{sResultFile}{A string specifying the output file (could include path). The default value is "RDMarkovSingulars_Results.csv".}
 \item{kPower}{A number indicating the power to be used for the Markov chain calculations. It indicates the number of atoms between the interaction atoms of the drug. The default value is 3.}
 \item{fAllKs}{A flag number indicating the number of the descriptors to be calculated. The values count be 1 (all descriptors) or 0 (only the averaged descriptors). The default value is 0.}
}
\details{
RDMarkovSingulars is extracting the atom connectivity and it is generating the molecular correspondent molecular graph (nodes = atoms, edges = chemical bonds). The descriptors/topological indices (TIs) are the Markov Singular Values of Transition Probability Matrix (Markov chain theory) and the atom weigths as 9 atom properties: number of valence electrons (Zv), vand der Waals atomic radius (Rvdw), covalent radius (Rcov), atomic mass (m), vand der Waals volume (Vvdw), Sanderson electronegativity (SAe), atomic polarizability (aPolar), ionization potential (IP), electron affinity (EA). The descriptors are calculating for 6 atom types: All (all atoms), Csat (saturated C), Cuns (unsaturated C), Hal (halogen), Het (heteroatoms) and HetNoX (heteroatoms but not halogens). The descriptors are averaged for all k values (distance between atoms that are interacting). Thus, if fAllKs=1, RDMarkovSingulars calculates 540 TIs for each atom property, atom type, k power, Min and Max values + the averages for all ks. If fAllKs=0, only 108 averaged TIs are calculated. The user can modify the atom properties file by adding or removing any column. s
}
\value{
 A data frame is returned containing:
\item{Descriptors}{the drug Markov Singular Values of Transition Probabilities including the header (name of descriptors)}
}
\examples{
\dontrun{
# if you downloaded a source distribution, you can also use the version in the package
library(ChemmineR)
library(base)
library(expm)
library(MASS)
source("../RMarkovTI/R/RMarkovTI_functions.R")

# call with all default parameters (SFile="SMILES.txt",sResultFile="RDMarkovSingulars_Results.csv",kPower="3")
RDMarkovSingulars_results <- RDMarkovSingulars()

# call using a specific input SMILES file
RDMarkovSingulars_results <- RDMarkovSingulars(SFile="mySMILES.txt")

# call using custom input and output file names
RDMarkovSingulars_results <- RDMarkovSingulars(SFile="mySMILES.txt", sResultFile="myResults.csv")

# call using all the function parameters
RDMarkovSingulars_results <- RDMarkovSingulars(SFile="mySMILES.txt", sResultFile="myResults.csv", kPower="5")
}
}
\author{
Cristian R. Munteanu, Carlos Fernandez-Lozano, Georgia Tsiliki, Haralambos Sarimveis, Humberto Gonzalez-Diaz, Egon Willighagen
}
