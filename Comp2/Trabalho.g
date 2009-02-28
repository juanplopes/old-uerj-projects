grammar Trabalho;

options { k=1; }

@header
{
	import java.util.HashMap;
	import java.util.ArrayList;
}

	
@members
{
	public class Operando 
	{
		public Boolean imediato;
		public Integer value;
		
		public String toString() 
		{
			String res = "";

			res += value.toString();
			if (imediato) res += "#";
			
			return res;
		}
	}

	public class Quad 
	{
		public String operador;
		public Operando op1;
		public Operando op2;
		public Operando op3;
		
		public String toString() 
		{
			String res = operador + '\t';
		
			if (op1 != null)
				res += op1.toString() + '\t';
			if (op2 != null)
				res += op2.toString() + '\t';
			if (op3 != null)
				res += op3.toString() + '\t';
				
			return res;
		}
	}

	HashMap<String, Operando> simbs = new HashMap<String, Operando>();
	ArrayList<Quad> quads = new ArrayList<Quad>();
	int memptr = 0;

	public Operando mem(Integer end) 
	{
		Operando op = new Operando();
		op.value = end;
		op.imediato = false;
		return op;
	}
	
	public Operando imed(Integer val) 
	{
		Operando op = new Operando();
		op.value = val;
		op.imediato = true;
		return op;
	}
	
	public void gera(String op, Operando op1, Operando op2, Operando op3) 
	{
		Quad q = new Quad();
		q.operador = op;
		q.op1 = op1;
		q.op2 = op2;
		q.op3 = op3;
		quads.add(q);
	}
	
	public void remenda(Integer pos, String op, Operando op1, Operando op2, Operando op3) 
	{
		Quad q = quads.get(pos);
		q.operador = op;
		q.op1 = op1;
		q.op2 = op2;
		q.op3 = op3;
	}
	
	public Operando aloca(String var) 
	{
		if (!simbs.containsKey(var))
			simbs.put(var, mem(memptr++));

		return consulta(var);
	}
	
	public Operando consulta(String var) 
	{
		return simbs.get(var);
	}
	
	public Operando temp() 
	{
		return mem(memptr++);
	}
}

/* A regra programa � uma lista de comandos encerrados com '.'
 * Equivale � regra P -> L '.' */
prog:	list '.'
		// Entre chaves temos a a��o associada � regra P -> L '.'
		// Nesse caso, imprime a lista de qu�druplas
		{ 
			for (Integer i = 0; i < quads.size(); i++) {
			    System.out.print(i + "\t");
			    System.out.println(quads.get(i).toString());
			}
		};

/* A regra lista � uma sequ�ncia de comandos separados por ';'.
   Equivale �s regras L -> S; L e L -> S
   Note que o �ltimo comando n�o � seguido por ';'
*/
list	
	:	stat (';' stat)* 
		// N�o possui a��o associada
	;

/* A regra comando define os diferentes comandos da linguagem
 * Equivale �s regras S -> V ':=' E
                      S -> 'begin' L 'end'
                      S -> 'if' E 'then' M S 'endif'
                      S -> 'if' E 'then' M S 'else' M S 'endif'
                      S -> 'while' N E M 'do' S 'enddo'
                      S -> 'repeat' S 'until' E
                      s -> 'do' S 'while' E
  */
stat :
	v=var ':=' e=expr
	{ 
		gera("MOV", $v.op, $e.op, null); 
	} |	
	
	'begin' list 'end' |
	
	'if' e=expr 'then' m1=m stat 
	{
		Integer quad = quads.size();
	}
	(
		'else' m2=m stat
		{
			remenda($m2.quad, "J", mem(quads.size()), null, null);
			quad = $m2.quad + 1;
		}
	)?
	'endif'
	{
		remenda($m1.quad, "JF", $e.op, mem(quad), null);
	} |	
	
	'while' n1=n e=expr m1=m 'do' stat 'enddo'
	{
		gera("J", mem($n1.quad), null, null);
		remenda($m1.quad, "JF", $e.op, mem(quads.size()), null);
	} |
	
	'repeat' n1=n stat 'until' e=expr
	{
		gera("JF", $e.op, mem($n1.quad), null);
	} |
	
	'do' n1=n stat 'while' e=expr
	{
		gera("JT", $e.op, mem($n1.quad), null);
	} ;
	
/* Essa regra equivale � regra M -> e (epsilon), ou seja, n�o corresponde � trecho de c�digo nenhum.
  Por�m, � necess�rio para "guardar" a posi��o de uma qu�drupla que requer preenchimento posterior.
 */
m returns[Integer quad] :
	{ 
		quad = quads.size();
		gera("", null, null, null);
	} ;
	
n returns[Integer quad] :
	{ 
		quad = quad = quads.size();
	} ;

// $<ExprToFactor

expr returns[Operando op] : 
	e=exprOr
	{
		op = $e.op;
	} ;


exprOr returns[Operando op] :
	e1=exprXor
	{
		op = $e1.op;
	}
	(
		'or' e2=exprXor
		{ 
			Operando taux = temp();
			gera("OR", $e1.op, $e2.op, taux);
			op = taux;
		} 
	)*	;


exprXor returns[Operando op] :
	e1=exprAnd
	{
		op = $e1.op;
	}
	(
		'xor' e2=exprAnd
		{ 
			Operando taux = temp();
			gera("XOR", $e1.op, $e2.op, taux);
			op = taux;
		}
	)*	;

exprAnd returns[Operando op] :
	e1=exprEqu
	{
		op = $e1.op;
	}
	(
		'and' e2=exprEqu
		{ 
			Operando taux = temp();
			gera("AND", $e1.op, $e2.op, taux);
			op = taux;
		} 
	)*	;

exprEqu returns[Operando op] :
	e1=exprRel
	{
		op = $e1.op;
	}
	(
		'=' e2=exprRel
		{ 
			Operando taux = temp();
			gera("SOE", $e1.op, $e2.op, taux); //Set on Equal
			op = taux;
		} |
		'!=' e2=exprRel
		{ 
			Operando taux = temp();
			gera("SOD", $e1.op, $e2.op, taux); //Set on Diff
			op = taux;
		} 
	)*	;

exprRel returns[Operando op] :
	e1=exprShift
	{
		op = $e1.op;
	}
	(
		'<' e2=exprShift
		{ 
			Operando taux = temp();
			gera("SLT", $e1.op, $e2.op, taux); //Set on Less Than
			op = taux;
		} |
		'<=' e2=exprShift
		{ 
			Operando taux = temp();
			gera("SLTE", $e1.op, $e2.op, taux); //Set on Less Than or Equal
			op = taux;
		} |
		'>' e2=exprShift
		{ 
			Operando taux = temp();
			gera("SGT", $e1.op, $e2.op, taux); //Set on Greater Than
			op = taux;
		} |
		'>=' e2=exprShift
		{ 
			Operando taux = temp();
			gera("SGTE", $e1.op, $e2.op, taux); //Set on Greater Than or Equal
			op = taux;
		}
	)*	;

exprShift returns[Operando op] :
	e1=exprSum
	{
		op = $e1.op;
	}
	(
		'<<' e2=exprSum
		{ 
			Operando taux = temp();
			gera("SLL", $e1.op, $e2.op, taux); //Shift Left Logical
			op = taux;
		} |
		'>>' e2=exprSum
		{ 
			Operando taux = temp();
			gera("SRL", $e1.op, $e2.op, taux); //Shift Right Logical
			op = taux;
		} 
	)*	;


exprSum returns[Operando op] :
	e1=exprMul
	{
		op = $e1.op;
	}
	(
		'+' e2=exprMul
		{ 
			Operando taux = temp();
			gera("ADD", $e1.op, $e2.op, taux);
			op = taux;
		} |
		'-' e2=exprMul
		{
			Operando taux = temp();
			gera("SUB", $e1.op, $e2.op, taux);
			op = taux;
		}
	)*	;


exprMul	returns[Operando op] :
	e1=exprPow
	{
		op = $e1.op;
	}
	(
		'*' e2=exprPow
		{ 
			Operando taux = temp();
			gera("MUL", $e1.op, $e2.op, taux);
			op = taux;
		} |
		'/' e2=exprPow
		{
			Operando taux = temp();
			gera("DIV", $e1.op, $e2.op, taux);
			op = taux;
		}
	)*	;
	
exprPow returns[Operando op] : 
	e1=factor
	{
		op = $e1.op;
	}
	(
		'**' e2=factor
		{
			Operando taux = temp();
			gera("EXP", $e1.op, $e2.op, taux);
			op = taux;
		}
	)* ;

factor returns[Operando op] :	
	'(' e=expr ')' 
	{
		op = $e.op;
	} |	
	
	v=var
	{
		op = $v.op;
	} |
	
	v=literal
	{
		op = $v.op;
	} ;
	
	

// $>

/* Regra V -> id */	
var	returns[Operando op] :
	ID
	{ 
		op = aloca($ID.text);
	};

literal returns[Operando op] :
	NUMBER
	{
		op = imed(Integer.parseInt($NUMBER.text));
	};
	

/*
Essa parte do c�digo representa o analisador l�xico.
A conven��o, estabelecida como regra pelo ANTLR, diz que regras sInteger�ticas
come�am com letra min�scula, enquanto que os tokens l�xicos come�am com letra MAI�SCULA
 */
	
ID	
	: LETTER ( DIGIT | LETTER )*
	;

NUMBER : ('-'|'+')?DIGIT*;
	
WHITESPACE 	
	: ( '\t' | ' ' | '\r' | '\n'| '\u000C' )+ 
	
	// Despreza espa�os em branco
	{ $channel = HIDDEN; } ;
	
fragment DIGIT	
	: '0'..'9' ;
	
fragment LETTER
	: 'a'..'z'
	| 'A'..'Z'
	;