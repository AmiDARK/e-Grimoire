#include <stdio.h>
#include <stdlib.h>

#include "ast.h"

/* Global AST root node. */
ASTNode *G_AST_Root;

ASTNode* create_ast_node(ASTNodeType type, ASTNodeFlags flags, ASTNode *parent) {
    char number_of_children;
    ASTNode *new_node = malloc(sizeof(ASTNode));

    if (new_node) {
        new_node->type = type;
        new_node->flags = flags;

        number_of_children = NumberOfChildrenForType[type];

        /* Allocate the array of child node pointers. */
        if (number_of_children) {
            new_node->child = (ASTNode **)malloc(sizeof(ASTNode *) * number_of_children);

            if (new_node->child) {
                /* Initialize all the child pointers to NULL. */
                for (int i = 0; i < number_of_children; i++) {
                    new_node->child[i] = NULL;
                }
            } else {
                /* Failure to allocate the child arrary means failure.  Cleanup and exit. */
                free(new_node);
                new_node = NULL;
            }
        }
    }

    return new_node;
}

void destroy_ast_node(ASTNode **node) {
    ASTNode *ast_node;

    if (node && *node) {
        ast_node = *node;


        if (ast_node->child) {
            /* Don't leave orphaned child nodes. */
            for (int i = 0; i < NumberOfChildrenForType[ast_node->type]; i++) {
                if (ast_node->child[i]) {
                    destroy_ast_node(&ast_node->child[i]);
                }
            }

            free(ast_node->child);
        }

        free(ast_node);
        *node = NULL;
    }
}

void traverse_ast(ASTTraverseDirection direction, ASTNode *root) {
   switch (direction) {
   case AST_DEPTH_FIRST:
       break;
   case AST_BREADTH_FIRST:
       break;
   }
}
