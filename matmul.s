	.file	"matmul.c"
	.text
	.globl	matmul_ijk
	.def	matmul_ijk;	.scl	2;	.type	32;	.endef
	.seh_proc	matmul_ijk
matmul_ijk:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$16, %rsp
	.seh_stackalloc	16
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movq	%rdx, 24(%rbp)
	movq	%r8, 32(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L2
.L7:
	movl	$0, -8(%rbp)
	jmp	.L3
.L6:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	movl	-8(%rbp), %eax
	cltq
	movl	$0, (%rdx,%rax,4)
	movl	$0, -12(%rbp)
	jmp	.L4
.L5:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	movl	-8(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %r8d
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rax, %rdx
	movl	-12(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %ecx
	movl	-12(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	24(%rbp), %rax
	addq	%rax, %rdx
	movl	-8(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %eax
	imull	%eax, %ecx
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	addl	%r8d, %ecx
	movl	-8(%rbp), %eax
	cltq
	movl	%ecx, (%rdx,%rax,4)
	addl	$1, -12(%rbp)
.L4:
	cmpl	$2, -12(%rbp)
	jle	.L5
	addl	$1, -8(%rbp)
.L3:
	cmpl	$2, -8(%rbp)
	jle	.L6
	addl	$1, -4(%rbp)
.L2:
	cmpl	$2, -4(%rbp)
	jle	.L7
	nop
	nop
	addq	$16, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	matmul_ikj
	.def	matmul_ikj;	.scl	2;	.type	32;	.endef
	.seh_proc	matmul_ikj
matmul_ikj:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$16, %rsp
	.seh_stackalloc	16
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movq	%rdx, 24(%rbp)
	movq	%r8, 32(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L9
.L16:
	movl	$0, -8(%rbp)
	jmp	.L10
.L11:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	movl	-8(%rbp), %eax
	cltq
	movl	$0, (%rdx,%rax,4)
	addl	$1, -8(%rbp)
.L10:
	cmpl	$2, -8(%rbp)
	jle	.L11
	movl	$0, -12(%rbp)
	jmp	.L12
.L15:
	movl	$0, -16(%rbp)
	jmp	.L13
.L14:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	movl	-16(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %r8d
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rax, %rdx
	movl	-12(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %ecx
	movl	-12(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	24(%rbp), %rax
	addq	%rax, %rdx
	movl	-16(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %eax
	imull	%eax, %ecx
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	32(%rbp), %rax
	addq	%rax, %rdx
	addl	%r8d, %ecx
	movl	-16(%rbp), %eax
	cltq
	movl	%ecx, (%rdx,%rax,4)
	addl	$1, -16(%rbp)
.L13:
	cmpl	$2, -16(%rbp)
	jle	.L14
	addl	$1, -12(%rbp)
.L12:
	cmpl	$2, -12(%rbp)
	jle	.L15
	addl	$1, -4(%rbp)
.L9:
	cmpl	$2, -4(%rbp)
	jle	.L16
	nop
	nop
	addq	$16, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "%4d\0"
.LC1:
	.ascii "PASS\0"
.LC2:
	.ascii "FAIL\0"
.LC3:
	.ascii "%s: all %d elements match.\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$96, %rsp
	.seh_stackalloc	96
	.seh_endprologue
	call	__main
	movl	$30, -64(%rbp)
	movl	$24, -60(%rbp)
	movl	$18, -56(%rbp)
	movl	$84, -52(%rbp)
	movl	$69, -48(%rbp)
	movl	$54, -44(%rbp)
	movl	$138, -40(%rbp)
	movl	$114, -36(%rbp)
	movl	$90, -32(%rbp)
	movl	$1, -4(%rbp)
	movl	$0, -8(%rbp)
	jmp	.L18
.L21:
	movl	$0, -12(%rbp)
	jmp	.L19
.L20:
	movl	-8(%rbp), %edx
	movl	%edx, %eax
	addl	%eax, %eax
	addl	%eax, %edx
	movl	-12(%rbp), %eax
	addl	%edx, %eax
	leal	1(%rax), %ecx
	movl	-12(%rbp), %eax
	movslq	%eax, %r8
	movl	-8(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%r8, %rax
	leaq	0(,%rax,4), %rdx
	leaq	a.3(%rip), %rax
	movl	%ecx, (%rdx,%rax)
	movl	-8(%rbp), %eax
	movl	%eax, %edx
	sall	$2, %eax
	subl	%eax, %edx
	leal	9(%rdx), %eax
	subl	-12(%rbp), %eax
	movl	%eax, %ecx
	movl	-12(%rbp), %eax
	movslq	%eax, %r8
	movl	-8(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%r8, %rax
	leaq	0(,%rax,4), %rdx
	leaq	b.2(%rip), %rax
	movl	%ecx, (%rdx,%rax)
	addl	$1, -12(%rbp)
.L19:
	cmpl	$2, -12(%rbp)
	jle	.L20
	addl	$1, -8(%rbp)
.L18:
	cmpl	$2, -8(%rbp)
	jle	.L21
	leaq	c.1(%rip), %rcx
	leaq	b.2(%rip), %rdx
	leaq	a.3(%rip), %rax
	movq	%rcx, %r8
	movq	%rax, %rcx
	call	matmul_ijk
	leaq	expected.0(%rip), %rcx
	leaq	b.2(%rip), %rdx
	leaq	a.3(%rip), %rax
	movq	%rcx, %r8
	movq	%rax, %rcx
	call	matmul_ikj
	movl	$0, -16(%rbp)
	jmp	.L22
.L26:
	movl	$0, -20(%rbp)
	jmp	.L23
.L25:
	movl	-20(%rbp), %eax
	movslq	%eax, %rcx
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%rcx, %rax
	movl	-64(%rbp,%rax,4), %ecx
	movl	-20(%rbp), %eax
	movslq	%eax, %r8
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%r8, %rax
	leaq	0(,%rax,4), %rdx
	leaq	expected.0(%rip), %rax
	movl	%ecx, (%rdx,%rax)
	movl	-20(%rbp), %eax
	movslq	%eax, %rcx
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%rcx, %rax
	leaq	0(,%rax,4), %rdx
	leaq	c.1(%rip), %rax
	movl	(%rdx,%rax), %ecx
	movl	-20(%rbp), %eax
	movslq	%eax, %r8
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%r8, %rax
	leaq	0(,%rax,4), %rdx
	leaq	expected.0(%rip), %rax
	movl	(%rdx,%rax), %eax
	cmpl	%eax, %ecx
	je	.L24
	movl	$0, -4(%rbp)
.L24:
	addl	$1, -20(%rbp)
.L23:
	cmpl	$2, -20(%rbp)
	jle	.L25
	addl	$1, -16(%rbp)
.L22:
	cmpl	$2, -16(%rbp)
	jle	.L26
	movl	$0, -24(%rbp)
	jmp	.L27
.L32:
	movl	$0, -28(%rbp)
	jmp	.L28
.L30:
	movl	-28(%rbp), %eax
	movslq	%eax, %rcx
	movl	-24(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	addq	%rcx, %rax
	leaq	0(,%rax,4), %rdx
	leaq	c.1(%rip), %rax
	movl	(%rdx,%rax), %eax
	leaq	.LC0(%rip), %rcx
	movl	%eax, %edx
	call	__mingw_printf
	addl	$1, -28(%rbp)
.L28:
	cmpl	$2, -28(%rbp)
	jg	.L29
	cmpl	$2, -28(%rbp)
	jle	.L30
.L29:
	movl	$10, %ecx
	call	putchar
	addl	$1, -24(%rbp)
.L27:
	cmpl	$2, -24(%rbp)
	jg	.L31
	cmpl	$2, -24(%rbp)
	jle	.L32
.L31:
	cmpl	$0, -4(%rbp)
	je	.L33
	leaq	.LC1(%rip), %rax
	jmp	.L34
.L33:
	leaq	.LC2(%rip), %rax
.L34:
	leaq	.LC3(%rip), %rcx
	movl	$9, %r8d
	movq	%rax, %rdx
	call	__mingw_printf
	cmpl	$0, -4(%rbp)
	sete	%al
	movzbl	%al, %eax
	addq	$96, %rsp
	popq	%rbp
	ret
	.seh_endproc
.lcomm a.3,36,32
.lcomm b.2,36,32
.lcomm c.1,36,32
.lcomm expected.0,36,32
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (GNU) 16.2.0"
	.def	putchar;	.scl	2;	.type	32;	.endef
