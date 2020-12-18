#include "ast.h"
#include "pass.h"
#include "constant_folding_pass.h"

Pass *create_constant_folding_pass(void) {
    return create_pass(CONSTANT_FOLDING_PASS, constant_folding_function, NULL, AST_DEPTH_FIRST);
}

void destroy_constant_folding_pass(Pass **pass) {
    destroy_pass(pass);
}

ASTNode *constant_folding_function(ASTNode *node) {
   return node; 
}
