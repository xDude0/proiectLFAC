%{
#include <iostream>
#include <fstream>
#include "sintaxa.tab.h"   
extern int yylineno;
extern FILE *yyin;
%}

%option noyywrap
%option yylineno
%x comment  

%%


int|float|string|bool        { return TYPE; }


class                        { return CLASS_KEYWORD; }
new                          { return NEW_KEYWORD; }
if                           { return IF_KEYWORD; }
else                         { return ELSE_KEYWORD; }
while                        { return WHILE_KEYWORD; }
main                         { return MAIN_KEYWORD; }
print                        { return PRINT_KEYWORD; }


-?[0-9]+                     { return INT_LITERAL; }
-?([0-9]+\.[0-9]*|\.[0-9]+)  { return FLOAT_LITERAL; }
true|false                   { return BOOL_LITERAL; }
\"(\\.|[^\\"])*\"            { return STRING_LITERAL; }

[a-zA-Z][_a-zA-Z0-9]*        { return ID; }


"+"   { return ADD; }
"-"   { return SUB; }
"*"   { return MUL; }
"/"   { return DIV; }
"%"   { return MOD; }

"=="  { return EQ; }
"!="  { return NEQ; }
"<"   { return LT; }
">"   { return GT; }
"<="  { return LE; }
">="  { return GE; }
"&&"  { return AND; }
"||"  { return OR; }
"!"   { return NOT; }


"="   { return ASSIGN; }
"("   { return '('; }
")"   { return ')'; }
"{"   { return '{'; }
"}"   { return '}'; }
";"   { return ';'; }
"."   { return DOT; }
","   { return ','; }


[ \t\r]+                     ;
\n                           { yylineno++; }
"//".*                       ; 
"/*"                         { BEGIN(comment); }
<comment>"*/"                { BEGIN(INITIAL); }
<comment>.|\n                ;


. { std::cerr << "Lexical Error on line " << yylineno
              << ": Unrecognized token: " << yytext << std::endl; }

%%

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (f) yyin = f;
        else {
            std::cerr << "Cannot open file: " << argv[1] << std::endl;
            return 1;
        }
    } else {
        yyin = stdin;
    }
    std::cout << "Starting Parsing..." << std::endl;
    yyparse();
    std::cout << "Parsing Complete." << std::endl;
    return 0;
}

