package es.ehu.oms.CPTMLTool.web;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLConnection;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import es.ehu.oms.CPTMLTool.model.AntiCaParams;
import es.ehu.oms.CPTMLTool.model.EEParams;
import es.ehu.oms.CPTMLTool.model.MMDParams;
import es.ehu.oms.CPTMLTool.model.Passwords;

@Controller
public class IndexController {
	

	
	@RequestMapping(value = "/", method = RequestMethod.GET)
	 public String index(Model model) {	
		 
		model.addAttribute("pwd", new Passwords());
		return "index";
	 } 
	
	 @RequestMapping(value = "/viewResultFile/{server}/{url}", method = RequestMethod.GET)
	 public String viewResultFile(@PathVariable("url") String url, @PathVariable("server") String server, Model model, HttpServletRequest request) {		 
		 
		    model.addAttribute("fileName", "../../files/"+server+"/resultFolder/"+url+".csv");	
			model.addAttribute("title", "Results "+url+".csv");

		 
		return "viewResultFile";
	  }
	 
	 
	 @RequestMapping(value = "/viewResultImages/{server}/{url}", method = RequestMethod.GET)
	 public String viewResultImages(@PathVariable("url") String url, @PathVariable("server") String server, Model model, HttpServletRequest request) {		 
		 
		 	String RESULT_FOLDER =  request.getServletContext().getRealPath("/files/EE/resultFolder/");
		 
		 	String csvFile = RESULT_FOLDER +url+".csv"; 	
		 
	        BufferedReader br = null;
	        String line = "";
	        String cvsSplitBy = ";";
	        
	        String subs = "";
            String cat = "";
            String nuc = "";

	        try {
	        	
	          	br = new BufferedReader(new FileReader(csvFile));
	    	          
	            int index = 0;
	            
	            while ((line = br.readLine()) != null) {

	            	index = index +1;
	            	
	            	if (index == 2)
	            	{
		                // use comma as separator
		                String[] reaction = line.split(cvsSplitBy);
		                
		                subs = reaction[8];
			            nuc = reaction[9];
			            cat = reaction[10];
			          
		                         
		                break;
	            	}
	 	                
	            }

	        } catch (FileNotFoundException e) {
	            e.printStackTrace();
	        } catch (IOException e) {
	            e.printStackTrace();
	        } finally {
	            if (br != null) {
	                try {
	                    br.close();
	                } catch (IOException e) {
	                    e.printStackTrace();
	                }
	            }
	        }
	        
	        model.addAttribute("catImage", cat) ;
	        model.addAttribute("nucImage", nuc) ;
	        model.addAttribute("subsImage", subs) ;
	   	  
	        model.addAttribute("fileName", "../../files/"+server+"/resultFolder/"+url+".csv");	
		 
		return "viewResultImages";
	  }
	 
	 @RequestMapping(value = "/mcdCalc", method = RequestMethod.GET)
	 public String mmdCalculate(Model model) {
		 
		  model.addAttribute("parameters", new MMDParams());	
		  
	      return "MMDescriptors";
	  }
	 
	 @RequestMapping(value = "/antiCa", method = RequestMethod.GET)
	 public String antiCaCalculate(Model model, HttpServletRequest request) {
		 
		 model.addAttribute("parameters", new AntiCaParams());	

		 return "antiCa";
	  }
	
	 
	 
	 @RequestMapping(value = "/mateo", method = RequestMethod.GET)
	 public String eeEnantiomeric(Model model, HttpServletRequest request) {	
		 
		 model.addAttribute("parametersEE", new EEParams()) ;
	      	   	    		
		List<String> elements = new ArrayList<String>();
		
		elements.add("Solvent");
		elements.add("Catalyst");
		elements.add("Substract");
		
		model.addAttribute("elements", elements) ;
		
			
		return "eeCalculation";
	 }
	 
	 
	 @RequestMapping(value = "/downloadResultFile/{server}/{url}", method = RequestMethod.GET)
		public void downloadFile(HttpServletResponse response, @PathVariable("server") String server, 
			@PathVariable("url") String url, HttpServletRequest request) throws IOException {
			
		 	String FILE_PATH = "";
		 
		 	if (server.equals("MMD"))
		 	{
		 		FILE_PATH = request.getServletContext().getRealPath("/files/MMD/resultFolder/"); 
		 	}
		 	
		 	if (server.equals("EE"))
		 	{
		 		FILE_PATH = request.getServletContext().getRealPath("/files/EE/resultFolder/"); 
		 	}
		 	
			File file = new File(FILE_PATH+url+".csv");
			
			if(!file.exists()){
				String errorMessage = "Sorry...."+ FILE_PATH+url+".csv";
				System.out.println(errorMessage);
				OutputStream outputStream = response.getOutputStream();
				outputStream.write(errorMessage.getBytes(Charset.forName("UTF-8")));
				outputStream.close();
				return;
			}
			
			String mimeType= URLConnection.guessContentTypeFromName(file.getName());
			
			if(mimeType==null){
				System.out.println("mimetype is not detectable, will take default");
				mimeType = "application/octet-stream";
			}
			
		    response.setContentType(mimeType);
	        
	        response.setHeader("Content-Disposition", String.format("attachment; filename=\"" + file.getName() +"\""));
	          
	        response.setContentLength((int)file.length());

			InputStream inputStream = new BufferedInputStream(new FileInputStream(file));

	        FileCopyUtils.copy(inputStream, response.getOutputStream());
		}
	   
}
