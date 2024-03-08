%{
#include "mini_l.tab.h"
int currLine = 1;
int currPos = 1;
%}

digit		[0-9]
int_const	{digit}+

%% 
"++"    {currPos += yyleng; return PLUS;}
"--"    {currPos += yyleng; return MINUS;}
"**"    {currPos += yyleng; return MULTI;}
"//"    {currPos += yyleng; return DIV;}
"%%"    {currPos += yyleng; return MOD;}
"("    {currPos += yyleng; return OPEN_PAR;}
")"    {currPos += yyleng; return CLOSE_PAR;}
"{"    {currPos += yyleng; return OPEN;}
"}"    {currPos += yyleng; return CLOSE;}

"N="    {currPos += yyleng; return NOT_EQUAL;}
"<<"    {currPos += yyleng; return LESS_THAN;}
">>"    {currPos += yyleng; return GREATER_THAN;}
">>="   {currPos += yyleng; return GREATER_THANEQ;}
"<<="   {currPos += yyleng; return LESS_THANEQ;}
";"     {currPos += yyleng; return SEMI;}
","     {currPos += yyleng; return COMMA;}

"function"    {currPos += yyleng; return FUNCTION;}
"inte"   {currPos += yyleng; return INTEGER;}
"i"   {currPos += yyleng; return IF;}
"e"   {currPos += yyleng; return ELSE;}
"W"    {currPos += yyleng; return WHILE_LOOP;}
"read"    {currPos += yyleng; return READ;}
"write"    {currPos += yyleng; return WRITE;}
"EE"    {currPos += yyleng; return EQUALITY;}
"Br"    {currPos += yyleng; return BREAK;}
"Con"    {currPos += yyleng; return CONTINUE;}
"eq"    {currPos += yyleng; return EQ;}
"arr"   {currPos += yyleng; return ARRAY;}
"ret"   { currPos += yyleng; return RET;}

"^^".* {currPos = 1;}

{int_const}	{ yylval.int_val = atoi(yytext); return DIGIT; }
[a-z][a-z0-9]* {currPos += yyleng; yylval.identVal = strdup(yytext); return IDENT;}
[a-zA-Z0-9_]* {printf("Error at line %d, column %d: identifier \"%s\" is invalid\n", currPos, currLine, yytext); exit(0);}
[ ]+ {currPos += yyleng;}
[\t]+ {currPos += yyleng;}
"\n"+ {currLine++; currPos = 1;}
. {printf("Error at line %d. column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}



%%
