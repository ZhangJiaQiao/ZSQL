%{
#include "zsql.h"
#include <stdio.h>

void print_log(char *id, char *msg);
void visit_expr(struct ast_expr *temp);
void visit_word_list(struct ast_word_list *temp);
void visit_select_stmt(struct ast_select_stmt *temp);
void visit_create_stmt(struct ast_create_stmt *temp);
void visit_insert_stmt(struct ast_insert_stmt *temp);
void visit_drop_stmt(struct ast_drop_stmt *temp);
void visit_col_list(struct ast_col_def_list *temp);
void visit_val_list(struct ast_val_list *temp);
%}

/***********************
 ** Define Data Types **
 ***********************/
%union {
    int  * intval;
    char * strval;
    int    con_int;

    struct ast_select_stmt*  select_stmt;
    struct ast_create_stmt*  create_stmt;
    struct ast_insert_stmt*  insert_stmt;
    struct ast_drop_stmt*    drop_stmt;
    struct ast_word_list*    word_list;
    struct ast_expr*         expr;
    struct ast_col_def_list* col_def_list;
    struct ast_col_def*      col_def;
    struct ast_val_list*     val_list;
    struct ast_val_node*     val_node;
}

/***********************
 ** Token Definitions **
 ***********************/
%token <strval> IDENTIFIER
%token <intval> INTVAL
%token <strval> STRINGVAL

/* SQL Keywords */
%token CREATE DELETE INSERT SELECT DROP
%token TABLE  WHERE  FROM   INTO   VALUES
%token AND    OR
%token STRING INT
%token ERROR

%type <word_list>    select_list from_clause // tables_ref
%type <select_stmt>  select_statement
%type <create_stmt>  create_statement
%type <insert_stmt>  insert_statement
%type <drop_stmt>    drop_statement
%type <expr>         expression opt_where operand
%type <expr>         logic_expression binary_expression cmp_expression
%type <strval>       table_ref table_name
%type <con_int>      data_type
%type <col_def_list> column_def_list
%type <col_def>      column_def
%type <val_list>     value_list
%type <val_node>     value
%%
statement_list: statement ';' { printf("> "); }
              | statement_list statement ';' { printf("> "); }
              | statement_list ERROR { yyclearin; yyerrok; printf("> "); }
              ;

statement: select_statement
         | create_statement
         |   drop_statement
         | insert_statement
    /*   | delete_statement  */
         ;

/*********************************************
 *   Select statement                        *
 *   SELECT id FROM sailor WHERE age = 18;   *
 *********************************************/
select_statement: SELECT select_list from_clause opt_where { $$ = new_select_stmt($2, $3, $4); visit_select_stmt($$); }
                ;

select_list: IDENTIFIER { $$ = new_word_list($1); }
           | select_list ',' IDENTIFIER { add_word($1, $3); $$ = $1; }
           | '*' { $$ = NULL }  // Select all column
           ;

from_clause: FROM table_ref { $$ = new_word_list($2); }
           ;

/* tables_ref: table_ref {}
          | tables_ref ',' table_ref {} TODO support multiple tables
          ; */

table_ref: IDENTIFIER { $$ = $1; }
         ;

opt_where: WHERE expression { $$ = $2; }
         |            {$$ = NULL} // no where opt
         ;

/**********************************************************
 *   Create statement                                     *
 *   CREATE TABLE sailor (id INT, age INT, name STRING)   *
 **********************************************************/
create_statement: CREATE TABLE table_name '(' column_def_list ')' {
                    $$ = new_create_stmt($3, $5);
                    visit_create_stmt($$);
                }
                ;

column_def_list: column_def { $$ = new_col_def_list($1); }
               | column_def_list ',' column_def { add_col_def($$, $3); }
               ;

column_def: IDENTIFIER data_type { $$ = new_col_def($1, $2); }
          ;

data_type: INT { $$ = Z_INT; }
         | STRING { $$ = Z_STRING; }
         ;

/***************************************
 *   Drop statement                    *
 *   DROP TABLE sailor                 *
 ***************************************/
drop_statement: DROP TABLE table_name { $$ = new_drop_stmt($3); visit_drop_stmt($$); }

/********************************************
 *   Insert statement                       *
 *   |------------|                         *
 *   |   sailor   |                         *
 *   |------------|                         *
 *   | age | name |                         *
 *   INSERT INTO sailor VALUES (zhang, 20)  *
 *   TODO :                                 *
 *   INSERT INTO sailor (name) VALUES (20)  *
 ********************************************/
insert_statement: INSERT INTO table_name VALUES '(' value_list ')' {
                    $$ = new_insert_stmt($3, $6);
                    visit_insert_stmt($$);
                }

/************
 **  TODO  **
 ************
delete_stmt:
 ************/

table_name: IDENTIFIER { $$ = $1; }
          ;

/* Expression */
operand: IDENTIFIER { $$ = new_expr((void *)$1, Identifier, NULL, NULL); print_log("ID", $1); }
       | STRINGVAL  { $$ =  new_expr((void *)$1, StrVal, NULL, NULL); print_log("Str", $1); }
       | INTVAL     { $$ =  new_expr((void *)$1, IntVal, NULL, NULL); print_log("Int", "detected"); }
       ;

expression: operand { $$ = $1; }
    | logic_expression { $$ = $1; }
    ;

operand: '(' expression ')' { $$ = $2; }
       | binary_expression { $$ = $1; }
       ;

logic_expression: expression OR expression { $$ = new_expr(NULL, OpOr, $1, $3); }
                | expression AND expression { $$ = new_expr(NULL, OpAnd, $1, $3); }
                ;

binary_expression: cmp_expression { $$ = $1; }
        /* | operand '+' operand {}
           | operand '-' operand {}
           | operand '*' operand {}
           | operand '/' operand {} support afterward*/
                 ;

cmp_expression: operand '=' operand { $$ = new_expr(NULL, OpEqual, $1, $3); }
        | operand '>' operand { $$ = new_expr(NULL, OpGt, $1, $3); }
        | operand '<' operand { $$ = new_expr(NULL, OpLt, $1, $3); }
        ;

/* Value: used to represent the INT, STRING values*/
value_list: value { $$ = new_val_list($1); }
          | value_list ',' value { add_val_node($1, $3); }
          ;

value: STRINGVAL { $$ = new_val_node(Z_STRING, (void*)$1); }
     | INTVAL { $$ = new_val_node(Z_INT, (void*)$1); }
     ;
%%

/***************Section 3*******************/

/* util functions */
void print_log(char *id, char *msg)
{
    printf("Log : %s is %s\n", id, msg);
}

void visit_select_stmt(struct ast_select_stmt *temp)
{
    if (temp->where_expr != NULL)
    {
        printf("========WHERE==========\n");
        visit_expr(temp->where_expr);
    }
    if (temp->select_target != NULL)
    {
        printf("========SELECT=========\n");
        visit_word_list(temp->select_target);
    }
    if (temp->from_tables != NULL)
    {
        printf("========FROM===========\n");
        visit_word_list(temp->from_tables);
    }
}

void visit_create_stmt(struct ast_create_stmt *temp)
{
    printf("CREATE Statement AST\n");
    if (temp->table_name != NULL) 
    {
        printf("========TABLE=========\n");
        printf("table name: %s\n", temp->table_name);
    }
    if (temp->col_list != NULL) 
    {
        printf("========COLUMN========\n");
        visit_col_list(temp->col_list);
    }
}

void visit_drop_stmt(struct ast_drop_stmt *temp)
{
    printf("DROP Statement AST\n");
    if (temp->table_name != NULL) 
    {
        printf("========TABLE=========\n");
        printf("table name: %s\n", temp->table_name);
    }
}

void visit_insert_stmt(struct ast_insert_stmt *temp)
{
    printf("INSERT Statement AST\n");
    if (temp->table_name != NULL) {
        printf("========TABLE=========\n");
        printf("table name: %s\n", temp->table_name);
    }
    if (temp->val_list != NULL)
    {
        printf("========VALUES========\n");
        visit_val_list(temp->val_list);
    }
}

void visit_col_list(struct ast_col_def_list *temp)
{
    struct ast_col_def *t_col = temp->start;
    while (t_col != NULL)
    {
        printf("col_name: %s | data_type: %d\n", t_col->col_name, t_col->data_type);
        t_col = t_col->next;
    }
}

void visit_val_list(struct ast_val_list *temp)
{
    struct ast_val_node *t_val = temp->start;
    while (t_val != NULL)
    {
        switch (t_val->data_type)
        {
            case Z_INT:
                printf("data_type: INT | val: %d\n", *(t_val->val.ival));
                break;
            case Z_STRING:
                printf("data_type: STRING | val: %s\n", t_val->val.strval);
                break;
            default:
                break;
        }
        t_val = t_val->next;
    }
}

void visit_word_list(struct ast_word_list *temp)
{
    struct ast_word_node *t_node = temp->start;
    while (t_node != NULL)
    {
        printf("word : %s\n", t_node->word);
        t_node = t_node->next;
    }
}

void visit_expr(struct ast_expr *temp)
{
    printf("Op type : %d ", temp->expr_type);
    if (temp->val != NULL)
    {
        if (temp->expr_type == IntVal)
        {
            printf("| Val = %d\n", *((int *)temp->val));
        }
        else
        {
            printf("| Val = %s\n", (char *)temp->val);
        }
    }
    else
    {
        printf("| No Val\n");
    }
    if (temp->left_opr != NULL)
    {
        visit_expr(temp->left_opr);
    }
    if (temp->right_opr != NULL)
    {
        visit_expr(temp->right_opr);
    }
}
