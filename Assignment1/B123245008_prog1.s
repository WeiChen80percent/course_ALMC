.cpu arm926ej-s
.fpu softvfp
.text
.align	2   
.global	main    

main:
        stmfd	sp!, {fp, lr}
	    add	fp, sp, #4
        ldr r4,=result
        ldr r2,[r1,#4]
loop:    
        ldrb r3,[r2],#1
        cmp r3,#0
        beq out
        cmp r3,#'A'
        blt loop
        cmp r3,#'Z'
        addle r3,r3,#'a'-'A'
        cmp r3,#'a'
        blt loop
        cmp r3,#'z'
        bgt loop
        strb r3,[r4],#1
        b loop
out:    
        strb r3,[r4]
        ldr r0,=result_header
        ldr r1,=result
        bl printf
        mov	r0, #0
        sub	sp, fp, #4
	    ldmfd	sp!, {fp, lr}
        bx	lr
.data
result_header:
    .asciz  "prog1 result:%s\n"

.bss
    .align 2
result:
    .space 2048
        
.end
