/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
%}

%{
	int next_int_id = 1;
	map<string, int> int_id;
	map<string, string> var_type;
	string assign_temp;
%}

%union{
	int	int_val;
	float	float_val;
	string*	op_val;
	char*	str_val;
}

%start	input 

%token	<str_val>	id
%token	<float_val>	num
%token	<str_val>	addop
%token	<str_val>	mulop
%token	<str_val>	relop
%token	<str_val>	T_float
%token	<str_val>	T_int

%type 	<str_val>	STATEMENT_LIST
%type 	<str_val>	STATEMENT
%type 	<str_val>	IF
%type 	<str_val>	WHILE
%type 	<str_val>	DECLARATION
%type 	<str_val>	PRIMITIVE_TYPE
%type 	<str_val>	ASSIGNMENT
%type 	<str_val>	EXPRESSION
%type 	<str_val>	SIMPLE_EXPRESSION
%type 	<str_val>	TERM
%type 	<str_val>	FACTOR

%left	Plus
%left	Mul
%left	Minus
%left	Div
%left	OPEN
%left	CLOSE
%left	T_boolean
%left	T_if
%left	T_else
%left	T_while
%left	assign
%left	Semi
%left	Comma
%left	Openbracket
%left	Closebracket

%%

input:		/* empty */
		| STATEMENT_LIST
		;
STATEMENT_LIST: STATEMENT
		| STATEMENT_LIST STATEMENT
		;
STATEMENT: 	DECLARATION
		|IF
		|WHILE		
		| ASSIGNMENT
		;
DECLARATION: 	PRIMITIVE_TYPE id{var_type[$2] = $1; int_id[$2] = next_int_id++;cout<<$1<<": "<<$2<<"="<<next_int_id-1<<endl;}Semi
		;
PRIMITIVE_TYPE: T_int	{$$="i";}
		| T_float{$$="f";}
		;
IF :	 	T_if OPEN EXPRESSION CLOSE Openbracket 
		STATEMENT 
		Closebracket
		T_else Openbracket STATEMENT Closebracket
		;
WHILE : 	T_while OPEN EXPRESSION CLOSE Openbracket STATEMENT Closebracket
		;
ASSIGNMENT: 	id assign EXPRESSION Semi{cout<<var_type[$1]<< "store_" << int_id[$1] << "\n"; }
		;
EXPRESSION: 	SIMPLE_EXPRESSION
		| SIMPLE_EXPRESSION relop SIMPLE_EXPRESSION
		;
SIMPLE_EXPRESSION: TERM
		| Minus TERM
		| SIMPLE_EXPRESSION Plus TERM{cout<<$3<<"add"<<endl;$$=$3;}
		| SIMPLE_EXPRESSION Minus TERM{cout<<$3<<"sub"<<endl;$$=$3;}
		;
TERM: 		FACTOR
		| TERM Mul FACTOR{cout<<$3<<"mul"<<endl;$$=$3;}
		| TERM Div FACTOR{cout<<$3<<"div"<<endl;$$=$3;}
		;
FACTOR: 	id{cout<<var_type[$1]<< "load_" << int_id[$1] << "\n";$$=new char[100];strcpy($$,var_type[$1].c_str());}
		| num{cout<<"iconst_"<<$1<<endl;$$="i";} | OPEN EXPRESSION CLOSE;
%%
int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}
int yyerror(char *s)
{
  return yyerror(string(s));
}
