#ifndef __SIMLOOP_HPP__
#define __SIMLOOP_HPP__

#include <iostream>

void sim_init(int argc, char** argv);

void cpu_exec(uint64_t n);

void sim_finish();

void InstrunctionTrace();

#endif
