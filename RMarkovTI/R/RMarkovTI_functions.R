library(base)

# ===================================================================================
# RMarkovTI = R Markov Topological Indices
# ===================================================================================
# Calculate Markov Topological Indices
# enanomapper.net
# ----------------------------------------------------------------------------------------------
# AUTHORS: 
# ----------------------------------------------------------------------------------------------
# Cristian R. Munteanu: RNASA-IMEDIR, University of A Coruna, Spain, muntisa@gmail.com
# Carlos Fernandez-Lozano: RNASA-IMEDIR, University of A Coruna, Spain, carlos.fernandez@udc.es 
# Georgia Tsiliki: ChemEng - NTUA, Greece, g_tsiliki@hotmail.com
# Haralambos Sarimveis: ChemEng - NTUA, Greece, hsarimv@central.ntua.gr
# Paula Carracedo: University of Basque Country, Spain, pcreboredo@gmail.com
# Humberto Gonzalez-Diaz, IKERBASQUE / University of Basque Country, Spain, gonzalezdiazh@yahoo.es
# Egon Willighagen: BiGCaT - Maastricht University, Netherlands, egon.willighagen@gmail.com
# ----------------------------------------------------------------------------------------------

# RMarkovTI depends on: ChemmineR, base, expm, MASS

# ------ FUNCTIONS --------------------------------------------------------------------------------------
RDMarkovMeans <- function(SFile="SMILES.txt",sResultFile="RDMarkovMeansResults.csv",kPower="3") {
  # Calculate Markov Mean Descriptors for drugs; output = CVS file
  # ---------------------------------------------------------------------------------------------------------------------------
  # FLOW
  # ---------------------------------------------------------------------------------------------------------------------------
  # Read the inputs: SMILES formulas and atom properties
  # Get connectivity matrix (CM), nodes = atoms, edges = chemical bonds
  # Get weights vector (w) for each atom property
  # Calculate weighted matrix (W) using CM and w
  # Calculate transition probability (P) based on W
  # Calculate absolute initial probability vectpr (p0j) based on W
  # Calculate k powers of P -> Pk matrices (k = distance in atoms for atomic interaction)
  # Calculate matrix products p0j * Pk * w -> MMPk (descriptors for each k and atomic property)
  # Calculate MMP for each atom property and atom type by averaging MMPk values (54 descriptors = 9 properties * 6 atom types)
  # ---------------------------------------------------------------------------------------------------------------------------
  # NOTES
  # ------------------------------------------------------------------------------
  # You can add any atom property into the properties file!
  # You need to have ALL the atoms from SMILEs into the properties files (if not, an error will occur!)
  
  WFile="weight/AtomProperties.txt" # text file with atom properties
  
  sDescription=paste("\n===================================================================================================",
                     "RDMarkovMeans - R Drug Markov Mean Descriptors",
                     "===================================================================================================",
                     "Calculate Drug Markov Mean Descriptors using SMILES drug formulas", "eNanoMapper.net","AUTHORS:",
                     "Cristian R. Munteanu: RNASA-IMEDIR, University of A Coruna, Spain, muntisa@gmail.com",
					 "Carlos Fernandez-Lozano: RNASA-IMEDIR, University of A Coruna, Spain, carlos.fernandez@udc.es", 
                     "Georgia Tsiliki: ChemEng - NTUA, Greece, g_tsiliki@hotmail.com",
                     "Haralambos Sarimveis: ChemEng - NTUA, Greece, hsarimv@central.ntua.gr",
					 "Humberto Gonzalez-Diaz, IKERBASQUE / University of Basque Country, Spain, gonzalezdiazh@yahoo.es",
                     "Egon Willighagen: BiGCaT - Maastricht University, The Netherlands, egon.willighagen@gmail.com",
                     "===================================================================================================",sep="\n")
  cat(sDescription) # print package header information
  cat("\nRunning ... \n")
  
  ptmTot <- proc.time() # starting counting executing time
  
  # read 2 column new input file
  dnew=read.table(SFile,header=F)
  # write only smiles into a new file onlySMILES.txt
  SFile2 = "onlySMILES.txt"
  write.table(dnew[,2], SFile2, row.names=F, col.names=F, sep="", quote = FALSE)
  
  #-------------------------------------------------------------------------------
  # Read SMILES formulas
  #-------------------------------------------------------------------------------
  smiset <- read.SMIset(SFile2)       # read a file with SMILES codes as object from onlySMILES.txt !!!! (intermediate file, not the original input file !!!
  smiles <- as.character(smiset)      # convert the object with SMILES into a text list
  
  nSmiles <- length(smiles)           # number of SMILES formulas
  #-------------------------------------------------------------------------------
  # Read WEIGHTs from file
  #-------------------------------------------------------------------------------
  dfW=read.table(WFile,header=T)      # read weigths TXT file
  # load("AtomProperties.RData")         # read R data -> dfW
  print(dfW)
  
  Headers    <- names(dfW)             # list variable names into the dataset
  wNoRows    <- dim(dfW)[1]            # number of rows = atoms with properties
  wNoCols    <- dim(dfW)[2]            # number of cols = atomic element, properties 
  #-------------------------------------------------------------------------------
  # TYPES of ATOMS: All (all atoms), Csat (saturated C), Cinst (insaturated C)
  # Hal (halogen), Het (heteroatoms), HetNoX (heteroatoms but not halogens
  atomTypes  <- c("All","Csat","Cuns","Hal","Het","HetNoX")
  natomTypes <- length(atomTypes)      # (6 = 5 types + all atoms)
  #-------------------------------------------------------------------------------
  # HEADER - names of the descriptors
  sResults <- "Molecule"               # initializate the result string
  for(h in 2:wNoCols){
    for(atty in 1:natomTypes){
      # Add each descriptor label as Chem-Phys property + Atom type (6*4 = 24 descriptors)
      sResults <- sprintf("%s,MMP_%s_%s",sResults,Headers[h],atomTypes[atty])
    }  
  }
  sResults <- sprintf("%s\n",sResults)
  
  #-------------------------------------------------------------------------------
  # PROCESS EACH SMILES
  # - calculate MMPs for each SMILES, each pythical-chemical property and atom type
  #   averaged for all powers (0-kPower)
  #-------------------------------------------------------------------------------
  for(s in 1:nSmiles){          # process for each SMILES
    smi <- smiles[[s]]                 # SMILES formula
    
	# molName <- names(smiles)[s]        # molecule label
    molName <- as.character(dnew[,1][s])        # molecule label from the 2 column original input file!
	
	print(c(s,molName))
    sdf <- smiles2sdf(smi)             # convert one smiles to sdf format
	
    BM <- conMA(sdf,exclude=c("H"))    # bond matrix (complex list!)
    
    sResults <- sprintf("%s%s",sResults,molName) # add molecule name to the result
    
    # Connectivity matrix CM
    CM <- BM[[1]]                      # get only the matrix  
    CM[CM > 0] <- 1                    # convert bond matrix into connectivity matrix/adjacency matrix CM
    
    # Degrees
    deg <- rowSums(CM)                 # atom degree (no of chemical bonds)
    atomNames <- (rownames(CM))        # atom labels from the bond table (atom_index)
    nAtoms <- length(atomNames)        # number of atoms
    BMM <- matrix(BM[[1]][1:(nAtoms*nAtoms)],ncol=nAtoms,byrow=T) # only matrix, no row names
    
    # Get list with atoms and positions
    Atoms <- list()                    # inicialize the list of atoms 
    AtIndexes <- list()                # inicialize the list of atom indixes
    for(a in 1:nAtoms){                # process each atom in bond table
      Atom <- atomNames[a]                      # pick one atom
      Elem_Ind <- strsplit(Atom,'_')            # split atom labels (atom_index)
      AtElem <- Elem_Ind[[1]][1]                # get atomic element
      AtIndex <- Elem_Ind[[1]][2]               # get index of atom element
      Atoms[a] <- c(AtElem)                     # add atom element to a list
      AtIndexes[a] <- as.numeric(c(AtIndex))    # add index of atom elements to a list
    }
    
    # Weights data frame (for all atom properties)
    # -----------------------------------------------------------------------
    # Atoms data frame
    dfAtoms <- data.frame(Pos=as.numeric(t(t(AtIndexes))),AtomE=t(t(Atoms)))
    
    # Weights data frame
    dfAtomsW <- merge(dfW,dfAtoms,by=c("AtomE")) # merge 2 data frame using values of AtomE
    dfAtomsW <- dfAtomsW[order(dfAtomsW$Pos),1:wNoCols] # order data frame and remove Pos
    rownames(dfAtomsW) <- seq(1:dim(dfAtomsW)[1])
    
    # NEED CORRECTION FOR ATOMS that are not in the properties file: nAtoms could be different by dim(dfAtomsW)[1] if the atom is not in the properties list
    
    # Get vectors for each type of atom: All (all atoms), Csat, Cinst, Halog, Hetero, Hetero No Halogens (6 = 5 types + all atoms)
    vAtoms=(c(dfAtomsW["AtomE"]))                         # List of atoms
    # Initialize all zero vectors for each type of atom
    vAll    <- vector(mode = "numeric", length = nAtoms)  # All atoms 
    vCsat   <- vector(mode = "numeric", length = nAtoms)  # Saturated C
    vCuns   <- vector(mode = "numeric", length = nAtoms)  # Unsaturated C
    vHal    <- vector(mode = "numeric", length = nAtoms)  # Halogen atom (F,Cl,Br,I)
    vHet    <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms (any atom different of C)
    vHetnoX <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms excluding the halogens
    
    # Calculate vectors for each type of atom (1 if atom present) - used to filter the poj*Pk*w multiplication
    vAll <- vAll+1                              # vector 1 for All atoms
    for(a in 1:nAtoms){                         # process each atom from the list
      if (vAtoms[[1]][a]=="C"){                 # C atoms
        if (max(BMM[a,]) == 1){ vCsat[a] <- 1 } # saturated C
        if (max(BMM[a,]) > 1) { vCuns[a] <- 1 } # unsaturated C 
      }
      else {
        vHet[a] <- 1 # Heteroatom
        if ( vAtoms[[1]][a] %in% c("F", "Cl", "Br", "I") ) { vHal[a] <- 1  } # Halogen atom (F,Cl,Br,I)
        else {vHetnoX[a] <- 1} # Heteroatoms excluding the halogens
      }
    }
    listAtomVectors <- list(vAll,vCsat,vCuns,vHal,vHet,vHetnoX) # list with the atom type vectors
    
    # For each atom property
    # -----------------------------------------
    vMMP <- c()                        # final MMP descriptors for one molecule
    for(prop in 2:wNoCols){                    # for each property
      w <- t(data.matrix(dfAtomsW[prop]))[1,]    # weigths VECTOR
      W <- t(CM * w)                             # weigthed MATRIX
      p0j <- w/sum(w,na.rm=TRUE)                            # absolute initial probabilities vector
      
      # Probability Matrix P
      # ----------------------
      degW <- rowSums(W,na.rm=TRUE) # degree vector
      P <- W * ifelse(degW == 0, 0, 1/degW)      # transition probability matrix (corrected for zero division)
      
      # Average all descriptors by power (0-k)
      # ------------------------------------------------------------
      for(v in 1:length(listAtomVectors)){       # for each type of atom
        vFilter <- unlist(listAtomVectors[v])          # vector to filter the atoms (using only a type of atom)
        vMMPk <- c()                                   # MMPs for k values
        for(k in 0:kPower){                            # power between 0 and kPower
          Pk <- (P %^% k)                              # Pk = k-powered transition probability matrix
          MMPk = (vFilter*t(p0j)) %*% Pk %*% (t(t(w))*vFilter)           # MMPk for all atoms for one k = vMv type product
          vMMPk <- c(vMMPk, MMPk)                      # vector with all MMPs for all ks and atom properties
        }
        avgvMMP  <- mean(vMMPk,na.rm=TRUE)             # average value for all k values ( +1 because of k starting with 0) for each type of atom
        sResults <- sprintf("%s,%s",sResults,avgvMMP)
      } 
    }
    # print final MMPs for one molecule, for each property (averaged by all k values), for all types of atoms
    sResults <- sprintf("%s\n",sResults)
  }
  # cat(sResults) # print final output
  write(sResults, file=sResultFile, append=F, sep="\t") # create the result file with the header
  descriptors = read.table(sResultFile,header=T,sep=",")   # read the results to create the function output, a data frame
  
  cat("\nDone!\n")
  
  # Print total execution time
  cat("\nRDMarkovMeans total execution time\n")
  print(proc.time() - ptmTot) # print running time
  
  #----------------------------
  # Indicate all files
  #----------------------------
  cat("\nFILES\n=======\n")
  cat("Result file:", sResultFile,"\n")
  cat("Input  file:", SFile,"\n")
  cat("Atomic properties:", WFile,"\n")
  cat(paste("Power k:",k,sep=" "),"\n")
  
  return (descriptors) # all molecular descriptors as a data frame including the hearder (descriptor names)
}

# -----------------------------------------------------------------------------------------------------------------
RDMarkovSingulars <- function(SFile="SMILES.txt",sResultFile="RDMarkovSingularsResults.csv",kPower=3,fAllKs=0) {
  # Calculate Drug Markov Singular Values of Transition Probabilities; output = CVS file
  # -------------------------------------------------------------------------------------------------------
  # FLOW
  # -------------------------------------------------------------------------------------------------------
  # Read the inputs: SMILES formulas and atom properties
  # Get connectivity matrix (CM), nodes = atoms, edges = chemical bonds
  # Get weights vector (w) for each atom property
  # Calculate weighted matrix (W) using CM and w
  # Calculate transition probability (P) based on W
  # Calculate k powers of P -> Pk matrices
  # Calculate Markov Singular Values of Transition Probability Matrix for all power,
  # each type of atom property and atom type
  # Calculate the average values over all K values
  # TOTAL = 336
  # 
  # If the flag fAllKs is 1 -> 336 descriptors; if 0 -> only 48 (averaged values)
  # Descriptors for all k values -> 288 = (4 properties*6 atom types* 6 powers) * 2 for Min and Max
  # Averages descriptors         -> 48  = (4 properties*6 atom types) * 2 for Min and Max
  # -------------------------------------------------------------------------------------------------------
  # NOTES
  # -------------------------------------------------------------------------------------------------------
  # You can add any atom property into the properties file!
  # You need to have ALL the atoms from SMILEs into the properties files (if not, an error will occur!)
  WFile="weight/AtomProperties.txt" # text file with atom properties
  
  sDescription=paste("\n===================================================================================================",
                     "RDMarkovSingulars - R Drug Markov Singular Values of Transition Probabilities Descriptors",
                     "===================================================================================================",
                     "Calculate Drug Markov Singular Values of Transition Probabilities using SMILES drug formulas", "eNanoMapper.net","AUTHORS:",
                     "Cristian R. Munteanu: RNASA-IMEDIR, University of A Coruna, Spain, muntisa@gmail.com",
					 "Carlos Fernandez-Lozano: RNASA-IMEDIR, University of A Coruna, Spain, carlos.fernandez@udc.es", 
                     "Georgia Tsiliki: ChemEng - NTUA, Greece, g_tsiliki@hotmail.com",
                     "Haralambos Sarimveis: ChemEng - NTUA, Greece, hsarimv@central.ntua.gr",
					 "Humberto Gonzalez-Diaz, IKERBASQUE / University of Basque Country, Spain, gonzalezdiazh@yahoo.es",
                     "Egon Willighagen: BiGCaT - Maastricht University, The Netherlands, egon.willighagen@gmail.com",
                     "===================================================================================================",sep="\n")
  cat(sDescription) # print package header information
  cat("\nRunning ... \n")
  
  ptmTot <- proc.time() # starting counting executing time
  
  # read 2 column new input file
  dnew=read.table(SFile,header=F)
  # write only smiles into a new file onlySMILES.txt
  SFile2 = "onlySMILES.txt"
  write.table(dnew[,2], SFile2, row.names=F, col.names=F, sep="", quote = FALSE)
  
  #--------------------------------------------------------------------------------------------------------
  # Read SMILES formulas
  #--------------------------------------------------------------------------------------------------------
  smiset <- read.SMIset(SFile2)        # read a file with SMILES codes as object from onlySMILES.txt !!
  smiles <- as.character(smiset)      # convert the object with SMILES into a text list
  nSmiles <- length(smiles)           # number of SMILES formulas
  #-------------------------------------------------------------------------------
  # Read WEIGHTs from file
  #-------------------------------------------------------------------------------
  dfW=read.table(WFile,header=T)       # read weigths TXT file
  # load("AtomProperties.RData")         # read R data -> dfW
  
  Headers    <- names(dfW)             # list variable names into the dataset
  wNoRows    <- dim(dfW)[1]            # number of rows = atoms with properties
  wNoCols    <- dim(dfW)[2]            # number of cols = atomic element, properties 
  #-------------------------------------------------------------------------------
  # TYPES of ATOMS: All (all atoms), Csat (saturated C), Cinst (insaturated C)
  # Hal (halogen), Het (heteroatoms), HetNoX (heteroatoms but not halogens
  atomTypes  <- c("All","Csat","Cuns","Hal","Het","HetNoX")
  natomTypes <- length(atomTypes)      # (6 = 5 types + all atoms)
  #-------------------------------------------------------------------------------
  # HEADER - names of the descriptors
  sResults <- "Molecule"               # initializate the result string
  for(h in 2:wNoCols){
    for(atty in 1:natomTypes){
      if (fAllKs == 1){                # if the flag for all descriptors (all k) is 1, add the header (descriptor names)
        for(k in 0:kPower){
          sResults <- sprintf("%s,MSVTP.%s.%s.%s.Min,MSVTP.%s.%s.%s.Max",sResults,Headers[h],atomTypes[atty],k,Headers[h],atomTypes[atty],k)
        }
      }
      # Add each descriptor label as 4 Chem-Phys property * 6 Atom type *2 for Min and Max = 48 descriptors
      sResults <- sprintf("%s,MSVTP.%s.%s.AvgMin,MSVTP.%s.%s.AvgMax",sResults,Headers[h],atomTypes[atty],Headers[h],atomTypes[atty])
    }  
  }
  sResults <- sprintf("%s\n",sResults)
  
  #----------------------------------------------------------------------------------------------
  # PROCESS EACH SMILES
  # - calculate MMPs for each SMILES, each pythical-chemical property, atom type and k power
  #----------------------------------------------------------------------------------------------
  for(s in 1:nSmiles){          # process for each SMILES
    smi <- smiles[[s]]                 # SMILES formula
    
	# molName <- names(smiles)[s]        # molecule label
	molName <- as.character(dnew[,1][s])        # molecule label from the 2 column original input file!
	
    print(c(s,molName))
    sdf <- smiles2sdf(smi)             # convert one smiles to sdf format
    BM <- conMA(sdf,exclude=c("H"))    # bond matrix (complex list!)
    
    sResults <- sprintf("%s%s",sResults,molName) # add molecule name to the result
    
    # Connectivity matrix CM
    CM <- BM[[1]]                      # get only the matrix  
    CM[CM > 0] <- 1                    # convert bond matrix into connectivity matrix/adjacency matrix CM
    
    # Degrees
    deg <- rowSums(CM)                 # atom degree (no of chemical bonds)
    atomNames <- (rownames(CM))        # atom labels from the bond table (atom_index)
    nAtoms <- length(atomNames)        # number of atoms
    BMM <- matrix(BM[[1]][1:(nAtoms*nAtoms)],ncol=nAtoms,byrow=T) # only matrix, no row names
    
    # Get list with atoms and positions
    Atoms <- list()                    # inicialize the list of atoms 
    AtIndexes <- list()                # inicialize the list of atom indixes
    for(a in 1:nAtoms){                # process each atom in bond table
      Atom <- atomNames[a]                      # pick one atom
      Elem_Ind <- strsplit(Atom,'_')            # split atom labels (atom_index)
      AtElem <- Elem_Ind[[1]][1]                # get atomic element
      AtIndex <- Elem_Ind[[1]][2]               # get index of atom element
      Atoms[a] <- c(AtElem)                     # add atom element to a list
      AtIndexes[a] <- as.numeric(c(AtIndex))    # add index of atom elements to a list
    }
    
    # Weights data frame (for all atom properties)
    # -----------------------------------------------------------------------
    # Atoms data frame
    dfAtoms <- data.frame(Pos=as.numeric(t(t(AtIndexes))),AtomE=t(t(Atoms)))
    # Weights data frame
    dfAtomsW <- merge(dfW,dfAtoms,by=c("AtomE")) # merge 2 data frame using values of AtomE
    dfAtomsW <- dfAtomsW[order(dfAtomsW$Pos),1:wNoCols] # order data frame and remove Pos
    rownames(dfAtomsW) <- seq(1:dim(dfAtomsW)[1])
    # NEED CORRECTION FOR ATOMS that are not in the properties file: nAtoms could be different by dim(dfAtomsW)[1] if the atom is not in the properties list
    
    # Get vectors for each type of atom: All (all atoms), Csat, Cinst, Halog, Hetero, Hetero No Halogens (6 = 5 types + all atoms)
    vAtoms=(c(dfAtomsW["AtomE"]))                         # List of atoms
    # Initialize all zero vectors for each type of atom
    vAll    <- vector(mode = "numeric", length = nAtoms)  # All atoms 
    vCsat   <- vector(mode = "numeric", length = nAtoms)  # Saturated C
    vCuns   <- vector(mode = "numeric", length = nAtoms)  # Unsaturated C
    vHal    <- vector(mode = "numeric", length = nAtoms)  # Halogen atom (F,Cl,Br,I)
    vHet    <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms (any atom different of C)
    vHetnoX <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms excluding the halogens
    
    # Calculate vectors for each type of atom (1 if atom present) - used to filter the poj*Pk*w multiplication
    vAll <- vAll+1                              # vector 1 for All atoms
    for(a in 1:nAtoms){                         # process each atom from the list
      if (vAtoms[[1]][a]=="C"){                 # C atoms
        if (max(BMM[a,]) == 1){ vCsat[a] <- 1 } # saturated C
        if (max(BMM[a,]) > 1) { vCuns[a] <- 1 } # unsaturated C 
      }
      else {
        vHet[a] <- 1 # Heteroatom
        if ( vAtoms[[1]][a] %in% c("F", "Cl", "Br", "I") ) { vHal[a] <- 1  } # Halogen atom (F,Cl,Br,I)
        else {vHetnoX[a] <- 1} # Heteroatoms excluding the halogens
      }
    }
    listAtomVectors <- list(vAll,vCsat,vCuns,vHal,vHet,vHetnoX) # list with the atom type vectors
    
    # Calculate descriptors for each atom property 
    # ----------------------------------------------------------------------------------
    vMMP <- c()                        # final MMP descriptors for one molecule
    for(prop in 2:wNoCols){                    # for each property
      w <- t(data.matrix(dfAtomsW[prop]))[1,]    # weigths VECTOR
      W <- t(CM * w)                             # weigthed MATRIX
      p0j <- w/sum(w)                            # absolute initial probabilities vector
      
      # Probability Matrix P
      # ----------------------
      degW <- rowSums(W) # degree vector
      P <- W * ifelse(degW == 0, 0, 1/degW)      # transition probability matrix (corrected for zero division)
      
      # Average all descriptors by power (0-k)
      # ------------------------------------------------------------
      for(v in 1:length(listAtomVectors)){       # for each type of atom
        vFilter <- unlist(listAtomVectors[v])          # vector to filter the atoms (using only a type of atom)
        vSVmin <- c()                                  # min of single values vector for all k values
        vSVmax <- c()                                  # max of single values vector for all k values
        for(k in 0:kPower){                            # power between 0 and kPower
          Pk <- (P %^% k)                              # Pk = k-powered transition probability matrix
          FilterPk <- matrix((1:(nAtoms*nAtoms))*0,ncol=nAtoms,byrow=T)  # filtered matrix for each type of atom
          for(lc in 1:nAtoms){
            if ( vFilter[lc] == 1) {       # use filter vector in order to keep only the lines and colomns into the Pk matrix for specific atoms
              FilterPk[lc,] <- (Pk[lc,])
              FilterPk[,lc] <- (Pk[,lc])
            }
          }
          # Single Values
          FilterPk.svd.d <- svd(FilterPk)$d
          FilterPk.svd.d.min <- min(FilterPk.svd.d)
          FilterPk.svd.d.max <- max(FilterPk.svd.d)
          # If the flag is 1, print all the descriptors for all k values (288 = 4 properties*6 atom types* 6 powers)
          if (fAllKs == 1){
            sResults <- sprintf("%s,%s,%s",sResults,FilterPk.svd.d.min,FilterPk.svd.d.max)
          }
          vSVmin <- c(vSVmin, FilterPk.svd.d.min)     # vector with min of sigle values for all k values (one type of atom property and atom type)
          vSVmax <- c(vSVmax, FilterPk.svd.d.max)     # vector with max of sigle values for all k values (one type of atom property and atom type)
        }
        avgMin  <- mean(vSVmin)                       # average value for all k values ( +1 because of k starting with 0) for each type of atom
        avgMax  <- mean(vSVmax)                       # average value for all k values ( +1 because of k starting with 0) for each type of atom
        sResults <- sprintf("%s,%s,%s",sResults,avgMin,avgMax)
      } 
    }
    # print final MMPs for one molecule, for each property (averaged by all k values), for all types of atoms
    sResults <- sprintf("%s\n",sResults)
  }
  # cat(sResults) # print final output
  write(sResults, file=sResultFile, append=F)           # create the result file with the header
  descriptors = read.table(sResultFile,header=T,sep=",")   # read the results to create the function output, a data frame
  
  cat("\nDone!\n")
  
  # Print total execution time
  cat("\nRDMarkovSingulars total execution time\n")
  print(proc.time() - ptmTot) # print running time
  
  #----------------------------
  # Indicate all files
  #----------------------------
  cat("\nFILES\n=======\n")
  cat("Result file:", sResultFile,"\n")
  cat("Input  file:", SFile,"\n")
  cat("Atomic properties:", WFile,"\n")
  cat(paste("Power k:",k,sep=" "),"\n")
  cat(paste("Descriptor flag:",fAllKs,sep=" "),"\n")
 
  return (descriptors) # all molecular descriptors as a data frame including the header (descriptor names)
}

