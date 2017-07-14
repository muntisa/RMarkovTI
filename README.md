RMarkovTI
===========

Markov Topoological Indices in R

University of A Coruna (Spain) & University of the Basque Country (Spain) & eNanoMapper Developers |  [eNanoMapper Project] (http://www.enanomapper.net/)
Contact: muntisa [at] gmail [dot] com

It is a tool for the calculation of Markov Molecular Topological Indices: Markov Mean Properties and Markov Singular Values of Transition Probabilities for drugs. 

The new tool implements two types of drug descriptors using molecular graph topology, atom interactions and atom properties: Markov Mean Properties and Markov Singular Values of Transition Probabilities. The algorithm is derived from a previous python private software, MInD-Prot but the atom weights are different: number of valence electrons, vand der Waals atomic radius, covalent radius, atomic mass, vand der Waals volume, Sanderson electronegativity, atomic polarizability, ionization potential, and electron affinity. The open source R package is based on ChemmineR, base, expm, and MASS packages.

Markov Mean Properties (MMPs) algorithm: 
- Read the inputs: SMILES formulas and atom properties
- Get connectivity matrix (CM), nodes = atoms, edges = chemical bonds
- Get weights vector (w) for each atom property
- Calculate weighted matrix (W) using CM and w
- Calculate transition probability (P) based on W
- Calculate absolute initial probability vectpr (p0j) based on W
- Calculate k powers of P -> Pk matrices
- Calculate matrix products p0j * Pk * w -> MMPk (descriptors for each k and atomic property)
- Calculate MMP for each atom property and atom type by averaging MMPk values
- Output: a file with 24 descriptors for each SMILES (4 atom properties * 6 atom types)
- The file of atom properties can be completed with any others or replaced with different ones!

The next steps:
- correct errors due to missing atoms into the atom properties file

The tool is presented as an R package and it will contains additional Web interface as an Web tool.

(C) 2017
