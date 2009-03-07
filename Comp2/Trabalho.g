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
	
	//Esse m�todo faz o corpo do for ser executado antes do seu incremento.
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

/* A regra programa � uma lista de comandos encerrados com '.'
 * Equivale � regra P -> L '.' */
prog
	: list '.'
	// Entre chaves temos a a��o associada � regra P -> L '.'
	// Nesse caso, imprime a lista de qu�druplas
	{ 
		gera("NOP", null, null, null);
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
	: stat (';' stat)*  // N�o possui a��o associada
	;

stat
	: attribution
	| ifThenElse
	| 'begin' list 'end'
	| forLoop
	| whileLoop
	| repeatLoop
	| doLoop
	| print
	;

// $<Statements
attribution
	: var ':=' expr
	{ gera("MOV", $var.op, $expr.op, null); };

ifThenElse
@init {
	Integer quad;
}	
	: 'if' expr 'then' m1=m stat
	{ quad = quads.size(); }
	(
		'else' m2=m stat
		{
			remenda($m2.quad, "J", imed(quads.size()-$m2.quad), null, null);
			quad = $m2.quad + 1;
		}
	)?
	'endif'
	{ remenda($m1.quad, "JF", $expr.op, imed(quad-$m1.quad), null); };
	
forLoop
	: 'for' attribution ';' n forCond m ';' forIncrement 'do' forStatements 'enddo'
	{
		remendaFor($forIncrement.quad, $forIncrement.nquads, $forStatements.end);
		gera("J", imed($n.quad-quads.size()), null, null);
		remenda($m.quad, "JF", $forCond.op, imed(quads.size()-$m.quad), null);
	};

whileLoop
	: 'while' n expr m 'do' stat 'enddo'
	{
		gera("J", imed(quads.size()-$n.quad), null, null);
		remenda($m.quad, "JF", $expr.op, imed(quads.size()-$m.quad), null);
	};
	
repeatLoop 
	: 'repeat' n stat 'until' expr
	{ gera("JF", $expr.op, imed($n.quad-quads.size()), null); };
	
doLoop
	: 'do' n stat 'while' expr
	{ gera("JT", $expr.op, imed($n.quad-quads.size()), null); };
	
print
	: 'print' expr //Comando de impress�o para testes.
	{ gera("OUT", $expr.op, null, null); };
// $>

// $<ForHelperRules
forCond	returns[Operando op]
	: expr { $op = $expr.op; };

forIncrement returns[int quad, int nquads]
@init { $quad = quads.size(); }	
@after { $nquads = quads.size() - $quad; }
	: attribution ;

forStatements returns [int end]
	: stat
	{ $end = quads.size(); };
// $>	

	
/* Essa regra equivale � regra M -> e (epsilon), ou seja, n�o corresponde � trecho de c�digo nenhum.
  Por�m, � necess�rio para "guardar" a posi��o de uma qu�drupla que requer preenchimento posterior.
 */
m returns[Integer quad]
	:
	{ 
		$quad = quads.size();
		gera("", null, null, null);
	};
	
n returns[Integer quad]
	:
	{ $quad = quads.size(); };

// $<ExprToFactor
expr returns[Operando op]
	: exprOr
	{ $op = $exprOr.op;	};

exprOr returns[Operando op]
	: e1=exprXor
	{ $op = $e1.op; }
	(
		'|' e2=exprXor
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value | $e2.op.value;
			} else {
				Operando taux = temp();
				gera("OR", $op, $e2.op, taux);
				$op = taux;
			}
		} 
	)*;

exprAnd returns[Operando op]
	: e1=exprEqu
	{ $op = $e1.op; }
	(
		'&' e2=exprEqu
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value & $e2.op.value;
			} else {
				Operando taux = temp();
				gera("AND", $op, $e2.op, taux);
				$op = taux;
			}
		} 
	)*;
exprXor returns[Operando op]
	: e1=exprAnd
	{ $op = $e1.op; }
	(
		'^' e2=exprAnd
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value ^ $e2.op.value;
			} else {
				Operando taux = temp();
				gera("XOR", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*;



exprEqu returns[Operando op]
	: e1=exprRel
	{ $op = $e1.op; }
	(
		'=' e2=exprRel
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = ($e1.op.value == $e2.op.value) ? 1 : 0;
			} else {
				Operando taux = temp();
				gera("SEQ", $op, $e2.op, taux); //Set on Equal
				$op = taux;
			}
		}
		| '!=' e2=exprRel
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = ($e1.op.value != $e2.op.value) ? 1 : 0;
			} else {
				Operando taux = temp();
				gera("SNE", $op, $e2.op, taux); //Set on Not Equal
				$op = taux;
			}
		} 
	)*;

exprRel returns[Operando op]
	: e1=exprShift
	{ $op = $e1.op; }
	(
		'<' e2=exprShift
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = ($e1.op.value < $e2.op.value) ? 1 : 0;
			} else {
				Operando taux = temp();
				gera("SLT", $op, $e2.op, taux); //Set on Less Than
				$op = taux;
			}
		}
		| '<=' e2=exprShift
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = ($e1.op.value <= $e2.op.value) ? 1 : 0;
			} else {
				Operando taux = temp();
				gera("SLE", $op, $e2.op, taux); //Set on Less Than or Equal
				$op = taux;
			}
		}
		| '>' e2=exprShift
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = ($e1.op.value > $e2.op.value) ? 1 : 0;
			} else {
				Operando taux = temp();
				gera("SGT", $op, $e2.op, taux); //Set on Greater Than
				$op = taux;
			}
		}
		| '>=' e2=exprShift
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = ($e1.op.value >= $e2.op.value) ? 1 : 0;
			} else {
				Operando taux = temp();
				gera("SGE", $op, $e2.op, taux); //Set on Greater Than or Equal
				$op = taux;
			}
		}
	)*;
	
exprShift returns[Operando op]
	: e1=exprSum
	{ $op = $e1.op; }
	(
		'<<' e2=exprSum
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value << $e2.op.value;
			} else {
				Operando taux = temp();
				gera("SLL", $op, $e2.op, taux); //Shift Left Logical
				$op = taux;
			}
		}
		| '>>' e2=exprSum
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value >> $e2.op.value;
			} else {
				Operando taux = temp();
				gera("SRL", $op, $e2.op, taux); //Shift Right Logical
				$op = taux;
			}
		} 
	)*;

exprSum returns[Operando op]
	: e1=exprMul
	{ $op = $e1.op; }
	(
		'+' e2=exprMul
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value + $e2.op.value;
			} else {
				Operando taux = temp();
				gera("ADD", $op, $e2.op, taux);
				$op = taux;
			}
		}
		| '-' e2=exprMul
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value - $e2.op.value;
			} else {
				Operando taux = temp();
				gera("SUB", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*;

exprMul	returns[Operando op]
	: e1=exprPow
	{ $op = $e1.op; }
	(
		'*' e2=exprPow
		{ 
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value * $e2.op.value;
			} else {
				Operando taux = temp();
				gera("MUL", $op, $e2.op, taux);
				$op = taux;
			}
		}
		| '/' e2=exprPow
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value / $e2.op.value;
			} else {
				Operando taux = temp();
				gera("DIV", $op, $e2.op, taux);
				$op = taux;
			}
		}
		| '%' e2=exprPow
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = $e1.op.value \% $e2.op.value; //O ANTLR nos obriga a escapar o s�mbolo de m�dulo.
			} else {
				Operando taux = temp();
				gera("MOD", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*;
	
exprPow returns[Operando op]
	: e1=unary
	{ $op = $e1.op; }
	(
		'**' e2=unary
		{
			if ($e1.op.imediato && $e2.op.imediato) {
				$op.value = (int)Math.pow($e1.op.value, $e2.op.value);
			} else {
				Operando taux = temp();
				gera("EXP", $op, $e2.op, taux);
				$op = taux;
			}
		}
	)*;

unary returns[Operando op]
	: e1=factor 
	{ $op = $e1.op; }
	| '-' e2=unary
	{
		if ($e2.op.imediato) {
			$e2.op.value = - $e2.op.value;
			$op = $e2.op;
		} else {
			Operando taux = temp();
			gera("NEG", $e2.op, taux, null);
			$op = taux;
		}
	}
	| '+' e2=unary
	{
		if ($e2.op.imediato)
			$op = $e2.op;
		else {
			Operando taux = temp();
			$op = taux;
		}
	}
	| '~' e2=unary
	{
		if ($e2.op.imediato) {
			$e2.op.value = ~ $e2.op.value;
			$op = $e2.op;
		} else {
			Operando taux = temp();
			gera("NOT", $e2.op, taux, null); //Bitwise NOT
			$op = taux;
		}
	}
	| '!' e2=unary
	{
		if ($e2.op.imediato) {
			$e2.op.value = ($e2.op.value == 0) ? 1 : 0;
			$op = $e2.op;
		} else {
			Operando taux = temp();
			gera("LNOT", $e2.op, taux, null); //Logical not
			$op = taux;
		}
	};

factor returns[Operando op]
	: '(' e=expr ')' 
	{
		$op = $e.op;
	}
	| v=var
	{
		$op = $v.op;
	}
	| v=literal
	{
		$op = $v.op;
	};
// $>

/* Regra V -> id */	
var	returns[Operando op]
	: ID
	{
		$op = aloca($ID.text);
	};

literal returns[Operando op]
	: NUMBER
	{
		$op = imed(Integer.parseInt($NUMBER.text));
	};
	
/*
Essa parte do c�digo representa o analisador l�xico.
A conven��o, estabelecida como regra pelo ANTLR, diz que regras sInteger�ticas
come�am com letra min�scula, enquanto que os tokens l�xicos come�am com letra MAI�SCULA
 */

ID	
	: LETTER ( DIGIT | LETTER )*;

NUMBER
	: DIGIT+;
	
WHITESPACE 	
	: ( '\t' | ' ' | '\r' | '\n'| '\u000C' )+ 
	{ $channel = HIDDEN; };
	
fragment DIGIT
	: '0'..'9';
	
fragment LETTER
	: 'a'..'z'
	| 'A'..'Z';
