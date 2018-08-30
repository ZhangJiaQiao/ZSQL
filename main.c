#include "zsql.h"
#include "zsql.tab.h"
#include <stdio.h>
#include <stdlib.h>

struct ast_word_list* new_word_list(char *new_word)
{
    struct ast_word_list *t_list = malloc(sizeof(struct ast_word_list));
    struct ast_word_node *t_node = malloc(sizeof(struct ast_word_node));
    
    t_node->word = new_word;
    t_node->next = NULL;
    t_list->count = 1;
    t_list->start = t_node;
    t_list->end = t_node;
    return t_list;
}

struct ast_expr* new_expr(void *t_val, ast_expr_type t_type, struct ast_expr *left, struct ast_expr *right)
{
    struct ast_expr *t_expr = malloc(sizeof(struct ast_expr));
    t_expr->val = t_val;
    t_expr->expr_type = t_type;
    t_expr->left_opr = left;
    t_expr->right_opr = right;
    return t_expr;
}

void add_word(struct ast_word_list* word_list, char *new_word)
{
    struct ast_word_node *temp = malloc(sizeof(struct ast_word_node));
    temp->word = new_word;
    temp->next = NULL;
    word_list->end->next = temp;
    word_list->end = temp;
    (word_list->count)++;
}

struct ast_col_def_list* new_col_def_list(struct ast_col_def *t_col_def)
{
    struct ast_col_def_list *t_col_list = malloc(sizeof(struct ast_col_def_list));
    t_col_list->count = 1;
    t_col_list->start = t_col_def;
    t_col_list->end = t_col_def;
    return t_col_list;
}

struct ast_col_def* new_col_def(char *t_col_name, zsql_data_type t_data_type)
{
    struct ast_col_def *t_col = malloc(sizeof(struct ast_col_def));
    t_col->col_name = t_col_name;
    t_col->data_type = t_data_type;
    t_col->next = NULL;
    return t_col;
}

void add_col_def(struct ast_col_def_list *t_col_list, struct ast_col_def *t_col)
{
    t_col_list->end->next = t_col;
    t_col_list->end = t_col;
    (t_col_list->count)++;
}

struct ast_val_list* new_val_list(struct ast_val_node *t_val_node)
{
    struct ast_val_list *temp = malloc(sizeof(struct ast_val_list));
    temp->count = 1;
    temp->start = t_val_node;
    temp->end   = t_val_node;
    return temp;
}

struct ast_val_node* new_val_node(zsql_data_type t_data_type, void *t_val)
{
    struct ast_val_node *temp = malloc(sizeof(struct ast_val_node));
    temp->data_type = t_data_type;
    switch (t_data_type)
    {
        case Z_INT:
            temp->val.ival = (int*)t_val;
            break;
        case Z_STRING:
            temp->val.strval = (char*)t_val;
            break;
        default:
            break;
            // TODO: ERROR
    }
    temp->next = NULL;
    return temp;
}

void add_val_node(struct ast_val_list *t_val_list, struct ast_val_node *t_val_node)
{
    t_val_list->end->next = t_val_node;
    t_val_list->end = t_val_node;
    (t_val_list->count)++;
}

struct ast_create_stmt* new_create_stmt(char *t_table_name, 
                                        struct ast_col_def_list *t_col_list)
{
    struct ast_create_stmt *temp = malloc(sizeof(struct ast_create_stmt));
    temp->table_name = t_table_name;
    temp->col_list = t_col_list;
    return temp;
}

struct ast_select_stmt* new_select_stmt(struct ast_word_list *t_select_target, 
                                        struct ast_word_list *t_from_tables,  
                                        struct ast_expr *t_where_expr)
{
    struct ast_select_stmt *temp = malloc(sizeof(struct ast_select_stmt));
    temp->select_target = t_select_target;
    temp->from_tables = t_from_tables;
    temp->where_expr = t_where_expr;
    return temp;
}

struct ast_drop_stmt* new_drop_stmt(char *t_table_name)
{
    struct ast_drop_stmt *temp = malloc(sizeof(struct ast_drop_stmt));
    temp->table_name = t_table_name;
    return temp;
}

struct ast_insert_stmt* new_insert_stmt(char *t_table_name, struct ast_val_list *t_val_list)
{
    struct ast_insert_stmt *temp = malloc(sizeof(struct ast_insert_stmt));
    temp->table_name = t_table_name;
    temp->val_list   = t_val_list;
    return temp;
}

int main()
{
    extern int yydebug;
    // yydebug = 1;
    printf("> ");
    return yyparse();
}
