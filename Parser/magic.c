#include <stdio.h>
#include <stdlib.h>

#define YY_DEBUG	1

#define YY_INPUT(buf, result, max)      \
{                                       \
    result = fread(buf, 1, max, yyin);  \
}

FILE *yyin, *yyout;
char *in_name, *out_name;

#include "parser.c"

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: magic <input file> <output file>\n");
	exit(1);
    } else {
        in_name = argv[1];
	out_name = argv[2];
    }

    yyout = fopen(out_name, "w");
    if (yyout) {
        yyin = fopen(in_name, "r");

        if (yyin) {
            while (yyparse())
                ;
	    fclose(yyin);
	}

	fclose(yyout);
    }

    return 0;
}
