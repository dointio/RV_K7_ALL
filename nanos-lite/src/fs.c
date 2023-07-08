#include <fs.h>

typedef size_t (*ReadFn) (void *buf, size_t offset, size_t len);
typedef size_t (*WriteFn) (const void *buf, size_t offset, size_t len);

typedef struct {
  char *name;
  size_t size;
  size_t disk_offset;
  ReadFn read;
  WriteFn write;
  //r: add zxp :
  size_t file_offset;
} Finfo;

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_EVENTS, FD_DISPINFO, FD_FB};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return -1;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return -1;
}

/* This is the information about all files in disk. */
size_t serial_write(const void *buf, size_t offset, size_t len);
size_t events_read(void *buf, size_t offset, size_t len);
size_t dispinfo_read(void *buf, size_t offset, size_t len);
size_t fb_write(const void *buf, size_t offset, size_t len);
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, invalid_read, invalid_write},
  [FD_STDOUT] = {"stdout", 0, 0, invalid_read, serial_write},
  [FD_STDERR] = {"stderr", 0, 0, invalid_read, serial_write},
  [FD_EVENTS] = {"/dev/events", 0, 0, events_read, invalid_write},
  [FD_DISPINFO] = {"/proc/dispinfo", 0, 0, dispinfo_read, invalid_write},
  [FD_FB] = {"/dev/fb", 0, 0, invalid_read, fb_write},
#include "files.h"
};

void init_fs() {
  // TODO: initialize the size of /dev/fb
  AM_GPU_CONFIG_T config_gpu;
  config_gpu = io_read(AM_GPU_CONFIG);
  file_table[FD_FB].size = config_gpu.height * config_gpu.width *4;
}

size_t ramdisk_write(const void *buf, size_t offset, size_t len);
size_t ramdisk_read(void *buf, size_t offset, size_t len);


int fs_open(const char* pathname, int flags, int mode){
  //r: now flags and mode is not used!
  uint64_t length_ftable = sizeof(file_table)/sizeof(file_table[0]);
  // printf("Length of filetable:%d.\n", length_ftable);
  for(uint64_t i=0; i<length_ftable; i++){
    if(!strcmp(file_table[i].name, pathname)){
      file_table[i].file_offset = 0;
      return i;
    }
  }
  printf("Nanos:No File! %s\n", pathname);
  return -1; //return -1 when error(man)
}

size_t fs_read(int fd, void *buf, size_t len)
{
  //r: vir file
  if(file_table[fd].read != NULL){
    size_t rv = file_table[fd].read(buf, file_table[fd].file_offset, len);
    if(rv >= 0){
      file_table[fd].file_offset += rv;
    }
    return rv;
  }
  //r: normal file
  else if(file_table[fd].file_offset == file_table[fd].size){
    return 0;
  }
  else if((file_table[fd].file_offset +len) <= file_table[fd].size){
    ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].file_offset, len);
    file_table[fd].file_offset += len;
    return len;
  }
  else{
    size_t max_len = file_table[fd].size - file_table[fd].file_offset;
    ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].file_offset, max_len);
    file_table[fd].file_offset = file_table[fd].size;
    return max_len;
  }
}

size_t fs_write(int fd, const void *buf, size_t len)
{
  // if(fd == FD_FB){
  //   printf("Nanos,Write! FD:%d, Len:%ld\n", fd, len);
  // }
  //r: vir file
  if(file_table[fd].write != NULL){
    size_t rv = file_table[fd].write(buf, file_table[fd].file_offset, len);
    if(rv >= 0){
      file_table[fd].file_offset += rv;
    }
    return rv;
  }
  //r: normal file
  else if(file_table[fd].file_offset == file_table[fd].size){
    return 0;//r: or return -1???
  }
  else if((file_table[fd].file_offset +len) <= file_table[fd].size){
    // ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].file_offset, len);
    ramdisk_write(buf, file_table[fd].disk_offset + file_table[fd].file_offset, len);
    file_table[fd].file_offset += len;
    return len;
  }
  else{
    size_t max_len = file_table[fd].size - file_table[fd].file_offset;
    // ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].file_offset, max_len);
    ramdisk_write(buf, file_table[fd].disk_offset + file_table[fd].file_offset, max_len);
    file_table[fd].file_offset = file_table[fd].size;
    return max_len;
  }
}

size_t fs_lseek(int fd, size_t offset, int whence)
{
  // if(fd == FD_FB){
  //   printf("Nanos,Lseek! FD:%d, OFF:%ld, ST:%d\n", fd, offset, whence);
  // }
  if(whence == SEEK_SET){
    //r: for pass test, we allow file_offset equal to size,but it not used, cannot be read or write!!!
    if(offset <= file_table[fd].size){
      file_table[fd].file_offset = offset;
      return file_table[fd].file_offset;
    }
    else{
      return -1;
    }
  }
  else if(whence == SEEK_CUR){
    if(offset + file_table[fd].file_offset <= file_table[fd].size){
      file_table[fd].file_offset += offset;
      return file_table[fd].file_offset;
    }
    else {
      return -1;
    }
  }
  else if(whence == SEEK_END){
    if(file_table[fd].size + offset <= file_table[fd].size){
      file_table[fd].file_offset = file_table[fd].size + offset;
      return file_table[fd].file_offset;
    }
    else {
      return -1;
    }
  }
  else {
    return -1;
  }
}

int fs_close(int fd)
{
  return 0;
}
