section	.text
	global _start		;must be declared for using gcc
	
_start:					;tell linker entry point

	mov	edx, lenUserInput1		;message length
	mov	ecx, userInput1		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov	edx, 2		
	mov	ecx, firstNum		
	mov	ebx, 2
	mov	eax, 3	
	int	0x80		

	mov	edx, lenUserInput2		;message length
	mov	ecx, userInput2		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov	edx, 1		
	mov	ecx, secondNum		
	mov	ebx, 2
	mov	eax, 3	
	int	0x80

	mov al, [firstNum]
	cmp al, byte [secondNum]
	je firstNum_equal_secondNum
	jg firstNum_greater_secondNum
	jl firstNum_less_secondNum
	jmp end_sec

firstNum_equal_secondNum:

	mov eax, 4
	mov ebx, 1
	mov ecx, newLine
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, firstNum
	mov edx, 1
	int 0x80

	mov	edx, lenEqualMsg		;message length
	mov	ecx, equalMsg		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov eax, 4
	mov ebx, 1
	mov ecx, secondNum
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, newLine
	mov edx, 1
	int 0x80

	jmp end_sec

firstNum_greater_secondNum:

	mov eax, 4
	mov ebx, 1
	mov ecx, newLine
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, firstNum
	mov edx, 1
	int 0x80

	mov	edx, lenGreaterMsg		;message length
	mov	ecx, greaterMsg		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov eax, 4
	mov ebx, 1
	mov ecx, secondNum
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, newLine
	mov edx, 1
	int 0x80

	jmp end_sec

firstNum_less_secondNum:

		mov eax, 4
	mov ebx, 1
	mov ecx, newLine
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, firstNum
	mov edx, 1
	int 0x80

	mov	edx, lenLessMsg		;message length
	mov	ecx, lessMsg		;message to write
	mov	ebx, 1		;file descriptor (stdout)
	mov	eax, 4		;system call number (sys_write)
	int	0x80			;call kernel

	mov eax, 4
	mov ebx, 1
	mov ecx, secondNum
	mov edx, 1
	int 0x80

	mov eax, 4
	mov ebx, 1
	mov ecx, newLine
	mov edx, 1
	int 0x80

	jmp end_sec

end_sec:
	mov	eax, 1		;system call number (sys_exit)
	mov ebx, 0
	int	0x80			;call kernel

section	.data

userInput1 db 'Please enter a digit: '
lenUserInput1 equ $-userInput1

userInput2 db 0x0a, 0x0d, 'Please enter a second digit: '
lenUserInput2 equ $-userInput2

firstNum db 0xff
secondNum db 0xee
char_lf db 0x0a, 0x0d

greaterMsg db ' is greater than '
lenGreaterMsg equ $-greaterMsg

equalMsg db ' is equal to '
lenEqualMsg equ $-equalMsg

lessMsg db ' is less than '
lenLessMsg equ $-lessMsg

newLine db 0xa, ''
lenNewLine equ $-newLine


