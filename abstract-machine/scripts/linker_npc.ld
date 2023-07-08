OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  flash (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 128K
  ram (wxa!ri) :   ORIGIN = 0xc0000000, LENGTH = 128M
}

SECTIONS
{
  __stack_size = DEFINED(__stack_size) ? __stack_size : 64M;

  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  /*. = _pmem_start + _entry_offset;*/
  .text : {
    *(entry)
    *(.text*)
  } > flash
  
  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
  } > flash

  .data : {
    *(.data)
  } > flash

  edata = .;
  _data = .;

  .bss : {
	  _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > flash

  . = ALIGN(64);
  _heap_start = .;

  .stack ORIGIN(ram) + LENGTH(ram) - __stack_size :
  {
    _stack_top = .;
    . = __stack_size;
    _stack_pointer = .;
  } >ram AT>ram

}
