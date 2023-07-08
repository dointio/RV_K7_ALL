/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>
#include "memory/paddr.h"
#include "cpu/cpu.h"

#define TOKEN_NAME(_TOKEN) #_TOKEN

enum expr_token{
  TK_NOTYPE = 0,
  /* TODO: Add more token types */

  /*******  logicl op  ********/
  TK_OPERATOR_START,
  TK_EQ,
  TK_NEQ,
  TK_AND,
  TK_OR,
  
  /*******  OP ********/
  TK_ADD,
  TK_SUB,
  TK_MUL,
  TK_DIV,
  TK_ADDROP,
  TK_NEG,

  /******* bk *****/
  TK_LBK,
  TK_RBK,
  TK_OPERATOR_END,

  /****** DATA ******/
  // TK_ADDRESS,
  TK_REG,
  TK_HEX,
  TK_INT,
};


static struct rule {
  const char *regex;
  int token_type;
  int priority;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */
  // {"\\*\\(0[xX][0-9]+\\)",          TK_ADDRESS, 0},
  {"0[xX][0-9a-fA-F]+",             TK_HEX, 0},
  {"[0-9]+",                        TK_INT, 0},
  {"\\$[\\$a-z]([0-9]{1,2}|[a-z])", TK_REG, 0},

  {" +",      TK_NOTYPE, 0},    // spaces

  {"==",      TK_EQ,  8},        // equal
  {"!=",      TK_NEQ, 8},
  {"&&",      TK_AND, 12},
  {"\\|\\|",      TK_OR,  13},

  {"\\+",     TK_ADD, 5},         // plus
  {"-",       TK_SUB, 5},
  {"\\*",     TK_MUL, 4},
  {"\\/",     TK_DIV, 4},

  {"\\(",     TK_LBK, 0},
  {"\\)",     TK_RBK, 0}
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
  int priority;
} Token;

static Token tokenSeq[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        // Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
        //     i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokenSeq'. For certain types
         * of tokenSeq, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
          // case TK_ADDRESS:
          case TK_HEX:
          case TK_INT:
          case TK_REG:
            
          case TK_EQ:
          case TK_NEQ:
          case TK_AND:
          case TK_OR:
          case TK_ADD:
          case TK_SUB:
          case TK_MUL:
          case TK_DIV:
          case TK_LBK:
          case TK_RBK:
            strncpy(tokenSeq[nr_token].str, substr_start, substr_len);
            tokenSeq[nr_token].str[substr_len] = '\0';
            tokenSeq[nr_token].type = rules[i].token_type;
            tokenSeq[nr_token].priority = rules[i].priority;
            nr_token ++;
          case TK_NOTYPE:
            break;
          default: TODO();
        }
        // printf("The token:%d\n", rules[i].token_type);

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

bool check_parentheses(int p, int q){
  int bk=0;
  if((tokenSeq[p].type == TK_LBK) && (tokenSeq[q].type == TK_RBK)){
    p++;
    bk = 1;
    while(p<q){
      if(bk == 0){
        return false;
      }
      else if(tokenSeq[p].type == TK_LBK){
        bk++;
      }
      else if(tokenSeq[p].type == TK_RBK){
        bk--;
      }
      p++;
    }
    if(bk == 1){
      return true;
    }
    else{
      printf("BK mismatch!\n");
      assert(0);
    }
  }
  else{
    return false;
  }
}

word_t tokenVal(Token token)
{
  word_t data = 0;
  char *cptr = token.str;
  switch (token.type)
  {
    case TK_INT:
      data = atoi(cptr);
      break;
    case TK_HEX:
      cptr += 2;
      while(*cptr != '\0'){
        data <<= 4;
        if((*cptr >= '0') && (*cptr <= '9')){
          data += (*cptr) & 0xf;
        }
        else if((*cptr >= 'a') && (*cptr <= 'f')){
          data += (*cptr) - 97+10;
        }
        else if((*cptr >= 'A') && (*cptr <= 'F')){
          data += (*cptr) - 65 + 10;
        }
        else{
          assert(0);
        }
        cptr += 1;
      }
      break;

    case TK_REG:
      data = isa_reg_str2val(cptr, NULL);
      break;
  
    default:
      assert(0);
      break;
  }
  return data;
}

int getMainOpIdx(int p, int q){
  int bk = 0;
  int mainopIdx = p;
  int mainopPro = TK_NOTYPE;
  while(p<q){
    if(tokenSeq[p].type == TK_LBK){
      bk ++;
    }
    else if(tokenSeq[p].type == TK_RBK){
      bk --;
    }
    else if(bk == 0){
      if(tokenSeq[p].priority>mainopPro){
        mainopIdx = p;
        mainopPro = tokenSeq[p].priority;
      }
    }
    p++;
  }
  return mainopIdx;
}


word_t eval(int p, int q){
  if(p > q){
    assert(0);
    return 0;
  }
  else if(p == q){
    return tokenVal(tokenSeq[p]);
  }
  else if(check_parentheses(p, q)){
    return eval(p+1, q-1);
  }
  else{
    int op_idx = getMainOpIdx(p, q);
    if(op_idx == p){
      if(tokenSeq[p].type == TK_NEG){
        return -(eval(p+1, q));
      }
      else if(tokenSeq[p].type == TK_ADDROP){
        return ((int32_t)paddr_read(eval(p+1, q), 4));//if word_t is 64 bit, sign extend!!! uint64-->int32-->uint64(int64)
      }
      else{
        assert(0);
      }
    }
    else{
      int val1 = eval(p, op_idx-1);
      int val2 = eval(op_idx+1, q);
      switch (tokenSeq[op_idx].type)
      {
      case TK_ADD:
        return val1 + val2;    
      case TK_SUB:
        return val1 - val2;
      case TK_MUL:
        return val1 * val2;
      case TK_DIV:
        return val1 / val2;
      case TK_EQ:
        return (val1 == val2);
      case TK_NEQ:
        return (val1 != val2);
      case TK_AND:
        return (val1 && val2);
      case TK_OR:
        return (val1 || val2);
      default:
        assert(0);
      }
    }
  }
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */

  // TODO();
  // printf("Val:%d\n", eval(0, nr_token-1));
  int i=0;
  if(tokenSeq[i].type == TK_MUL){
    tokenSeq[i].type = TK_ADDROP;
    tokenSeq[i].priority = 0;
  }
  else if(tokenSeq[i].type == TK_SUB){
    tokenSeq[i].type = TK_NEG;
    tokenSeq[i].priority = 0;
  }
  for(i=1; i<nr_token; i++){
    if(tokenSeq[i-1].type < TK_OPERATOR_END){
      if(tokenSeq[i].type == TK_MUL){
        tokenSeq[i].type = TK_ADDROP;
        tokenSeq[i].priority = 0;
      }
      else if(tokenSeq[i].type == TK_SUB){
        tokenSeq[i].type = TK_NEG;
        tokenSeq[i].priority = 0;
      }
    }
  }
  *success = true;
  return eval(0, nr_token-1);

  // return 0;
}
