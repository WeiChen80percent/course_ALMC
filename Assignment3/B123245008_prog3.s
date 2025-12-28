section .data
  ;general string 
	msg_func  db "Function ",0
	msg_colon  db ": ",0
	msg_of  db " of ",0
	msg_and  db " and ",0
	msg_is  db " is ",0
	msg_dot  db ".",10,0
	;operation string
	msg_max  db "maximum",0
	msg_gcd  db "greatest common divisor",0
	msg_lcm  db "least common multiply",0
	msg_exp  db "exponent",0

	

section .bss
  input_buf       resb 100        
  num_str_buf     resb 20        
  
  val_A           resq 1          
  val_B           resq 1         
  val_Op          resq 1          
  val_result      resq 1        
  
  curr_pos        resq 1
    
section .text
  global _start

_start:
  mov eax, 3 ;system_read
  mov ebx, 0 ;stdin
  mov ecx, input_buf ;buffer address
  mov edx, 100 ;length
  int 80h
  
  mov byte [input_buf + eax], 0
  
  mov qword [curr_pos], input_buf ; put initial address of input_buf into [curr_pos] 
  
  call parse_next_int
  mov [val_A], rax
  
  call parse_next_int
  mov [val_B], rax
  
  call parse_next_int
  mov [val_Op], rax
  
  mov rax, [val_Op]
  
  cmp rax, 1
  je max
  
  cmp rax, 2
  je gcd
  
  cmp rax, 3
  je lcm
  
  cmp rax, 4
  je exp
  
  jmp end_prog
   
max:
  mov rax, [val_A]
  mov rbx, [val_B]
  
  cmp rax, rbx
  jge .save_greater
  mov rax, rbx

.save_greater:
  mov [val_result], rax
  jmp print_result
  
gcd:
  mov rax, [val_A]
  mov rbx, [val_B]
.gcd_loop:
  cmp rbx, 0
  je .gcd_done
  
  mov rdx, 0
  div rbx
  mov rax, rbx
  mov rbx, rdx
  jmp .gcd_loop
.gcd_done:
  mov [val_result], rax
  jmp print_result
  
lcm:
  mov rax, [val_A]
  mov rbx, [val_B]
.lcm_gcd_loop:
  cmp rbx, 0
  je .lcm_gcd_done
  
  mov rdx, 0
  div rbx
  mov rax, rbx
  mov rbx, rdx
  jmp .lcm_gcd_loop
.lcm_gcd_done:
  mov rcx, rax ;gcd
  mov rax, [val_A]
  mov rbx, [val_B]
  
  mov rdx, 0
  mul rbx
  div rcx
  mov [val_result], rax
  jmp print_result
  
exp:
  mov rax, 1
  mov rbx, [val_A]
  mov rcx, [val_B]
.exp_loop:
  cmp rcx, 0
  je .exp_done
  sub rcx, 1
  mul rbx
  jmp .exp_loop
.exp_done:
  mov [val_result], rax
  jmp print_result

parse_next_int:
  push rbx
  push rcx
  push rdx
  push rsi
  
  mov rsi, [curr_pos] ;current input_buf address
  mov rax, 0 ;initialize return value to 0
  mov rbx, 0 ;temp least significant digit
  
.skip_space:
  movzx rbx, byte [rsi]
  
  cmp rbx, " "
  je .space_increment
  
  cmp rbx, 10
  je .space_increment
  
  cmp rbx, 0
  je .parsing_done
  
  jmp .parse_digits

.space_increment:
  inc rsi
  jmp .skip_space
  
.parse_digits:
  movzx rbx, byte [rsi]
  
  cmp rbx, "0"
  jl .parsing_done 
  
  cmp rbx, "9"
  jg .parsing_done
  
  imul rax, 10
  sub rbx, "0"
  add rax, rbx
  
  inc rsi
  jmp .parse_digits

.parsing_done:
  mov [curr_pos], rsi

  pop rsi
  pop rdx
  pop rcx
  pop rbx
  
  ret
  
; format: "Function {op}: {name} of {A} and {B} is {Res}."
print_result:

  mov rcx, msg_func
  call print_string
  
  mov rax, [val_Op]
  call print_int
  
  mov rcx, msg_colon
  call print_string
  
  mov rax, [val_Op]
  cmp rax, 1
  je .print_max_string
  cmp rax, 2
  je .print_gcd_string
  cmp rax, 3
  je .print_lcm_string
  cmp rax, 4
  je .print_exp_string
  
.print_max_string:
  mov rcx, msg_max
  jmp .print_func_string
.print_gcd_string:
  mov rcx, msg_gcd
  jmp .print_func_string
.print_lcm_string:
  mov rcx, msg_lcm
  jmp .print_func_string
.print_exp_string:
  mov rcx, msg_exp
  jmp .print_func_string

.print_func_string:
  call print_string

  mov rcx, msg_of
  call print_string
  
  mov rax, [val_A]
  call print_int
  
  mov rcx, msg_and
  call print_string
  
  mov rax, [val_B]
  call print_int
  
  mov rcx, msg_is
  call print_string
  
  mov rax, [val_result]
  call print_int
  
  mov rcx, msg_dot
  call print_string
  
end_prog:
  mov eax, 1  ;sys_exit
  mov ebx, 0
  int 80h

print_string:
  push rax
  push rbx
  push rdx
  push rsi
  
  mov rsi, rcx ;initial address of string
  mov rdx, 0
.string_len:
  cmp byte [rsi + rdx], 0
  je .string_len_done
  inc rdx
  jmp .string_len
.string_len_done:
  mov eax, 4
  mov ebx, 1
  mov ecx, esi
  int 80h
  
  pop rsi
  pop rdx
  pop rbx
  pop rax
  ret
  
print_int:
  push rax
  push rbx
  push rcx
  push rdx
  push rsi
  
  mov rcx, num_str_buf
  add rcx, 19         
  mov byte [rcx], 0   
  
  mov rbx, 10 ;for divide to get least significant digit
  
  cmp rax, 0
  jne .num_to_str 
  dec rcx
  mov byte [rcx], "0"
  jmp .print_num_to_str
  
.num_to_str:
  cmp rax, 0
  je .print_num_to_str
  
  mov rdx, 0
  div rbx
  add dl, "0"
  dec rcx
  mov byte [rcx], dl
  jmp .num_to_str
  
.print_num_to_str:
  call print_string
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  pop rax
  ret