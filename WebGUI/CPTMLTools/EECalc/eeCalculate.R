library(ChemmineR)
library(base)
library(expm)
library(MASS)
library(openxlsx)

source("F:/CPTMLTools/EECalc/RMarkovTI_functions_VPCR.R")

args <- commandArgs(TRUE)

fileInput = args[1]
resultFile = args[2]

minTime = as.numeric(args[3])
maxTime = as.numeric(args[4])
stepTime = as.numeric(args[5])

minTemp = as.numeric(args[6])
maxTemp = as.numeric(args[7])
stepTemp = as.numeric(args[8])

minLoad = as.numeric(args[9])
maxLoad = as.numeric(args[10])
stepLoad = as.numeric(args[11])

quiral = as.numeric(args[12])

refData = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "All")

inputData=read.table(fileInput,header=T, sep=",")

  finalDf <- data.frame(matrix(ncol = 5, nrow = 0))
  
  colnames(finalDf) <- c("Reacction","*ee(%)[R]", "Time", "Temp", "Load")
  
  print(inputData[2,6])
  print(inputData[2,7])
  
  for(i in 1:nrow(inputData)){
    
    # Call functions to calculate individual descriptors
    subs_Vvdw_All <- calculateDescriptor("Zv,EA,aPolar,SAe","All", inputData[i,3])
    
    prod_EA_Csat <- calculateDescriptor("Zv,aPolar,Vvdw,SAe","Csat", inputData[i,5])
    prod_aPolar_HetNox <- calculateDescriptor("Zv,EA,Vvdw,SAe","HetNoX", inputData[i,5])
    
    cat_Zv_Cuns <- calculateDescriptor("EA,aPolar,Vvdw,SAe","Cuns", inputData[i,7])
    cat_Sae_HetNox <- calculateDescriptor("Zv,EA,aPolar,Vvdw","HetNoX", inputData[i,7])
    cat_aPolar_Cuns <- calculateDescriptor("Zv,EA,Vvdw,SAe","Cuns", inputData[i,7])
    cat_EA_HetNox <- calculateDescriptor("Zv,aPolar,Vvdw,SAe","HetNoX", inputData[i,7])
    
    solv_Zv_Cuns <- calculateDescriptor("EA,aPolar,Vvdw,SAe","Cuns", inputData[i,9])
    
    nuc_SAe_Het <- calculateDescriptor("Zv,EA,aPolar,Vvdw","Het", inputData[i,11])
 
    
    minDist = sqrt((cat_Zv_Cuns - refData[r2,"Zv_Cuns_Cat_Mean_ref"])^2
                      + (prod_EA_Csat - refData[r2,"EA_Csat_Prod_Mean_ref"])^2
                      + (solv_Zv_Cuns - refData[r2,"Zv_Cuns_Solv_Mean_ref"])^2
                      + (nuc_SAe_Het - refData[r2,"SAe_Het_Nuc_Mean_ref"])^2
                      + (cat_Sae_HetNox - refData[r2,"SAe_HetNoX_Cat_Mean_ref"])^2
                      + (cat_aPolar_Cuns - refData[r2,"aPolar_Cuns_Cat_Mean_ref"])^2
                      + (cat_EA_HetNox - refData[r2,"EA_HetNoX_Cat_Mean_ref"])^2
                      + (prod_aPolar_HetNox - refData[r2,"aPolar_HetNoX_Prod_Mean_ref"])^2
                      + (subs_Vvdw_All - refData[r2,"Vvdw_All_Sub_Mean_ref"])^2)
    
    reaRef = 1
    
    for(r in 1:nrow(refData)){
    
      
      dist <- sqrt((cat_Zv_Cuns - refData[r2,"Zv_Cuns_Cat_Mean_ref"])^2
                   + (prod_EA_Csat - refData[r2,"EA_Csat_Prod_Mean_ref"])^2
                   + (solv_Zv_Cuns - refData[r2,"Zv_Cuns_Solv_Mean_ref"])^2
                   + (nuc_SAe_Het - refData[r2,"SAe_Het_Nuc_Mean_ref"])^2
                   + (cat_Sae_HetNox - refData[r2,"SAe_HetNoX_Cat_Mean_ref"])^2
                   + (cat_aPolar_Cuns - refData[r2,"aPolar_Cuns_Cat_Mean_ref"])^2
                   + (cat_EA_HetNox - refData[r2,"EA_HetNoX_Cat_Mean_ref"])^2
                   + (prod_aPolar_HetNox - refData[r2,"aPolar_HetNoX_Prod_Mean_ref"])^2
                   + (subs_Vvdw_All - refData[r2,"Vvdw_All_Sub_Mean_ref"])^2)
      
      
      if (minDist > dist)
      {
        minDist = dist
        reaRef = r
      }
      
    }
    
    # Compare values for each file from ref datasource  
    
    for(time in seq(from=minTime, to=maxTime, by=stepTime)){
      
      for(temp in seq(from=minTemp, to=maxTemp, by=stepTemp)){
        
        for(load in seq(from=minLoad, to=maxLoad, by=stepLoad)){
          
          
          eeqq <- -0.914038918667643 + refData[reaRef,"ee_ref"] - 0.821032133512764 * (load-minDfProp[reaRef,"Load"]) 
                                                                - 0.343919121414324 * (temp-minDfProp[reaRef,"Temp"])
                                                                + 0.211791266990752 * (time-minDfProp[reaRef,"Time"])
                                                                + 22.0406704292748 * (cat_Zv_Cuns - refData[reaRef,"Zv_Cuns_Cat_Mean_ref"])
                                                                - 215.982019256065 * (prod_EA_Csat - refData[reaRef,"EA_Csat_Prod_Mean_ref"])
                                                                - 12.4578151202493 * (solv_Zv_Cuns - refData[reaRef,"Zv_Cuns_Solv_Mean_ref"])
                                                                - 42.4863067259439 * (nuc_SAe_Het - refData[reaRef,"SAe_Het_Nuc_Mean_ref"])
                                                                + 750.757360483937 * (cat_Sae_HetNox - refData[reaRef,"SAe_HetNoX_Cat_Mean_ref"])
                                                                - 174.368536901798 * (cat_aPolar_Cuns - refData[reaRef,"aPolar_Cuns_Cat_Mean_ref"])
                                                                - 1747.11691314115 * (cat_EA_HetNox - refData[reaRef,"EA_HetNoX_Cat_Mean_ref"])
                                                                - 1534.17019704508 * (prod_aPolar_HetNox - refData[reaRef,"aPolar_HetNoX_Prod_Mean_ref"])
                                                                - 34.1870137382133 * (subs_Vvdw_All - refData[reaRef,"Vvdw_All_Sub_Mean_ref"])
          
          
          
              
          finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), round(AVGee, digits=1), time, temp, load)
        }
      }
    }
  }
  
  write.table(finalDf, resultFile, sep=";", row.names=FALSE,  quote = TRUE)
  

