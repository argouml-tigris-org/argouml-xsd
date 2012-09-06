
package org.argouml.language.xsd;

import java.util.Collection;

import org.argouml.uml.generator.CodeGenerator;
import org.argouml.uml.generator.SourceUnit;

/**
 * XSD Generator
 * @author Joel Byford
 * @version 0.0.1
 */
public final class GeneratorXsd implements CodeGenerator {
	
	/**
	 * Static Final Constants Defined
	 */
	
	

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
	@Override
	public Collection<SourceUnit> generate(Collection elements, boolean deps) {
		// TODO Auto-generated method stub
		return null;
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
	@Override
	public Collection<String> generateFileList(Collection elements, boolean deps) {
		// TODO Auto-generated method stub
		return null;
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
	@Override
	public Collection<String> generateFiles(Collection elements, String path,
			boolean deps) {
		// TODO Auto-generated method stub
		return null;
	}

}
