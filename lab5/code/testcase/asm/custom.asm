.globl __start


.text

__start:
  addi a0, a0, 0x22
  add a1, a0, a0
  sw a1, 0(sp)
  lw a0, 0(sp)
  add a2, a0, a0
  xor a0, a0, a0
  addi a0, sp, -4
  sw a0, 0(sp)
  addi a0, a0, -4
  sw a0, -4(sp)
  lw a1, 0(sp)
  lw a2, 0(a1)
  jal ra, __firstjump
  xor a0, a0, a0
  addi a0, a0, 0xcc
  xor ra, ra, ra
  addi ra, ra, 0xc
  jalr x0, ra, 0

__firstjump:
  xor a1, a1, a1
  addi a1, a1, 0xdd 
  beq a1, a1, __secondjump
  ret 
  
__secondjump:
  xor a1, a1, a1
  addi a1, a1, 0xee
  ret
   