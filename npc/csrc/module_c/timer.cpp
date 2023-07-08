#include "dpi_import.hpp"
#include "sys/time.h"
#include "verilated_dpi.h"

// extern "C" svBitVecVal getTimerCnt(svBit lowCnt);

svBitVecVal getTimerCnt(svBit lowCnt)
{
    struct timeval time_val;
    gettimeofday(& time_val, NULL);
    uint64_t bfval = time_val.tv_sec*1000000 + time_val.tv_usec;
    if(lowCnt){
        return bfval;
    }
    else {
        return (bfval>>32);
    }
}

uint64_t getTimerCntAll()
{
    struct timeval time_val;
    gettimeofday(& time_val, NULL);
    return time_val.tv_sec*1000000 + time_val.tv_usec;
}


// uint64_t getTimeUs()
// {
//   struct timeval time_val;
//   gettimeofday(& time_val, NULL);
//   return time_val.tv_sec*1000000 + time_val.tv_usec;
// }


