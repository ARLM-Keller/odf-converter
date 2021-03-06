﻿/* 
 * Copyright (c) 2006, Clever Age
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
using System.IO;
using System.Reflection;
using System.Xml;
using System.Xml.Schema;
using System.Collections;

using CleverAge.OdfConverter.OdfZipUtils;
using CleverAge.OdfConverter.OdfConverterLib;
#if MONO
// no Tenuto yet
#else
using Tenuto.Reader;
using Tenuto.Grammar;
using Tenuto.Verifier;
#endif


namespace OdfConverter.CommandLineTool
{
	
#if MONO
	// Dummy validation class
	public class OdfValidator : IValidator
	{
		public OdfValidator(ConversionReport report)
		{ 
		}
		public void validate(String fileName)
		{
			System.Console.WriteLine("Dummy validator");
		}
	}
#else 
	// Not Mono

    /// <summary>Check the validity of an ODF file. Throws a ValidationException if an errors occurs</summary>
    public class OdfValidator : IValidator
	{
        private const string RESOURCES_LOCATION = ".resources.";
		
        // namespaces and related schemas
        private static string ODF_SCHEMA = "odfschemas.OpenDocumentSchema10.rng";

        private XmlReader grammarName = null;
        private Grammar grammar = null;
        private ConversionReport report;

		/// <summary>
		/// Initialize the validator
		/// </summary>
		public OdfValidator(ConversionReport report)
		{
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ValidationType = ValidationType.None;
            settings.XmlResolver = new EmbeddedResourceResolver(Assembly.GetExecutingAssembly(), 
                this.GetType().Namespace, RESOURCES_LOCATION, false);
            this.grammarName = XmlReader.Create(ODF_SCHEMA, settings);
            this.report = report;
            try
            {
                this.grammar = new GrammarReader(new ReportController(this.report)).parse(this.grammarName);
            }
            catch (Exception e)
            {
                throw new ValidationException("Problem parsing grammar file : " + e.Message);
            }
        }
		
	    /// <summary>
	    /// Check the validity of an Office Open XML file.
	    /// </summary>
	    /// <param name="fileName">The path of the docx file.</param>
		public void validate(String fileName)
		{
            ZipReader reader = null;
            bool isValid = true;
            try
            {
                reader = ZipFactory.OpenArchive(fileName);
                
            }
            catch (Exception e)
            {
                throw new ValidationException("Problem opening ODF file : " + e.Message);
            }
            try
            {
                Stream content = null;
                content = reader.GetEntry("content.xml");
                XmlReader xmlReader = XmlReader.Create(content);
                isValid &= Verifier.Verify(xmlReader, this.grammar, new ErrorReporter (this.report, fileName + "|" + "content.xml"));
            }
            catch (ZipEntryNotFoundException e)
            {
                throw new ValidationException("Entry not found in ODF file [content.xml]: " + e.Message);
            }
            catch (Exception e)
            {
                this.report.LogDebug(fileName, "Problem validating ODF file [content.xml]: " + e.Message);
            }
            try
            {
                Stream content = null;
                content = reader.GetEntry("styles.xml");
                XmlReader xmlReader = XmlReader.Create(content);
                isValid &= Verifier.Verify(xmlReader, this.grammar, new ErrorReporter(this.report, fileName + "|" + "styles.xml"));
            }
            catch (ZipEntryNotFoundException)
            {
                this.report.LogDebug(fileName, "Entry not found: styles.xml");
            }
            catch (Exception e)
            {
                this.report.LogDebug(fileName, "Problem validating ODF file [styles.xml]: " + e.Message);
            }
            try
            {
                Stream content = null;
                content = reader.GetEntry("meta.xml");
                XmlReader xmlReader = XmlReader.Create(content);
                isValid &= Verifier.Verify(xmlReader, this.grammar, new ErrorReporter(this.report, fileName + "|" + "meta.xml"));
            }
            catch (ZipEntryNotFoundException)
            {
                this.report.LogDebug(fileName, "Entry not found: meta.xml");
            }
            catch (Exception e)
            {
                this.report.LogDebug(fileName, "Problem validating ODF file [meta.xml]: " + e.Message);
            }
            try
            {
                Stream content = null;
                content = reader.GetEntry("settings.xml");
                XmlReader xmlReader = XmlReader.Create(content);
                isValid &= Verifier.Verify(xmlReader, this.grammar, new ErrorReporter(this.report, fileName + "|" + "settings.xml"));
            }
            catch (ZipEntryNotFoundException)
            {
                this.report.LogDebug(fileName, "Entry not found: settings.xml");
            }
            catch (Exception e)
            {
                this.report.LogDebug(fileName, "Problem validating ODF file [settings.xml]: " + e.Message);
            }
            if (!isValid)
            {
                throw new ValidationException("File is not valid");
            }
        }

        private class ErrorReporter:Tenuto.Verifier.ErrorHandler
        {
            private ConversionReport report;
            private string filename;

            public ErrorReporter(ConversionReport report, string filename)
            {
                this.report = report;
                this.filename = filename;
            }

            public void Error(string msg)
            {
                this.report.LogDebug(this.filename, msg);
            }

        }

        private class ReportController : GrammarReaderController
        {
            private ConversionReport report;

            public ReportController(ConversionReport report)
            {
                this.report = report;
            }

            public void error(string msg, IXmlLineInfo loc)
            {
                this.report.AddComment("Error: " + msg);
            }

            public void warning(string msg, IXmlLineInfo loc)
            {
                this.report.AddComment("Warning: " + msg);
            }

        }
	}
#endif
}
