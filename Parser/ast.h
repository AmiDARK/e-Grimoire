#ifndef __AST_H__
#define __AST_H__

typedef enum _ast_node_type {
    AST_NONE = 0,
    AST_ADD,
    AST_SUBTRACT,
    AST_MULTIPLY,
    AST_DIVIDE,
    AST_POWER,
    AST_AND,
    AST_OR,
    AST_XOR,
    AST_NOT,
    AST_NEGATE,
    AST_STORE,
    AST_LOAD,
    AST_VALUE,
} ASTNodeType;

typedef enum _ast_traverse_direction {
    AST_DEPTH_FIRST = 0,
    AST_BREADTH_FIRST
} ASTTraverseDirection;

typedef unsigned short int ASTNodeFlags;

typedef struct _ast_node {
    ASTNodeType type;
    ASTNodeFlags flags;
    struct _ast_node *parent;
    struct _ast_node **child;
} ASTNode;

static const char NumberOfChildrenForType[14] ={
    0, /* AST_NONE     */
    2, /* AST_ADD      */
    2, /* AST_SUBTRACT */
    2, /* AST_MULTIPLY */
    2, /* AST_DIVIDE   */
    2, /* AST_POWER    */
    2, /* AST_AND      */
    2, /* AST_OR       */
    2, /* AST_XOR      */
    1, /* AST_NOT      */
    1, /* AST_NEGATE   */
    2, /* AST_STORE    */
    2, /* AST_LOAD     */
    1, /* AST_VALUE    */
};

ASTNode* create_ast_node(ASTNodeType type, ASTNodeFlags flags, ASTNode *parent);
void destroy_ast_node(ASTNode **node);
void traverse_ast(ASTTraverseDirection direction, ASTNode *root);

#endif /* __AST_H__ */
