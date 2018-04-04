package es.ehu.oms.CPTMLTool.web;

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

import es.ehu.oms.CPTMLTool.model.MMDParams;
import es.ehu.oms.CPTMLTool.model.Passwords;
import es.ehu.oms.CPTMLTool.utils.Utils;



@Controller
public class MMDController {
	
	
	private static String FILE_NAME = "";
	
	@RequestMapping(value = "/pwdMMd")
	 public String loginMateo(@ModelAttribute("pwdMMD") String pwdMMD, Model model) {
		 
		 if (pwdMMD.equals("CPTMLTools"))
		 {
			 return "redirect:/mcdCalc";
		 }
		 else
		 {
			 model.addAttribute("pwdMMDError", "Password Incorrect");
			 model.addAttribute("pwd", new Passwords());
			 return "index";
		 }
	 }

	 @RequestMapping(value = "/calcaulateDescriptors")
	 public String calcaulateDescriptors(@ModelAttribute("parameters") MMDParams parameters,
			 @RequestParam("fileToUpload") MultipartFile file, Model model, HttpServletRequest request) throws IOException {
		 
		 	String UPLOADED_FOLDER = request.getServletContext().getRealPath("/files/MMD/uploadedFolder/"); 	
		 	String RESULT_FOLDER =  request.getServletContext().getRealPath("/files/MMD/resultFolder/");
		
		try{
			
			Utils utils = new Utils();		
			FILE_NAME = utils.randomNameFile()+".csv";
			
			if (file.getSize() != 0)
			{		
				byte[] bytes = file.getBytes();
			    Path path = Paths.get(UPLOADED_FOLDER + FILE_NAME);
	            Files.write(path, bytes);	
			}
			else				
			{				
				PrintWriter writer = new PrintWriter(UPLOADED_FOLDER+FILE_NAME, "UTF-8");
				writer.println(parameters.getContent());
				writer.close();
			}
			
			String atomProperties = utils.atomProperties(parameters);
			String atomTypes = utils.atomTypes(parameters);
			
			if (parameters.isMeans())
			{				
				Runtime.getRuntime().exec("Rscript F://CPTMLTools/MCDCalc/means.R "+UPLOADED_FOLDER+FILE_NAME +" "+RESULT_FOLDER+"MEANS_"+FILE_NAME+atomProperties+" "+atomTypes);	
				model.addAttribute("urlMeans", "MEANS_"+FILE_NAME);
				model.addAttribute("urlMeans2", RESULT_FOLDER+"MEANS_"+FILE_NAME);
			}
			
			if (parameters.isSingular())
			{
				Runtime.getRuntime().exec("Rscript F://CPTMLTools/MCDCalc/singular.R "+UPLOADED_FOLDER+FILE_NAME+" " +RESULT_FOLDER+"SINGULAR_"+FILE_NAME+atomProperties+" "+atomTypes);			
				model.addAttribute("urlSingular", "SINGULAR_"+FILE_NAME);
			}
			
			model.addAttribute("server", "MMD");
			
		} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
		  } 
		
		  return "resultsMMD";
		}
	 
	
}
