<?xml version="1.0" encoding="UTF-8"?>
<!-- *************************************** -->
<!--                                         -->
<!--                                         -->
<!-- Author: Joel Byford                     -->
<!--                                         -->
<!-- joel@sooscreekconsulting.com            -->
<!-- http://www.niematron.org/               -->
<!--                                         -->
<!-- Date Created: 2012-09-21                -->
<!-- Last Updated: 2012-09-21                -->
<!--                                         -->
<!--                                         -->
<!-- *************************************** -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:UML="org.omg.xmi.namespace.UML"
    xmlns:niematron="http://www.niematron.org/" exclude-result-prefixes="xsl UML niematron"
    version="1.0">
    <xsl:output method="xml" indent="yes"/>
    
    
    
    <xsl:template match="/uml">
        <xsl:apply-templates select="XMI" mode="RecursiveDeepCopy" />
    </xsl:template> 
    
    <xsl:template match="@*|node()" mode="RecursiveDeepCopy">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates mode="RecursiveDeepCopy" />
        </xsl:copy> 
    </xsl:template> 
    

</xsl:stylesheet>
