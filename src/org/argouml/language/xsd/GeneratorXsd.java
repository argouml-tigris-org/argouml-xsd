
package org.argouml.language.xsd;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.argouml.uml.generator.*;
import org.argouml.application.api.Argo;
import org.argouml.configuration.Configuration;
import org.argouml.kernel.Project;
import org.argouml.kernel.ProjectManager;
import org.argouml.persistence.PersistenceManager;

import org.apache.log4j.Logger;

/**
 * XSD Generator
 * http://www.niematron.org/
 * Date Created: 2012-09-18
 * 
 * @author Joel Byford
 * @version 0.0.1
 */

public final class GeneratorXsd implements CodeGenerator {
	
	/**
	 * Static Final Constants Defined
	 */
    private static final GeneratorXsd INSTANCE = new GeneratorXsd();
	
    //TODO: Remove static and make dynamic based on project name.
    private static final String SCRIPT_FILENAME = "model.xsd";

	private static final String XSL_FILE_NAME = "ArgoXmlToXsd.xsl";
	
	private static final Logger LOG = Logger.getLogger(GeneratorXsd.class);

	
	/**
     * Generate code for the specified classifiers. If generation of
     * dependencies is requested, then every file the specified elements depends
     * on is generated too (e.g. if the class MyClass has an attribute of type
     * OtherClass, then files for OtherClass are generated too).
     * 
     * @param elements
     *            the UML model elements to generate code for.
     * @param deps
     *            Recursively generate dependency files too.
     * @return A collection of {@link org.argouml.uml.generator.SourceUnit}
     *         objects. The collection may be empty if no file is generated.
     * @see org.argouml.uml.generator.CodeGenerator#generate( Collection,
     *      boolean)
     */
	@SuppressWarnings("rawtypes")
	@Override
	public Collection<SourceUnit> generate(Collection elements, boolean deps) {
		
		
		File tmpdir = null;
        try {
            tmpdir = TempFileUtils.createTempDir();
            if (tmpdir != null) {
                generateFiles(elements, tmpdir.getPath(), deps);
                return TempFileUtils.readAllFiles(tmpdir);
            }
            else
            	return Collections.emptyList();
        } finally {
            if (tmpdir != null) {
                TempFileUtils.deleteDir(tmpdir);
            }
           
        }
		
	}

	/**
     * Returns a list of files that will be generated from the specified
     * model elements.
     * 
     * @see #generate(Collection, boolean)
     * @param elements
     *            the UML model elements to generate code for.
     * @param deps
     *            Recursively generate dependency files too.
     * @return The filenames (with relative path) as a collection of Strings.
     *         The collection may be empty if no file will be generated.
     * @see org.argouml.uml.generator.CodeGenerator#generateFileList(
     *      Collection, boolean)
     */
	@SuppressWarnings("rawtypes")
	@Override
	public Collection<String> generateFileList(Collection elements, boolean deps) {
		Collection<String> c = new HashSet<String>();
		c.add(SCRIPT_FILENAME);
		return c;
	}
	
	/**
     * Write files utility
     * 
     * @param filename
     *            The name of the file to be saved.
     * @param content
     *            The data to be saved in the file.
     */
	private void writeFile(String filename, String content) {
        BufferedWriter fos = null;
        try {
            String inputSrcEnc = Configuration
                    .getString(Argo.KEY_INPUT_SOURCE_ENCODING);
            if (inputSrcEnc == null || inputSrcEnc.trim().equals("")) {
                inputSrcEnc = System.getProperty("file.encoding");
            }
            fos = new BufferedWriter(new OutputStreamWriter(
                    new FileOutputStream(filename), inputSrcEnc));
            fos.write(content);
        } catch (IOException e) {
            LOG.error("IO Exception: " + e);
        } finally {
            try {
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException e) {
            	LOG.error("IO Exception: " + e);
            }
        }
    }

	/**
     * Generate files for the specified classifiers.
     * 
     * @see #generate(Collection, boolean)
     * @param elements
     *            the UML model elements to generate code for.
     * @param path
     *            The source base path.
     * @param deps
     *            Recursively generate dependency files too.
     * @return The filenames (with relative path) as a collection of Strings.
     *         The collection may be empty if no file will be generated.
     * @see org.argouml.uml.generator.CodeGenerator#generateFiles( Collection,
     *      String, boolean)
     */
	@SuppressWarnings("rawtypes")
	@Override
	public Collection<String> generateFiles(Collection elements, String path,
			boolean deps) {
		 
		String filename = SCRIPT_FILENAME;
        if (!path.endsWith(FILE_SEPARATOR)) {
            path += FILE_SEPARATOR;
        }

        Collection<String> result = new ArrayList<String>();
        String fullFilename = path + filename;
        
        //Obtain a reference to current project
  		//TODO: Research and Replace deprecated method
  		@SuppressWarnings("deprecation")
		Project project = ProjectManager.getManager().getCurrentProject();

  		//Obtain the ArgoUML "XML Dump"
  		String data =
  		    PersistenceManager.getInstance().getQuickViewDump(project);
  		
  		//Temporary ArgoUML Bug [Issue 6440] Workaround
  		// -- Delete all "aroguml:" prefixes
  		String code = data.replaceAll("argouml:", "");
  		
  		//transform
  		String sXsdData = transformXmlIntoXsd(code);
  		
  		
  		//return
  		writeFile(fullFilename, sXsdData);
        result.add(fullFilename);
	        
		return result;
	}
	
	/**
     * Transform Argo XML Dump into XSD
     * 
     * @param sXml
     *            ArgoUML XML Dump provided by the application with embedded XMI.
     */
	private String transformXmlIntoXsd(String sXml){
		
		//INPUT - make an IO stream out of the XML string
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
	    	URL url = getClass().getResource(XSL_FILE_NAME).toURI().toURL();
	    	InputStream is = url.openStream();
	    	Source xslSource = new StreamSource(is);
	    	xslSource.setSystemId(getClass().getResource(XSL_FILE_NAME).toString());
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

	/**
     * Static Instance Return Utility for returning
     * a pointer to an instance of the generator class
     * as required by the Module Loader.
     */
	public static CodeGenerator getInstance() {
		
		return INSTANCE;
	}
	
	

}
