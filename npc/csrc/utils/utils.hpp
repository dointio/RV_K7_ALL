#ifndef __UTILS_HPP__
#define __UTILS_HPP__

#include <iostream>
//o: parse args
int parse_args(int argc, char* argv[]);

//o: log file

void init_log();
void setInstTraceStartNum(uint64_t st);
void setInstTraceMaxNum(uint64_t max);
void setInstLogFile(const char* file);
bool log_inst_enable() ;

void setMemLogFile(const char* file);
bool log_mem_enable();

//o: disassemble
extern "C" void init_disasm(const char *triple);
extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

//o: load img
void setBinFile(const char *fileName);
void loadBinFile();

//o:end
#endif
