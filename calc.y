/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
%}

%{
	int next_int_id = 1;
	int pc = 0;
	int temp_pc=0;
	map<string, int> int_id;
	map<string, string> var_type;
	string assign_temp;
	vector<pair<int, string>> code;
	bool eval=false;
	bool neg=false;
	string type;
	
	void calc_if_address();
	void add_code(string s, int len);
	string add_string(string a, string b);
	string tostr(int a);
	string tostr(float a);
	string get_if(string s);
	void modify_goto();
	void print_all_code();
	void modify_while();
	char* add_constant(float f);
	float evaluate(string s1,string s2, string op);
	string adjust_code();
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
		| STATEMENT_LIST{print_all_code();}
		;
STATEMENT_LIST: STATEMENT
		| STATEMENT_LIST STATEMENT
		;
STATEMENT: 	DECLARATION
		|IF
		|WHILE		
		| ASSIGNMENT
		;
DECLARATION: 	PRIMITIVE_TYPE id{var_type[$2] = $1; int_id[$2] = next_int_id++;}Semi
		;
PRIMITIVE_TYPE: T_int	{$$="i";}
		| T_float{$$="f";}
		;
IF :	 	T_if OPEN EXPRESSION CLOSE Openbracket {if(type=="f"){add_code("fcmpg",1);};add_code(get_if($3), 3);} 
		STATEMENT 
		Closebracket
		T_else {add_code("goto", 3); calc_if_address();} Openbracket STATEMENT Closebracket {modify_goto();}
		;
WHILE : 	T_while{temp_pc=pc;} OPEN EXPRESSION CLOSE Openbracket {add_code(get_if($4), 3);} 
		STATEMENT 
		Closebracket{add_code("goto", 3); calc_if_address();modify_while();}
		;
ASSIGNMENT: 	id {type=var_type[$1];}assign EXPRESSION Semi{string l = "store_"; if(int_id[$1] > 3) l = "store\t";
					add_code(add_string(var_type[$1]+ l ,tostr(int_id[$1])), 1); }
		;
EXPRESSION: 	SIMPLE_EXPRESSION
		| SIMPLE_EXPRESSION relop SIMPLE_EXPRESSION{$$=$2;}
		;
SIMPLE_EXPRESSION: TERM
		| Minus {neg=true;} TERM {if(neg) add_code(add_string($3, "neg"), 1);neg=false;$$=$3;}
		| SIMPLE_EXPRESSION Plus TERM{add_code(add_string($3, "add"), 1);$$=$3;}
		| SIMPLE_EXPRESSION Minus TERM{add_code(add_string($3, "sub"), 1);$$=$3;}
		;
TERM: 		FACTOR
		| TERM Mul FACTOR{add_code(add_string($3, "mul"), 1);$$=$3;}
		| TERM Div FACTOR{add_code(add_string($3, "div"), 1);$$=$3;}
		;
FACTOR: 	id{string l = "load_"; if(int_id[$1] > 3) l = "load\t";
				add_code(add_string(var_type[$1] + l,tostr(int_id[$1])), 1);
				$$=new char[100];strcpy($$,var_type[$1].c_str()); type=var_type[$1];}
		| num{$$=add_constant($1);} | OPEN EXPRESSION CLOSE;
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
void add_code(string s, int len){
	if((s.substr(0,6)=="iconst"||s.substr(0,6)=="bipush"||s.substr(0,3)=="ldc")&&(code.size()!=0)){
		if(code.back().second.substr(0,6)=="iconst"||code.back().second.substr(0,6)=="bipush"||code.back().second.substr(0,3)=="ldc"){
			eval=true;
		}
		
	}
	if((s.substr(1,4)=="add"||s.substr(1,4)=="sub"||s.substr(1,4)=="mul"||s.substr(1,4)=="div")&&eval){
		string s1=adjust_code();
		string s2=adjust_code();		
		eval=false;
		if(s1.substr(0,3)=="ldc"){
			if(s2.substr(0,3)=="ldc")
				add_constant(evaluate(s2.substr(4,s2.size()),s1.substr(4,s1.size()),s.substr(1,4)));
			else
				add_constant(evaluate(s2.substr(7,s2.size()),s1.substr(4,s1.size()),s.substr(1,4)));			
		}
		else if(s2.substr(0,3)=="ldc")
			add_constant(evaluate(s2.substr(4,s2.size()),s1.substr(7,s1.size()),s.substr(1,4)));			
		else
			add_constant(evaluate(s2.substr(7,s2.size()),s1.substr(7,s1.size()),s.substr(1,4)));
	}
	else{
		code.push_back(make_pair(pc, s)); 
		//cout << pc <<": "<< s << "\n";
		pc += len;
	}
	
}
string add_string(string a, string b){
	stringstream ss;
	ss << a << b;
	return ss.str();
}
string tostr(int a){
	stringstream ss;
	ss << a;
	return ss.str();
}
string tostr(float a){
	stringstream ss;
	ss << a;
	return ss.str();
}
void calc_if_address(){
	int else_addr = pc;
	int i = code.size() - 2;
	while(i >= 0 && code[i].second.substr(0, 2) != "if"){
		i--;
	}
	code[i].second += "\t";
	
	code[i].second += tostr(else_addr);
}
string get_if(string s){
	if(type=="i"){
		if(s == "<")
			return "if_icmpge";
		if(s == ">")
			return "if_icmple";
		if(s == ">=")
			return "if_icmplt";
		if(s == "<=")
			return "if_icmpgt";		
		if(s == "==")
			return "if_acmpne";
		if(s == "!=")
			return "if_acmpeq";
	}
	if(type=="f"){
	
		if(s == "<")
			return "ifge";
		if(s == ">")
			return "ifle";
		if(s == ">=")
			return "iflt";
		if(s == "<=")
			return "ifgt";				
		if(s == "==")
			return "ifne";
		if(s == "!=")
			return "ifeq";
	}

	return "BAD_STRING";
}
void modify_goto(){
	int else_addr = pc;
	int i = code.size() - 2;
	while(i >= 0 && code[i].second != "goto"){
		i--;
	}
	code[i].second += "\t";
	code[i].second += tostr(else_addr);
}
void print_all_code(){
	freopen("output.j","w",stdout);
	cout<<"\nStart"<<endl;
	for(auto a: code){
		
		cout<<a.first<<": "<<a.second<<endl;	
	}
	cout<<pc<<": return"<<endl;
}
void modify_while(){
	int while_addr = temp_pc;
	int i = code.size() - 1;
	code[i].second += "\t";
	code[i].second += tostr(while_addr);
}
char* add_constant(float f){
	if(neg)
		f=-f;
	
	if (type=="i"){
		if(f <= 5 && f>=0){
			add_code(add_string("iconst_", tostr(floor(f))), 1);
		}
		else {
			if(neg)
				add_code(add_string("bipush\t-", tostr(floor(-f))), 2);
			else
				add_code(add_string("bipush\t", tostr(floor(f))), 2);
		}
		neg=false;
		return "i";
	}
	else if(type=="f"){
		add_code(add_string("ldc\t", tostr(f)), 2);	
		neg=false;	
		return "f";
	}
}
float evaluate(string s1,string s2, string op){
	float a=stof(s1);
	float b=stof(s2);
	if(op=="add")
		return a+b;
	else if(op=="sub")
		return a-b;
	else if(op=="mul")
		return a*b;
	else if(op=="div")
		return a/b;
}
string adjust_code(){
	string s=code.back().second;
		if(s.substr(0,6)=="iconst")
			pc -=1;
		else
			pc -=2;
		code.pop_back();
	return s;
}

