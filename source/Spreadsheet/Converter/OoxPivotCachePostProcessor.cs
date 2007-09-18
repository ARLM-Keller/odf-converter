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
using System.Xml;
using System.Collections;
using System.IO;
using CleverAge.OdfConverter.OdfConverterLib;

namespace CleverAge.OdfConverter.Spreadsheet
{

    public class OoxPivotCachePostProcessor : AbstractPostProcessor
    {
        private Stack pivotContext;
        private const string PXSI_NAMESPACE = "urn:cleverage:xmlns:post-processings:pivotTable";
        private const string REL_NAMESPACE = "http://schemas.openxmlformats.org/package/2006/relationships";
        private const string EXCEL_NAMESPACE = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        private bool isPxsi;

        //<pxsi:pivotTable> variables
        private bool isInPivotTable;        
        private bool isSheetNum;
        private string cacheSheetNum;
        private bool isColStart;
        private string cacheColStart;
        private bool isColEnd;
        private string cacheColEnd;
        private bool isRowStart;
        private string cacheRowStart;
        private bool isRowEnd;
        private string cacheRowEnd;
        private string[,] pivotTable;
        private Hashtable[,] fieldItems;
        private Hashtable[] fieldNames;
        //fieldItems[i,j] (dimesion i equals number of pivotFields, dimesion j equals 2) 
        //fieldItems variable for each pivotField contains hashtable with unique values of this pivotField and a sequential number
        //at fieldItems[i,0] pivotField[i] values are the key and sequential number are the key values
        //at fieldItems[i,1] sequential number is the key and pivotField[i] values are the key values  

        //<pxsi:pivotCell> variables
        private bool isInPivotCell;
        private Hashtable pivotCells;
        private bool isPivotCellSheet;
        private string pivotCellSheet;
        private bool isPivotCellCol;
        private string pivotCellCol;
        private bool isPivotCellRow;
        private string pivotCellRow;
        private string pivotCellVal;

        //<pxsi:sharedItems> variables
        private bool isInSharedItems;
        private bool isFieldType;
        private string fieldType; //{"axis", "data" or "empty"}
        private bool isFieldName;
        private string fieldName;
        private string cacheFields;

        //<pxsi:cacheRecords> variables
        private bool isInCacheRecords;

        //<pxsi:items> variables
        private bool isInItems;
        private bool isItemsFieldName;
        private string itemsFieldName;
        private bool isItemsHide;
        private string itemsHide;

        //<pxsi:pageItem> variables
        private bool isInPageItem;
        private bool isPageField;
        private string pageField;
        private bool isPageItem;
        private string pageItem;

        public OoxPivotCachePostProcessor(XmlWriter nextWriter)
            : base(nextWriter)
        {
            this.pivotContext = new Stack();
            this.isPxsi = false;

            //<pxsi:pivotTable> variables
            this.isInPivotTable = false;
            this.isSheetNum = false;
            this.cacheSheetNum = "";
            this.isColStart = false;
            this.cacheColStart = "";
            this.isColEnd = false;
            this.cacheColEnd = "";
            this.isRowStart = false;
            this.cacheRowStart = "";
            this.isRowEnd = false;
            this.cacheRowEnd = "";

            //<pxsi:pivotCell> variables
            this.isInPivotCell = false;
            this.isPivotCellSheet = false;
            this.pivotCellSheet = "";
            this.isPivotCellCol = false;
            this.pivotCellCol = "";
            this.isPivotCellRow = false;
            this.pivotCellRow = "";
            this.pivotCellVal = "";
            this.pivotCells = new Hashtable();

            //<pxsi:sharedItems> variables
            this.isInSharedItems = false; ;
            this.isFieldType = false; ;
            this.fieldType = "";
            this.isFieldName = false;
            this.fieldName = "";
            this.cacheFields = ",";

            //<pxsi:cacheRecords> variables
            this.isInCacheRecords = false;

            //<pxsi:items> variables
            this.isInItems = false;
            this.isItemsFieldName = false;
            this.itemsFieldName = "";
            this.isItemsHide = false;
            this.itemsHide = "";

            //<pxsi:pageItem> variables
            this.isInPageItem = false;
            this.isPageField = false;
            this.pageField = "";
            this.isPageItem = false;
            this.pageItem = "";
}

        public override void WriteStartElement(string prefix, string localName, string ns)
        {

            if (PXSI_NAMESPACE.Equals(ns) && "pivotCell".Equals(localName))
            {
                this.pivotContext = new Stack();
                this.pivotContext.Push(new Element(prefix, localName, ns));
                this.isInPivotCell = true;
                this.isPxsi = true;
                //Console.WriteLine("<PivotCell>");
            }
            else if (PXSI_NAMESPACE.Equals(ns) && "pivotTable".Equals(localName))
            {
                this.pivotContext = new Stack();
                this.pivotContext.Push(new Element(prefix, localName, ns));
                this.isInPivotTable = true;
                this.isPxsi = true;
                //Console.WriteLine("<PivotTable>");
            }
            else if (PXSI_NAMESPACE.Equals(ns) && "sharedItems".Equals(localName))
            {
                this.pivotContext = new Stack();
                this.pivotContext.Push(new Element(prefix, localName, ns));
                this.isInSharedItems = true;
                this.isPxsi = true;
            }
            else if (PXSI_NAMESPACE.Equals(ns) && "cacheRecords".Equals(localName))
            {
                this.pivotContext = new Stack();
                this.pivotContext.Push(new Element(prefix, localName, ns)); 
                this.isInCacheRecords = true;
                this.isPxsi = true;
            }
            else if (PXSI_NAMESPACE.Equals(ns) && "items".Equals(localName))
            {
                this.pivotContext = new Stack();
                this.pivotContext.Push(new Element(prefix, localName, ns));
                this.isInItems = true;
                this.isPxsi = true;
            }
            else if (PXSI_NAMESPACE.Equals(ns) && "pageItem".Equals(localName))
            {
                this.pivotContext = new Stack();
                this.pivotContext.Push(new Element(prefix, localName, ns));
                this.isInPageItem = true;
                this.isPxsi = true;
            }
            else
            {
                this.nextWriter.WriteStartElement(prefix, localName, ns);
            }
        }

        public override void WriteStartAttribute(string prefix, string localName, string ns)
        {
            if (isInPivotTable)
            {
                if (PXSI_NAMESPACE.Equals(ns) && "sheetNum".Equals(localName))
                    this.isSheetNum = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "colStart".Equals(localName))
                    this.isColStart = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "colEnd".Equals(localName))
                    this.isColEnd = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "rowStart".Equals(localName))
                    this.isRowStart = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "rowEnd".Equals(localName))
                    this.isRowEnd = true;
            }
            else if (isInPivotCell)
            {
                if (PXSI_NAMESPACE.Equals(ns) && "col".Equals(localName))
                    this.isPivotCellCol = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "row".Equals(localName))
                    this.isPivotCellRow = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "sheetNum".Equals(localName))
                    this.isPivotCellSheet = true;
            }
            else if (isInSharedItems)
            {
                if (PXSI_NAMESPACE.Equals(ns) && "fieldType".Equals(localName))
                    this.isFieldType = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "fieldName".Equals(localName))
                    this.isFieldName = true;
            }
            else if (isInItems)
            {
                if (PXSI_NAMESPACE.Equals(ns) && "field".Equals(localName))
                    this.isItemsFieldName = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "hide".Equals(localName))
                    this.isItemsHide = true;
            }
            else if (isInPageItem)
            {
                if (PXSI_NAMESPACE.Equals(ns) && "pageField".Equals(localName))
                    this.isPageField = true;
                else if (PXSI_NAMESPACE.Equals(ns) && "pageItem".Equals(localName))
                    this.isPageItem = true;
            }
            else
            {
                this.nextWriter.WriteStartAttribute(prefix, localName, ns);
            }
        }

        public override void WriteString(string text)
        {
            if (isInPivotTable)
            {
                if (isSheetNum)
                    this.cacheSheetNum += text;
                else if (isColStart)
                    this.cacheColStart += text;
                else if (isColEnd)
                    this.cacheColEnd += text;
                else if (isRowStart)
                    this.cacheRowStart += text;
                else if (isRowEnd)
                    this.cacheRowEnd += text;
            }
            else if (isInPivotCell)
            {
                if (isPivotCellCol)
                    this.pivotCellCol += text;
                else if (isPivotCellRow)
                    this.pivotCellRow += text;
                else if (isPivotCellSheet)
                    this.pivotCellSheet += text;
                else
                    this.pivotCellVal += text;
            }
            else if (isInSharedItems)
            {
                if (isFieldType)
                    this.fieldType += text;
                else if (isFieldName)
                    this.fieldName += text;
            }
            else if (isInItems)
            {
                if (isItemsFieldName)
                    this.itemsFieldName += text;
                else if (isItemsHide)
                    this.itemsHide += text;
            }
            else if (isInPageItem)
            {
                if (isPageField)
                    this.pageField += text;
                else if (isPageItem)
                    this.pageItem += text;
            }
            else
            {
                this.nextWriter.WriteString(text);
            }
        }

        public override void WriteEndAttribute()
        {

            if (isSheetNum)
                this.isSheetNum = false;
            else if (isColStart)
                this.isColStart = false;
            else if (isColEnd)
                this.isColEnd = false;
            else if (isRowStart)
                this.isRowStart = false;
            else if (isRowEnd)
                this.isRowEnd = false;
            else if (isPivotCellCol)
                this.isPivotCellCol = false;
            else if (isPivotCellRow)
                this.isPivotCellRow = false;
            else if (isPivotCellSheet)
                this.isPivotCellSheet = false;
            else if (isFieldType)
                this.isFieldType = false;
            else if (isFieldName)
                this.isFieldName = false;
            else if (isItemsFieldName)
                this.isItemsFieldName = false;
            else if (isItemsHide)
                this.isItemsHide = false;
            else if (isPageField)
                this.isPageField = false;
            else if (isPageItem)
                this.isPageItem = false;
            else if (!isPxsi)
                this.nextWriter.WriteEndAttribute();
        }

        public override void WriteEndElement()
        {

            if (isPxsi)
            {
				Element element = (Element) pivotContext.Pop();

                if (PXSI_NAMESPACE.Equals(element.Ns) && "pivotTable".Equals(element.Name))
                {
                    this.pivotTable = new string[Convert.ToInt32(cacheRowEnd) - Convert.ToInt32(cacheRowStart) + 1, Convert.ToInt32(cacheColEnd) - Convert.ToInt32(cacheColStart) + 1];
                    CreatePivotTable(Convert.ToInt32(cacheSheetNum),Convert.ToInt32(cacheRowStart),Convert.ToInt32(cacheRowEnd),Convert.ToInt32(cacheColStart),Convert.ToInt32(cacheColEnd));

                    foreach (string key in fieldNames[0].Keys)
                        //Console.WriteLine("\t - " + key + ":" + fieldNames[0][key].ToString()); 
                    
                    this.isInPivotTable = false;
                    
                    //other <pivotTable> variables are being used in other postprocessor commands
                    //so they are not erased here

                    this.isPxsi = false;
                }
                else if (PXSI_NAMESPACE.Equals(element.Ns) && "pivotCell".Equals(element.Name))
                {
                    pivotCells.Add(pivotCellSheet + "#" + pivotCellCol + ":" + pivotCellRow, pivotCellVal);

                    this.isInPivotCell = false;
                    this.pivotCellSheet = "";
                    this.pivotCellCol = "";
                    this.pivotCellRow = "";
                    this.pivotCellVal = "";
                    this.isPxsi = false;
                }
                else if (PXSI_NAMESPACE.Equals(element.Ns) && "sharedItems".Equals(element.Name))
                {

                    //store in cacheFields variable processed field names
                    if (!"empty".Equals(fieldType))
                        this.cacheFields += fieldName + ",";

                    if("date".Equals(fieldType))
                    {
                        int field = Convert.ToInt32(fieldNames[0][fieldName]);
                        //Console.WriteLine(fieldName + ": " + field.ToString());

                        InsertSharedItemAttributes(field);
                    }
                    else if ("axis".Equals(fieldType))
                    {
                        int field = Convert.ToInt32(fieldNames[0][fieldName]);
                        //Console.WriteLine(fieldName + ": " + field.ToString());

                        InsertSharedItemAttributes(field);

                        //insert "count" attribute
                        this.nextWriter.WriteStartAttribute("count");
                        this.nextWriter.WriteString((string)this.fieldItems[field, 0].Count.ToString());
                        this.nextWriter.WriteEndAttribute();

                        for (int i = 0; i < this.fieldItems[field, 1].Count; i++)
                        {

                            // <e> - error, <d> - date and <b> - bool not handled for now

                            try
                            {
                                //if field value is a number
                                Convert.ToDouble(this.fieldItems[field, 1][i].ToString().Replace('.', ','));
                                this.nextWriter.WriteStartElement("n", EXCEL_NAMESPACE);
                                this.nextWriter.WriteStartAttribute("v");
                                this.nextWriter.WriteString(this.fieldItems[field, 1][i].ToString());
                                this.nextWriter.WriteEndAttribute();
                            }
                            catch
                            {
                                //if field value is a string
                                if (this.fieldItems[field, 1][i].ToString().Length == 0)
                                    //blank value
                                    this.nextWriter.WriteStartElement("m", EXCEL_NAMESPACE);
                                else
                                {
                                    this.nextWriter.WriteStartElement("s", EXCEL_NAMESPACE);
                                    this.nextWriter.WriteStartAttribute("v");
                                    this.nextWriter.WriteString(this.fieldItems[field, 1][i].ToString());
                                    this.nextWriter.WriteEndAttribute();
                                }
                            }

                            this.nextWriter.WriteEndElement();
                        }
                    }
                    else if ("empty".Equals(fieldType))
                    {
                        Console.WriteLine(cacheFields);

                        foreach (string key in fieldNames[0].Keys)
                        {
                            if (!cacheFields.Contains("," + key + ","))
                            {
                                int field = Convert.ToInt32(fieldNames[0][key]);

                                this.nextWriter.WriteStartElement("cacheField", EXCEL_NAMESPACE);
                                    this.nextWriter.WriteStartAttribute("name");
                                    this.nextWriter.WriteString(key);
                                    this.nextWriter.WriteEndAttribute();
                                
                                    this.nextWriter.WriteStartElement("sharedItems", EXCEL_NAMESPACE);
                                    InsertSharedItemAttributes(field);
                                    this.nextWriter.WriteEndElement();

                                this.nextWriter.WriteEndElement();
                            }
                        }
                    }

                    this.isInSharedItems = false;
                    this.fieldName = "";
                    this.fieldType = "";
                    this.isPxsi = false;
                }
                else if (PXSI_NAMESPACE.Equals(element.Ns) && "cacheRecords".Equals(element.Name))
                {
                    string value;

                    int rows = Convert.ToInt32(cacheRowEnd) - Convert.ToInt32(cacheRowStart) + 1;
                    int cols = Convert.ToInt32(cacheColEnd) - Convert.ToInt32(cacheColStart) + 1;

                    for (int row = 0; row < rows; row++)
                    {
                        this.nextWriter.WriteStartElement("r",EXCEL_NAMESPACE);
                        for (int col = 0; col < cols; col++)
                        {
                            try
                            {
                                //if this is number value
                                Convert.ToDouble(pivotTable[row, col].Replace('.',','));
                                this.nextWriter.WriteStartElement("n",EXCEL_NAMESPACE);
                                this.nextWriter.WriteStartAttribute("v");
                                this.nextWriter.WriteString(pivotTable[row, col]);
                                this.nextWriter.WriteEndAttribute();
                                this.nextWriter.WriteEndElement();
                            }
                            catch
                            {
                                //if this is string value
                                this.nextWriter.WriteStartElement("x",EXCEL_NAMESPACE);
                                this.nextWriter.WriteStartAttribute("v");
                                value = pivotTable[row, col];
                                this.nextWriter.WriteString(this.fieldItems[col, 0][value].ToString());
                                this.nextWriter.WriteEndAttribute();
                                this.nextWriter.WriteEndElement();
                            }
                        }                         
                        this.nextWriter.WriteEndElement();
                    }
                    this.isInCacheRecords = false;
                    this.isPxsi = false;
                    
                }
                else if (PXSI_NAMESPACE.Equals(element.Ns) && "items".Equals(element.Name))
                {
                    int fieldNum = Convert.ToInt32(fieldNames[0][itemsFieldName]);

                    int items = fieldItems[fieldNum, 0].Count;

                    this.nextWriter.WriteStartAttribute("count");
                    this.nextWriter.WriteString((items + 1).ToString());
                    this.nextWriter.WriteEndAttribute();

                    Hashtable numbers = new Hashtable();
                    Hashtable strings = new Hashtable();

                    bool isBlank = false;

                    foreach (string key in fieldItems[fieldNum, 0].Keys)
                    {
                        try
                        {
                            Convert.ToDouble(key.ToString().Replace('.',','));
                            numbers.Add(key.ToString().Replace('.', ','),key);
                        }
                        catch
                        {
                            if (key.Length == 0)
                                isBlank = true;
                            else
                                strings.Add(key,key);
                        }

                    }

                    double[] sortedNumbers = new double[numbers.Count];
                    string[] sortedStrings = new string[strings.Count];

                    //sort numbers and strings
                    int count = 0;
                    foreach (string key in numbers.Keys)
                    {
                        sortedNumbers[count] = Convert.ToDouble(key);
                        count++;
                    }
                    Array.Sort(sortedNumbers);
                    count = 0;
                    foreach (string key in strings.Keys)
                    {
                        sortedStrings[count] = key;
                        count++;
                    }
                    Array.Sort(sortedStrings);

                    //output sorted item types in order: numbers, strings, blank
                    for (int i = 0; i < sortedNumbers.Length; i++)
                    {
                        OutputItem(sortedNumbers[i].ToString().Replace(',', '.'));
                    }

                    for (int i = 0; i < sortedStrings.Length; i++)
                    //foreach (string text in sortedStrings)
                    {
                        OutputItem(sortedStrings[i]);
                    }

                    if (isBlank)
                        OutputItem("");

                    this.isInItems = false;
                    this.itemsFieldName = "";
                    this.itemsHide = "";
                    this.isPxsi = false;
                }
                else if (PXSI_NAMESPACE.Equals(element.Ns) && "pageItem".Equals(element.Name))
                {
                    int fieldNum = Convert.ToInt32(fieldNames[0][pageField]);
                    this.nextWriter.WriteStartAttribute("item");
                    //output value increased by 1
                    this.nextWriter.WriteString((Convert.ToInt32(fieldItems[fieldNum,0][pageItem]) + 1).ToString());
                    this.nextWriter.WriteEndAttribute();

                    this.isInPageItem = false;
                    this.pageField = "";
                    this.pageItem = "";
                    this.isPxsi = false;
                }
                else
                {
                    this.nextWriter.WriteEndElement();
                }
            }
            else
            {
                this.nextWriter.WriteEndElement();
            }
        }

        private void CreatePivotTable(int sheetNum, int rowStart, int rowEnd, int colStart, int colEnd)
        {

            int rows = rowEnd - rowStart + 1;
            int cols = colEnd - colStart + 1;
            int[] index = new int[cols];

            this.fieldNames = new Hashtable[2];
            this.fieldItems = new Hashtable[cols, 2];

            //initialize Hashtables
            for (int i = 0; i < 2; i++)
            {
                fieldNames[i] = new Hashtable();
                for (int field = 0; field < cols; field++)
                    fieldItems[field, i] = new Hashtable();
            }
            
            //fill fieldNames
            for (int col = 0; col < cols; col++)
            {
                int keyCol = Convert.ToInt32(colStart) + col;
                int keyRow = Convert.ToInt32(rowStart) - 1;

                string key = sheetNum + "#" + keyCol.ToString() + ":" + keyRow.ToString();
                
                if (!fieldNames[0].ContainsKey((string)pivotCells[key]))
                {
                    fieldNames[0].Add((string)pivotCells[key], col);
                    fieldNames[1].Add(col, (string)pivotCells[key]);
                }
            }

            //fill pivotTable and fieldItems
            for (int row = 0; row < rows; row++)
                for (int col = 0; col < cols; col++)
                {
                    int keyCol = Convert.ToInt32(colStart) + col;
                    int keyRow = Convert.ToInt32(rowStart) + row;

                    string key = sheetNum + "#" + keyCol.ToString() + ":" + keyRow.ToString();

                    if (pivotCells.ContainsKey(key))
                    {                        
                        this.pivotTable[row, col] = (string)pivotCells[key];

                        if (!fieldItems[col,0].ContainsKey((string)pivotCells[key]))
                        {
                            fieldItems[col,0].Add((string)pivotCells[key], index[col]);
                            fieldItems[col,1].Add(index[col],(string)pivotCells[key]);
                            index[col]++;
                        }
                    }
                    else
                    {
                        this.pivotTable[row, col] = "";
                        if (!fieldItems[col,0].ContainsKey(""))
                        {
                            //fieldItems[col].Add("", index[col]);
                            fieldItems[col,0].Add("", index[col]);
                            fieldItems[col,1].Add(index[col],"");
                            index[col]++;
                        }
                    }
                }

            //Console.WriteLine(indeces[0].Count);
                //foreach (string key in this.fieldItems[0].Keys)
                //{
                //    Console.WriteLine("-" + fieldItems[0][key] + ":" + key);
                //}

        }

        private void InsertSharedItemAttributes(int field)
        {
            bool containsDouble = false;

            //attributes
            bool containsBlank = false;
            //bool containsDate;        //not checked for now but it is in specification
            bool containsInteger = false;
            //bool containsNonDate;     //can be omitted without loss of functionality
            bool containsNumber = false;
            bool containsString = false;
            bool longText = false;      //not checked for now but it is in specification
            //double minValue;
            //double maxValue;
            //minDate                   //not checked for now but it is in specification
            //maxDate                   //not checked for now but it is in specification

            //analize items
//            Console.WriteLine("FIELD" + field.ToString());
            for (int i = 0; i < this.fieldItems[field, 1].Count; i++)
            {
                //check weather an item is an integer
                try
                {
                    Convert.ToDouble(this.fieldItems[field, 1][i].ToString().Replace('.', ','));
                    if (this.fieldItems[field, 1][i].ToString().Contains("."))
                    {
                        containsNumber = true;
                        containsDouble = true;

                    }

                    //check weather an item is an integer
                    try
                    {
                        Convert.ToInt32(this.fieldItems[field, 1][i]);
                        containsNumber = true;
                        containsInteger = true;
                    }
                    catch
                    {
                    }
                }
                catch
                {
                    string text = this.fieldItems[field, 1][i].ToString();

//                    Console.WriteLine(text.Length + "(" + text +")");
                    if (text.Length == 0)
                    {
                        containsBlank = true;
//                        Console.WriteLine("-----BLANK-----");
                    }
                    else if (text.Length > 255)
                        longText = true;
                    else
                        containsString = true;
                }
            }

                if (containsBlank)
                {
                    this.nextWriter.WriteStartAttribute("containsBlank");
                    this.nextWriter.WriteString("1");
                    this.nextWriter.WriteEndAttribute();
                }
                if (containsInteger && !containsDouble)
                {
                    this.nextWriter.WriteStartAttribute("containsInteger");
                    this.nextWriter.WriteString("1");
                    this.nextWriter.WriteEndAttribute();
                }
                if (containsNumber)
                {
                    this.nextWriter.WriteStartAttribute("containsNumber");
                    this.nextWriter.WriteString("1");
                    this.nextWriter.WriteEndAttribute();
                }
                if (containsNumber && containsString)
                {
                    this.nextWriter.WriteStartAttribute("containsMixedTypes");
                    this.nextWriter.WriteString("1");
                    this.nextWriter.WriteEndAttribute();
                }
                if (containsNumber && !containsString && !containsBlank)
                {
                    this.nextWriter.WriteStartAttribute("containsSemiMixedTypes");
                    this.nextWriter.WriteString("0");
                    this.nextWriter.WriteEndAttribute();
                }
                if (!containsString)
                {
                    this.nextWriter.WriteStartAttribute("containsString");
                    this.nextWriter.WriteString("0");
                    this.nextWriter.WriteEndAttribute();
                }
        }

        private void OutputItem(string key)
        {
            //Console.WriteLine(itemsFieldName);
            int fieldNum = Convert.ToInt32(fieldNames[0][itemsFieldName]); 
            
            this.nextWriter.WriteStartElement("item", EXCEL_NAMESPACE);

            //if this item is hidden
            if (itemsHide.Contains(";" + key + ";"))
            {
                this.nextWriter.WriteStartAttribute("h");
                this.nextWriter.WriteString("1");
                this.nextWriter.WriteEndAttribute();
            }
            this.nextWriter.WriteStartAttribute("x");
            this.nextWriter.WriteString(fieldItems[fieldNum, 0][key].ToString());
            this.nextWriter.WriteEndAttribute();
            this.nextWriter.WriteEndElement();
        }

    }
}
