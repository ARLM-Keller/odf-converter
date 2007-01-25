/* 
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
using System.Collections.Generic;
using System.Windows.Forms;
using CleverAge.OdfConverter.OdfWordAddinLib;
using System.Runtime.InteropServices;
using System.Reflection;

namespace OdfConverterLauncher
{
    class Word
    {
        Type _type;
        object _instance;
        Type _docsType;
        object _documents;

        public Word()
        {
            _type = Type.GetTypeFromProgID("Word.Application");
            _instance = Activator.CreateInstance(_type);
            _docsType = null;
            _documents = null;
        }

        public bool Visible
        {
            set
            {
                object[] args = new object[] { value };
                _type.InvokeMember("Visible", BindingFlags.SetProperty, null, _instance, args);
            }
        }

        public void Quit()
        {
            object[] args = new object[] { Missing.Value,
                                            Missing.Value,
                                            Missing.Value };
            _type.InvokeMember("Quit", BindingFlags.InvokeMethod, null, _instance, args);
        }

        public void Open(string document)
        {
            if (_documents == null)
            {
                _documents = _type.InvokeMember("Documents", BindingFlags.GetProperty, null, _instance, null);
                _docsType = _documents.GetType();
            }
            object[] args = new object[] { document };
            object aDoc = _docsType.InvokeMember("Open", BindingFlags.InvokeMethod, null, _documents, args);
            Type aType = aDoc.GetType();
            object fields = aType.InvokeMember("Fields", BindingFlags.GetProperty, null, aDoc, null);
            Type fieldsType = fields.GetType();
            fieldsType.InvokeMember("Update", BindingFlags.InvokeMethod, null, fields, null);
        }
    }

    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            if (args.Length == 1) 
            {
                string input = args[0];
                OdfWordAddinLib lib = new OdfWordAddinLib();
                try
                {
                    bool showUserInterface = true;   
                    string output = lib.GetTempFileName(input);
                    lib.OdfToOox(input, output, showUserInterface);
                    Word word = new Word();
                    word.Visible = true;
                    word.Open(output);
                }
                catch (Exception e)
                {
                    System.Resources.ResourceManager rm = new System.Resources.ResourceManager("OdfWordAddinLib.resources.Labels", 
                        Assembly.GetAssembly(lib.GetType()));
                    InfoBox infoBox = new InfoBox("OdfUnexpectedError", e.GetType() + ": " + e.Message + " (" + e.StackTrace + ")",  rm);
                    infoBox.ShowDialog();
                }

            }
        }

    }
}