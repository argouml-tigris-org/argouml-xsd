<?xml version="1.0" encoding="UTF-8"?>
<!-- *************************************** -->
<!--                                         -->
<!--                                         -->
<!-- Author: Joel Byford                     -->
<!--                                         -->
<!-- joel@sooscreekconsulting.com            -->
<!-- http://www.niematron.org/               -->
<!--                                         -->
<!-- Date Created: 2012-08-20                -->
<!-- Last Updated: 2012-09-21                -->
<!--                                         -->
<!--                                         -->
<!-- *************************************** -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:UML="org.omg.xmi.namespace.UML"
    xmlns:niematron="http://www.niematron.org/" exclude-result-prefixes="xsl UML niematron"
    version="1.0">

    <!-- File location of the xsd.xmi file.  Defaults to same directory as the XSLT if not provided. -->
    <xsl:param name="gXsdProfileFileLocation" select="'./'"/>

    <xsl:output indent="yes" encoding="UTF-8"/>

    <!-- **************** -->
    <!-- Static Variables -->
    <!-- **************** -->

    <!-- TODO: Replace these statics with a dynamic call to external XSD XMI? -->
    <xsl:variable name="sXsdAll"
        select="'http://argouml.org/user-profiles/xsd.xmi#id-xsd-m-s-c-all'"/>
    <xsl:variable name="sXsdSequence"
        select="'http://argouml.org/user-profiles/xsd.xmi#id-xsd-m-s-c-sequence'"/>
    <xsl:variable name="sXsdChoice"
        select="'http://argouml.org/user-profiles/xsd.xmi#id-xsd-m-s-c-choice'"/>

    <!-- TODO: Replace these statics with a dynamic call to external UML XMI? -->
    <xsl:variable name="sUmlInteger"
        select="'http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087C'"/>
    <xsl:variable name="sUmlString"
        select="'http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087E'"/>
    <xsl:variable name="sUmlUlimitedInteger"
        select="'http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087D'"/>
    <xsl:variable name="sUmlBoolean"
        select="'http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:0000000000000880'"/>

    <!-- ********************************  -->
    <!-- Get Data Type Function            -->
    <!-- fxnGetDataType(a)                 -->
    <!--   a= Root node of UML:Attribute   -->
    <!-- ********************************  -->

    <xsl:template name="niematron:fxnGetDataType">
        <xsl:param name="vAttributeRootNode"/>

        <xsl:choose>
            <!-- If a UML Boolean type -->
            <xsl:when
                test="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:Enumeration[@href = $sUmlBoolean]">
                <xsl:value-of select="'xsd:boolean'"/>
            </xsl:when>

            <!-- If a UML String type -->
            <xsl:when
                test="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:DataType[@href = $sUmlString]">
                <xsl:value-of select="'xsd:string'"/>
            </xsl:when>

            <!-- If a UML Integer type -->
            <xsl:when
                test="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:DataType[@href = $sUmlInteger]">
                <xsl:value-of select="'xsd:integer'"/>
            </xsl:when>

            <!-- If a UML Unsigned Integer type -->
            <xsl:when
                test="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:DataType[@href = $sUmlUlimitedInteger]">
                <xsl:value-of select="'xsd:nonNegativeInteger'"/>
            </xsl:when>

            <!-- If an enumeration (not a UML boolean type-->
            <xsl:when test="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:Enumeration">
                <xsl:variable name="vEnumType"
                    select="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:Enumeration/@xmi.idref"/>
                <xsl:value-of
                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Enumeration[@xmi.id=$vEnumType]/@name"
                />
            </xsl:when>

            <!-- If a local data type (UNSUPPORTED)-->
            <xsl:when
                test="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:DataType/@xmi.idref != ''">
                <xsl:variable name="vDataType"
                    select="$vAttributeRootNode/UML:StructuralFeature.type[1]/UML:DataType/@xmi.idref"/>
                <xsl:value-of
                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:DataType[@xmi.id=$vDataType]/@name"
                />
            </xsl:when>

            <!-- Otherwise must be a fixed data type from xsd.xmi file -->
            <xsl:otherwise>
                <xsl:variable name="vDataType"
                    select="substring-after($vAttributeRootNode/UML:StructuralFeature.type/UML:DataType/@href,'http://argouml.org/user-profiles/xsd.xmi#')"/>
                <xsl:value-of
                    select="concat('xsd:', document(concat($gXsdProfileFileLocation, 'xsd.xmi'))/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:DataType[@xmi.id=$vDataType]/@name)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- *************************  -->
    <!-- Get Attributes Function    -->
    <!-- fxnGetClassAttributes(a)   -->
    <!--   a= Root node of Class    -->
    <!-- *************************  -->

    <xsl:template name="niematron:fxnGetClassAttributes">
        <xsl:param name="vClassRootNode"/>
        <xsl:for-each
            select="$vClassRootNode/UML:Classifier.feature[1]/UML:Attribute[./UML:ModelElement.stereotype/UML:Stereotype/@href='http://argouml.org/user-profiles/xsd.xmi#id-xsd-m-s-e-attribute']">
            <xsl:element name="xsd:attribute">

                <!-- Attribute Name -->
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>

                <!-- Attribute Type -->
                <xsl:attribute name="type">
                    <xsl:call-template name="niematron:fxnGetDataType">
                        <xsl:with-param name="vAttributeRootNode" select="."/>
                    </xsl:call-template>

                </xsl:attribute>

                <!-- Attribute Required -->
                <xsl:if
                    test="./UML:StructuralFeature.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[@lower = 1]">
                    <xsl:attribute name="use">
                        <xsl:value-of select="'required'"/>
                    </xsl:attribute>
                </xsl:if>

                <!-- Attribute Prohibited -->
                <xsl:if
                    test="./UML:StructuralFeature.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[@upper = 0]">
                    <xsl:attribute name="use">
                        <xsl:value-of select="'prohibited'"/>
                    </xsl:attribute>
                </xsl:if>

            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    <!-- *****************************  -->


    <!-- *************************  -->
    <!-- Get Elements Function      -->
    <!-- fxnGetClassElements(a)     -->
    <!--   a= Root node of Class    -->
    <!-- *************************  -->

    <xsl:template name="niematron:fxnGetClassElements">
        <xsl:param name="vClassRootNode"/>
        <xsl:param name="vContentModelString"/>

        <xsl:for-each
            select="$vClassRootNode/UML:Classifier.feature[1]/UML:Attribute[./UML:ModelElement.stereotype/UML:Stereotype/@href='http://argouml.org/user-profiles/xsd.xmi#id-xsd-m-s-e-element' or count(./UML:ModelElement.stereotype)=0 ]">

            <xsl:element name="xsd:element">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:call-template name="niematron:fxnGetDataType">
                        <xsl:with-param name="vAttributeRootNode" select="."/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="minOccurs">
                    <xsl:choose>
                        <!-- Use limit if provided (not null)  -->
                        <xsl:when
                            test="./UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower">
                            <xsl:value-of
                                select="./UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower"
                            />
                        </xsl:when>

                        <!-- Use "0" if not provided -->
                        <xsl:otherwise>
                            <xsl:value-of select="'0'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="maxOccurs">

                    <xsl:choose>
                        <!-- Cannot exceed "1" for xsd:all -->
                        <xsl:when test="$vContentModelString = 'xsd:all'">
                            <xsl:value-of select="'1'"/>
                        </xsl:when>

                        <!-- Replace "-1" with "unbounded" -->
                        <xsl:when
                            test="./UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper = -1">
                            <xsl:value-of select="'unbounded'"/>
                        </xsl:when>

                        <!-- Make 'unbounded' if not specified -->
                        <xsl:when
                            test="count(./UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper) = 0">
                            <xsl:value-of select="'unbounded'"/>
                        </xsl:when>

                        <!-- All others, just take what's in the 'upper' attribute -->
                        <xsl:otherwise>
                            <xsl:value-of
                                select="./UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper"
                            />
                        </xsl:otherwise>
                    </xsl:choose>


                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>

        <!-- Public Elements/Lines -->
        <xsl:for-each
            select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Association">
            <xsl:for-each
                select="./UML:Association.connection[1]/UML:AssociationEnd[@isNavigable='false' and @aggregation!='composite' and UML:AssociationEnd.participant/UML:Class/@xmi.idref = $vClassRootNode/@xmi.id]">
                <xsl:variable name="vToClassIdref"
                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.participant/UML:Class/@xmi.idref"/>
                <xsl:variable name="vToInterfaceIdref"
                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.participant/UML:Interface/@xmi.idref"/>
                <xsl:element name="xsd:element">
                    <xsl:choose>

                        <!-- Use Class Name if it exists -->
                        <xsl:when
                            test="count(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vToClassIdref]) > 0">
                            <xsl:attribute name="ref">
                                <xsl:value-of
                                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vToClassIdref]/@name"
                                />
                            </xsl:attribute>
                        </xsl:when>

                        <!-- Use Interface Name if it exists -->
                        <xsl:when
                            test="count(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface[@xmi.id = $vToInterfaceIdref]) > 0">
                            <xsl:attribute name="ref">
                                <xsl:value-of
                                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface[@xmi.id = $vToInterfaceIdref]/@name"
                                />
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>

                    <!-- MinOccurs -->
                    <xsl:attribute name="minOccurs">

                        <!-- Use limit if provided (not null)  -->
                        <xsl:choose>
                            <xsl:when
                                test="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@lower">
                                <xsl:value-of
                                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@lower"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'"/>
                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:attribute>

                    <!-- MaxOccurs -->
                    <xsl:attribute name="maxOccurs">
                        <xsl:choose>

                            <!-- Cannot exceed "1" for xsd:all -->
                            <xsl:when test="$vContentModelString = 'xsd:all'">
                                <xsl:value-of select="'1'"/>
                            </xsl:when>

                            <!-- Replace "-1" with "unbounded" -->
                            <xsl:when
                                test="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@upper = -1">
                                <xsl:value-of select="'unbounded'"/>
                            </xsl:when>

                            <!-- Make 'unbounded' if not specified -->
                            <xsl:when
                                test="count(../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@upper) = 0">
                                <xsl:value-of select="'unbounded'"/>
                            </xsl:when>

                            <!-- All others, just take what's in the 'upper' attribute -->
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@upper"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>

                </xsl:element>
            </xsl:for-each>
        </xsl:for-each>

        <!-- Private Elements/Lines -->
        <xsl:for-each
            select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Association">
            <xsl:for-each
                select="./UML:Association.connection[1]/UML:AssociationEnd[@isNavigable='false' and @aggregation='composite' and UML:AssociationEnd.participant/UML:Class/@xmi.idref = $vClassRootNode/@xmi.id]">
                <xsl:variable name="vToClassIdref"
                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.participant/UML:Class/@xmi.idref"/>
                <xsl:variable name="vToInterfaceIdref"
                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.participant/UML:Interface/@xmi.idref"/>
                <xsl:element name="xsd:element">
                    <xsl:choose>
                        <!-- Use Interface Name if it exists (can't be a private element) -->
                        <xsl:when
                            test="count(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface[@xmi.id = $vToInterfaceIdref]) > 0">
                            <xsl:attribute name="ref">
                                <xsl:value-of
                                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface[@xmi.id = $vToInterfaceIdref]/@name"
                                />
                            </xsl:attribute>
                        </xsl:when>

                        <!-- Use Line Name if it exists -->
                        <xsl:when test="string-length(../../@name) > 0">
                            <xsl:attribute name="name">
                                <xsl:value-of select="../../@name"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of
                                    select="concat(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vToClassIdref]/@name, 'Type')"
                                />
                            </xsl:attribute>
                        </xsl:when>

                        <!-- Use Class Name if it exists -->
                        <xsl:when
                            test="count(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vToClassIdref]) > 0">
                            <xsl:attribute name="name">
                                <xsl:value-of
                                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vToClassIdref]/@name"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of
                                    select="concat(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vToClassIdref]/@name, 'Type')"
                                />
                            </xsl:attribute>
                        </xsl:when>


                    </xsl:choose>

                    <!-- MinOccurs -->
                    <xsl:attribute name="minOccurs">

                        <xsl:choose>
                            <xsl:when
                                test="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@lower">
                                <xsl:value-of
                                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@lower"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'"/>
                            </xsl:otherwise>

                        </xsl:choose>


                    </xsl:attribute>

                    <!-- MaxOccurs -->
                    <xsl:attribute name="maxOccurs">
                        <xsl:choose>

                            <!-- Cannot exceed "1" for xsd:all -->
                            <xsl:when test="$vContentModelString = 'xsd:all'">
                                <xsl:value-of select="'1'"/>
                            </xsl:when>

                            <!-- Replace "-1" with "unbounded" -->
                            <xsl:when
                                test="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@upper = -1">
                                <xsl:value-of select="'unbounded'"/>
                            </xsl:when>

                            <!-- Make 'unbounded' if not specified -->
                            <xsl:when
                                test="count(../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@upper) = 0">
                                <xsl:value-of select="'unbounded'"/>
                            </xsl:when>

                            <!-- All others, just take what's in the 'upper' attribute -->
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="../UML:AssociationEnd[@isNavigable='true']/UML:AssociationEnd.multiplicity[1]/UML:Multiplicity[1]/UML:Multiplicity.range[1]/UML:MultiplicityRange[1]/@upper"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <!-- *****************************  -->


    <!-- *************************  -->
    <!-- Add Content Function       -->
    <!-- fxnAddClassContent(a)      -->
    <!--   a = Root node of Class   -->
    <!-- *************************  -->

    <xsl:template name="niematron:fxnAddClassContent">
        <xsl:param name="vClassRootNode"/>


        <!-- Use Content Model in Stereotype if Defined -->
        <xsl:choose>
            <xsl:when
                test="$vClassRootNode/UML:ModelElement.stereotype/UML:Stereotype/@href=$sXsdAll">

                <xsd:all>
                    <xsl:call-template name="niematron:fxnGetClassElements">
                        <xsl:with-param name="vClassRootNode" select="$vClassRootNode"/>
                        <xsl:with-param name="vContentModelString" select="'xsd:all'"/>
                    </xsl:call-template>
                </xsd:all>

            </xsl:when>
            <xsl:when
                test="$vClassRootNode/UML:ModelElement.stereotype/UML:Stereotype/@href=$sXsdChoice">

                <xsd:choice>
                    <xsl:call-template name="niematron:fxnGetClassElements">
                        <xsl:with-param name="vClassRootNode" select="$vClassRootNode"/>
                        <xsl:with-param name="vContentModelString" select="'xsd:choice'"/>
                    </xsl:call-template>
                </xsd:choice>

            </xsl:when>

            <!-- Default to xsd:sequence if none exists-->
            <xsl:otherwise>

                <xsd:sequence>
                    <xsl:call-template name="niematron:fxnGetClassElements">
                        <xsl:with-param name="vClassRootNode" select="$vClassRootNode"/>
                        <xsl:with-param name="vContentModelString" select="'xsd:sequence'"/>
                    </xsl:call-template>
                </xsd:sequence>

            </xsl:otherwise>
        </xsl:choose>

        <!-- Add Attributes if they exist -->
        <xsl:call-template name="niematron:fxnGetClassAttributes">
            <xsl:with-param name="vClassRootNode" select="$vClassRootNode"/>
        </xsl:call-template>

    </xsl:template>
    <!-- *****************************  -->


    <!-- ***********************  -->
    <!-- Start of core transform. -->
    <!-- ***********************  -->
    <xsl:template match="*">

        <!-- Version Check -->
        <xsl:choose>
            <xsl:when
                test="/XMI/@xmi.version != '1.2' or /XMI/XMI.header/XMI.metamodel/@xmi.version !='1.4'">

                <!-- Unsupported version of XMI -->
                <xsl:text>
** UNSUPPORTED FILE TYPE **
This transform currently only supports 
- UML version 1.4 encpasulated in XMI version 1.2. 
</xsl:text>
            </xsl:when>
            <xsl:otherwise>

                <!-- Store the ID's required -->
                <xsl:variable name="vDocumentTagId"
                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:TagDefinition[1]/@xmi.id"/>

                <xsl:element name="xsd:schema">
                    <!-- Annotation for the file comes from the Model description tag. -->
                    <xsl:for-each
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:ModelElement.taggedValue/UML:TaggedValue[./UML:TaggedValue.type/UML:TagDefinition/@xmi.idref = $vDocumentTagId]">
                        <xsd:annotation>
                            <xsd:documentation>
                                <xsl:value-of select="./UML:TaggedValue.dataValue"/>
                            </xsd:documentation>
                        </xsd:annotation>
                    </xsl:for-each>

                    <!--  Complex Data Types (Classes) -->
                    <xsl:for-each
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement/UML:Class">
                        <xsl:variable name="vClassId" select="@xmi.id"/>
                        <xsl:text>
     
    </xsl:text>
                        <xsl:comment>
                            <xsl:value-of select="concat (@name, ' Class as defined in the UML.')"/>
                        </xsl:comment>
                        <xsl:element name="xsd:complexType">
                            <xsl:attribute name="name">
                                <xsl:value-of select="concat(@name, 'Type')"/>
                            </xsl:attribute>


                            <!-- Documentation Tag if it exists. -->
                            <xsl:for-each
                                select="./UML:ModelElement.taggedValue[1]/UML:TaggedValue[./UML:TaggedValue.type/UML:TagDefinition/@xmi.idref = $vDocumentTagId]">
                                <xsd:annotation>
                                    <xsd:documentation>
                                        <xsl:value-of select="./UML:TaggedValue.dataValue"/>
                                    </xsd:documentation>
                                </xsd:annotation>
                            </xsl:for-each>

                            <xsl:choose>

                                <!-- Extension if applicable -->
                                <xsl:when
                                    test="./UML:GeneralizableElement.generalization[1]/UML:Generalization">
                                    <xsl:element name="xsd:complexContent">
                                        <xsl:element name="xsd:extension">
                                            <xsl:attribute name="base">
                                                <xsl:variable name="vGeneralizationRef"
                                                  select="./UML:GeneralizableElement.generalization[1]/UML:Generalization[1]/@xmi.idref"/>
                                                <xsl:variable name="vParentIdRef"
                                                  select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Generalization[@xmi.id = $vGeneralizationRef]/UML:Generalization.parent[1]/UML:Class[1]/@xmi.idref"/>
                                                <xsl:value-of
                                                  select="concat(/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class[@xmi.id = $vParentIdRef]/@name, 'Type')"
                                                />
                                            </xsl:attribute>

                                            <!-- Populate the xsd:element and xsd:attributes in the defined content model -->
                                            <xsl:call-template name="niematron:fxnAddClassContent">
                                                <xsl:with-param name="vClassRootNode" select="."/>
                                            </xsl:call-template>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:when>

                                <!-- No extension required -->
                                <xsl:otherwise>
                                    <!-- Populate the xsd:element and xsd:attributes in the defined content model -->
                                    <xsl:call-template name="niematron:fxnAddClassContent">
                                        <xsl:with-param name="vClassRootNode" select="."/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:element>
                    </xsl:for-each>

                    <!-- Abstract Data Elements -->
                    <xsl:if
                        test="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface">
                        <xsl:text>
                        
   </xsl:text>
                        <xsl:comment>Global Abstract Elements</xsl:comment>
                    </xsl:if>
                    <xsl:for-each
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface">

                        <xsl:element name="xsd:element">
                            <xsl:attribute name="name">
                                <xsl:value-of select="./@name"/>
                            </xsl:attribute>
                            <xsl:attribute name="abstract">
                                <xsl:value-of select="'true'"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:for-each>

                    <!-- Substitution Elements/Lines -->
                    <xsl:text>
                        
   </xsl:text>
                    <xsl:comment>Global Elements</xsl:comment>
                    <xsl:variable name="vRealizeStereotype"
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Stereotype[@name='realize']/@xmi.id"/>
                    <xsl:for-each
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Class">

                        <xsl:element name="xsd:element">
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:value-of select="concat(@name,'Type')"/>
                            </xsl:attribute>
                            <xsl:variable name="vClassAbstrRef"
                                select="./UML:ModelElement.clientDependency/UML:Abstraction/@xmi.idref"/>

                            <xsl:if
                                test="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Abstraction[@xmi.id=$vClassAbstrRef]/UML:ModelElement.stereotype[1]/UML:Stereotype/@xmi.idref = $vRealizeStereotype">
                                <xsl:variable name="vAbstractRef"
                                    select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Abstraction[@xmi.id=$vClassAbstrRef]/UML:Dependency.supplier/UML:Interface/@xmi.idref"/>
                                <xsl:attribute name="substitutionGroup">
                                    <xsl:value-of
                                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Interface[@xmi.id=$vAbstractRef]/@name"
                                    />
                                </xsl:attribute>
                            </xsl:if>
                        </xsl:element>
                    </xsl:for-each>

                    <!-- Enumerations -->
                    <xsl:if
                        test="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Enumeration">
                        <xsl:text>
                        
   </xsl:text>
                        <xsl:comment>Global Enumerations</xsl:comment>
                    </xsl:if>
                    <xsl:for-each
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:Enumeration">
                        <xsl:element name="xsd:simpleType">
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                            </xsl:attribute>

                            <xsl:element name="xsd:restriction">
                                <xsl:attribute name="base">
                                    <xsl:value-of select="'xsd:token'"/>
                                </xsl:attribute>

                                <xsl:for-each
                                    select="./UML:Enumeration.literal[1]/UML:EnumerationLiteral">
                                    <xsl:element name="xsd:enumeration">
                                        <xsl:attribute name="value">
                                            <xsl:value-of select="@name"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:for-each>

                            </xsl:element>

                        </xsl:element>
                    </xsl:for-each>

                    <!-- WARNING: UNSUPPORTED DATA TYPE -->
                    <xsl:if
                        test="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:DataType">
                        <xsl:text>
                        
   </xsl:text>
                        <xsl:comment>WARNING: UNSUPPORTED DATA TYPES! Please remap to a data type in
                            xsd.xmi profile.</xsl:comment>
                    </xsl:if>
                    <xsl:for-each
                        select="/XMI/XMI.content[1]/UML:Model[1]/UML:Namespace.ownedElement[1]/UML:DataType">
                        <xsl:element name="xsd:simpleType">
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                            </xsl:attribute>

                            <xsl:element name="xsd:restriction">
                                <xsl:attribute name="base">
                                    <xsl:value-of select="'xsd:string'"/>
                                </xsl:attribute>
                            </xsl:element>

                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>

            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>
    <!-- *****************************  -->

</xsl:stylesheet>
