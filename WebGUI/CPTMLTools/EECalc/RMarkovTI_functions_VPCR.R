library(ChemmineR)
library(base)
library(expm)
library(MASS)


calculateDescriptor <- function(atomPropExcluded, atomTypesSelected, smile, kPower="3") {
  
  dfW=read.table("F:/CPTMLTools/MCDCalc/weight/AtomProperties.txt",header=T)  # read weigths TXT file
  
  excludeAtomsFormat <-lapply(strsplit(atomPropExcluded,','), as.character)[[1]]
  outputAtomsFile<-dfW[ , !(names(dfW) %in% excludeAtomsFormat)]
  
  Headers    <- names(outputAtomsFile)             # list variable names into the dataset
  wNoRows    <- dim(outputAtomsFile)[1]            # number of rows = atoms with properties
  wNoCols    <- dim(outputAtomsFile)[2]            # number of cols = atomic element, properties 
  
  atomTypes <- unlist(strsplit(atomTypesSelected, split=","))
  
  #-------------------------------------------------------------------------------
  # PROCESS EACH SMILES
  # - calculate MMPs for each SMILES, each pythical-chemical property and atom type
  #   averaged for all powers (0-kPower)
  #-------------------------------------------------------------------------------
  
  tryCatch({
    
    sdf <- smiles2sdf(as.character(smile))
    BM <- conMA(sdf,exclude=c("H"))    # bond matrix (complex list!)
    
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
    dfAtomsW <- merge(outputAtomsFile,dfAtoms,by=c("AtomE")) # merge 2 data frame using values of AtomE
    dfAtomsW <- dfAtomsW[order(dfAtomsW$Pos),1:wNoCols] # order data frame and remove Pos
    rownames(dfAtomsW) <- seq(1:dim(dfAtomsW)[1])
    
    # NEED CORRECTION FOR ATOMS that are not in the properties file: nAtoms could be different by dim(dfAtomsW)[1] if the atom is not in the properties list
    
    # Get vectors for each type of atom: All (all atoms), Csat, Cinst, Halog, Hetero, Hetero No Halogens (6 = 5 types + all atoms)
    vAtoms=(c(dfAtomsW["AtomE"]))                         # List of atoms
    # Initialize all zero vectors for each type of atom
    #vAll    <- vector(mode = "numeric", length = nAtoms)  # All atoms 
    #vCsat   <- vector(mode = "numeric", length = nAtoms)  # Saturated C
    #vCuns   <- vector(mode = "numeric", length = nAtoms)  # Unsaturated C
    #vHal    <- vector(mode = "numeric", length = nAtoms)  # Halogen atom (F,Cl,Br,I)
    #vHet    <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms (any atom different of C)
    #vHetnoX <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms excluding the halogens
    
    if ('All' %in% atomTypes){
      vAll    <- vector(mode = "numeric", length = nAtoms)  # All atoms 
      vAll <- vAll+1                              # vector 1 for All atoms
    }
    
    if ('Csat' %in% atomTypes){
      vCsat   <- vector(mode = "numeric", length = nAtoms)  # Saturated C
    }
    
    if ('Cuns' %in% atomTypes){
      vCuns   <- vector(mode = "numeric", length = nAtoms)  # Unsaturated C
    }
    
    if ('Hal' %in% atomTypes){
      vHal    <- vector(mode = "numeric", length = nAtoms)  # Halogen atom (F,Cl,Br,I)
    }
    
    if ('Het' %in% atomTypes){
      vHet    <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms (any atom different of C)
    }
    
    if ('HetNoX' %in% atomTypes){
      vHetnoX <- vector(mode = "numeric", length = nAtoms)  # Heteroatoms excluding the halogens
    }
    
    
    
    for(a in 1:nAtoms){                         # process each atom from the list
      if (vAtoms[[1]][a]=="C"){                 # C atoms
        
        if ('Csat' %in% atomTypes){
          if (max(BMM[a,]) == 1){ 
            vCsat[a] <- 1 } # saturated C
        }
        
        if ('Cuns' %in% atomTypes){
          if (max(BMM[a,]) > 1) { 
            vCuns[a] <- 1 } # unsaturated C 
        }
        
      }
      
      else {
        if ('Het' %in% atomTypes){
          vHet[a] <- 1 # Heteroatom
        }
        
        if (vAtoms[[1]][a] %in% c("F", "Cl", "Br", "I") ) { 
          if ('Hal' %in% atomTypes){
            vHal[a] <- 1 } # Halogen atom (F,Cl,Br,I)
        }
        else {
          if ('HetNoX' %in% atomTypes){
            vHetnoX[a] <- 1 } # Heteroatoms excluding the halogens
        }
      }
    }
    
    listAtomVectors <- list() # list with the atom type vectors
    
    if ('All' %in% atomTypes){
      listAtomVectors <- c(listAtomVectors, list(vAll))
    }
    
    if ('Csat' %in% atomTypes){
      listAtomVectors <- c(listAtomVectors, list(vCsat))
    }
    
    if ('Cuns' %in% atomTypes){
      listAtomVectors <- c(listAtomVectors, list(vCuns))
    }
    
    if ('Hal' %in% atomTypes){
      listAtomVectors <- c(listAtomVectors, list(vHal))
    }
    
    if ('Het' %in% atomTypes){
      listAtomVectors <- c(listAtomVectors, list(vHet))
      
    }
    
    if ('HetNoX' %in% atomTypes){
      listAtomVectors <- c(listAtomVectors, list(vHetnoX))
    }
    
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
        
      } 
    }
    return(avgvMMP)
    
  }, error=function(e){
    
    return("error")
  })
  
}

