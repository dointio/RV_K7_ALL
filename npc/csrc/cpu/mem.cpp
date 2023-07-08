#include "common.hpp"
#include "dpi_import.hpp"


uint64_t paddr_read(paddr_t addr, int len) {
    uint64_t data;
    readMem((uint32_t*)&addr, (uint32_t*)&data);

    switch(len){
        case 1:
            {
                switch(addr&0x7){
                    case 0:
                        return data&0xff;
                    case 1:
                        return (data>>8)&0xff;
                    case 2:
                        return (data>>16)&0xff;
                    case 3:
                        return (data>>24)&0xff;
                    case 4:
                        return (data>>32)&0xff;
                    case 5:
                        return (data>>40)&0xff;
                    case 6:
                        return (data>>48)&0xff;
                    // case 7:
                    default:
                        return (data>>56)&0xff;
                }
            }
            // break;    
        case 2:
            {
                switch((addr>>1)&0x3){
                    case 0:
                        return data&0xffff;
                    case 1:
                        return (data>>16)&0xffff;
                    case 2:
                        return (data>>32)&0xffff;
                    // case 3:
                    default:
                        return (data>>48)&0xffff;
                }
            }
            // break;
        case 4:
            {
                switch((addr>>2)&0x1){
                    case 0:
                        return data&0xffffffff;
                    //case 1:
                    default:
                        return (data>>32)&0xffffffff;
                }
            }
            // break;
        case 8:
            return data;
        default:
            printf("Error! Read mem, but len illagel!!");
            break;
    }
  
    return 0;
}
// extern void readMem(const svBitVecVal* addr, svBitVecVal* data);