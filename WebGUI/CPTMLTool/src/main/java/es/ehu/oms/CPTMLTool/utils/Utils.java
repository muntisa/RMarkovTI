package es.ehu.oms.CPTMLTool.utils;


import java.util.Random;

import es.ehu.oms.CPTMLTool.model.EEParams;
import es.ehu.oms.CPTMLTool.model.MMDParams;

public class Utils {
	
	public String randomNameFile()
	{
		String cadenaAleatoria = "";
		long milis = new java.util.GregorianCalendar().getTimeInMillis();
		Random r = new Random(milis);
		
		int i = 0;
		while ( i < 11){
			char c = (char)r.nextInt(255);
			if ( (c >= '0' && c <='9') || (c >='A' && c <='Z') ){
				cadenaAleatoria += c;
				i ++;
			}
		}
		
		return cadenaAleatoria;
	}
	
	public String getElementScan(boolean scanCat, boolean scanSol, boolean scanNuc, boolean scanSub)
	{
		String elementScan = "";
		
		if (scanCat)
		{
			elementScan ="cat";
		}
		else
		{		
			if (scanSol)
			{
				elementScan ="sol";
			}
			else
			{			
				if (scanNuc)
				{
					elementScan ="nuc";
				}
				else {									
					if (scanSub)
					{
						elementScan ="sub";
					}
					else
					{
						elementScan = "none";
					}
				}
			}
		}
		return elementScan;
	}
	

	
	public String atomProperties(MMDParams parameters)
	{
		String atomPropertiesUnselected = " ";
		
				
		if (!parameters.isaPolar())
		{
			atomPropertiesUnselected = atomPropertiesUnselected + "aPolar,";
		}
		
		if (!parameters.isEa())
		{
			atomPropertiesUnselected = atomPropertiesUnselected + "EA,";
		}
		
		if (!parameters.isSae())
		{
			atomPropertiesUnselected = atomPropertiesUnselected + "SAe,";
		}
		
		if (!parameters.isVvdw())
		{
			atomPropertiesUnselected = atomPropertiesUnselected + "Vvdw,";
		}
		
		if (!parameters.isZv())
		{
			atomPropertiesUnselected = atomPropertiesUnselected + "Zv,";
		}
		
		if ((parameters.isaPolar() && (parameters.isEa()) && (parameters.isSae()) && (parameters.isVvdw())
				&& (parameters.isZv())) || (parameters.isNoneAtProp()))
		{
			atomPropertiesUnselected =  " none,"; 
		}
		
		String atomPropertiesUnselectedFinal = atomPropertiesUnselected.substring(0, atomPropertiesUnselected.length()-1);
		
			
		return atomPropertiesUnselectedFinal;
	}
	
	public String atomTypes(MMDParams parameters)
	{
		String atomTypesSelected = "";
		
		if (parameters.isAllAtoms())
		{
			atomTypesSelected = atomTypesSelected +"All,";
					
		}
		
		if (parameters.iscSat())
		{
			atomTypesSelected = atomTypesSelected +"Csat,";
					
		}
		
		if (parameters.iscUns())
		{
			atomTypesSelected = atomTypesSelected +"Cuns,";
					
		}
		
		if (parameters.isHal())
		{
			atomTypesSelected = atomTypesSelected +"Hal,";
					
		}
		
		if (parameters.isHet())
		{
			atomTypesSelected = atomTypesSelected +"Het,";
					
		}
		
		if (parameters.isHetNoX())
		{
			atomTypesSelected = atomTypesSelected +"HetNoX,";
					
		}
		
		String atomTypesSelectedFinal = atomTypesSelected.substring(0, atomTypesSelected.length()-1);
	
		return atomTypesSelectedFinal;
	}

}
