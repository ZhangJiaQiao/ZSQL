typedef enum ast_expr_type
{
    Identifier,
    StrVal,
    IntVal,
    OpAnd,
    OpOr,
    OpAdd,
    OpSub,
    OpEqual,
    OpGt,
    OpLt
}  ast_expr_type;

typedef union t_zsql_val
{
    int  *ival;
    char *strval;
} zsql_val;

typedef enum t_zsql_data_type
{
    Z_INT,
    Z_STRING
} zsql_data_type;

struct ast_expr
{
    void *val;                   // value of expr
    // bool is_judge;              // whether the expr is judge expr
    ast_expr_type expr_type;        // identify the op type
    struct ast_expr *left_opr;  // left operand
    struct ast_expr *right_opr; // right operand
};

struct ast_select_stmt
{
    struct ast_expr      *where_expr;    // the expr after WHERE
    struct ast_word_list *from_tables;   // the word list after FROM
    struct ast_word_list *select_target; // the select column after SELECT
};

struct ast_create_stmt
{
    char *table_name;
    struct ast_col_def_list *col_list;
};

struct ast_col_def_list
{
    struct ast_col_def *start;
    struct ast_col_def *end;
    int count;
};

struct ast_col_def
{
    zsql_data_type data_type;
    char *col_name;
    struct ast_col_def *next;
};

struct ast_insert_stmt
{
    char *table_name;
    struct ast_val_list *val_list;
};

struct ast_drop_stmt
{
    char *table_name;
};

struct ast_delete_stmt
{

};

struct ast_word_list
{
    int count;
    struct ast_word_node* start;
    struct ast_word_node* end;
};

struct ast_word_node
{   
    char *word;
    struct ast_word_node* next;
};

struct ast_val_list
{
    int count;
    struct ast_val_node *start;
    struct ast_val_node *end;
};

struct ast_val_node
{
    zsql_data_type       data_type;
    zsql_val             val;
    struct ast_val_node *next;
};

struct ast_word_list* new_word_list(char *new_word);

struct ast_expr* new_expr(void *t_val, ast_expr_type t_type,
                          struct ast_expr *left,             
                          struct ast_expr *right);

void add_word(struct ast_word_list *word_list, char *new_word);

struct ast_col_def_list* new_col_def_list(struct ast_col_def *t_col_def);

struct ast_col_def* new_col_def(char *t_col_name, zsql_data_type t_data_type);

void add_col_def(struct ast_col_def_list *t_col_list, struct ast_col_def *t_col);

struct ast_val_list* new_val_list(struct ast_val_node *t_val_node);

struct ast_val_node* new_val_node(zsql_data_type t_data_type, void *t_val);

void add_val_node(struct ast_val_list *t_val_list, struct ast_val_node *t_val_node);

/* function about statement creation */
struct ast_create_stmt* new_create_stmt(char *t_table_name, 
                                        struct ast_col_def_list *t_col_list);

struct ast_select_stmt* new_select_stmt(struct ast_word_list *t_select_target, 
                                        struct ast_word_list *t_from_tables,  
                                        struct ast_expr *t_where_expr);

struct ast_drop_stmt*   new_drop_stmt(char *t_table_name);

struct ast_insert_stmt* new_insert_stmt(char *t_table_name, 
                                        struct ast_val_list *t_val_list);
