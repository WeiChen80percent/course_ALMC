.cpu arm926ej-s
.fpu softvfp
.text
.align	2   
.global	main
.data  

result_header: 
.asciz "PC    instruction\n"              
normal_instr:
.asciz "%-3d   %s\n"
swi_instr: 
.asciz "%-3d   SWI    #%d\n"
unknown_instr:
.asciz "%-3d   --\n"

s_ldr: .asciz "LDR"
s_str: .asciz "STR"
s_add: .asciz "ADD"
s_adc: .asciz "ADC"
s_sub: .asciz "SUB"
s_sbc: .asciz "SBC"
s_rsb: .asciz "RSB"
s_rsc: .asciz "RSC"
s_and: .asciz "AND"
s_eor: .asciz "EOR"
s_orr: .asciz "ORR"
s_bic: .asciz "BIC"
s_cmp: .asciz "CMP"
s_cmn: .asciz "CMN"
s_tst: .asciz "TST"
s_teq: .asciz "TEQ"
s_mov: .asciz "MOV"
s_mvn: .asciz "MVN"

.align 2
data_processing_table:
    .word s_and, s_eor, s_sub, s_rsb
    .word s_add, s_adc, s_sbc, s_rsc
    .word s_tst, s_teq, s_cmp, s_cmn
    .word s_orr, s_mov, s_bic, s_mvn


main:
    stmfd sp!, {r4-r8,lr}
    
    @print header
    LDR r0, =result_header
    BL printf

    BL start_deasm
    .include "test.s"

start_deasm:
    MOV r4, lr
    MOV r5, #0
    LDR r6, =start_deasm

deasm_loop:
    ADD r0, r4, r5
    CMP r0, r6
    BEQ end_pg

    LDR r1, [r0]
    
    AND r0, r1, #0x0C000000 @0000 '00'00 => see if [27:26]=00, C=1100
    CMP r0, #0
    BEQ handle_dp

    AND r0, r1, #0x0C000000 @0000 '01'00 => see if [27:26]=01, C=1100
    CMP r0, #0x04000000
    BEQ handle_mem

    AND r0, r1, #0x0F000000 @0000 '1111' => see if [27:24]=1111, F=1111
    CMP r0, #0x0F000000
    BEQ handle_swi

    B handle_unknown

handle_dp:
    @handle multiply
    MOV r0, r1
    LDR r2, =0x0F0000F0
    AND r0, r0, r2
    CMP r0, #0x00000090
    BEQ handle_unknown

    @handle swap
    MOV r0, r1
    LDR r2, =0x0FB00FF0
    AND r0, r0, r2
    LDR r2, =0x01000090
    CMP r0, r2
    BEQ handle_unknown

    MOV r1, r1, LSR #21 @see what [24:21] equal to => convert it into 0-15
    AND r1, r1, #0x0000000F @clear top 28 bits

    LDR r2, =data_processing_table
    LDR r2, [r2, r1, LSL #2] @arg 2 => instruction name

    MOV r1, r5 @arg 1 => pc value
    LDR r0, =normal_instr @arg 0 => format string address
    BL printf

    B next_iteration

handle_mem:
    MOV r1, r1, LSR #20 @see [20] equal to => 1:load 0:store
    AND r1, r1, #1
    CMP r1, #0
    LDREQ r2, =s_str
    LDRNE r2, =s_ldr @arg 2 => instruction name

    MOV r1, r5 @arg 1 => pc value
    LDR r0, =normal_instr @arg 0 => format string address
    BL printf

    B next_iteration

handle_swi:
    BIC r2, r1, #0xFF000000 @arg 2 => swi number
    MOV r1, r5 @arg 1 => pc value
    LDR r0, =swi_instr @arg 0 => format string address
    BL printf

    B next_iteration

handle_unknown:
    MOV r1, r5
    LDR r0, =unknown_instr
    BL printf

    B next_iteration
    
next_iteration:
    ADD r5, r5, #4
    B deasm_loop

end_pg:
    ldmfd sp!, {r4-r8,lr}
    bx	lr
.end
