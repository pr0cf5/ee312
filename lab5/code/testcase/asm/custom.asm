.globl __start


.text

__start:
  addi a0, a0, 0x22
  add a1, a0, a0
  sw a1, 0(sp)
  lw a0, 0(sp)