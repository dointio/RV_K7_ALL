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

#include "common.hpp"
#include "sdb.hpp"
#include "Debug.hpp"
#include <string.h>

#define NR_WP 32

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */
  uint64_t oldval;
  uint64_t newval;
  char* exprPtr;
} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */


WP* new_wp(char* exprStr)
{
  if(free_ == NULL){
    assert(0);
  }
  else if(head == NULL){
    head = free_;
    free_ = free_->next;
    head->next = NULL;
  }
  else{
    WP* p = free_;   
    free_ = free_->next;
    p->next = head;
    head = p;
  }
  return head;
}

void free_wp(WP *wp)
{
  WP *p = head;
  WP *p_pre = NULL;
  if(wp == NULL){
  }
  else if(wp == head){
    head = head->next;
    p->next = free_;
    free_ = p;
  }
  else{
    while(1){
      p_pre = p;
      p = p->next;
      if(p == wp)
        break;
      else if(p == NULL)
        break;
    }
    if(p != NULL){
      p_pre->next = p->next;
      p->next = free_;
      free_ = p;
    }
  }
}


bool addWatchPoint(char* exprStr){
  bool exprTrue;
  expr(exprStr, &exprTrue);
  if(!exprTrue) return false;
  WP *p = new_wp(exprStr);
  if(p == NULL)
    return false;
  p->exprPtr = (char*)malloc(strlen(exprStr)+1);
  strncpy(p->exprPtr, exprStr, strlen(exprStr)+1);
  // p->exprPtr[strlne(exprStr)] = '\0';
  bool vld;
  p->oldval = expr(p->exprPtr, &vld);
  p->newval = p->oldval;
#ifdef CONFIG_ISA64
  printf("Val: %ld(0x%016lx)\n", (int64_t)p->newval, p->newval);
#else
  printf("Val: %d(0x%08x)\n", (int32_t)p->newval, p->newval);
#endif
  return true;
}

bool checkWatchPoint()
{
  WP *p = head;
  uint32_t data;
  bool vld;
  while(p != NULL){
    data = expr(p->exprPtr, &vld);
    if(data != p->newval){
      p->oldval = p->newval;
      p->newval = data;
      printf("WatchPoint Interrupt!\n");
      printf("Expr: %s\n", p->exprPtr);
#ifdef CONFIG_ISA64
      printf("Old val: %ld(0x%016lx), New val: %ld(0x%016lx)\n", p->oldval, p->oldval, p->newval, p->newval);
#else
      printf("Old val: %d(0x%08x), New val: %d(0x%08x)\n", p->oldval, p->oldval, p->newval, p->newval);
#endif
      return true;
    }
    p = p->next;
  }
  return false;
}

void listWatchPoint()
{
  WP *p = head;
  printf("WatchPoint Info:\n");
  int i = 0;
  while(p != NULL){
    printf("Point_%d, expr: %s\n", i, p->exprPtr);
    p=p->next;
    i++;
  }
}

bool deleteWatchPoint(uint32_t idx)
{
  WP *p = head;
  int i = 0;
  while(p != NULL){
    if(i == idx){
      free_wp(p);
      free(p->exprPtr);
      return true;  
    }
    p=p->next;
    i++;
  }
  return false;
}