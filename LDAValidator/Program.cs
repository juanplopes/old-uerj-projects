using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Xml;
using System.IO;
using System.Xml.Schema;
using System.Xml.Serialization;
using System.Text;

namespace LDAValidator
{
    static class Program
    {
        static void Main(string[] args)
        {
            string fileName = "LDASample.xml";
            if (args.Length > 0)
                fileName = args[0];

            try
            {
                using (var file = File.Open(fileName, FileMode.Open))
                {
                    using (var schemaFile = new MemoryStream(Encoding.UTF8.GetBytes(Resources.LDASchema)))
                    {
                        Console.WriteLine("Validação fase 1...");

                        var settings = new XmlReaderSettings();
                        settings.Schemas.Add(XmlSchema.Read(schemaFile, (obj, e) => Console.WriteLine(e.Message)));
                        settings.ValidationType = ValidationType.Schema;

                        using (var reader = XmlReader.Create(file, settings))
                            while (reader.Read()) ;

                        file.Seek(0, SeekOrigin.Begin);

                        XmlSerializer xml = new XmlSerializer(typeof(XmlCenarios));
                        var cenarios = (XmlCenarios)xml.Deserialize(XmlReader.Create(file, settings));

                        ColorPrint("Validação fase 1: OK", ConsoleColor.Green);

                        Console.WriteLine("Validação fase 2...");
                        var inexistent = cenarios.Cenarios.SelectMany(x => x.Conectores.Select(y => y.CenarioRelacionado).Where(z => cenarios.Cenarios.Count(w => w.Nome == z) == 0));

                        if (inexistent.Count() > 0) throw new InvalidOperationException("Conectores inválidos. Rever referências aos cenários: " + string.Join(", ", inexistent.ToArray()));

                        ColorPrint("Validação fase 2: OK", ConsoleColor.Green);

                        Console.WriteLine();
                        Console.WriteLine("Cenários: " + cenarios.Cenarios.Count);
                        Console.WriteLine("Conectores: " + cenarios.Cenarios.SelectMany(x=>x.Conectores).Count());
                    }
                }
            }
            catch (Exception e)
            {
                while (e != null)
                {
                    ColorPrint(e.Message, ConsoleColor.Red);
                    e = e.InnerException;
                }
            }
            Console.ReadKey();
        }

        static void ColorPrint(string text, ConsoleColor color)
        {
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = ConsoleColor.Gray;
        }
    }
}
