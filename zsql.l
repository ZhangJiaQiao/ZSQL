/**************************
 **  Section 1 C Headers **
 **************************/
%{
#include <string.h>
#include <stdio.h>
#include "zsql.tab.h"  

#define TOKEN(name) {return name;}
%}

/* ignore upper and lower cases */
%option case-insensitive

/****************************
 **  Section 2 Lexer Rules **
 ****************************/
%%

CREATE TOKEN(CREATE)
DELETE TOKEN(DELETE)
INSERT TOKEN(INSERT)
SELECT TOKEN(SELECT)
DROP   TOKEN(DROP)

TABLE  TOKEN(TABLE)
FROM   TOKEN(FROM)
WHERE  TOKEN(WHERE)
INTO   TOKEN(INTO)
VALUES TOKEN(VALUES)

AND    TOKEN(AND)
OR     TOKEN(OR)

INT    TOKEN(INT)
STRING TOKEN(STRING)

[ \t\n]+    // skip whitespace

-?[0-9]+    {int *temp = malloc(sizeof(int)); *temp = atoi(yytext); yylval.intval = temp; return INTVAL;} /*INT VALUE*/

[-+*/(){},.;<>=^%;?[\]|]    {return yytext[0];}
[A-Za-z][A-Za-z0-9_]*   {
    yylval.strval = strdup(yytext);
    return IDENTIFIER;
}
'(\\.|''|[^'\n])*' {
    yylval.strval = strdup(yytext);
    yylval.strval = (char *)(yylval.strval + 1);
    yylval.strval[strlen(yylval.strval) - 1] = '\0';
    return STRINGVAL;
}

.   {fprintf(stderr, "[ZSQL-Lexer-Error] Unknown Character: %c\n", yytext[0]); return ERROR;}

%%

/***************************
 **  Section 3 User Codes **
 ***************************/
int yyerror(const char *msg) {
     fprintf(stderr, "[ZSQL-Lexer-Error] %s\n", msg);
     return 0;
}

int yywrap(void) {
    return 1;
}
