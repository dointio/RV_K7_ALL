#include "common.hpp"
#include "sdb.hpp"
#include <getopt.h>
#include "utils.hpp"
#include "Debug.hpp"

#define no_argument 0
#define req_argument 1
#define sel_argument 2


extern char* WaveLogFile;
extern bool WaveLogOpen;
void setWaveLogFile(const char* file);

extern bool logInstOpen;
extern bool logMemOpen;


int parse_args(int argc, char* argv[]){
    static const option table[] = {
        {"file",        req_argument,   NULL, 'f'},
        {"batch",       no_argument,    NULL, 'b'},
        {"Instlog",     req_argument,   NULL, 'I'},
        {"Memlog",      req_argument,   NULL, 'M'},
        {"Wavelog",     req_argument,   NULL, 'W'},
        {"stLogCnt",    req_argument,   NULL, 's'},
        {"maxLogCnt",   req_argument,   NULL, 'm'},
        {"difftest",    no_argument,    NULL, 'd'},
        {"help",        no_argument,    NULL, 'h'},
        {0, 0, NULL, 0}
    };

    int o;
    while((o = getopt_long(argc, argv, "-fbI:M:W:s:m:c:dh", table, NULL)) != -1){
        switch(o){
            case 'f':
                setBinFile(optarg);
                break;
            case 'b':
                sdb_set_batch_mode(true);
                break;
            case 'I':
                logInstOpen = true;
                setInstLogFile(optarg);
                break;
            case 'M':
                logMemOpen = true;
                setMemLogFile(optarg);
                break;
            case 'W':
                WaveLogOpen = true;
                setWaveLogFile(optarg);
                break;
            case 's':
                setInstTraceStartNum(atol(optarg));
                break;
            case 'm':
                setInstTraceMaxNum(atol(optarg));
                break;
            case 'd':
                printf(ANSI_FG_RED);
                printf("DiffTest function wait implementing....\n");
                printf(ANSI_NONE);
                break;

            default:
                printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
                printf("\t-f,--file=xxx           img file,format: binary!\n");
                printf("\t-b,--batch              run with batch mode\n");
                printf("\t-I,--Instlog=xxx        instrunctions log to FILE\n");
                printf("\t-M,--Memlog=xxx         memory fetch log to FILE\n");
                printf("\t-W,--Wavelog=xxx        Wave log to FILE\n");
                printf("\t-s,--stLogCnt=xxx       start log when inst_cnt greater than it\n");
                printf("\t-m,--maxLogCnt=xxx      stop log when log_cnt greater than it\n");
                printf("\t-d,--difftest           run DiffTest with reference(nemu,wait implementing)\n");
                printf("\n");
                exit(0);
        }
    }
    return 0;
}

