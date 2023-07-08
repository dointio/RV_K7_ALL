#include <stdio.h>

#define STR(x)      #x
#define TO_STR(x)   STR(x)
#define ADD(a, b)   (a + b)


#define ADDEE "HHH"
#define MM(AA) ADD##AA

#define uu(aa) aa##c`#c
uu(mmmm)

void main(void)
{
    printf("%s\n", MM(EE));
}
