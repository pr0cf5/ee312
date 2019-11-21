.globl __start


.text

__start:
  addi a0, a0, 0x22
  add a1, a0, a0
  sw a1, 0(sp)
  lw a0, 0(sp)
  add a2, a0, a0
  xor a0, a0, a0
  addi a0, sp, 4
  sw a0, 0(sp)
  addi a0, a0, 4
  sw a0, 4(sp)
  lw a1, 0(sp)
  lw a2, 0(a1)
  lw a3, 0(a2)
   