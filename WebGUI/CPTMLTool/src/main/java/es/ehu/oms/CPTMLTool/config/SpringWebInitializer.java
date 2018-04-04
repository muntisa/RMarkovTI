package es.ehu.oms.CPTMLTool.config;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;


/**
 *  Spring configuration and Spring MVC bootstrapping.
 */
public class SpringWebInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {
 

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class[] { WebMvcConfig.class };
    }
  
    @Override
    protected Class<?>[] getServletConfigClasses() {
        return null;
    }
  
    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }
 
 }


