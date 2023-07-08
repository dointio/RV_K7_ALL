	.file	"hello.c"
	.option pic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,1
	sw	a5,-32(s0)
	li	a5,268509184
	sw	a5,-20(s0)
	li	a5,1
	sw	a5,-28(s0)
	li	a5,1
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	lw	a4,-32(s0)
	sw	a4,0(a5)
.L8:
	sw	zero,-28(s0)
	j	.L2
.L5:
	sw	zero,-24(s0)
	j	.L3
.L4:
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L3:
	lw	a4,-24(s0)
	li	a5,1699
	bleu	a4,a5,.L4
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
.L2:
	lw	a4,-28(s0)
	li	a5,499
	bleu	a4,a5,.L5
	lw	a4,-32(s0)
	li	a5,16
	bne	a4,a5,.L6
	li	a5,1
	sw	a5,-32(s0)
	j	.L7
.L6:
	lw	a5,-32(s0)
	slli	a5,a5,1
	sw	a5,-32(s0)
.L7:
	lw	a5,-20(s0)
	lw	a4,-32(s0)
	sw	a4,0(a5)
	j	.L8
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.3.0-1ubuntu1~22.04.1) 11.3.0"
	.section	.note.GNU-stack,"",@progbits
