#include "verilated.h"
#include "dpi_import.hpp"
#include "Debug.hpp"


extern void readDataAsyncFifo(
    const svBitVecVal* inputW, 
    const svBitVecVal* outputW,
    const svBitVecVal* deep,
    svBitVecVal* data_r, 
    // const svOpenArrayHandle data_r,
    svBitVecVal* w_cnt_ptr, 
    svBitVecVal* r_cnt_ptr, 
    svBitVecVal* data_o, 
    svBitVecVal* wcnt, 
    svBitVecVal* rcnt, 
    svBit* full, 
    svBit* empty
)
{
    if(*empty) return;
    uint8_t *d_ptr = (uint8_t*)data_r;
    uint8_t *rd_ptr = (uint8_t*)data_o;
    uint32_t cnt_buf;
    assert(*deep);
    *r_cnt_ptr = ((*r_cnt_ptr)+(*outputW))%(*deep);

    if(*w_cnt_ptr < *r_cnt_ptr){
        cnt_buf = *deep-*r_cnt_ptr+*w_cnt_ptr;
    }
    else{
        cnt_buf = *w_cnt_ptr - *r_cnt_ptr;
    }
    if(*deep-cnt_buf >= *inputW){
        *full = 0;
    }
    if(cnt_buf < *outputW){
        *empty = 1;
        for(uint32_t i=0; i<(*outputW); i++){
            rd_ptr[i] = 0;
        }
    }
    else{
        for(uint32_t i=0; i<(*outputW); i++){
            rd_ptr[i] = d_ptr[*r_cnt_ptr+i];
        }
    }
    assert(*outputW);
    *rcnt = (cnt_buf+*outputW-1)/(*outputW);
    *wcnt = (cnt_buf+*inputW-1)/(*inputW);
}

void writeDataAsyncFifo(
    const svBitVecVal* inputW, 
    const svBitVecVal* outputW,
    const svBitVecVal* deep,
    svBitVecVal* data_r, 
    // const svOpenArrayHandle data_r,
    svBitVecVal* w_cnt_ptr, 
    svBitVecVal* r_cnt_ptr, 
    const svBitVecVal* data_i,
    svBitVecVal* data_o, 
    svBitVecVal* wcnt, 
    svBitVecVal* rcnt, 
    svBit* full, 
    svBit* empty
)
{
    printf("in:%d, %d, %d, %p, %p\n", *inputW, *outputW, *deep, inputW, data_r);
    // printf("in:%d,%d,%d,%d\n", *w_cnt_ptr, *r_cnt_ptr, *data_i, *data_o);
    // printf("in:%d,%d,%d,%d\n", *wcnt, *rcnt, *full, *empty);
    if(*full) return;
    uint8_t *d_ptr = (uint8_t*)data_r;
    uint8_t *wd_ptr = (uint8_t*)data_i;
    uint8_t *rd_ptr = (uint8_t*)data_o;
    uint32_t cnt_buf;
    for(uint32_t i = 0; i<(*inputW); i++){
        d_ptr[*w_cnt_ptr] = wd_ptr[i];
        assert(*deep);
        *w_cnt_ptr = ((*w_cnt_ptr)+1)%(*deep);
    }
    if(*w_cnt_ptr < *r_cnt_ptr){
        cnt_buf = *deep-*r_cnt_ptr+*w_cnt_ptr;
    }
    else{
        cnt_buf = *w_cnt_ptr - *r_cnt_ptr;
    }
    if(*deep-cnt_buf < *inputW){
        *full = 1;
    }
    if(cnt_buf < *outputW){
        *empty = 1;
        for(uint32_t i=0; i<(*outputW); i++){
            rd_ptr[i] = 0;
        }
    }
    else{
        *empty = 0;
        for(uint32_t i=0; i<(*outputW); i++){
            rd_ptr[i] = d_ptr[*r_cnt_ptr+i];
        }
    }
    // printf("f:%d, %d, %d, %p\n", *inputW, *outputW, *deep, data_r);
    // printf("f:%d,%d,%d,%d\n", *w_cnt_ptr, *r_cnt_ptr, *data_i, *data_o);
    // printf("f:%d,%d,%d,%d\n", *wcnt, *rcnt, *full, *empty);
    assert(*inputW);
    *wcnt = (cnt_buf+*inputW-1)/(*inputW);
    *rcnt = (cnt_buf+*outputW-1)/(*outputW);
}

