	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main						; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;*** Chapter 9, Problem 10 ***
		LDR r0, =0x00000014	; a Lower
		LDR r1, =0x00000000	; a Upper
		
		LDR r2, =0x00000005	; b Lower
		LDR r3, =0x00000000	; b Upper
		
		BL	gcd				; Solution is stored in: r5
							; Test: a = 20, b = 5
							; Result should be: r5 = 5
		
stop	B  	stop	; Program hangs here.
		ENDP
	
		; *** SUBROUTINES ***
gcd		PROC
		PUSH {r0-r3, lr} 	; Preserve caller's conditions

wh_loop 
		CMP	 r0, r2
		BNE  subtrct		; If not equal, subtract (do until they are)
		CMP	 r1, r3
		BEQ  return

subtrct 
		CMP  r1, r3			; Check if Upper are equal to continue
		BGT  aGTsub 		; if (a > b)
		BLT  elsesub		; else
		CMP  r0, r2
		BGT  aGTsub
		BLT  elsesub

aGTsub	
		SUBS r0, r0, r2
		SBC	 r1, r1, r3
		BL 	 wh_loop

elsesub
		SUBS r2, r2, r0
		SBC	 r3, r3, r1
		B	 wh_loop
		
return
		MOV  r4, r0
		MOV  r5, r1
		POP  {r0-r3, pc}
		
		ENDP
				
		ALIGN
		AREA	myData, DATA, READWRITE

		; *** DECLARATIONS ***
		
		END