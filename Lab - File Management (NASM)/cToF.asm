;
;   Program to multiply two values
;   COMPILATION OPTION:
;       nasm -f elf *.asm; ld -m elf_i386 -s -o mulB *.o; mulB 0x40 0x03
;   The above compilation option perform 5 * 3
;   WARNING: the program can overflow 8-bits

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;	CONSTANT DEFINITIONS	;;;;;;;;;;;;;;;;;;;;
null		equ		0x00
MAXARGS		equ		2 ; 1 = program path 2 = 1st arg  3 = 2nd arg etc... 
sys_exit	equ		1
sys_read	equ		3
sys_write	equ		4
stdin		equ		0
stdout		equ		1
stderr		equ		3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;	MACRO DEFINITIONS	;;;;;;;;;;;;;;;;;;;;;;;;

%macro pushRegisters 0
	push eax
	push ebx
	push ecx
	push edx
%endmacro

%macro popRegisters 0
	pop edx
	pop ecx
	pop ebx
	pop eax
%endmacro


; print_char macro
; prints one ascii character to the console
%macro print_char 1
	mov eax, 4	;system call number (sys_write)
	mov ebx, [fd_out]	;file descriptor (stdout)
	mov ecx, %1		;address of data to print
	mov edx, 1	;number of bytes to print
	int 0x80	;do it!
%endmacro

; exit0 macro
; exits program with return code 0
%macro exit0 0
	mov ebx, 0
	mov eax, sys_exit
	int 0x80
%endmacro
;;;;;;;;;;;;;;;;;;;;	END MACRO DEFINITIONS	;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;	DATA SEGMENT	;;;;;;;;;;;;;;;;;;;;
SECTION     .data
hexprefix   db "0x",null
debugOK     db  "OK",null
nl          db  0x0a,0x0d
msgIS db " to celsius is ", null
var1        db  0xff    ; default value
var2        db  0xff    ; default value
var3        db  0x00 
file_name   db '012718938.txt', 0
fn_len          equ $ - file_name

;;;;; error messages ;;;;;
szErrMsg    		db      "Too many arguments.  The max number of args is !", null
szLineFeed  		db      10
szBErrMsg			db "Invalid number of hex digits entered.",null
properMsg			db "Proper 2 digit hex value: 0x4F",null
arg1nullMsg:		db "First argument is null",null
arg2nullMsg:		db "Second argument is null",null

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;	BSS SEGMENT	;;;;;;;;;;;;;;;;;;;;
section .bss
tmpbyte		resb	1	;hold byte temporarily for the hex to ascii conversion
tmphexchar	resb	2	;holds hex version of ascii char to be printed

arg1hex		resb	1	;holds the hex value of first argument
arg2hex		resb	1	;holds the hex value of second argument

arg1ascii	resb	5	;holds the ascii version of first argument (4 characters and a null)
arg2ascii	resb	5	;holds the ascii version of second argument (4 characters and a null)

fd_out      resb    1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;	TEXT SEGMENT	;;;;;;;;;;;;;;;;;;;;
SECTION     .text
global      _start
    
_start:		;;;;; BEGIN MAIN PROGRAM SECTION ;;;;;
    nop
	;;;;;;;;;;;;;;;;;;;; Get arguments from the stack ;;;;;;;;;;;;;;;;;;;;
    push    ebp								; save ebp on stack
    mov     ebp, esp						; set base pointer to stack pointer
    
    cmp     dword [ebp + 4], 1				; check to see if no args were received (arg count will always be at least 1)
    je      NoArgs							; if no args entered (arge count == 1) then go to program exit section
    
    cmp     dword [ebp + 4], MAXARGS+1      ; check if total args entered is more than the maximum
    ja      TooManyArgs                     ; if total is greater than MAXARGS, show error message and exit

    mov     ebx, 3							; ebx is index into the argument pointer array
											; since ebp was pushed, args pointer array starts @ [ebp+12] = [ebp +4*3] = [ebp+4*ebx]

	;;;;; Get first command line argument! ;;;;;
    mov     edi, dword [ebp + 4 * ebx]		; put pointer address of an arg into edi
    test    edi, edi						; test to see if pointer address is null (i.e. check if edi equal to 0)
    jz      arg1Null						; exit loop if edi == 0 (argument 1 is a null string)

    call    GetStrlen						; string length will be returned in edx register
    mov     ecx, dword [ebp + 4 * ebx]		; put address of first argument into ecx register
	
	; EXIT program if invalid length hex value detected in first arg
	cmp edx, 4								; check for length of string to be 4 (not including null character)
	jne invalidHexByte 						; if the lengh is incorrect then go to show error and exit

	; put first arg string into arg1ascii and then print to std_out
	mov al, [ecx]
	mov [arg1ascii], al						; put first character into arg1ascii
	mov al, [ecx + 1]
	mov [arg1ascii + 1], al					; put second character into arg1ascii
	mov al, [ecx + 2]
	mov [arg1ascii + 2], al					; put third character into arg1ascii
	mov al, [ecx + 3]
	mov [arg1ascii + 3], al					; put fourth character into arg1ascii
	mov byte [arg1ascii + 4], null			; put null character at end of arg1ascii
	
	;;;;; Get second command line argument! ;;;;;
    inc     ebx                             ; step arg array index
    mov     edi, dword [ebp + 4 * ebx]		; put pointer address of an arg into edi
    test    edi, edi						; test to see if pointer address is null (i.e. check if edi equal to 0)
    jz      arg2Null						; exit loop if edi == 0 (argument 2 is a null string)
    
    call    GetStrlen						; string length will be returned in edx register
    
    mov     ecx, dword [ebp + 4 * ebx]		; put address of second argument into ecx register	
	
	; EXIT program when invalid length hex value detected in second arg
	cmp edx, 4								;check for length of string to be 4 (including null character)
	jne invalidHexByte ;
	
	;put second arg string into arg2ascii
	mov al, [ecx]
	mov [arg2ascii], al
	mov al, [ecx + 1]
	mov [arg2ascii + 1], al
	mov al, [ecx + 2]
	mov [arg2ascii + 2], al
	mov al, [ecx + 3]
	mov [arg2ascii + 3], al
	mov byte [arg2ascii + 4], null	;put null character at end of arg2ascii

	;convert arg1ascii to raw data
	mov eax, [arg1ascii]		; four ascii digits is the 32-bits that will go into eax to be converted
	call ascii_hex_byte_to_raw	; convert the ascii hex quantity to raw data
	mov [var1], al

	;convert arg2ascii to raw data
	mov eax, [arg2ascii]		; four ascii digits is the 32-bits that will go into eax to be converted
	call ascii_hex_byte_to_raw	; convert the ascii hex quantity to raw data
	mov [var2], al
	
;;;;;;;;;;;;;;;;;;;;; DO NOT MODIFY ANYTHING ABOVE THIS COMMENT!
    ; program expects that var1 will hold a Celsius temperature value in hex
    ; the Fahrenheit value will be computed and displayed
    ; F = C * 9 / 5 + 32

    mov eax, 8
    mov ebx, file_name
    mov ecx, 0o644      ; read and write by owner, read by everone else
    mov edx, fn_len 
    int 0x80                ; call kernel
    mov [fd_out], al    ; filedescriptor is returned in the A register
    
    mov cl , [var1] ; put var1 value into cl
    mov dl, [var2] ; put var2 value into dl
    
continue:
    cmp dl, [var3] ; compare to value in dl(var3)
    je exitLoop

    mov eax, 0
    mov al, cl

    sub al, 32
    mov bl, 5           ; set up too multiply al by 5
    mul bl              ; al has been multiplied by 5
    mov bl, 9           ; set up to divide by 9
    div bl  
    
    mov [var1], cl
    mov edi, var1
    call print_hex_byte
 
    mov edi, msgIS
    call print_string
    
    mov [var2], al  ; put the celsius value into var3 so it can be displayed
    mov edi, var2  ; pass address of var3 for print_hex_byte
    call print_hex_byte
    call print_nl       ; print_nl
 
    inc byte [var3]
    add cl, 5

    jmp continue
    
exitLoop:
    mov eax, 6
    mov ebx, [fd_out]
    int 0x80

;;;;;;;;;;;;;;;;;;;; DO NOT MODIFY ANYTHING BELOW THIS COMMENT!
	exit0

NoArgs:
   ; No args entered,
   ; start program without args here
   jmp arg1Null

    
TooManyArgs:
	mov edi, szErrMsg
	call print_string
	call print_nl
	exit0

invalidHexByte:
	mov edi, szBErrMsg
	call print_string
	call print_nl
	mov edi, properMsg
	call print_string
	call print_nl
	exit0
	
arg1Null:
	mov edi, arg1nullMsg
	call print_string
	call print_nl
	exit0
	
arg2Null:
	mov edi, arg2nullMsg
	call print_string
	call print_nl
	exit0
;;;;; end of main function


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;	FUNCTIONS/SUBROUTINES	;;;;;;;;;;;;;;;;;;;;


;;print newline
;	returns		- nothing
print_nl:
pushRegisters
	mov eax, 4	;system call number (sys_write) - p75 of Assembly Language Tutorial
	mov ebx, [fd_out]	;file descriptor (stdout)
	mov ecx, nl	;address of data to print
	mov edx, 2	;number of bytes to print
	int 0x80	;do it!
popRegisters
	ret


;;print hexadecimal prefix characters "0x"
;	uses - eax, ebx, ecx, edx
;	returns		- nothing
print_0x:
	mov eax, 4			;system call number (sys_write) - p75 of Assembly Language Tutorial
	mov ebx, [fd_out]			;file descriptor (stdout)
	mov ecx, hexprefix	;address of data to print
	mov edx, 2			;number of bytes to print
	int 0x80			;do it!
	ret


;print_string
;	recieves	- address of a C-Style String in register edi
;				C-Style means null terminated
;	uses		- eax, ebx, ecx, edx
;	returns		- nothing
print_string:
pushRegisters
	mov ecx, edi
	checknull:
	cmp byte [ecx],null
	jz endstring
		print_char ecx
		inc ecx
		jmp checknull
	endstring:
popRegisters
		ret


;print byte of data
;	recieves	- address of a data byte in register edi
;	uses		- eax, ebx, ecx, edx, tmpbyte, tmphexchar
;	returns		- nothing
print_hex_byte:
pushRegisters
	call print_0x		;print hex prefix
	mov al, [edi]		;get hex byte to be printed
	mov [tmpbyte], al	;put hex byte into tempbyte variable
	and byte [tmpbyte], 0x0f	;isolate lower hex digit in bl
	shr al, 4			;isolate upper hex digit in al
	;
	mov ah, al				;pass upper hex digit to hex_char_to_ascii
	call hex_char_to_ascii	;convert upper hex digit to ascii
	mov [tmphexchar], ah
	print_char tmphexchar
	;
	mov ah, [tmpbyte]		;pass lower hex digit to hex_char_to_ascii
	call hex_char_to_ascii	;convert lower hex digit to ascii
	mov [tmphexchar], ah
	print_char tmphexchar
	;
popRegisters
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Functions for getting command line parameters ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;convert one hex character to ascii
;	recieves	- hex value in register ah
;	uses		- ah register
;	returns		- ascii encoded hex char in ah register
hex_char_to_ascii:
	cmp ah, 10
	jl hexlessthan10	;check if hex digit is a through f
		add ah, 0x07	;adjust value for hex digit a through f
	hexlessthan10:
		add ah, 0x30		;add ascii encoding
		ret

;convert one hex byte in ascii to a raw data byte
;	recieves	- ascii encoded hex value with 0x prefix in register ax
;	uses		- ah register
;	returns		- raw data hex value in al register
ascii_hex_byte_to_raw:
	ror eax, 16
	cmp al, '9'			; see if hex character is '9' or less
	jle lowCharLT9		; 
		sub al, 7		; offset the ascii value if it is A-F
	lowCharLT9:
		and al, 0x0f	; remove ascii encoding
	cmp ah, '9'			; see if hex character is '9' or less
	jle highCharLT9		; 
		sub ah, 7		; offset the ascii value if it is A-F
	highCharLT9:
		and ah, 0x0f	; remove ascii encoding
	shl al, 4
	add al, ah
	ret

;get length of a C-Style string from command line argument passed in stack
;taken from http://www.dreamincode.net/forums/topic/285550-nasm-linux-getting-command-line-parameters/
;	recieves	- address of string in edi register
;	uses		- eax, ecx registers
;	returns		- address of the string into edx register
GetStrlen:
    push    ebx					;put ebx register data on the stack
    xor     ecx, ecx			;clear ecx register
    not     ecx					;set ecx = 0xffffffff, ecx will be decremented by repne as non-null characters are counted
    xor     eax, eax			;clear eax register, al will be used by scasb to search for null character
    cld							;clear direction flag, index registers are incremented
    repne   scasb				;search for 0 in string; if not found edi++, ecx--, and check next character
								;scasb: compares AL and [ES:EDI], EDI +=1	pcasm page 109
								;repne: repeat instruction while string char not null (string char != AL) pcasm page 110
    mov     byte [edi - 1], 10	;append newline character in place of null?
    not     ecx					;1's complement ecx, it will now contain address of an arg
    pop     ebx					;restore ebx value from stack
    lea     edx, [ecx - 1]		;put address of the string into edx register??
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;EOF;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

