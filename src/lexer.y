%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(char const *msg);
%}

%start program_start
%token FUNCTION
%token SEMI
%token OPEN
%token COMMA
%token CLOSE
%token OPEN_PAR
%token CLOSE_PAR
%token INTEGER
%token MOD
%token PLUS
%token MINUS
%token MULTI
%token DIV
%token LESS_THAN
%token GREATER_THAN
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
%token IDENT
%token INVALID_IDENT
%token DIGIT

%%

program_start: functions {printf("program_start->functions\n");}; 

functions: /* empty */ 
    | function functions {printf("functions->function functions\n");};

function: FUNCTION IDENT OPEN_PAR declerations CLOSE_PAR  OPEN statements CLOSE {printf("function->FUNCTION IDENT OPEN_PAR declerations CLOSE_PAR  OPEN statements CLOSE\n");};

declerations: /* empty */ 
    | INTEGER IDENT {printf("decleration -> INTEGER IDENT\n");}
    | INTEGER IDENT COMMA declerations {printf("declerations -> INTEGER IDENT COMMA declerations\n");}

statements: /* empty */ 
    | op_statements {printf("statement -> op_statements\n");}
    | BREAK {printf("statement -> BREAK\n");}
    | INTEGER IDENT SEMI {printf("statement -> INTEGER IDENT SEMI\n");}
    | INTEGER IDENT EQ expression SEMI {printf("statement -> INTEGER IDENT EQ expression SEMI\n");}
    | WHILE_LOOP whileloop {printf("statement -> WHILE_LOOP whileloop\n");}
    | IF ifstatement {printf("statement -> IF ifstatement\n");}

whileloop: OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE {printf("whileloop -> OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE\n");}

ifstatement: OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE
    | OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE ELSE elsestatement {printf("ifstatement -> OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE\n");}

elsestatement: OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE {printf("elsestatement -> OPEN_PAR expression CLOSE_PAR OPEN statements CLOSE\n");}

expression: IDENT EQUALITY DIGIT {printf("expression -> IDENT EQUALITY DIGIT\n");}
    | IDENT GREATER_THAN DIGIT {printf("expression -> IDENT GREATER_THAN DIGIT\n");}
    | IDENT LESS_THAN DIGIT {printf("expression -> IDENT LESS_THAN DIGIT\n");}
    | IDENT NOT_EQUAL DIGIT {printf("expression -> IDENT NOT_EQUAL DIGIT\n");}
    | IDENT EQUALITY IDENT {printf("expression -> IDENT EQUALITY IDENT\n");}
    | IDENT GREATER_THAN IDENT {printf("expression -> IDENT GREATER_THAN IDENT\n");}
    | IDENT LESS_THAN IDENT {printf("expression -> IDENT LESS_THAN IDENT\n");}
    | IDENT NOT_EQUAL IDENT {printf("expression -> IDENT NOT_EQUAL IDENT\n");}

op_statements:  DIGIT PLUS DIGIT {printf("op_statements -> DIGIT PLUS DIGIT\n");}
    | DIGIT MINUS DIGIT {printf("op_statements -> DIGIT MINUS DIGIT\n");}
    | DIGIT MULTI DIGIT {printf("op_statements -> DIGIT MULTI DIGIT\n");}
    | DIGIT DIV DIGIT {printf("op_statements -> DIGIT DIV DIGIT\n");}
    | DIGIT MOD DIGIT {printf("op_statements -> DIGIT MOD DIGIT\n");}

%%

void main(int argc, char** argv){
    if(argc >= 2){
        yyin = fopen(argv[1], "r");
        if(yyin == NULL)
            yyin = stdin;
    }else{
        yyin = stdin;
    }
    yyparse();
}

/* Called by yyparse on error. */
void
yyerror (char const *s)
{
      fprintf (stderr, "%s\n", s);
}
