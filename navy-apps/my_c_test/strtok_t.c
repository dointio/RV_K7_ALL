#include <stdio.h>
#include <string.h>

int main(void){

char input[50] = "I like stuststuwww.dotcpp.com very much";

char *p = strtok(input, " ");

if(p){
    printf("%s\n", input);
}
else {
    printf("%s\n", input);
}

while(p = strtok(NULL, "a")){//使用第一个参数为NULL来提取子串
    printf("%ld\n", strlen(p));
    printf("%s\n", p);
}

return 0;

}