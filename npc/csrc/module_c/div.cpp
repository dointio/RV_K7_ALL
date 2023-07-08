#include "verilated.h"
#include "dpi_import.hpp"
#include "Debug.hpp"

// extern void MULDIV(const svBitVecVal* op_type, const svBitVecVal* op_1, const svBitVecVal* op_2, svBitVecVal* res);
inline uint64_t mulhu(uint64_t a, uint64_t b)
{
  uint64_t t;
  uint32_t y1, y2, y3;
  uint64_t a0 = (uint32_t)a, a1 = a >> 32;
  uint64_t b0 = (uint32_t)b, b1 = b >> 32;

  t = a1*b0 + ((a0*b0) >> 32);
  y1 = t;
  y2 = t >> 32;

  t = a0*b1 + y1;

  t = a1*b1 + y2 + (t >> 32);
  y2 = t;
  y3 = t >> 32;

  return ((uint64_t)y3 << 32) | y2;
}

inline int64_t mulh(int64_t a, int64_t b)
{
  int negate = (a < 0) != (b < 0);
  uint64_t res = mulhu(a < 0 ? -a : a, b < 0 ? -b : b);
  return negate ? ~res + (a * b == 0) : res;
}

inline int64_t mulhsu(int64_t a, uint64_t b)
{
  int negate = a < 0;
  uint64_t res = mulhu(a < 0 ? -a : a, b);
  return negate ? ~res + (a * b == 0) : res;
}

inline int64_t div_64(int64_t a, int64_t b)
{   
    // if(b == 0)
    //     return 0;
    Assert((b != 0), "Div Zero!"); 
    Assert((a != INT64_MAX), "Div, a is int64_max!"); 
    return a/b;
}

inline uint64_t divu(uint64_t a, uint64_t b)
{
    // if(b == 0)
    //     return 0;
    Assert((b != 0), "Div Zero!"); 
    return a/b;
}


inline int64_t rem(int64_t a, int64_t b)
{
    // if(b == 0)
    //     return 0;
    Assert((b != 0), "Div Zero!"); 
    Assert((a != INT64_MAX), "Div, a is int64_max!"); 
    return a%b;
}


inline uint64_t remu(uint64_t a, uint64_t b)
{
    // if(b == 0)
    //     return 0;
    Assert((b != 0), "Div Zero!"); 
    return a%b;
}


void MULDIV(const svBitVecVal* op_type, const svBitVecVal* op_1, const svBitVecVal* op_2, svBitVecVal* res)
{
    uint64_t op1 = *(uint64_t*) op_1;
    uint64_t op2 = *(uint64_t*) op_2;
    uint64_t *result = (uint64_t*) res;
    switch((*op_type)&0x7){
        case 0: //o: mul
            (*result) = op1 * op2;
            break;
        case 1: //o: mulh
            (*result) = mulh(op1, op2);
            break;
        case 2: //o: mulhsu
            (*result) = mulhsu(op1, op2);
            break;
        case 3: //o: mulhu
            (*result) = mulhu(op1, op2);
            break;
        case 4: //o: div_64
            (*result) = div_64(op1, op2);
            break;
        case 5: //o: divu
            (*result) = divu(op1, op2);
            break;
        case 6: //o: rem
            (*result) = rem(op1, op2);
            break;
        case 7: //o: remu
            (*result) = remu(op1, op2);
            break;
    }
}


