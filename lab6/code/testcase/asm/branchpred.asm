.globl __start


.text

__start:
  xor s0, s0, s0
  xor s2, s2, s2
  xor s3, s3, s3
  addi s3, s3, 0x100
  
__loop:
  andi s1, s0, 1
  beq s1, zero, __even

__odd:
  jal x0, __end
  
__even:
  addi s2, s2, 1
  
__end:
  addi s0, s0, 1
  blt s0, s3, __loop
  xor ra, ra, ra
  addi ra, ra, 0xc
  jalr x0, ra, 0