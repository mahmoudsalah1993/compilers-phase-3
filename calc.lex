%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);
%}
digit		[0-9]
digits		{digit}+
id		[a-zA-Z][0-9a-zA-Z]*
relop		"=="|">="|"<="|">|<"|"!="
num		[0-9]+|[0-9]+"."[0-9]+
addop		"+"|"-"
mulop		"*"|"/"
semi		';'
%%
"+"		{ yylval.op_val = new std::string(yytext); return Plus; }
"-"		{ yylval.op_val = new std::string(yytext); return Minus; }
"*"		{ yylval.op_val = new std::string(yytext); return Mul; }
"/"		{ yylval.op_val = new std::string(yytext); return Div; }
")"		{ yylval.op_val = new std::string(yytext); return CLOSE; }
"("		{ yylval.op_val = new std::string(yytext); return OPEN; }
";"		{ yylval.op_val = new std::string(yytext); return Semi; }
","		{ yylval.op_val = new std::string(yytext); return Comma; }
"{"		{ yylval.op_val = new std::string(yytext); return Openbracket; }
"}"		{ yylval.op_val = new std::string(yytext); return Closebracket; }
"boolean" 	{ yylval.str_val = yytext; return T_boolean;}
"int" 		{ yylval.str_val = yytext; return T_int;}
"float"		{ yylval.str_val = yytext; return T_float;}
"if"		{ yylval.str_val = yytext; return T_if;}
"else"		{ yylval.str_val = yytext; return T_else;}
"while" 	{ yylval.str_val = yytext; return T_while;}
"="		{ yylval.str_val = yytext; return assign;}
{num}		{ yylval.float_val = atof(yytext); return num; }
{id} 		{ yylval.str_val = yytext; return id;}
{relop} 	{ yylval.str_val = yytext; return relop;}

[ \t]*		{}
[\n]		{ yylineno++;	}

.		{ std::cerr << "SCANNER "; yyerror(""); exit(1);	}

