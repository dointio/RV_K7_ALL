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

#ifndef __SDB_H__
#define __SDB_H__

#include <iostream>

uint64_t expr(char *e, bool *success);

bool checkWatchPoint();
void listWatchPoint();
bool addWatchPoint(char* exprStr);
bool deleteWatchPoint(uint32_t idx);

void sdb_set_batch_mode(bool open);
bool sdb_in_batch_mode();

void sdb_mainloop();

void init_sdb();

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

#endif
