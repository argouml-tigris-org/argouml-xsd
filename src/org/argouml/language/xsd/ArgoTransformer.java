package org.argouml.language.xsd;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;

public class ArgoTransformer {
	
	//	Globals
	
	private static final Logger LOG = Logger.getLogger(GeneratorXsd.class);
	
	private static final String XMI_XSL_FILE = "ArgoXmlToXmi.xsl";
	
	/**
	 * Standard Constructors
	 */
	public ArgoTransformer(){
		
	}
	
	/**
     * Transform Argo XML Dump into XSD
     * 
     * @param sXml
     *            ArgoUML XML Dump provided by the application with embedded XMI.
     */
	public String executeTransform(String sXml, String sXsl){
		
		//Temporary ArgoUML Bug [Issue 6440] Workaround
  		// -- Delete all "aroguml:" prefixes
  		String code = sXml.replaceAll("argouml:", "");
  		
  		//First Transform
  		String sXmiString = transform(code, XMI_XSL_FILE);
  		
  		//SecondTransform
  		//return transform(sXmiString, sTransformName); 
  		return transform(sXmiString, sXsl); 
 
	} 
	
	private String transform(String sXml, String sXsl){
		
		//INPUT - make an IO stream out of the XMI string
		StringReader xmlReader = new StringReader(sXml);
		Source xmlSource = new StreamSource(xmlReader);
		
		//OUTPUT - make a place-holder for XSLT file output
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
	    Result result = new StreamResult(baos);
		
		//TRANSFORM - obtain the XSLT from the file system.
	    TransformerFactory transFact = TransformerFactory.newInstance();
	    Transformer trans;
	    
	    //load transform from file
	    try{
	    	URL url = getClass().getResource(sXsl).toURI().toURL();
	    	InputStream is = url.openStream();
	    	Source xslSource = new StreamSource(is);
	    	xslSource.setSystemId(getClass().getResource(sXsl).toString());
	    	trans = transFact.newTransformer(xslSource);
	    	trans.transform(xmlSource, result);
	    }catch (TransformerException e){
	    	LOG.warn("Error Creating or Calling Transformer", e);
	    }catch (URISyntaxException e) {
            LOG.warn("Could not find XSLT file", e);
		} catch (MalformedURLException e) {
            LOG.warn("Could not find XSLT file", e);
		} catch (IOException e) {
            LOG.warn("Error reading/fetching XSLT file", e);
		}
	    
		return new String(baos.toByteArray());
	
	}
}
