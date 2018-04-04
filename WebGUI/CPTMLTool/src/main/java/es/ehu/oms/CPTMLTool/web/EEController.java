
package es.ehu.oms.CPTMLTool.web;


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import es.ehu.oms.CPTMLTool.model.EEParams;
import es.ehu.oms.CPTMLTool.model.Passwords;
import es.ehu.oms.CPTMLTool.utils.Utils;

@Controller
public class EEController {
		
	private static String FILE_NAME = "";
	
	 @RequestMapping(value = "pwdMateo")
	 public String loginMateo(@ModelAttribute("pwdMateo") String pwdMateo, Model model) {
		 
		 if (pwdMateo.equals("CPTMLTools"))
		 {
			 return "redirect:/mateo";
		 }
		 else
		 {
			 model.addAttribute("pwdMateoError", "Password Incorrect");
			 model.addAttribute("pwd", new Passwords());
			 return "index";
		 }
	 }
	
	 
	 @RequestMapping(value = "calculateEE")
	 public String calculateEE(@ModelAttribute("parametersEE") EEParams parametersEE,
			 @RequestParam("fileToUpload") MultipartFile file, Model model, HttpServletRequest request) {	
			 
		 	String UPLOADED_FOLDER = request.getServletContext().getRealPath("/files/EE/uploadedFolder/"); 	
		 	String RESULT_FOLDER =  request.getServletContext().getRealPath("/files/EE/resultFolder/");
		 	String urlEE = "";
		 	
		 	String urlfinal = "";

		 
		 	long size = 0;
		 	int lines = 0;
		 	Utils utils = new Utils();		
			FILE_NAME = utils.randomNameFile()+".csv";
		
			try{			
					
				if (file.getSize() != 0)
				{	
					byte[] bytes = file.getBytes();
				    Path path = Paths.get(UPLOADED_FOLDER + FILE_NAME);
				    
				    Files.write(path, bytes);
		            
				    BufferedReader reader = new BufferedReader(new FileReader(UPLOADED_FOLDER + FILE_NAME));
					
					while (reader.readLine() != null) 
					{
						lines++;
					}	
					
					reader.close();	
					
				}
				else
				{
					PrintWriter writer = new PrintWriter(UPLOADED_FOLDER+FILE_NAME, "UTF-8");					
						
					if (parametersEE.isScanCat())
					{
						writer.println("Reaction;Subs;SubsSmile;Prod;ProdSmile;Solv;SolvSmile;Nuc;NucSmile");
						
						writer.println("Reaction;"+parametersEE.getContentSubs()+";"+
								parametersEE.getContentProd()+";"+parametersEE.getContentSolv()+";"+parametersEE.getContentNuc());
					}
					else
					{
						if (parametersEE.isScanNuc())
						{
							writer.println("Reaction;Subs;SubsSmile;Prod;ProdSmile;Cat;CatSmile;Solv;SolvSmile");
							
							writer.println("Reaction;"+parametersEE.getContentSubs()+";"+
									parametersEE.getContentProd()+";"+parametersEE.getContentCat()+";"+
									parametersEE.getContentSolv());
						}
						else
						{
							if (parametersEE.isScanSol())
							{
								writer.println("Reaction;Subs;SubsSmile;Prod;ProdSmile;Cat;CatSmile;Nuc;NucSmile");
								
								writer.println("Reaction;"+parametersEE.getContentSubs()+";"+
										parametersEE.getContentProd()+";"+parametersEE.getContentCat()+";"+
										parametersEE.getContentNuc());
							}
							else
							{
								if (parametersEE.isScanSub())
								{
									writer.println("Reaction;Prod;ProdSmile;Cat;CatSmile;Solv;SolvSmile;Nuc;NucSmile");
									
									writer.println("Reaction;"+
											parametersEE.getContentProd()+";"+parametersEE.getContentCat()+";"+
											parametersEE.getContentSolv()+";"+parametersEE.getContentNuc());
								
								}
								else
								{
									writer.println("Reaction;Subs;SubsSmile;Prod;ProdSmile;Cat;CatSmile;Solv;SolvSmile;Nuc;NucSmile");
									
									writer.println("Reaction;"+parametersEE.getContentSubs()+";"+
											parametersEE.getContentProd()+";"+parametersEE.getContentCat()+";"+
											parametersEE.getContentSolv()+";"+parametersEE.getContentNuc());
								
								}
							}
						}
					}					
					
					writer.close();				
				}
				
				if ((parametersEE.isScanCat()) || (parametersEE.isScanNuc()) || (parametersEE.isScanSol()) || (parametersEE.isScanSub()))
				{					
				
				
					String elementSelected = utils.getElementScan(parametersEE.isScanCat(),parametersEE.isScanSol(), parametersEE.isScanNuc(), parametersEE.isScanSub());
					
					if (parametersEE.isPredict())
					{
						
						if (parametersEE.isScanCat())
						{
							size = file.getSize()/3;
						}
						
						if (parametersEE.isScanNuc())
						{
							size = file.getSize()/5;
						}
						
						if (parametersEE.isScanSol())
						{
							size = file.getSize()/5;
						}
						
						if (parametersEE.isScanSub())
						{
							size = file.getSize()/3;
						}				
						
						Runtime.getRuntime().exec("Rscript F://CPTMLTools/EECalc/scanElementsPredict.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+elementSelected+"_"+FILE_NAME+" "+
								elementSelected+" "+parametersEE.getTime()+" "+parametersEE.getTemp()+" "+parametersEE.getLoad());	
						
						String paula = "Rscript F://CPTMLTools/EECalc/scanElementsPredict.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+elementSelected+"_"+FILE_NAME+" "+
								elementSelected+" "+parametersEE.getTime()+" "+parametersEE.getTemp()+" "+parametersEE.getLoad();
						
						model.addAttribute("paula", paula);
						
					}
					else
					{
						size = file.getSize()/7;
						
						Runtime.getRuntime().exec("Rscript F://CPTMLTools/EECalc/scanElements.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+elementSelected+"_"+FILE_NAME+" "+
								elementSelected+" "+parametersEE.getTime()+" "+parametersEE.getTemp()+" "+parametersEE.getLoad());	
						
						String paula = "Rscript F://CPTMLTools/EECalc/scanElements.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+elementSelected+"_"+FILE_NAME+" "+
								elementSelected+" "+parametersEE.getTime()+" "+parametersEE.getTemp()+" "+parametersEE.getLoad();
						
						model.addAttribute("paula", paula);
							
					}
					
							model.addAttribute("time", size);
					
					urlEE = "EE_"+elementSelected+"_"+FILE_NAME;
					
					urlfinal = "resultsEE";
					
				}
				else
				{
					if (parametersEE.isScanVars())
					{
					
						double minTime = parametersEE.getMinTime();
						double maxTime = parametersEE.getMaxTime();
						double stepTime = parametersEE.getStepTime();
						
						double minTemp = parametersEE.getMinTemp();
						double maxTemp = parametersEE.getMaxTemp();
						double stepTemp = parametersEE.getStepTemp();
						
						double minLoad = parametersEE.getMinLoad();
						double maxLoad = parametersEE.getMaxLoad();
						double stepLoad = parametersEE.getStepLoad();
						
						size = file.getSize()/5;
						double it = ((maxTime - minTime)/stepTime + (maxTemp - minTemp)/stepTemp + (maxLoad - minLoad)/stepLoad);
						
							Runtime.getRuntime().exec("Rscript F://CPTMLTools/EECalc/eeCalculate.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+FILE_NAME+" "+
								minTime+" "+maxTime+" "+stepTime+" "+minTemp+" "+maxTemp+" "+stepTemp+" "+minLoad+" "+maxLoad+" "+stepLoad+" "+
								parametersEE.getQuiral());	
					
							String paula = "Rscript F://CPTMLTools/EECalc/eeCalculate.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+FILE_NAME+" "+
									minTime+" "+maxTime+" "+stepTime+" "+minTemp+" "+maxTemp+" "+stepTemp+" "+minLoad+" "+maxLoad+" "+stepLoad+" "+
									parametersEE.getQuiral();
								
							model.addAttribute("paula", paula);
							
							urlEE="EE_"+FILE_NAME;
						
						
						model.addAttribute("time", size * it/7);
						urlfinal = "resultsEE";
						
					}
					else
					{
			
						if (parametersEE.isPredict())
						{
							Runtime.getRuntime().exec("Rscript F://CPTMLTools/EECalc/prediction.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_PREDIC_"+FILE_NAME+" "+
									parametersEE.getTime()+" "+parametersEE.getTemp()+" "+parametersEE.getLoad());	
						
								String paula = "Rscript F://CPTMLTools/EECalc/prediction.R  "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_PREDIC_"+FILE_NAME+" "+
										parametersEE.getTime()+" "+parametersEE.getTemp()+" "+parametersEE.getLoad();
								
								System.out.println(paula);
									
								model.addAttribute("paula", paula);
								model.addAttribute("time", file.getSize()/15);
								
								urlEE = "EE_PREDIC_"+FILE_NAME;
								urlfinal = "resultsEEImages";
						
						}
						else
						{
							Runtime.getRuntime().exec("Rscript F://CPTMLTools/EECalc/eeCalculate.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+FILE_NAME+" "+
									parametersEE.getTime()+" "+parametersEE.getTime()+" "+0+" "+
									parametersEE.getTemp()+" "+parametersEE.getTemp()+" "+0+" "+
									parametersEE.getLoad()+" "+parametersEE.getLoad()+" "+0+" "+
									parametersEE.getQuiral());
							
							String paula = "Rscript F://CPTMLTools/EECalc/eeCalculate.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"EE_"+FILE_NAME+" "+
									parametersEE.getTime()+" "+parametersEE.getTime()+" "+0+" "+
									parametersEE.getTemp()+" "+parametersEE.getTemp()+" "+0+" "+
									parametersEE.getLoad()+" "+parametersEE.getLoad()+" "+0+" "+
									parametersEE.getQuiral();
							
							model.addAttribute("paula", paula);
							model.addAttribute("time", file.getSize()/15);
							
							urlEE="EE_"+FILE_NAME;
							urlfinal = "resultsEE";
							
								
						}
						
						
					}
					
				}
			
				model.addAttribute("server", "EE");
				model.addAttribute("fileName", FILE_NAME);
				model.addAttribute("urlEE", urlEE);
				model.addAttribute("intermedio", urlEE+"_INTER.csv");
				
					
			} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
			} 
			
		 return urlfinal;
	}
	 
	
	 
}
