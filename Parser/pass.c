#include <stdlib.h>

#include "ast.h"
#include "pass.h"

Pass *create_pass(PassType _type, ASTNode *(*_func)(ASTNode *), ASTNode *_start, ASTTraverseDirection _direction) {
    Pass *new_pass = NULL;
    
    if (_func && _start) {
        new_pass = (Pass *)malloc(sizeof(Pass));

        if (new_pass) {
            new_pass->type = _type;
            new_pass->func = _func;
            new_pass->start_node = _start;
            new_pass->direction = _direction;
        }
    }

    return new_pass;
}

void destroy_pass(Pass **_pass) {
    if (_pass && *_pass) {
        destroy_ast_node(&(*_pass)->start_node);
        free(*_pass);

        *_pass = NULL;
    }
}


