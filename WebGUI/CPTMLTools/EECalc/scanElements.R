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

finalDf <- data.frame(matrix(ncol = 6, nrow = 0))

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
  
  if (AVGee > 100)
  {
    AVGee = 99
  }
  
  if (AVGee < -100)
  {
    AVGee = -99
  }
  
  colnames(finalDf) <- c("Reacction", "Changed","*ee(%)[R]", "Time", "Temp", "Load")
  
  finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), "--", round(AVGee, digits=1), time, temp, load)
  
 
  if (scanElements == "sol")
  { 
     refSol = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Sol")
    
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
     
     
     if (AVGee > 100)
     {
       AVGee = 99
     }
     
     if (AVGee < -100)
     {
       AVGee = -99
     }
     
     colnames(finalDf) <- c("Reacction", "Solv_Changed","*ee(%)[R]", "Time", "Temp", "Load")
     
     finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), refSol[j,1], round(AVGee, digits=1), time, temp, load)
     
  
    }
  }
  
  if (scanElements == "cat")
  { 
    refCat = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Cat")
    
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
      
      if (AVGee > 100)
      {
        AVGee = 99
      }
      
      if (AVGee < -100)
      {
        AVGee = -99
      }
      
      colnames(finalDf) <- c("Reacction", "Cat_Changed","*ee(%)[R]", "Time", "Temp", "Load")
      
      finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), refCat[j,1], round(AVGee, digits=1), time, temp, load)
      
      
   }
    
  }
  
  if (scanElements == "nuc")
  { 
    refNuc  = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Nuc")
    
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
        
        if (AVGee > 100)
        {
          AVGee = 99
        }
        
        if (AVGee < -100)
        {
          AVGee = -99
        }
        
        colnames(finalDf) <- c("Reacction", "Nuc_Changed","*ee(%)[R]", "Time", "Temp", "Load")
        
        finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), refNuc[j,1], round(AVGee, digits=1), time, temp, load)
        
        
        }
  }
  
  if (scanElements == "sub")
  { 
    refSub = read.xlsx("F:/CPTMLTools/EECalc/RefRecctions.xlsx", sheet = "Sub")
    
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
        
        if (AVGee > 100)
        {
          AVGee = 99
        }
        
        if (AVGee < -100)
        {
          AVGee = -99
        }
        
        colnames(finalDf) <- c("Reacction", "Sub_Changed","*ee(%)[R]", "Time", "Temp", "Load")
        
        finalDf[nrow(finalDf) + 1,] = c(as.character(inputData[i,1]), refSub[j,1], round(AVGee, digits=1), time, temp, load)
        
       }
  }
  
}


write.table(finalDf, resultFile, sep=";", quote = FALSE, row.names = FALSE)



  
  
