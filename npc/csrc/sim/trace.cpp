#include "common.hpp"
#include "utils.hpp"
#include "cpuStatus.hpp"
#include "Debug.hpp"

#include "dpi_import.hpp"

char inst_buf[50];

extern CPUState cpuState;


void InstrunctionTrace()
{
    disassemble(inst_buf, 50, cpuState.pc, (uint8_t*)&(cpuState.inst), 4);
    _LogInst("Cnt:%ld, ", cpuState.cnt);
    _LogInst("0x%016lx : ", cpuState.pc);
    _LogInst("%02x ", ((cpuState.inst>>24)&0xff));
    _LogInst("%02x ", ((cpuState.inst>>16)&0xff));
    _LogInst("%02x ", ((cpuState.inst>>8)&0xff));
    _LogInst("%02x : ", (cpuState.inst&0xff));
    _LogInst("%s\n", inst_buf);
}

// extern "C" void RdLog(const svBitVecVal* lsu_rop_addr, const svBitVecVal* lsu_rop_data, const svBitVecVal* lsu_rop_rmask);
// extern "C" void WrLog(const svBitVecVal* lsu_wop_addr, const svBitVecVal* lsu_wop_data, const svBitVecVal* lsu_wop_wmask);

void RdLog(const svBitVecVal* lsu_rop_addr, const svBitVecVal* lsu_rop_data, const svBitVecVal* lsu_rop_rmask)
{
    _LogMem("Rd, Addr:0x%016lx, rmask:0x%02x, TrueData:%016lx(lx) # %ld(ld)\n", *(uint64_t*)lsu_rop_addr, *(uint32_t*)lsu_rop_rmask, *(uint64_t*)lsu_rop_data, *(uint64_t*)lsu_rop_data);
    _LogInst("Rd, Addr:0x%016lx, rmask:0x%02x, TrueData:%016lx(lx) # %ld(ld)\n", *(uint64_t*)lsu_rop_addr, *(uint32_t*)lsu_rop_rmask, *(uint64_t*)lsu_rop_data, *(uint64_t*)lsu_rop_data);
}

void WrLog(const svBitVecVal* lsu_wop_addr, const svBitVecVal* lsu_wop_data, const svBitVecVal* lsu_wop_wmask)
{
    _LogMem("Wr, Addr:0x%016lx, wmask:0x%02x,     Data:%016lx(lx) # %ld(ld) , c:%c\n", *(uint64_t*)lsu_wop_addr, *(uint32_t*)lsu_wop_wmask, *(uint64_t*)lsu_wop_data, *(uint64_t*)lsu_wop_data, (char)(*(uint64_t*)lsu_wop_data));
    _LogInst("Wr, Addr:0x%016lx, wmask:0x%02x,     Data:%016lx(lx) # %ld(ld) , c:%c\n", *(uint64_t*)lsu_wop_addr, *(uint32_t*)lsu_wop_wmask, *(uint64_t*)lsu_wop_data, *(uint64_t*)lsu_wop_data, (char)(*(uint64_t*)lsu_wop_data));
}

// extern "C" void PPI_OVERFLOW(const svBitVecVal* addr_i, svBit Read, const svBitVecVal* data_i, const svBitVecVal* mask_i);
// extern "C" void IFU_OVERFLOW(const svBitVecVal* addr_i, svBit Read, const svBitVecVal* data_i, const svBitVecVal* mask_i);

char binFormatBuf[512];
void uintToBinStr(uint64_t data, int32_t tarLen){
    int32_t i;
    for(i=0; i<tarLen; i++){
        if(data&1){
            binFormatBuf[tarLen-i-1] = '1';
        }
        else{
            binFormatBuf[tarLen-i-1] = '0';
        }
        data >>= 1;
    }
    binFormatBuf[tarLen] = '\0';
}

void PPI_OVERFLOW(const svBitVecVal* addr_i, svBit Read, const svBitVecVal* data_i, const svBitVecVal* mask_i)
{
    uintToBinStr(*(uint32_t*)mask_i, 8);
    _LogInst("Warn! PPI Ifetch overflow:\n");
    _LogInst("Addr: 0x%016lx, Read: %1d, Mask: %s, Data:%ld(0x%lx)(c:%c).", 
        *(uint64_t*)addr_i, Read, binFormatBuf, *(uint64_t*)data_i, *(uint64_t*)data_i, (char)(*(uint64_t*)data_i));

    _LogMem("Warn! PPI Ifetch overflow:\n");
    _LogMem("Addr: 0x%016lx, Read: %1d, Mask: %s, Data:%ld(0x%lx)(c:%c).", 
        *(uint64_t*)addr_i, Read, binFormatBuf, *(uint64_t*)data_i, *(uint64_t*)data_i, (char)(*(uint64_t*)data_i));        
}

void IFU_OVERFLOW(const svBitVecVal* addr_i, svBit Read, const svBitVecVal* data_i, const svBitVecVal* mask_i)
{
    uintToBinStr(*(uint32_t*)mask_i, 8);
    _LogInst("Error! IFU ifetch overflow memory region:\n");
    _LogInst("Addr: 0x%016lx, Read: %1d, Mask: %s, Data:%ld(0x%lx)(c:%c).", 
        *(uint64_t*)addr_i, Read, binFormatBuf, *(uint64_t*)data_i, *(uint64_t*)data_i, (char)(*(uint64_t*)data_i));

    _LogMem("Error! IFU ifetch overflow memory region:\n");
    _LogMem("Addr: 0x%016lx, Read: %1d, Mask: %s, Data:%ld(0x%lx)(c:%c).", 
        *(uint64_t*)addr_i, Read, binFormatBuf, *(uint64_t*)data_i, *(uint64_t*)data_i, (char)(*(uint64_t*)data_i));  
}
