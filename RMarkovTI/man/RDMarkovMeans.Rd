\name{RDMarkovMeans}
\alias{RDMarkovMeans}
\title{
R Drug Markov Mean Properties.
}
\description{
Calculate Markov Mean Properties (molecular graph descriptors) based on SMILES formulas. 
}
\usage{
RDMarkovMeans(SFile,sResultFile,kPower)}
\arguments{
 \item{SFile}{A string specifiyng the input file with drug SMILES formulas. Each row contains a SMILES formula. The default value is "SMILES.txt"}
 \item{sResultFile}{A string specifying the output file (could include path). The default value is "RDMarkovMeans_Results.csv".}
 \item{kPower}{A number indicating the power to be used for the Markov chain calculations. It indicates the number of atoms between the interaction atoms of the drug. The default value is 3.}
}
\details{
RDMarkovMeans is extracting the atom connectivity and it is generating the molecular correspondent molecular graph. The descriptors are using Markov chain theory and the atom weigths as X atom properties: ..., ...,...,...,...,... .
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
Cristian R. Munteanu, Georgia Tsiliki, Haralambos Sarimveis, Egon Willighagen
}
