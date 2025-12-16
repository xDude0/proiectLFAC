%code requires {
#include <iostream>
#include <string>

// Declaratii externe necesare pentru Flex/Bison
extern "C" int yylex();
extern "C" int yyparse();
extern  FILE *yyin;
extern  int yylineno; 

// Declararea functiei de eroare in C++
void yyerror(const char *s);
}

%code {
void yyerror(const char *s) {
    std::cerr << "Syntax Error on line " << yylineno << ": " << s << std::endl;
}
}

/***** 1. Definirea Token-urilor (Returnate de Flex) *****/
%token TYPE CLASS_KEYWORD NEW_KEYWORD ID
%token INT_LITERAL FLOAT_LITERAL BOOL_LITERAL STRING_LITERAL
%token ADD SUB MUL DIV MOD
%token EQ NEQ LT GT LE GE AND OR NOT
%token ASSIGN DOT

// NOI TOKEN-uri pentru Cerința 3 (Instrucțiuni și main)
%token IF_KEYWORD ELSE_KEYWORD WHILE_KEYWORD MAIN_KEYWORD PRINT_KEYWORD

/***** 2. Precedenta Operatorilor *****/
/* Folosim "left" sau "right" pentru asociativitate.
 De jos (cea mai mica prec.) in sus (cea mai mare prec.) */
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LE GE
%left ADD SUB
%left MUL DIV MOD
%right NOT
%right UMINUS // Unary minus (e.g., -5)

%%
/***** 3. Reguli Gramaticale (Gramatica Context-Free) *****/

// Punctul de start (Combinam scope-ul global cu blocul main)
program: global_scope_statements main_block ;

// Declaratii permise in scope-ul global (Clase si (implicit) declaratii de var)
global_scope_statements: /* empty */
                       | global_scope_statements declaration ';'
                       | global_scope_statements class_definition ;

// --- Cerință: Blocul Main (Global Scope, fără variabile sau funcții locale definite în el) ---
main_block: MAIN_KEYWORD '(' ')' block_main ;

// Bloc special pentru main: nu permite 'declaration' în interior
block_main: '{' main_statements '}' ;

main_statements: /* empty */
               | main_statements main_statement ;

main_statement: expression ';' // Assignment, field access, method call, new
              | control_statement
              | print_statement ';'
              | block_main ; // Bloc imbricat (fără declarații)

// --- Regulile generale pentru statements (folosite în block-uri de metodă) ---
statements: statement
          | statements statement ;

statement: declaration ';' // Declarare variabila locala (permisa in functii/metode)
         | class_definition
         | expression ';'
         | control_statement
         | print_statement ';'
         | block ;
         
block: '{' statements '}' ; // Bloc de cod general (permite declaration)

// --- Cerință: Instrucțiuni de Control (if, while) ---

control_statement: IF_KEYWORD '(' expression ')' statement else_opt
                 | WHILE_KEYWORD '(' expression ')' statement ;

else_opt: /* empty */
        | ELSE_KEYWORD statement ;

// --- Cerință: Funcția Predefinită Print(expr) ---

print_statement: PRINT_KEYWORD '(' expression ')' ;


// --- Cerință: Classes ---

// Definitia unei clase
class_definition: CLASS_KEYWORD ID '{' class_body '}' ;
class_body: /* empty */
          | class_body declaration ';' // Campuri (fields)
          | class_body method_definition ;

// Definitia simplificata a unei metode
method_definition: TYPE ID '(' parameters_opt ')' block ; 
// Folosim 'block' care permite declaratii (variabile locale)

parameters_opt: /* empty */
              | parameters ;

parameters: TYPE ID
          | parameters ',' TYPE ID ;

// Declaratia de variabile/obiecte
declaration: TYPE ID initialization_opt // Ex: int x = 10;
           | ID ID initialization_opt ; // Ex: MyClass obj = new MyClass();

// Sintaxa pentru Initializarea Obiectelor (utilizare 'new')
initialization_opt: /* empty */
                  | ASSIGN expression ; 

arguments_opt: /* empty */
             | expression
             | arguments_opt ',' expression ;

// --- Cerinta: Arithmetic and boolean expressions & Field/Method Access ---

expression: primary_expression
          | expression ADD expression
          | expression SUB expression
          | expression MUL expression
          | expression DIV expression
          | expression MOD expression
          | expression EQ expression
          | expression NEQ expression
          | expression LT expression
          | expression GT expression
          | expression LE expression
          | expression GE expression
          | expression AND expression
          | expression OR expression
          | NOT expression %prec NOT // Negatie unara
          | SUB expression %prec UMINUS // Minus unar
          | ID ASSIGN expression // Assignment simplu (x = 5)
          | member_access ASSIGN expression // Assignment pe un membru (obj.field = 10)
          | NEW_KEYWORD ID '(' arguments_opt ')' // Apel constructor (new MyClass())
          ;

// Accesarea campurilor sau apelul de metode
member_access: ID DOT ID
             | ID DOT ID '(' arguments_opt ')' ;

primary_expression: ID
                  | literal
                  | member_access
                  | '(' expression ')' ;

literal: INT_LITERAL
       | FLOAT_LITERAL
       | BOOL_LITERAL
       | STRING_LITERAL ;
%%
