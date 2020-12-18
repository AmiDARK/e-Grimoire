#ifndef __CONSTANT_FOLDING_PASS_H__
#define __CONSTANT_FOLDING_PASS_H__

#include "ast.h"
#include "pass.h"

Pass *create_constant_folding_pass(void);
void destroy_constant_folding_pass(Pass **pass);

ASTNode *constant_folding_function(ASTNode *node);

#endif  /* __CONSTANT_FOLDING_PASS_H__ */
