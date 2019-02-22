; this source was taken from https://www.tutorialspoint.com/compile_assembly_online.php

section	.text
	global _start		;must be declared for using gcc
	
_start:					;tell linker entry point

	mov	edx, firstLen		;message length
	mov	ecx, first		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov	edx, lastLen		;message length
	mov	ecx, last		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov	edx, idLen		;message length
	mov	ecx, id		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov	eax, 1		;system call number (sys_exit)
	int	0x80			;call kernel

section	.data

first db 'First: Bryan',0xa
firstLen equ $-first

last db 'Last: Rojas',0xa
lastLen equ $-last

id db 'ID: 012718938',0xa
idLen equ $-id

