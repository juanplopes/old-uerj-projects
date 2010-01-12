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

                        Console.WriteLine("Validação fase 3...");

                        var cycle = HasCycles(cenarios);
                        if (cycle != null) throw new InvalidOperationException("Encontrado ciclo: " + string.Join(" > ", MountCycle(cycle, cenarios).ToArray()));

                        ColorPrint("Validação fase 3: OK", ConsoleColor.Green);

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
            Console.WriteLine("Pressione qualquer tecla para sair.");
            Console.ReadKey();
        }

        static XmlCenario HasCycles(XmlCenarios cenarios)
        {
            var alreadySeen = new HashSet<XmlCenario>();
            var dic = cenarios.Cenarios.ToDictionary(x => x.Nome);
            foreach (var cenario in cenarios.Cenarios)
            {
                if (!alreadySeen.Contains(cenario)) {
                    if (HasCycles(cenario, dic)) return cenario;
                }
            }
            return null;
        }

        static bool HasCycles(XmlCenario cenario, IDictionary<string, XmlCenario> dic)
        {
            var alreadySeen = new HashSet<XmlCenario>();
            var queue = new Queue<XmlCenario>();
            queue.Enqueue(cenario);

            while (queue.Count > 0)
            {
                var item = queue.Dequeue();
                if (alreadySeen.Contains(item)) return true;
                alreadySeen.Add(item);
                foreach (var child in item.Conectores.Select(x => dic[x.CenarioRelacionado]))
                {
                    queue.Enqueue(child);
                }
            }
            return false;
        }

        static IList<string> MountCycle(XmlCenario cenario, XmlCenarios cenarios)
        {
            var dic = cenarios.Cenarios.ToDictionary(x => x.Nome);
            var queue = new Queue<XmlCenario>();
            var list = new List<string>();
            queue.Enqueue(cenario);
            while (queue.Count > 0)
            {
                var item = queue.Dequeue();
                list.Add(item.Nome);
                if (item == cenario && list.Count > 1) return list;
                
                foreach (var child in item.Conectores.Select(x => dic[x.CenarioRelacionado]))
                {
                    queue.Enqueue(child);
                }
            }
            return list;
        }

        static void ColorPrint(string text, ConsoleColor color)
        {
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = ConsoleColor.Gray;
        }
    }
}
