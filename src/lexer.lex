%{
#include <stdio.h>

int col_num = 0;
%}
%option yylineno
COMMENT "^^".*
M_COMMENT "^*"(.|\n)*"*^"
SEMI ";"
OPEN "{"
COMMA ","
CLOSE "}"
OPEN_PAR "("
CLOSE_PAR ")"
FUNCTION "function"
INTEGER "inte"
MOD "%%"
PLUS "++"
MINUS "--"
MULTI "**"
DIV "//"
LESS_THAN "<<"
GREATER_THAN ">>"
EQUALITY "EE"
NOT_EQUAL "N="
WHILE_LOOP "W"
BREAK "Br"
CONTINUE "Con"
IF [i]
ELSE "e"
READ "read"
WRITE"write"
EQ "eq"
IDENT [a-z][a-z0-9]*
INVALID_IDENT [a-zA-Z0-9_]*
DIGIT [0-9]

%%
{COMMENT} {}
{M_COMMENT} {}
{EQ}    { 
col_num++;
printf("EQUALS: %s\n", yytext); }
{ELSE}    { 
col_num++;
printf("ELSE: %s\n", yytext); }
{INTEGER}    { 
col_num++;
printf("INTEGER: %s\n", yytext); }
{FUNCTION}    { 
col_num++;
printf("FUNCTION: %s\n", yytext); }
{COMMA}    { 
col_num++;
printf("COMMA: %s\n", yytext); }
{MOD}    { 
col_num++;
printf("MOD: %s\n", yytext); }
{PLUS}    { 
col_num++;
printf("PLUS: %s\n", yytext); }
{MINUS}    { 
col_num++;
printf("MINUS: %s\n", yytext); }
{MULTI}    { 
col_num++;
printf("MULTI: %s\n", yytext); }
{DIV}    { 
col_num++;
printf("DIV: %s\n", yytext); }
{LESS_THAN}+    { 
col_num++;
printf("LESS_THAN: %s\n", yytext); }
{EQUALITY}    { 
col_num++;
printf("EQUALITY: %s\n", yytext); }
{GREATER_THAN}    { 
col_num++;
printf("GREATER_THAN: %s\n", yytext); }
{NOT_EQUAL}    { 
col_num++;
printf("NOT_EQUAL: %s\n", yytext); }
{WHILE_LOOP}+    { 
col_num++;
printf("WHILE_LOOP: %s\n", yytext); }
{BREAK}    { 
col_num++;
printf("BREAK: %s\n", yytext); }
{CONTINUE}+    { 
col_num++;
printf("CONTINUE: %s\n", yytext); }
{IF}    { 
col_num++;
printf("IF: %s\n", yytext); }
{READ}+    { 
col_num++;
printf("READ: %s\n", yytext); }
{WRITE}+    { 
col_num++;
printf("WRITE: %s\n", yytext); }
{SEMI}    { 
col_num++;
printf("SEMICOLON: %s\n", yytext); }
{OPEN}    { 
col_num++;
printf("OPEN BRACKET: %s\n", yytext); }
{CLOSE}    { 
col_num++;
printf("CLOSE BRACKET: %s\n", yytext); }
{OPEN_PAR}    { 
col_num++;
printf("OPEN_PAR: %s\n", yytext); }
{CLOSE_PAR}    { 
col_num++;
printf("CLOSE_PAR: %s\n", yytext); }
{DIGIT}+   { 
col_num++;
printf("NUMBER: %s\n", yytext); }
{IDENT}   { 
col_num++;
printf("INDETIFIER:   %s\n", yytext); }
{INVALID_IDENT}   { 
col_num++;
printf("**Error. Invalid Indetifier '%s', ", yytext); 
             printf("line '%d', ", yylineno);
			printf("column '%d'\n", col_num);
            }
" "        {}
"\n" {col_num = 0;}
.          { 
col_num++;
printf("**Error. Unidentified symbol '%s', ", yytext); 
             printf("line '%d', ", yylineno);
			printf("column '%d'\n", col_num);
           }

%%

