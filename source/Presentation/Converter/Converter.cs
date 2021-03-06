﻿/* 
 * Copyright (c) 2007, Sonata Software Limited
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Clever Age nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;
using CleverAge.OdfConverter.OdfConverterLib;

namespace Sonata.OdfConverter.Presentation
{
    public class Converter : AbstractConverter
    {
        private const string ODF_MIME_TYPE_PRESENTATION = "application/vnd.oasis.opendocument.presentation";
        private const string ODF_MIME_TYPE_PRESENTATION_TEMPLATE = "application/vnd.oasis.opendocument.presentation-template";

        public Converter() : base(Assembly.GetExecutingAssembly()) { }

        protected override Type LoadPrecompiledXslt()
        {
            Type stylesheet = null;
            try
            {
                if (this.DirectTransform)
                {
                    stylesheet = Assembly.Load("PresentationConverter2Oox")
                                            .GetType("PresentationConverter2Oox");
                }
                else
                {
                    stylesheet = Assembly.Load("PresentationConverter2Odf")
                                            .GetType("PresentationConverter2Odf");
                }
            }
            catch (Exception)
            {
                return null;
            }
            return stylesheet;
        }


        protected override string[] DirectPostProcessorsChain
        {
            get
            {
                string fullname = Assembly.GetExecutingAssembly().FullName;
                return new string[]  {
                   "CleverAge.OdfConverter.OdfConverterLib.OoxSpacesPostProcessor",
        	       "CleverAge.OdfConverter.OdfConverterLib.OoxCharactersPostProcessor"
                };
            }
        }

        protected override string[] ReversePostProcessorsChain
        {
            get
            {
                string fullname = Assembly.GetExecutingAssembly().FullName;
                return new string[]  {
                    "CleverAge.OdfConverter.OdfConverterLib.OdfCharactersPostProcessor"
                };
            }
        }

        protected override void CheckOdfFile(string fileName)
        {
            // Test for encryption
            XmlDocument docContent, docStyle, doc;
            try
            {
                XmlReaderSettings settings = new XmlReaderSettings();
                settings.XmlResolver = new ZipResolver(fileName);
                settings.ProhibitDtd = false;
                doc = new XmlDocument();
                XmlReader reader = XmlReader.Create("META-INF/manifest.xml", settings);
                doc.Load(reader);
                docStyle = new XmlDocument();
                XmlReader readerStyle = XmlReader.Create("styles.xml", settings);
                docStyle.Load(readerStyle);

                docContent = new XmlDocument();
                XmlReader readerContent = XmlReader.Create("content.xml", settings);
                docContent.Load(readerContent);

                string svgNameSpace = docContent.DocumentElement.Attributes["xmlns:svg"].Value.ToString();
                if (svgNameSpace == "http://www.w3.org/2000/svg")
                {
                    throw new NotAnOdfDocumentException("Could not convert " + fileName + ". Invalid OASIS OpenDocument file");
                }

            }
            catch (Exception e)
            {
                throw new NotAnOdfDocumentException(e.Message);
            }

            XmlNodeList nodes = doc.GetElementsByTagName("encryption-data", "urn:oasis:names:tc:opendocument:xmlns:manifest:1.0");
            if (nodes.Count > 0)
            {
                throw new EncryptedDocumentException(fileName + " is an encrypted document");
            }

            // Check the document mime-type.
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
            nsmgr.AddNamespace("manifest", "urn:oasis:names:tc:opendocument:xmlns:manifest:1.0");

            XmlNode node = doc.SelectSingleNode("/manifest:manifest/manifest:file-entry[@manifest:media-type='" 
                                                    + ODF_MIME_TYPE_PRESENTATION + "' or @manifest:media-type='"
                                                    + ODF_MIME_TYPE_PRESENTATION_TEMPLATE + "']", nsmgr);
            if (node == null)
            {
                throw new NotAnOdfDocumentException("Could not convert " + fileName + ". Invalid OASIS OpenDocument file");
            }

        }

        protected override void CheckOoxFile(string fileName)
        {
            //Validator for pptx
            PptxValidator v = new PptxValidator();
            v.validate(fileName);
        }

    }
}
