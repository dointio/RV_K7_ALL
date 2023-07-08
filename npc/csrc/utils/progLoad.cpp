#include <iostream>
#include <string.h>
#include <stdlib.h>
#include <svdpi.h>
#include "Debug.hpp"
#include "Vriscv_tb__Dpi.h"
#include "mem.hpp"

char *ImgBinFile = nullptr;

// extern void writeVirDDR(const svBitVecVal* addr, const svBitVecVal* memData);
// extern void writeVirDDR(const uint32_t* addr, const uint32_t* memData);

void setBinFile(const char *fileName){
    int i = strlen(fileName);
    if(ImgBinFile != nullptr){
        free(ImgBinFile);
    }
    ImgBinFile = (char*)malloc(sizeof(char) * i+1);
    strncpy(ImgBinFile, fileName, i+1);
}

void loadBinFile(){
    printf("File name: %s\n", ImgBinFile);
    FILE* fp = fopen(ImgBinFile, "rb");
    Assert(fp != nullptr, "Try to load a BinFile, but cannot open!\n");

    uint32_t data_buf[2];
    uint64_t addrCnt = 0x80000000;
    while(fread(&data_buf, sizeof(uint32_t), 2, fp) != 0){
        // writeVirDDR((uint32_t*)&addrCnt, data_buf);
        writeSRAM((uint32_t*)&addrCnt, data_buf);
        addrCnt += 8;
    }

    
    
    fclose(fp);
}


//g:for test function

// int main()
// {
//     setBinFile("/home/xpzh/ysyx/ysyx-workbench/npc/example/gpio_me/mygpio.bin");
//     loadBinFile();
// }

//g: end