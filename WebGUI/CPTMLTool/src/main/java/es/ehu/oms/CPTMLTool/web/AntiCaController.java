package es.ehu.oms.CPTMLTool.web;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import es.ehu.oms.CPTMLTool.model.Passwords;

public class AntiCaController {
	
	 @RequestMapping(value = "/pwdAntiCa")
	 public String loginMateo(@ModelAttribute("pwdMateo") String pwdMateo, Model model) {
		 
		 if (pwdMateo.equals("CPTMLTools"))
		 {
			 return "redirect:/antiCa";
		 }
		 else
		 {
			 model.addAttribute("pwdAntiCaError", "Password Incorrect");
			 model.addAttribute("pwd", new Passwords());
			 return "index";
		 }
	 }
	

}
