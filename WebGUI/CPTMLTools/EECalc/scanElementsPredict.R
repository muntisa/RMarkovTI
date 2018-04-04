library(ChemmineR)
library(base)
library(expm)
library(MASS)
library(openxlsx)

source("F:/CPTMLTools/EECalc/RMarkovTI_functions_VPCR.R")

args <- commandArgs(TRUE)

fileInput = args[1]
resultFile = args[2]

scanElements = args[3]

temp =  as.numeric(args[5])
time =  as.numeric(args[4])
load =  as.numeric(args[6])

refData = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "All")

inputData=read.table(fileInput ,header=T, sep=",")


intermediateDf <- data.frame(matrix(ncol = 20, nrow = 0))
  
colnames(intermediateDf) <- c("Reacction_pred", "Changed", "*ee(%)[R]_pred", "Time_pred", "Temp_pred", "Load_pred", 
            "Subs_pred","Vvdw_All_Sub_Mean_pred", 
            "Prod_pred", "EA_Csat_Prod_Mean_pred",  "aPolar_HetNoX_Prod_Mean_pred",
            "Cat_pred", "Zv_Cuns_Cat_Mean_pred", "SAe_HetNoX_Cat_Mean_pred", 
            "aPolar_Cuns_Cat_Mean_pred", "EA_HetNoX_Cat_Mean_pred",  
            "Solv_pred", "Zv_Cuns_Solv_Mean_pred", 
            "Nuc_pred", "SAe_Het_Nuc_Mean_pred")

finalDf <- data.frame(matrix(ncol = 21, nrow = 0))



for (i in 1:nrow(inputData))
{
  
  subs_Vvdw_All <- calculateDescriptor("Zv,EA,aPolar,SAe","All", inputData[i,3])
  
  prod_EA_Csat <- calculateDescriptor("Zv,aPolar,Vvdw,SAe","Csat", inputData[i,5])
  prod_aPolar_HetNox <- calculateDescriptor("Zv,EA,Vvdw,SAe","HetNoX", inputData[i,5])

  cat_Zv_Cuns <- calculateDescriptor("EA,aPolar,Vvdw,SAe","Cuns", inputData[i,7])
  cat_Sae_HetNox <- calculateDescriptor("Zv,EA,aPolar,Vvdw","HetNoX", inputData[i,7])
  cat_aPolar_Cuns <- calculateDescriptor("Zv,EA,Vvdw,SAe","Cuns", inputData[i,7])
  cat_EA_HetNox <- calculateDescriptor("Zv,aPolar,Vvdw,SAe","HetNoX", inputData[i,7])
  
  solv_Zv_Cuns <- calculateDescriptor("EA,aPolar,Vvdw,SAe","Cuns", inputData[i,9])
  
  nuc_SAe_Het <- calculateDescriptor("Zv,EA,aPolar,Vvdw","Het", inputData[i,11])
  
  AVGee = 0
  
  for(r in 1:nrow(refData)){
    
    cte1 = -4.49913625358213 + refData[r,"ee_ref"]
    cte2 = 0.0000390108439044042 * load *(temp + 273.15) * time
    
   
    eeqq <-  cte1 + (cte2 + 32.3276108875090 * (cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])
                   - 295.534521483766 * (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])
                   - 12.1067270366917 * (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])
                   - 66.2389259935735 * (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])
                   + 794.286096493798 * (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])
                   - 207.479742141609 * (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])
                   - 1754.83723650373 * (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])
                   - 1284.32408460585 * (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])
                   - 21.5757084028704 * (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"]))
    
    AVGee = AVGee + eeqq 
    
    
    
  }
  
  AVGee = AVGee/nrow(refData)
  
  
  
  intermediateDf[nrow(intermediateDf) + 1,] = c(as.character(inputData[i,1]), "--", AVGee, time, temp, load, 
                                  as.character(inputData[i,2]), subs_Vvdw_All,
                                  as.character(inputData[i,4]), prod_EA_Csat, prod_aPolar_HetNox,
                                  as.character(inputData[i,6]), cat_Zv_Cuns, cat_Sae_HetNox, cat_aPolar_Cuns, cat_EA_HetNox,
                                  as.character(inputData[i,8]), solv_Zv_Cuns,
                                  as.character(inputData[i,10]), nuc_SAe_Het)
  
  if (scanElements == "sol")
  { 
     refSol = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Sol")
     
     colnames(finalDf) <- c("Reacction_pred", "Sol_Changed", "Time_pred", "Temp_pred", "Load_pred", "*ee(%)[R]_pred", "Structural Similarity Prob(%)",
                            "Reference","ee_ref","Subs_code_ref","Nuc_code_ref",
                            "Cat_Code_ref","Prod_Code_ref","dcat_ref", "Load_ref","Temp_ref","Time_ref",
                            "Smile_Prod_ref","Smile_Subs_ref","Smile_Nuc_ref", "Smile_Cat_ref")
     
     
    
    for (j in 1:nrow(refSol))
    {
      
     solv_Zv_Cuns <- refSol[j,3]
    
     AVGee = 0
     
     for(r in 1:nrow(refData)){
       
       cte1 = -4.49913625358213 + refData[r,"ee_ref"]
       cte2 = 0.0000390108439044042 * load *(temp + 273.15) * time
         
        eeqq <- cte1 + cte2 + 32.3276108875090 * (cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])
        - 295.534521483766 * (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])
        - 12.1067270366917 * (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])
        - 66.2389259935735 * (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])
        + 794.286096493798 * (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])
        - 207.479742141609 * (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])
        - 1754.83723650373 * (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])
        - 1284.32408460585 * (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])
        - 21.5757084028704 * (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"])
                                                   
        AVGee = AVGee + eeqq 
     }
         
     AVGee = AVGee/nrow(refData)
     
    
     intermediateDf[nrow(intermediateDf) + 1,] = c(as.character(inputData[i,1]), refSol[j,1], AVGee, time, temp, load,  
                                                   as.character(inputData[i,2]), subs_Vvdw_All,
                                                   as.character(inputData[i,4]), prod_EA_Csat, prod_aPolar_HetNox,
                                                   as.character(inputData[i,6]), cat_Zv_Cuns, cat_Sae_HetNox, cat_aPolar_Cuns, cat_EA_HetNox,
                                                   as.character(refSol[j,1]), solv_Zv_Cuns,
                                                   as.character(inputData[i,10]), nuc_SAe_Het)
    }
  }
  
  if (scanElements == "cat")
  { 
    refCat = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Cat")
    
    colnames(finalDf) <- c("Reacction_pred", "Cat_Changed", "Time_pred", "Temp_pred", "Load_pred", "*ee(%)[R]_pred", "Structural Similarity Prob(%)",
                           "Reference","ee_ref","Subs_code_ref","Nuc_code_ref",
                           "Cat_Code_ref","Prod_Code_ref","dcat_ref", "Load_ref","Temp_ref","Time_ref",
                           "Smile_Prod_ref","Smile_Subs_ref","Smile_Nuc_ref", "Smile_Cat_ref")
    
    for (j in 1:nrow(refCat))
    {
      cat_Zv_Cuns = refCat[j,3]
      cat_Sae_HetNox = refCat[j,4]
      cat_aPolar_Cuns = refCat[j,5]
      cat_EA_HetNox = refCat[j,6]
      
      AVGee = 0
        
      for(r in 1:nrow(refData)){
          
      cte1 = -4.49913625358213 + refData[r,"ee_ref"]
      cte2 = 0.0000390108439044042 * load *(temp + 273.15) * time
      
      eeqq <- cte1 + cte2 + 32.3276108875090 * (cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])
          - 295.534521483766 * (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])
          - 12.1067270366917 * (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])
          - 66.2389259935735 * (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])
          + 794.286096493798 * (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])
          - 207.479742141609 * (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])
          - 1754.83723650373 * (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])
          - 1284.32408460585 * (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])
          - 21.5757084028704 * (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"])
          
          AVGee = AVGee + eeqq 
      }
      
      AVGee = AVGee/nrow(refData)
      
       intermediateDf[nrow(intermediateDf) + 1,] = c(as.character(inputData[i,1]), refCat[j,1], AVGee, time, temp, load, 
                                                    as.character(inputData[i,2]), subs_Vvdw_All,
                                                    as.character(inputData[i,4]), prod_EA_Csat, prod_aPolar_HetNox,
                                                    as.character(refCat[j,1]), cat_Zv_Cuns, cat_Sae_HetNox, cat_aPolar_Cuns, cat_EA_HetNox,
                                                    as.character(inputData[i,8]), solv_Zv_Cuns,
                                                    as.character(inputData[i,10]), nuc_SAe_Het)
    }
    
  }
  
  if (scanElements == "nuc")
  { 
    refNuc  = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Nuc")
    
    colnames(finalDf) <- c("Reacction_pred", "Nuc_Changed", "Time_pred", "Temp_pred", "Load_pred", "*ee(%)[R]_pred", "Structural Similarity Prob(%)",
                           "Reference","ee_ref","Subs_code_ref","Nuc_code_ref",
                           "Cat_Code_ref","Prod_Code_ref","dcat_ref", "Load_ref","Temp_ref","Time_ref",
                           "Smile_Prod_ref","Smile_Subs_ref","Smile_Nuc_ref", "Smile_Cat_ref")
    
    for (j in 1:nrow(refNuc))
    {
      nuc_SAe_Het = refNuc[j,3]
     
       AVGee = 0
       
        for(r in 1:nrow(refData)){
          
          cte1 = -4.49913625358213 + refData[r,"ee_ref"]
          cte2 = 0.0000390108439044042 * load *(temp + 273.15) * time
            
          eeqq <- cte1 + cte2 + 32.3276108875090 * (cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])
          - 295.534521483766 * (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])
          - 12.1067270366917 * (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])
          - 66.2389259935735 * (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])
          + 794.286096493798 * (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])
          - 207.479742141609 * (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])
          - 1754.83723650373 * (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])
          - 1284.32408460585 * (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])
          - 21.5757084028704 * (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"])
          
          AVGee = AVGee + eeqq 
        }
        
        AVGee = AVGee/nrow(refData)
        
        intermediateDf[nrow(intermediateDf) + 1,] = c(as.character(inputData[i,1]), refNuc[j,1], AVGee, time, temp, load, 
                                                      as.character(inputData[i,2]), subs_Vvdw_All,
                                                      as.character(inputData[i,4]), prod_EA_Csat, prod_aPolar_HetNox,
                                                      as.character(inputData[i,6]), cat_Zv_Cuns, cat_Sae_HetNox, cat_aPolar_Cuns, cat_EA_HetNox,
                                                      as.character(inputData[i,8]), solv_Zv_Cuns,
                                                      as.character(refNuc[j,1]), nuc_SAe_Het)
      }
  }
  
  if (scanElements == "sub")
  { 
    refSub = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Sub")
    
    colnames(finalDf) <- c("Reacction_pred", "Sub_Changed", "Time_pred", "Temp_pred", "Load_pred", "*ee(%)[R]_pred", "Structural Similarity Prob(%)",
                           "Reference","ee_ref","Subs_code_ref","Nuc_code_ref",
                           "Cat_Code_ref","Prod_Code_ref","dcat_ref", "Load_ref","Temp_ref","Time_ref",
                           "Smile_Prod_ref","Smile_Subs_ref","Smile_Nuc_ref", "Smile_Cat_ref")
    
    for (j in 1:nrow(refSub))
    {
      subs_Vvdw_All = refSub[j,3]
      
      AVGee = 0
        
        for(r in 1:nrow(refData)){
          
          cte1 = -4.49913625358213 + refData[r,"ee_ref"]
          cte2 = 0.0000390108439044042 * load *(temp + 273.15) * time
          
          eeqq <- cte1 + cte2 + 32.3276108875090 * (cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])
          - 295.534521483766 * (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])
          - 12.1067270366917 * (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])
          - 66.2389259935735 * (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])
          + 794.286096493798 * (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])
          - 207.479742141609 * (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])
          - 1754.83723650373 * (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])
          - 1284.32408460585 * (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])
          - 21.5757084028704 * (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"])
          
          AVGee = AVGee + eeqq 
        }
        
        AVGee = AVGee/nrow(refData)
        
        intermediateDf[nrow(intermediateDf) + 1,] = c(as.character(inputData[i,1]), refSub[j,1], AVGee, time, temp,load, 
                                                      as.character(refSub[j,1]), subs_Vvdw_All,
                                                      as.character(inputData[i,4]), prod_EA_Csat, prod_aPolar_HetNox,
                                                      as.character(inputData[i,6]), cat_Zv_Cuns, cat_Sae_HetNox, cat_aPolar_Cuns, cat_EA_HetNox,
                                                      as.character(inputData[j,8]), solv_Zv_Cuns,
                                                      as.character(inputData[i,10]), nuc_SAe_Het)
    }
  }
  
}



for(i in 1:nrow(intermediateDf)){
  
  # Call functions to calculate individual descriptors
  subs_Vvdw_All <- as.numeric(intermediateDf[i,8])
  
  prod_EA_Csat <- as.numeric(intermediateDf[i,10])
  prod_aPolar_HetNox <- as.numeric(intermediateDf[i,11])
  
  cat_Zv_Cuns <- as.numeric(intermediateDf[i,13])
  cat_Sae_HetNox <- as.numeric(intermediateDf[i,14])
  cat_aPolar_Cuns <- as.numeric(intermediateDf[i,15])
  cat_EA_HetNox <- as.numeric(intermediateDf[i,16])

  solv_Zv_Cuns <- as.numeric(intermediateDf[i,18])
  
  nuc_SAe_Het <- as.numeric(intermediateDf[i,20])
 
  
  # Compare values for each file from ref datasource  
  
  AVGee = 0
  
  for(r in 1:nrow(refData)){
    
      eeqq <- -4.49913625358213 + refData[r,"ee_ref"] + (0.0000390108439044042 * load *(temp + 273.15) * time
                                                       + 32.3276108875090 * (cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])
                                                       - 295.534521483766 * (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])
                                                       - 12.1067270366917 * (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])
                                                       - 66.2389259935735 * (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])
                                                       + 794.286096493798 * (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])
                                                       - 207.479742141609 * (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])
                                                       - 1754.83723650373 * (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])
                                                       - 1284.32408460585 * (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])
                                                       - 21.5757084028704 * (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"]))
    AVGee = AVGee + eeqq
    
  }

  AVGee = AVGee/nrow(refData)
  
  constante <- 32.3276108875090 * (cat_Zv_Cuns - refData[1,"Zv_Cuns_Cat_Mean_ref"])
  - 295.534521483766 * (prod_EA_Csat - refData[1,"EA_Csat_Prod_Mean_ref"])
  - 12.1067270366917 * (solv_Zv_Cuns - refData[1,"Zv_Cuns_Solv_Mean_ref"])
  - 66.2389259935735 * (nuc_SAe_Het - refData[1,"SAe_Het_Nuc_Mean_ref"])
  + 794.286096493798 * (cat_Sae_HetNox - refData[1,"SAe_HetNoX_Cat_Mean_ref"])
  - 207.479742141609 * (cat_aPolar_Cuns - refData[1,"aPolar_Cuns_Cat_Mean_ref"])
  - 1754.83723650373 * (cat_EA_HetNox - refData[1,"EA_HetNoX_Cat_Mean_ref"])
  - 1284.32408460585 * (prod_aPolar_HetNox - refData[1,"aPolar_HetNoX_Prod_Mean_ref"])
  - 21.5757084028704 * (subs_Vvdw_All - refData[1,"Vvdw_All_Sub_Mean_ref"])
  
  
  
  dist <- sqrt((cat_Zv_Cuns - refData[1,"Zv_Cuns_Cat_Mean_ref"])^2
               + (prod_EA_Csat - refData[1,"EA_Csat_Prod_Mean_ref"])^2
               + (solv_Zv_Cuns - refData[1,"Zv_Cuns_Solv_Mean_ref"])^2
               + (nuc_SAe_Het - refData[1,"SAe_Het_Nuc_Mean_ref"])^2
               + (cat_Sae_HetNox - refData[1,"SAe_HetNoX_Cat_Mean_ref"])^2
               + (cat_aPolar_Cuns - refData[1,"aPolar_Cuns_Cat_Mean_ref"])^2
               + (cat_EA_HetNox - refData[1,"EA_HetNoX_Cat_Mean_ref"])^2
               + (prod_aPolar_HetNox - refData[1,"aPolar_HetNoX_Prod_Mean_ref"])^2
               + (subs_Vvdw_All - refData[1,"Vvdw_All_Sub_Mean_ref"])^2)
  
  
  min0 <- abs((AVGee - refData[1,"ee_ref"]) + constante)
  
  distMin <- dist
  distMax <- dist
  
  minDfProp<-data.frame(refData[1,]) 
  
  minValue <- data.frame(distMin)
  maxValue <- data.frame(distMax)
  
  for(r2 in 2:nrow(refData)){
    
    
    constante <- 32.3276108875090 * (cat_Zv_Cuns - refData[r2,"Zv_Cuns_Cat_Mean_ref"])
    - 295.534521483766 * (prod_EA_Csat - refData[r2,"EA_Csat_Prod_Mean_ref"])
    - 12.1067270366917 * (solv_Zv_Cuns - refData[r2,"Zv_Cuns_Solv_Mean_ref"])
    - 66.2389259935735 * (nuc_SAe_Het - refData[r2,"SAe_Het_Nuc_Mean_ref"])
    + 794.286096493798 * (cat_Sae_HetNox - refData[r2,"SAe_HetNoX_Cat_Mean_ref"])
    - 207.479742141609 * (cat_aPolar_Cuns - refData[r2,"aPolar_Cuns_Cat_Mean_ref"])
    - 1754.83723650373 * (cat_EA_HetNox - refData[r2,"EA_HetNoX_Cat_Mean_ref"])
    - 1284.32408460585 * (prod_aPolar_HetNox - refData[r2,"aPolar_HetNoX_Prod_Mean_ref"])
    - 21.5757084028704 * (subs_Vvdw_All - refData[r2,"Vvdw_All_Sub_Mean_ref"])
    
    dist <- sqrt((cat_Zv_Cuns - refData[r2,"Zv_Cuns_Cat_Mean_ref"])^2
                 + (prod_EA_Csat - refData[r2,"EA_Csat_Prod_Mean_ref"])^2
                 + (solv_Zv_Cuns - refData[r2,"Zv_Cuns_Solv_Mean_ref"])^2
                 + (nuc_SAe_Het - refData[r2,"SAe_Het_Nuc_Mean_ref"])^2
                 + (cat_Sae_HetNox - refData[r2,"SAe_HetNoX_Cat_Mean_ref"])^2
                 + (cat_aPolar_Cuns - refData[r2,"aPolar_Cuns_Cat_Mean_ref"])^2
                 + (cat_EA_HetNox - refData[r2,"EA_HetNoX_Cat_Mean_ref"])^2
                 + (prod_aPolar_HetNox - refData[r2,"aPolar_HetNoX_Prod_Mean_ref"])^2
                 + (subs_Vvdw_All - refData[r2,"Vvdw_All_Sub_Mean_ref"])^2)
    
    min <- abs(AVGee - refData[r2,"ee_ref"] + constante)
    
    if (dist < distMin)
    {
      distMin = dist
      minValue <- data.frame(distMin)
    }
    
    if (dist > distMax)
    {
      distMax = dist
      maxValue <- data.frame(distMax)
    }
    
    similarityProb = (1-(distMin/distMax)) * 100;
    
    
    if (min == min0)
    {
      minDfProp[nrow(minDfProp) + 1,]<-data.frame(refData[r2,])
      minValue[nrow(minValue) + 1,]<-data.frame(similarityProb)
    }
    else
    {
      if (min < min0)
      {
        min0 <- min
        minDfProp<-data.frame(refData[r2,]) 
        minValue<-data.frame(similarityProb)
        
      }
    }
  }
  
  
  minDfProp <- cbind(minDfProp, minValue)
  
  if (nrow(minDfProp) > 1)
  {
    minDfVars<-data.frame(minDfProp[1,]) 
    
    min1 <- sqrt((load-minDfProp[1,"Load"])^2 + 
                   (time-minDfProp[1,"Time"])^2 + (temp-minDfProp[1,"Temp"])^2)
    
    
    for(d in 2:nrow(minDfProp)){
      
      min2 <- sqrt((load-minDfProp[d,"Load"])^2 + 
                     (time-minDfProp[d,"Time"])^2 + 
                     (temp-minDfProp[d,"Temp"])^2)
      
      if (min1 == min2)
      {
        minDfVars[nrow(minDfVars) + 1,]<-data.frame(minDfProp[d,])
      }
      else
      {
        if (min2 < min1)
        {
          min1 <- min2
          minDfVars<-data.frame(minDfProp[d,])  
         
        }
      }
     
    }
    
    if (nrow(minDfVars) > 1)
    {
       
      for(p in 1:nrow(minDfVars)){
        
        
        finalDf[nrow(finalDf) + 1,] = c(as.character(intermediateDf[i,1]), as.character(intermediateDf[i,2]),
                                        time, temp, load, round(AVGee, digits = 1), minDfVars[p,29],
                                        minDfVars[p,2],minDfVars[p,3],minDfVars[p,5],minDfVars[p,6],
                                        minDfVars[p,7],minDfVars[p,8],minDfVars[p,9],minDfVars[p,10],minDfVars[p,11],
                                        minDfVars[p,12],minDfVars[p,14],minDfVars[p,15],
                                        minDfVars[p,17],minDfVars[p,19])
      }
      
    }
    else
    {
       
      
      finalDf[nrow(finalDf) + 1,] = c(as.character(intermediateDf[i,1]), as.character(intermediateDf[i,2]),
                                      time, temp, load, round(AVGee, digits = 1), minDfVars[1,29],
                                      minDfVars[1,2],minDfVars[1,3],minDfVars[1,5],minDfVars[1,6],
                                      minDfVars[1,7],minDfVars[1,8],minDfVars[1,9],minDfVars[1,10],minDfVars[1,11],
                                      minDfVars[1,12],minDfVars[1,14],minDfVars[1,15],
                                      minDfVars[1,17], minDfVars[1,19])
    }
  }
  else
  {
     finalDf[nrow(finalDf) + 1,] = c(as.character(intermediateDf[i,1]), as.character(intermediateDf[i,2]),
                                    time, temp, load, round(AVGee, digits = 1),  minDfProp[1,29],
                                    minDfProp[1,2],minDfProp[1,3],minDfProp[1,5],minDfProp[1,6],
                                    minDfProp[1,7],minDfProp[1,8],minDfProp[1,9],minDfProp[1,10],minDfProp[1,11],
                                    minDfProp[1,12],minDfProp[1,14],minDfProp[1,15],
                                    minDfProp[1,17], minDfProp[1,19])
  }
  
 
}

write.table(finalDf, resultFile, sep=";", quote = FALSE, row.names = FALSE)



  
  
