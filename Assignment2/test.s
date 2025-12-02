	adds r1,r2,r3
	mov r1, #1
L1:	and r1, r1, #1
	cmple r2, #100
	ble L1
	SWI #9
	ldr r3, [r1], #101
	str r5, [r2], #6
	RSB r2,r15, #8
	
	SWI #0
	
	
	

    
    