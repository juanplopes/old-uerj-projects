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
	
	//Esse método faz o corpo do for ser executado antes do seu incremento.
	public void remendaFor(int incStart, int incSize, int statEnd) {
		for (int i=0; i<incSize; i++) {
			Quad q = quads.remove(incStart);
			quads.add(statEnd - 1, q);
		}
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

/* A regra programa é uma lista de comandos encerrados com '.'
 * Equivale à regra P -> L '.' */
prog:	list '.'
		// Entre chaves temos a ação associada à regra P -> L '.'
		// Nesse caso, imprime a lista de quádruplas
		{ 
			gera("NOP", null, null, null);
			for (Integer i = 0; i < quads.size(); i++) {
			    System.out.print(i + "\t");
			    System.out.println(quads.get(i).toString());
			}
		};

/* A regra lista é uma sequência de comandos separados por ';'.
   Equivale às regras L -> S; L e L -> S
   Note que o último comando não é seguido por ';'
*/
list	
	:	stat (';' stat)* 
		// Não possui ação associada
	;

/* A regra comando define os diferentes comandos da linguagem
 * Equivale às regras S -> V ':=' E
                      S -> 'begin' L 'end'
                      S -> 'if' E 'then' M S 'endif'
                      S -> 'if' E 'then' M S 'else' M S 'endif'
                      S -> 'while' N E M 'do' S 'enddo'
                      S -> 'repeat' S 'until' E
                      s -> 'do' S 'while' E
  */
stat scope {
		Integer quad;
	} :
	v=var ':=' e=expr
	{ 
		gera("MOV", $v.op, $e.op, null); 
	} |	
	
	'begin' list 'end' | 
	
	'if' e=expr 'then' m1=m stat 
	{
		$stat::quad = quads.size();
	}
	(
		'else' m2=m stat
		{
			remenda($m2.quad, "J", mem(quads.size()), null, null);
			$stat::quad = $m2.quad + 1;
		}
	)?
	'endif'
	{
		remenda($m1.quad, "JF", $e.op, mem($stat::quad), null);
	} |	
	'for' forInit ';' n1=n c=forCond m1=m ';' i1=forIncrement 'do' st2=forStatements 'enddo'
	{
		remendaFor($i1.quad, $i1.nquads, $st2.end);
		gera("J", mem($c.quad), null, null);
		remenda($m1.quad, "JF", $c.op, mem(quads.size()), null);
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
	} |
	'print' e1=expr //Comando de impressão para testes.
	{
		gera("OUT", $e1.op, null, null);
	}
	;

// $<ForHelperRules
forInit	:
	v1=var ':=' e1=expr
	{
		gera("MOV", $v1.op, $e1.op, null);
	} ;

forCond	returns[Integer quad, Operando op] :
	{
		$quad = quads.size();
	}	
	e=expr {
		$op = $e.op;
	}
	;

forIncrement returns[int quad, int nquads] :
	{
		$quad = quads.size();
	}	
		v=var ':=' e=expr
	{
		gera("MOV", $v.op, $e.op, null);
	}
	{
		$nquads = quads.size() - $quad;
	} ;

forStatements returns [int end]:
	stat
	{
		$end = quads.size();
	} ;
// $>	

	
/* Essa regra equivale à regra M -> e (epsilon), ou seja, não corresponde à trecho de código nenhum.
  Porém, é necessário para "guardar" a posição de uma quádrupla que requer preenchimento posterior.
 */
m returns[Integer quad] :
	{ 
		$quad = quads.size();
		gera("", null, null, null);
	} ;
	
n returns[Integer quad] :
	{ 
		$quad = quads.size();
	} ;

// $<ExprToFactor

expr returns[Operando op] : 
	e=exprOr
	{
		$op = $e.op;
	} ;

exprOr returns[Operando op] :
	e1=exprXor
	{
		$op = $e1.op;
	}
	(
		'|' e2=exprXor
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value | $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("OR", $op, $e2.op, taux);
				$op = taux;
			}
		} 
	)*	;



exprAnd returns[Operando op] :
	e1=exprEqu
	{
		$op = $e1.op;
	}
	(
		'&' e2=exprEqu
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value & $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("AND", $op, $e2.op, taux);
				$op = taux;
			}
		} 
	)*	;
exprXor returns[Operando op] :
	e1=exprAnd
	{
		$op = $e1.op;
	}
	(
		'^' e2=exprAnd
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value ^ $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("XOR", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*	;



exprEqu returns[Operando op] :
	e1=exprRel
	{
		$op = $e1.op;
	}
	(
		'=' e2=exprRel
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = ($e1.op.value == $e2.op.value) ? 1 : 0;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SEQ", $op, $e2.op, taux); //Set on Equal
				$op = taux;
			}
		} |
		'!=' e2=exprRel
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = ($e1.op.value != $e2.op.value) ? 1 : 0;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SNE", $op, $e2.op, taux); //Set on Diff
				$op = taux;
			}
		} 
	)*	;

exprRel returns[Operando op] :
	e1=exprShift
	{
		$op = $e1.op;
	}
	(
		'<' e2=exprShift
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = ($e1.op.value < $e2.op.value) ? 1 : 0;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SLT", $op, $e2.op, taux); //Set on Less Than
				$op = taux;
			}
		} |
		'<=' e2=exprShift
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = ($e1.op.value <= $e2.op.value) ? 1 : 0;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SLE", $op, $e2.op, taux); //Set on Less Than or Equal
				$op = taux;
			}
		} |
		'>' e2=exprShift
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = ($e1.op.value > $e2.op.value) ? 1 : 0;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SGT", $op, $e2.op, taux); //Set on Greater Than
				$op = taux;
			}
		} |
		'>=' e2=exprShift
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = ($e1.op.value >= $e2.op.value) ? 1 : 0;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SGE", $op, $e2.op, taux); //Set on Greater Than or Equal
				$op = taux;
			}
		}
	)*	;
exprShift returns[Operando op] :
	e1=exprSum
	{
		$op = $e1.op;
	}
	(
		'<<' e2=exprSum
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value << $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SLL", $op, $e2.op, taux); //Shift Left Logical
				$op = taux;
			}
		} |
		'>>' e2=exprSum
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value >> $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SRL", $op, $e2.op, taux); //Shift Right Logical
				$op = taux;
			}
		} 
	)*	;

exprSum returns[Operando op] :
	e1=exprMul
	{
		$op = $e1.op;
	}
	(
		'+' e2=exprMul
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value + $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("ADD", $op, $e2.op, taux);
				$op = taux;
			}
		} |
		'-' e2=exprMul
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value - $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("SUB", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*	;

exprMul	returns[Operando op] :
	e1=exprPow
	{
		$op = $e1.op;
	}
	(
		'*' e2=exprPow
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value * $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("MUL", $op, $e2.op, taux);
				$op = taux;
			}
		} |
		'/' e2=exprPow
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = $e1.op.value / $e2.op.value;
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("DIV", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*	;


	
exprPow returns[Operando op] : 
	e1=unary
	{
		$op = $e1.op;
	}
	(
		'**' e2=unary
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$e1.op.value = (int)Math.pow($e1.op.value, $e2.op.value);
				$op = $e1.op;
			} else {
				Operando taux = temp();
				gera("EXP", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)* ;

unary returns[Operando op] : 
	e1=factor 
	{
		$op = $e1.op;
	} |
	'-' e2=unary
	{
		if ($e2.op.imediato) {
			$e2.op.value = - $e2.op.value;
			$op = $e2.op;
		} else {
			Operando taux = temp();
			gera("NEG", $op, $e2.op, taux);
			$op = taux;
		}
	} |
	'+' e2=unary
	{
		if ($e2.op.imediato)
			$op = $e2.op;
		else {
			Operando taux = temp();
			$op = taux;
		}
	} |
	'~' e2=unary
	{
		if ($e2.op.imediato) {
			$e2.op.value = ~ $e2.op.value;
			$op = $e2.op;
		} else {
			Operando taux = temp();
			gera("NOT", $op, $e2.op, taux);
			$op = taux;
		}
	} |
	'!' e2=unary
	{
		if ($e2.op.imediato) {
			$e2.op.value = ($e2.op.value == 0) ? 1 : 0;
			$op = $e2.op;
		} else {
			Operando taux = temp();
			gera("LNOT", $op, $e2.op, taux);
			$op = taux;
		}
	}
	;

factor returns[Operando op] :	
	'(' e=expr ')' 
	{
		$op = $e.op;
	} |	
	
	v=var
	{
		$op = $v.op;
	} |
	
	v=literal
	{
		$op = $v.op;
	} ;
	
	

// $>

/* Regra V -> id */	
var	returns[Operando op] :
	ID
	{ 
		$op = aloca($ID.text);
	};

literal returns[Operando op] :
	NUMBER
	{
		$op = imed(Integer.parseInt($NUMBER.text));
	};
	

/*
Essa parte do código representa o analisador léxico.
A convenção, estabelecida como regra pelo ANTLR, diz que regras sIntegeráticas
começam com letra minúscula, enquanto que os tokens léxicos começam com letra MAIÚSCULA
 */
	
ID	
	: LETTER ( DIGIT | LETTER )*
	;

NUMBER : DIGIT+;
	
WHITESPACE 	
	: ( '\t' | ' ' | '\r' | '\n'| '\u000C' )+ 
	
	// Despreza espaços em branco
	{ $channel = HIDDEN; } ;
	
fragment DIGIT	
	: '0'..'9' ;
	
fragment LETTER
	: 'a'..'z'
	| 'A'..'Z'
	;
