using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using CleverAge.OdfConverter.OdfConverterLib;

namespace CleverAge.OdfConverter.Presentation
{
    public class Converter : AbstractConverter
    {


        public Converter() : base(Assembly.GetExecutingAssembly()) { }


    }
}
