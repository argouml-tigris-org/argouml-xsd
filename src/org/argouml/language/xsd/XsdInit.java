package org.argouml.language.xsd;

import org.argouml.application.helpers.ResourceLoaderWrapper;
import org.argouml.moduleloader.ModuleInterface;
import org.argouml.uml.generator.GeneratorHelper;
import org.argouml.uml.generator.GeneratorManager;
import org.argouml.uml.generator.Language;

public class XsdInit implements ModuleInterface {
	
	/**
     * The language that we are implementing.
     */
    static final String LANGUAGE_NAME = "XSD";

    /**
     * The prepared struct for registering.
     */
    private static final Language MY_LANG = GeneratorHelper.makeLanguage(
            LANGUAGE_NAME, ResourceLoaderWrapper
                    .lookupIconResource(LANGUAGE_NAME + "Notation"));

    /**
     * Method to disable the module.
     * <p>
     * 
     * If we cannot disable the module because some other module relies on it,
     * we return false. This will then make it impossible to turn off. (An error
     * is signalled at the attempt).
     * 
     * @return true if all went well.
     */    
	@Override
	public boolean disable() {
		GeneratorManager.getInstance().removeGenerator(MY_LANG);
		return true;
	}

	/**
     * Method to enable the module.
     * <p>
     * 
     * If it cannot enable the module because some other module is not enabled
     * it can return <code>false</code>. In that case the module loader will
     * defer this attempt until all other modules are loaded (or until some more
     * of ArgoUML is loaded if at startup). Eventually it is only this and some
     * other modules that is not loaded and they will then be listed as having
     * problems.
     * 
     * @return true if all went well
     */	
	@Override
	public boolean enable() {
		GeneratorManager.getInstance().addGenerator(MY_LANG,
                GeneratorXsd.getInstance());
		
		//No UI at this time
        //GUI.getInstance().addSettingsTab(new SettingsTabSql());

        return true;
	}

	
	/**
     * The info about the module.
     * <p>
     * 
     * This returns texts with information about the module.
     * <p>
     * 
     * The possible informations are retrieved by giving any of the arguments:
     * <ul>
     * <li>{@link #DESCRIPTION}
     * <li>{@link #AUTHOR}
     * <li>{@link #VERSION}
     * <li>{@link #DOWNLOADSITE}
     * </ul>
     * 
     * If a module does not provide a specific piece of information,
     * <code>null</code> can be returned. Hence the normal implementation
     * should be:
     * 
     * <pre>
     *         public String getInfo(int type) {
     *             switch (type) {
     *             case DESCRIPTION:
     *                 return &quot;This module does ...&quot;;
     *             case AUTHOR:
     *                 return &quot;Annie Coder&quot;;
     *             default:
     *                 return null;
     *         }
     * </pre>
     * 
     * @param type
     *            The type of information.
     * @return The description. A String.
     */
	@Override
	public String getInfo(int type) {
		switch (type) {
        case DESCRIPTION:
            return "XSD Generator";
        case AUTHOR:
            return "Joel Byford";
        //case VERSION:
        //    return "$Id: XsdInit.java 1 2012-09-11 17:41:03Z linus $";
        default:
            return null;
		}
	}

	
	/**
     * The name of the module.
     * <p>
     * 
     * This should be a short string. For the purpose of having the GUI that
     * turns on and off the module look nice there is no whitespace in this
     * string (no spaces, tabs or newlines).
     * <p>
     * 
     * This name is also used as the key internally when modules checks for
     * other modules, if they are available.
     * 
     * @return the name (A String).
     */
	@Override
	public String getName() {
		
		return "Xsd";
	}

}
