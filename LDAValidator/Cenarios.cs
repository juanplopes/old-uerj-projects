using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace LDAValidator
{
    [XmlRoot("cenarios", Namespace="http://uerj.br/LDASchema")]
    public class XmlCenarios
    {
        [XmlElement("cenario")]
        public List<XmlCenario> Cenarios { get; set; }
    }

    public class XmlCenario
    {
        [XmlElement("nome")]
        public string Nome { get; set; }

        [XmlElement("conector")]
        public List<XmlConector> Conectores { get; set; }
    }



    public class XmlConector
    {
        public enum XmlEnumTipo
        {
            [XmlEnum("restricao")]
            Restricao,
            
            [XmlEnum("pre_condicao")]
            PreCondicao,

            [XmlEnum("sub_cenario")]
            SubCenario,

            [XmlEnum("excecao")]
            Excecao
        }

        [XmlElement("tipo")]
        public XmlEnumTipo Tipo { get; set; }
        [XmlElement("cenario_relacionado")]
        public string CenarioRelacionado { get; set; }
    }
}
