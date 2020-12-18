set +xe

leg -o parser.c amos.leg
vc -c99 -o magic parser.c ast.c pass.c constant_folding_pass.c
