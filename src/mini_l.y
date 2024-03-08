%{
#include<stdio.h>
#include<string>
#include<vector>
#include<string.h>
#include<stdlib.h>
using namespace std;
extern FILE * yyin;
extern int currLine;
extern int currPos; 
void yyerror(const char * msg);
extern int yylex(void);
using namespace std;

char *identToken;
int numberToken;
int  count_names = 0;

enum Type { Integer, Array };

struct CodeNode{ 
  std::string code; 
  std::string name; 
};
struct Symbol { 
  std:: string name;
  Type type;
};
struct Function{ 
  std::string name;
  std:: vector<Symbol> declarations; 
};

std::vector <Function> symbol_table;

Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

bool find(std::string &value) { /*find if there is a name in the symbol table*/
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

bool arrCheck(std::string &value) { /*find if the name is an array*/
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->type == Array) {
      return true;
    }
  }
  return false;
}

bool intCheck(std::string &value) { /*find if the name is an int*/
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->type == Integer) {
      return true;
    }
  }
  return false;
}
void add_function_to_symbol_table(std::string &value) { /*function to add functions into the symbol table*/
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) { /*function to add ident into the symbol table*/
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

std::string create_temp()
{
  static int num = 0;
  std::string value = "_temp" + std::to_string(num);
  num += 1;
  return value;
}
std::string create_label()
{
  static int num = 0;
  std::string value = "label" + std::to_string(num);
  num += 1;
  return value;
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%union{
  int		int_val;
  char * identVal;
  struct CodeNode *node;
}

%start program_start
%token	<int_val>	DIGIT
%token <identVal> IDENT
%type <identVal> function_ident
%token FUNCTION
%token SEMI
%token OPEN
%token CLOSE
%token COMMA
%token OPEN_PAR
%token CLOSE_PAR
%token INTEGER
%token ARRAY
%token MOD
%token PLUS
%token MINUS
%token MULTI
%token DIV
%token LESS_THAN
%token GREATER_THAN
%token LESS_THANEQ
%token GREATER_THANEQ
%token EQUALITY
%token NOT_EQUAL
%token WHILE_LOOP
%token BREAK
%token CONTINUE
%token IF
%token ELSE
%token READ
%token WRITE
%token EQ
%token COMMENT
%token RET
%type  <node>   statement
%type  <node>   statements
%type  <node>   functions
%type  <node>   function
%type  <node>   declerations
%type  <node>   op_statements
%%
program_start:	functions 
{
    CodeNode *node = $1;
    std::string code = node->code;
    printf("Generated code:\n");
    printf("%s\n", code.c_str());
}
		| error 
       	;

functions: 	 
%empty
{ 
   CodeNode *node = new CodeNode;
   $$ = node;
}
| function functions
{
   CodeNode *func  = $1;
   CodeNode *funcs = $2;
   std::string code = func->code + funcs->code;
   CodeNode *node = new CodeNode;
   node->code = code;
   $$ = node;
};

function: FUNCTION function_ident OPEN_PAR declerations CLOSE_PAR OPEN statements CLOSE 
{
    std::string func_name = $2;
    CodeNode *params = $4;
    CodeNode *stmts = $7;
    std::string code = std::string("func ") + func_name + std::string("\n");
    code += params -> code;
    code += stmts -> code;
    code += std::string("endfunc\n");

    CodeNode *node = new CodeNode;
    node-> code = code;
    $$ = node;
};

function_ident: IDENT 
{
  std::string func_name = $1;
  add_function_to_symbol_table(func_name);
  $$ = $1;
}
;
declerations: %empty 
{ 
   CodeNode *node = new CodeNode;
   $$ = node;
}
    | INTEGER ARRAY IDENT declerations 
    {
        std::string ident1 = $3;
        if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
        CodeNode *node = new CodeNode;
        $$ = node;

    }
    | INTEGER ARRAY IDENT COMMA declerations 
    {
        std::string ident1 = $3;
        if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
        CodeNode *node = new CodeNode;
        $$ = node;
    }
    | INTEGER IDENT COMMA INTEGER IDENT
    {
        std::string ident1 = $2;
        std::string ident2 = $5;
        std::string code = std::string(". ") + ident1 + std::string("\n") + std::string(". ") + ident2 + std::string("\n") + std::string("= ") + ident1 + std::string (", $0") + std::string("\n") + std::string("= ") + ident2 + std::string (", $1") + std::string("\n");
        CodeNode *node = new CodeNode;
        node->code = code;
        $$ = node;
    }
    | INTEGER IDENT 
    
    {
        std::string ident1 = $2;
        if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
        CodeNode *node = new CodeNode;
        $$ = node;
    };

statements: statement statements
    {
        CodeNode *stat  = $1;
        CodeNode *stats = $2;
        std::string code = stat->code + stats->code;
        CodeNode *node = new CodeNode;
        node->code = code;
        $$ = node;
        
    }
    | %empty{
        CodeNode *node = new CodeNode;
        $$ = node;
    };
statement: IDENT EQ IDENT SEMI  
    {
        std::string ident1 = $1;
        std::string ident2 = $3;
        Type t = Integer;

        if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
        std::string code = std::string("= ") + ident1 + std::string(", ") + ident2 + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | IDENT EQ DIGIT SEMI  
    {
        std::string ident1 = $1;
        int symbol1 = $3;
        if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
        std::string code = std::string("= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | INTEGER ARRAY IDENT OPEN_PAR DIGIT CLOSE_PAR SEMI
    {
        std::string ident1 = $3;
        int symbol1 = $5;
        Type t = Array;
        if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
        add_variable_to_symbol_table(ident1, t);
        if (symbol1 <= 0) 
        {
            std::string message = std::string("Array Size Less Than or Equal to 0");
            yyerror(message.c_str());
        }
        std::string code = std::string(".[] ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | INTEGER IDENT SEMI {
      std::string ident1 = $2;
      Type t = Integer;
      if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
      add_variable_to_symbol_table(ident1, t);
      std::string code = std::string(". ") + ident1 + std::string("\n");
      CodeNode *node = new CodeNode;
      node -> code = code;
      $$ = node;
    }
    | INTEGER IDENT EQ IDENT SEMI
    {
      std::string ident1 = $2;
      std::string ident2 = $4;
      Type t = Integer;
       if (!find(ident2)) 
        {
            std::string message = std::string("unidentified symbol '") + ident2 + std::string("'");
            yyerror(message.c_str());
        }
        if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
        if (!find(ident1)) 
        {
          add_variable_to_symbol_table(ident1, t);
        }
        else 
        {
          std::string message = std::string("symbol already used '") + ident1 + std::string("'");
          yyerror(message.c_str()); 
        }
      add_variable_to_symbol_table(ident1, t);
      std::string code = std::string("= ") + ident1 + std::string(", ") + ident2 + std::string("\n");
      CodeNode *node = new CodeNode;
      node -> code = code;
      $$ = node;
    }
    | INTEGER IDENT EQ DIGIT SEMI
    {
      std::string ident1 = $2;
      int symbol1 = $4;
      Type t = Integer;
      if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
      add_variable_to_symbol_table(ident1, t);
      std::string code = std::string(". ") + ident1 + std::string("\n") + std::string("= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n");
      CodeNode *node = new CodeNode;
      node -> code = code;
      $$ = node;
    }
    | WRITE IDENT SEMI  
    {
      std::string ident1 = $2;
      if (!find(ident1)) 
        {
            print_symbol_table();
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
      std::string code = std::string(".> ") + ident1 + std::string("\n");
      CodeNode *node = new CodeNode;
      node -> code = code;
      $$ = node;
    }
    | WRITE IDENT OPEN_PAR DIGIT CLOSE_PAR SEMI  
    {
      std::string ident1 = $2;
      int symbol1 = $4;
      if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
      std::string code = std::string(".[]> ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n");
      CodeNode *node = new CodeNode;
      node -> code = code;
      $$ = node;
    }
    | READ IDENT SEMI 
    {
      std::string ident1 = $2;
      if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
      std::string code = std::string(".< ") + ident1 + std::string("\n");
    }
    | READ IDENT OPEN_PAR DIGIT CLOSE_PAR SEMI
    {
      std::string ident1 = $2;
      int symbol1 = $4;
      if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
      std::string code = std::string(".[]< ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n");
      CodeNode *node = new CodeNode;
      node -> code = code;
      $$ = node;
    }
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ DIGIT SEMI
    {
        std::string ident1 = $1;
        int symbol1 = $3;
        int symbol2 = $6;

        if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
        if(ident1 == "inte" || ident1 == "eq" || ident1 == "EE" || ident1 == "W" || ident1 == "Br" || ident1 == "Con" || ident1 == "i" || ident1 == "e" || ident1 == "read" || ident1 == "write" || ident1 == "arr")
        {
            std::string message = std::string("Usage of resrvered keyword as variable '") + ident1 + std::string("'");
        }
        if (symbol1 < 0) 
        {
            std::string message = std::string("Array Size Less Than or Equal to 0");
            yyerror(message.c_str());
        }
        //[]= dst, index, src
        std::string code = std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + std::to_string(symbol2) + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code; 
         $$ = node;
    }
    | RET IDENT SEMI
    {
        std::string ident1 = $2;
        std::string code = std::string("ret ") + ident1 + std::string("\n");
        if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | op_statements  
    {
        $$ = $1;
    }
    | IDENT EQ IDENT OPEN_PAR IDENT COMMA IDENT CLOSE_PAR SEMI
    {
        std::string ident1 = $1;
        std::string ident2 = $5;
        std::string ident3 = $7;
        std::string fName = $3;

        if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }

        std::string code = std::string("param ") + ident2 + std::string("\n") + std::string("param ") + ident3 + std::string("\n") + std::string("call ") + fName +std::string(", ") + ident1 + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | WHILE_LOOP OPEN_PAR IDENT LESS_THAN DIGIT CLOSE_PAR OPEN statements WHILE_LOOP OPEN_PAR IDENT LESS_THANEQ DIGIT CLOSE_PAR OPEN statements CLOSE statements CLOSE
    {
        std::string temp1 = create_temp();
        std::string temp2 = create_temp();
        std::string ident1 = $3;
        std::string ident2 = $11;
        CodeNode *stat  = $8;
        CodeNode *stat1 = $16;
        CodeNode *stat2 = $18;
        int symbol1 = $5;
        int symbol2 = $13;
        std::string code = std::string(": label1") + std::string("\n") + std::string(". ") + temp1 + std::string("\n")+ std::string(">= ") + temp1 + std::string(", ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("?:= label4") + std::string(", ") + temp1 + std::string("\n");
        code += stat -> code; 
        code += std::string(": label2") + std::string("\n") + std::string(". ") + temp2 + std::string("\n") + std::string("> ") + temp2 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + std::string("?:= label3") + std::string(", ") + temp2 + std::string("\n");
        code += stat1 -> code; 
        code += std::string(": label3") + std::string("\n");
        code += stat2 -> code;
        code += std::string(": label4") + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | WHILE_LOOP OPEN_PAR IDENT LESS_THAN DIGIT CLOSE_PAR OPEN statements CLOSE
    {
        std::string temp1 = create_temp();
        std::string label1 = create_label();
        std::string label2 = create_label();
        std::string ident1 = $3;
        CodeNode *stat  = $8;
        int symbol1 = $5;
        std::string code = std::string(": ") + label1 + std::string("\n") + std::string(". ") + temp1 + std::string("\n")+ std::string(">= ") + temp1 + std::string(", ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("?:= ") + label2 + std::string(", ") + temp1 + std::string("\n");
        code += stat -> code;
        code += std::string(":= ") + label1 + std::string("\n") + std::string(": ") + label2 + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | IF OPEN_PAR IDENT LESS_THAN IDENT CLOSE_PAR OPEN statements CLOSE ELSE OPEN statements CLOSE
    {
        std::string ident1 = $3;
        std::string ident2 = $5;
        std::string temp1 = create_temp();

        std::string label1 = std::string("label1");
        std::string label2 = std::string("label2");
        std::string endif = std::string("endif");

        CodeNode *ifstat = $8;
        CodeNode *elstat = $12;

        std::string code = std::string(". ") + temp1 + std::string("\n");
        code += std::string(">= ") + temp1 + std::string(", ") + ident1 + std::string(", ") + ident2 + std::string("\n");
        code += std::string("?:= ") + label2 + std::string(", ") + temp1 + std::string("\n");
        code += std::string(":= ") + label1 + std::string("\n");
        code += std::string(": ") + label2 + std::string("\n");
        code += elstat -> code;
        code += std::string(":= ") + endif + std::string("\n");
        code += std::string(": ") + label1 + std::string("\n");
        code += ifstat -> code;
        code += std::string(": ") + endif + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    ;
op_statements: IDENT EQ DIGIT PLUS DIGIT SEMI
{
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $5;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("+ ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + std::to_string(symbol2) + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT PLUS IDENT SEMI
{
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $5;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("+ ") + ident1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT PLUS DIGIT SEMI
    {
        std::string ident1 = $1;
        std::string ident2 = $3;
        int symbol1 = $5;
        if (!find(ident1) || !find(ident2)) 
            {
             std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
             yyerror(message.c_str());
         }   
        std::string code = 	std::string("+ ") + ident1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol1) + std::string("\n");
        CodeNode *node = new CodeNode;
        node -> code = code;
        $$ = node;
    }
    | IDENT EQ IDENT OPEN_PAR DIGIT CLOSE_PAR PLUS IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $8;
    int symbol1 = $5;
    int symbol2 = $10;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + std::string("+ ") + ident1 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ DIGIT MINUS DIGIT SEMI
{
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $5;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("- ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + std::to_string(symbol2) + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT MINUS IDENT SEMI
{
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $5;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("- ") + ident1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT OPEN_PAR DIGIT CLOSE_PAR MINUS IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $8;
    int symbol1 = $5;
    int symbol2 = $10;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + std::string("- ") + ident1 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ DIGIT MULTI DIGIT SEMI
{
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $5;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("* ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + std::to_string(symbol2) + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT MULTI IDENT SEMI
{
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $5;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("* ") + ident1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT OPEN_PAR DIGIT CLOSE_PAR MULTI IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $8;
    int symbol1 = $5;
    int symbol2 = $10;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + std::string("* ") + ident1 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}

    | IDENT EQ DIGIT DIV DIGIT SEMI
{
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $5;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("/ ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + std::to_string(symbol2) + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT DIV IDENT SEMI
{
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $5;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("/ ") + ident1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT OPEN_PAR DIGIT CLOSE_PAR DIV IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $8;
    int symbol1 = $5;
    int symbol2 = $10;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + std::string("/ ") + ident1 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ DIGIT MOD DIGIT SEMI
{
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $5;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("% ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + std::to_string(symbol2) + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT MOD IDENT SEMI
{
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $5;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = 	std::string("% ") + ident1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT EQ IDENT OPEN_PAR DIGIT CLOSE_PAR MOD IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $3;
    std::string ident3 = $8;
    int symbol1 = $5;
    int symbol2 = $10;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol1) + std::string("\n") + std::string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + std::string("% ") + ident1 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code;
    $$ = node;
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ DIGIT PLUS DIGIT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $6;
    int symbol3 = $8;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
        if (symbol1 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("+ ") + temp1 + std::string(", ") + std::to_string(symbol2) + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT PLUS IDENT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $8;
    int symbol1 = $3;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("+ ") + temp1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT OPEN_PAR DIGIT CLOSE_PAR PLUS IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string temp3 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $11;
    int symbol1 = $3;
    int symbol2 = $8;
    int symbol3 = $13;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0 || symbol3 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }    
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("+ ") + temp3 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ DIGIT MINUS DIGIT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $6;
    int symbol3 = $8;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("- ") + temp1 + std::string(", ") + std::to_string(symbol2) + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT MINUS IDENT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $8;
    int symbol1 = $3;
    if (!find(ident1) || !find(ident2) || !find(ident3)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }
    std::string code = std::string("- ") + temp1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT OPEN_PAR DIGIT CLOSE_PAR MINUS IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string temp3 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $11;
    int symbol1 = $3;
    int symbol2 = $8;
    int symbol3 = $13;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0 || symbol3 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }  
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("- ") + temp3 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ DIGIT MULTI DIGIT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $6;
    int symbol3 = $8;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = std::string("* ") + temp1 + std::string(", ") + std::to_string(symbol2) + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT MULTI IDENT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $8;
    int symbol1 = $3;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = std::string("* ") + temp1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT OPEN_PAR DIGIT CLOSE_PAR MULTI IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string temp3 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $11;
    int symbol1 = $3;
    int symbol2 = $8;
    int symbol3 = $13;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0 || symbol3 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }  
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("* ") + temp3 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ DIGIT DIV DIGIT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $6;
    int symbol3 = $8;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = std::string("/ ") + temp1 + std::string(", ") + std::to_string(symbol2) + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT DIV IDENT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $8;
    int symbol1 = $3;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = std::string("/ ") + temp1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT OPEN_PAR DIGIT CLOSE_PAR DIV IDENT OPEN_PAR DIGIT CLOSE_PAR
{
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string temp3 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $11;
    int symbol1 = $3;
    int symbol2 = $8;
    int symbol3 = $13;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0 || symbol3 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }  
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("/ ") + temp3 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ DIGIT MOD DIGIT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    int symbol1 = $3;
    int symbol2 = $6;
    int symbol3 = $8;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = std::string("% ") + temp1 + std::string(", ") + std::to_string(symbol2) + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT MOD IDENT SEMI
{
    std::string temp1 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $8;
    int symbol1 = $3;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    std::string code = std::string("% ") + temp1 + std::string(", ") + ident2 + std::string(", ") + ident3 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp1 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
    | IDENT OPEN_PAR DIGIT CLOSE_PAR EQ IDENT OPEN_PAR DIGIT CLOSE_PAR MOD IDENT OPEN_PAR DIGIT CLOSE_PAR
{
  {
    std::string temp1 = create_temp();
    std::string temp2 = create_temp();
    std::string temp3 = create_temp();
    std::string ident1 = $1;
    std::string ident2 = $6;
    std::string ident3 = $11;
    int symbol1 = $3;
    int symbol2 = $8;
    int symbol3 = $13;
    if (!find(ident1)) 
        {
            std::string message = std::string("unidentified symbol '") + ident1 + std::string("'");
            yyerror(message.c_str());
        }
    if (symbol1 < 0 || symbol2 < 0 || symbol3 < 0) 
        {
            std::string message = std::string("Array index Less Than 0");
            yyerror(message.c_str());
        }  
    std::string code = std::string("=[] ") + temp1 + std::string(", ") + ident2 + std::string(", ") + std::to_string(symbol2) + std::string("\n") + string("=[] ") + temp2 + std::string(", ") + ident3 + std::string(", ") + std::to_string(symbol3) + std::string("\n") + std::string("% ") + temp3 + std::string(", ") + temp1 + std::string(", ") + temp2 + std::string("\n") + std::string("[]= ") + ident1 + std::string(", ") + std::to_string(symbol1) + std::string(", ") + temp3 + std::string("\n");
    CodeNode *node = new CodeNode;
    node -> code = code; 
}
}
    ;
%%

int main(int argc, char **argv)
{
   yyparse();
   return 0;
}

void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", currLine, msg);
   exit(1);
}