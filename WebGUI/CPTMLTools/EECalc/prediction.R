library(ChemmineR)
library(base)
library(expm)
library(MASS)
library(openxlsx)

source("F:/CPTMLTools/EECalc/RMarkovTI_functions_VPCR.R")
args <- commandArgs(TRUE)

fileInput = args[1]
resultFile = args[2]

time = as.numeric(args[3])
temp = as.numeric(args[4])
load = as.numeric(args[5])


refData = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "All")

inputData=read.table(fileInput, header=T, sep=",")

finalDf <- data.frame(matrix(ncol = 20, nrow = 0))


colnames(finalDf) <- c("Reacction_query", "Time_query", "Temp_query", "Load_query","*ee(%)[R]_query", "Structural Similarity Prob(%)",
                       "Reference","ee_ref","Subs_code_ref","Nuc_code_ref",
                       "Cat_Code_ref","Prod_Code_ref","dcat_ref", "Load_ref","Temp_ref","Time_ref",
                       "Smile_Prod_ref","Smile_Subs_ref","Smile_Nuc_ref", "Smile_cat_ref")

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
  
  minDfProp<-data.frame(refData[1,]) 
  
  minDistProp = sqrt((cat_Zv_Cuns - refData[1,"Zv_Cuns_Cat_Mean_ref"])^2
                     + (prod_EA_Csat - refData[1,"EA_Csat_Prod_Mean_ref"])^2
                     + (solv_Zv_Cuns - refData[1,"Zv_Cuns_Solv_Mean_ref"])^2
                     + (nuc_SAe_Het - refData[1,"SAe_Het_Nuc_Mean_ref"])^2
                     + (cat_Sae_HetNox - refData[1,"SAe_HetNoX_Cat_Mean_ref"])^2
                     + (cat_aPolar_Cuns - refData[1,"aPolar_Cuns_Cat_Mean_ref"])^2
                     + (cat_EA_HetNox - refData[1,"EA_HetNoX_Cat_Mean_ref"])^2
                     + (prod_aPolar_HetNox - refData[1,"aPolar_HetNoX_Prod_Mean_ref"])^2
                     + (subs_Vvdw_All - refData[1,"Vvdw_All_Sub_Mean_ref"])^2)
  
    minDfPropFrame<-data.frame(minDistProp)
  

    for(r in 2:nrow(refData)){
    
    distProp <- sqrt((cat_Zv_Cuns - refData[r,"Zv_Cuns_Cat_Mean_ref"])^2
                     + (prod_EA_Csat - refData[r,"EA_Csat_Prod_Mean_ref"])^2
                     + (solv_Zv_Cuns - refData[r,"Zv_Cuns_Solv_Mean_ref"])^2
                     + (nuc_SAe_Het - refData[r,"SAe_Het_Nuc_Mean_ref"])^2
                     + (cat_Sae_HetNox - refData[r,"SAe_HetNoX_Cat_Mean_ref"])^2
                     + (cat_aPolar_Cuns - refData[r,"aPolar_Cuns_Cat_Mean_ref"])^2
                     + (cat_EA_HetNox - refData[r,"EA_HetNoX_Cat_Mean_ref"])^2
                     + (prod_aPolar_HetNox - refData[r,"aPolar_HetNoX_Prod_Mean_ref"])^2
                     + (subs_Vvdw_All - refData[r,"Vvdw_All_Sub_Mean_ref"])^2)
    
    if (distProp == minDistProp)
    {
      minDfProp[nrow(minDfProp) + 1,]<-data.frame(refData[r,])
      minDfPropFrame[nrow(minDfPropFrame) + 1,]<-data.frame(minDistProp)
    }
    else
    {
      if (distProp < minDistProp)
      {
        minDfPropFrame<-data.frame(distProp)
        minDfProp<-data.frame(refData[r,])
      }
    }
  }
  

  
  if (nrow(minDfProp) < 2)
  {
    
    eeqq <- -0.914038918667643 + minDfProp[1,"ee_ref"] - 0.821032133512764 * (load-minDfProp[1,"Load"]) 
    - 0.343919121414324 * (temp-minDfProp[1,"Temp"])
    + 0.211791266990752 * (time-minDfProp[1,"Time"])
    + 22.0406704292748 * (cat_Zv_Cuns - minDfProp[1,"Zv_Cuns_Cat_Mean_ref"])
    - 215.982019256065 * (prod_EA_Csat - minDfProp[1,"EA_Csat_Prod_Mean_ref"])
    - 12.4578151202493 * (solv_Zv_Cuns - minDfProp[1,"Zv_Cuns_Solv_Mean_ref"])
    - 42.4863067259439 * (nuc_SAe_Het - minDfProp[1,"SAe_Het_Nuc_Mean_ref"])
    + 750.757360483937 * (cat_Sae_HetNox - minDfProp[1,"SAe_HetNoX_Cat_Mean_ref"])
    - 174.368536901798 * (cat_aPolar_Cuns - minDfProp[1,"aPolar_Cuns_Cat_Mean_ref"])
    - 1747.11691314115 * (cat_EA_HetNox - minDfProp[1,"EA_HetNoX_Cat_Mean_ref"])
    - 1534.17019704508 * (prod_aPolar_HetNox - minDfProp[1,"aPolar_HetNoX_Prod_Mean_ref"])
    - 34.1870137382133 * (subs_Vvdw_All - minDfProp[1,"Vvdw_All_Sub_Mean_ref"])
    
    if (eeqq > 100)
    {
      eeqq <- 99
    }
    
    if (eeqq < -100)
    {
      eeqq <- -99
    }
    
    
    similarityProb = 100/(minDfPropFrame[1,]+1);
    
      
    finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), time, temp, load,
                                    round(eeqq, digits=1), round(similarityProb, digits=1),
                                    minDfProp[1,2],minDfProp[1,3],minDfProp[1,5],minDfProp[1,6],
                                    minDfProp[1,7],minDfProp[1,8],minDfProp[1,9],minDfProp[1,10],minDfProp[1,11],
                                    minDfProp[1,12],minDfProp[1,14],minDfProp[1,15],
                                    minDfProp[1,17], minDfProp[1,19])
    
  }else
  {
 
    minDistVars = sqrt((load-minDfProp[1,"Load"])^2 + 
                         (time-minDfProp[1,"Time"])^2 + (temp-minDfProp[1,"Temp"])^2)
    
    minDVars<-data.frame(minDfProp[1,])
    minDfVarsFrame<-data.frame(minDistVars)
    

    for(m in 1:nrow(minDfProp)){
      
      distVars = sqrt((load-minDfProp[m,"Load"])^2 + 
                        (time-minDfProp[m,"Time"])^2 + (temp-minDfProp[m,"Temp"])^2)
      
      
      if (distVars == minDistVars)
      {
        minDVars[nrow(minDVars) + 1,]<-data.frame(minDfProp[m,])
        minDfVarsFrame[nrow(minDfVarsFrame) + 1,]<-data.frame(minDistVars[m,])
        
      }else
      {
        if (distVars < minDistVars)
        {
          minDVars<-data.frame(distVars)
          minDistVars<-data.frame(minDfProp[m,])
        }
      }
      
    }
    
    for(f in 1:nrow(minDVars)){
      
       similarityProb = 100/(minDfVarsFrame[1,]+1);
      
      eeqq <- -0.914038918667643 + minDVars[f,"ee_ref"] - 0.821032133512764 * (load-minDVars[f,"Load"]) 
      - 0.343919121414324 * (temp-minDVars[f,"Temp"])
      + 0.211791266990752 * (time-minDVars[f,"Time"])
      + 22.0406704292748 * (cat_Zv_Cuns - minDVars[f,"Zv_Cuns_Cat_Mean_ref"])
      - 215.982019256065 * (prod_EA_Csat - minDVars[f,"EA_Csat_Prod_Mean_ref"])
      - 12.4578151202493 * (solv_Zv_Cuns - minDVars[f,"Zv_Cuns_Solv_Mean_ref"])
      - 42.4863067259439 * (nuc_SAe_Het - minDVars[f,"SAe_Het_Nuc_Mean_ref"])
      + 750.757360483937 * (cat_Sae_HetNox - minDVars[f,"SAe_HetNoX_Cat_Mean_ref"])
      - 174.368536901798 * (cat_aPolar_Cuns - minDVars[f,"aPolar_Cuns_Cat_Mean_ref"])
      - 1747.11691314115 * (cat_EA_HetNox - minDVars[f,"EA_HetNoX_Cat_Mean_ref"])
      - 1534.17019704508 * (prod_aPolar_HetNox - minDVars[f,"aPolar_HetNoX_Prod_Mean_ref"])
      - 34.1870137382133 * (subs_Vvdw_All - minDVars[f,"Vvdw_All_Sub_Mean_ref"])
      
      if (eeqq > 100)
      {
        eeqq <- 99
      }
      
      if (eeqq < -100)
      {
        eeqq <- -99
      }
      
      
      finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), time, temp, load,
                                      round(eeqq, digits=1), round(similarityProb, digits=1),
                                      minDVars[f,2],minDVars[f,3],minDVars[f,5],minDVars[f,6],
                                      minDVars[f,7],minDVars[f,8],minDVars[f,9],minDVars[f,10],minDVars[f,11],
                                      minDVars[f,12],minDVars[f,14],minDVars[f,15],
                                      minDVars[f,17], minDVars[f,19])
      
    }
    

    
  }

}


write.table(finalDf, resultFile, sep=";", quote = FALSE, row.names=FALSE)  









