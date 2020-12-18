#ifndef __PASS_H__
#define __PASS_H__

#include "ast.h"
#include <stdio.h>

typedef enum _pass_type {
    GENERIC_PASS = 0,
    CONSTANT_FOLDING_PASS
} PassType;

typedef struct _pass {
    PassType type;
    ASTNode *(*func)(ASTNode *node);
    ASTNode *start_node;
    ASTTraverseDirection direction;
} Pass;

Pass *create_pass(PassType _type, ASTNode *(*_func)(ASTNode *), ASTNode *_start, ASTTraverseDirection _direction);
void destroy_pass(Pass **_pass);

#endif  /* __PASS_H__ */
