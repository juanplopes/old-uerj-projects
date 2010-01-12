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
                        Console.WriteLine("Validando XML contra o Schema...");

                        var settings = new XmlReaderSettings();
                        settings.Schemas.Add(XmlSchema.Read(schemaFile, (obj, e) => Console.WriteLine(e.Message)));
                        settings.ValidationType = ValidationType.Schema;

                        using (var reader = XmlReader.Create(file, settings))
                            while (reader.Read()) ;

                        file.Seek(0, SeekOrigin.Begin);

                        XmlSerializer xml = new XmlSerializer(typeof(XmlCenarios));
                        var cenarios = (XmlCenarios)xml.Deserialize(XmlReader.Create(file, settings));

                        Console.WriteLine();
                        Console.WriteLine("Cenários: " + cenarios.Cenarios.Count);
                        Console.WriteLine("Conectores: " + cenarios.Cenarios.SelectMany(x => x.Conectores).Count());
                        Console.WriteLine();

                        ColorPrint("Validação fase 1: OK", ConsoleColor.Green);

                        Console.WriteLine("Validação referências de nome de cenário...");
                        var inexistent = cenarios.Cenarios.SelectMany(x => x.Conectores.Select(y => y.CenarioRelacionado).Where(z => cenarios.Cenarios.Count(w => w.Nome == z) == 0));

                        if (inexistent.Count() > 0) throw new InvalidOperationException("Conectores inválidos. Rever referências aos cenários: " + string.Join(", ", inexistent.ToArray()));

                        ColorPrint("Validação fase 2: OK", ConsoleColor.Green);

                        Console.WriteLine("Validando não-existência de ciclos...");

                        var cycle = HasCycles(cenarios);
                        if (cycle != null) throw new InvalidOperationException("Encontrado ciclo: " + string.Join(" > ", cycle.Select(x=>x.Nome).ToArray()));

                        ColorPrint("Validação fase 3: OK", ConsoleColor.Green);

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

        static IEnumerable<XmlCenario> HasCycles(XmlCenarios cenarios)
        {
            var dic = cenarios.Cenarios.ToDictionary(x => x.Nome);
            foreach (var cenario in cenarios.Cenarios)
            {
                var cycle = HasCycles(cenario, dic);
                if (cycle.Count() > 0) return cycle;
            }
            return null;
        }

        class Node
        {
            public Node Ultimo { get; set; }
            public XmlCenario Cenario { get; set; }
        }

        static IEnumerable<XmlCenario> HasCycles(XmlCenario cenario, IDictionary<string, XmlCenario> dic)
        {
            var queue = new Queue<Node>();
            queue.Enqueue(new Node { Cenario = cenario });

            bool first = true;

            while (queue.Count > 0)
            {
                var item = queue.Dequeue();
                if (cenario == item.Cenario && !first)
                {
                    while (item != null)
                    {
                        yield return item.Cenario;
                        item = item.Ultimo;
                    }

                    yield break;
                }

                foreach (var child in item.Cenario.Conectores.Select(x => dic[x.CenarioRelacionado]))
                {
                    queue.Enqueue(new Node { Cenario = child, Ultimo = item });
                }
                first = false;
            }
            yield break;
        }


        static void ColorPrint(string text, ConsoleColor color)
        {
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = ConsoleColor.Gray;
        }
    }
}
