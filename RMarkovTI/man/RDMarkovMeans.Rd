\name{RDMarkovMeans}
\alias{RDMarkovMeans}
\title{
Drug Markov Mean Properties in R.
}
\description{
Calculate Markov Mean Properties (molecular graph topological indices) based on SMILES formulas. 
}
\usage{
RDMarkovMeans(SFile,sResultFile,kPower)}
\arguments{
 \item{SFile}{A string specifiyng the input file with drug SMILES formulas. Each row contains a SMILES formula. The default value is "SMILES.txt"}
 \item{sResultFile}{A string specifying the output file (could include path). The default value is "RDMarkovMeans_Results.csv".}
 \item{kPower}{A number indicating the power to be used for the Markov chain calculations. It indicates the number of atoms between the interaction atoms of the drug. The default value is 3.}
}
\details{
RDMarkovMeans is extracting the atom connectivity and it is generating the molecular correspondent molecular graph (nodes = atoms, edges = chemical bonds). The descriptors/topological indices (TIs) are using Markov chain theory and the atom weigths as 9 atom properties: number of valence electrons (Zv), vand der Waals atomic radius (Rvdw), covalent radius (Rcov), atomic mass (m), vand der Waals volume (Vvdw), Sanderson electronegativity (SAe), atomic polarizability (aPolar), ionization potential (IP), electron affinity (EA). The descriptors are calculating for 6 atom types: All (all atoms), Csat (saturated C), Cinst (unsaturated C), Hal (halogen), Het (heteroatoms) and HetNoX (heteroatoms but not halogens). The descriptors are averaged for all k values (distance between atoms that are interacting). Thus, RDMarkovMeans is calculating 54 TIs (9 atom properties x 6 atom types). The user can modify the atom properties file by adding or removing any column.
}
\value{
 A data frame is returned containing:
\item{sResults}{the drug Markov Mean Properties including the header (name of descriptors)}
}
\examples{
\dontrun{
# if you downloaded a source distribution, you can also use the version in the package
library(ChemmineR)
library(base)
library(expm)
library(MASS)
source("../RMarkovTI/R/RMarkovTI_functions.R")

# call with all default parameters (SFile="SMILES.txt",sResultFile="RDMarkovMeans_Results.csv",kPower="3")
RDMarkovMeans_results <- RDMarkovMeans()

# call using a specific input SMILES file
RDMarkovMeans_results <- RDMarkovMeans(SFile="mySMILES.txt")

# call using custom input and output file names
RDMarkovMeans_results <- RDMarkovMeans(SFile="mySMILES.txt", sResultFile="myResults.csv")

# call using all the function parameters
RDMarkovMeans_results <- RDMarkovMeans(SFile="mySMILES.txt", sResultFile="myResults.csv", kPower="5")
}
}
\author{
Cristian R. Munteanu, Carlos Fernandez-Lozano, Georgia Tsiliki, Haralambos Sarimveis, Humberto Gonzalez-Diaz, Egon Willighagen
}
