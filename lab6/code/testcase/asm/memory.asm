.globl __start


.text

__start:
li a0, 0xcccc
sw a0, 0(sp)
lw a1, 0(sp)