	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main						; make __main visible to linker
	ENTRY			
				
__main	PROC
	
		;*** Chapter 8, Problem 9 ***
			MOV  r0, #5	 ; 5th arg 
			MOV  r1, #6	 ; 6th arg 	
			MOV	 r2, #7	 ; 7th arg 
			MOV	 r3, #8	 ; 8th arg 

			PUSH {r0, r1, r2, r3}; push args 5-8 to stack

			MOVS r0, #1	 ; 1st arg
			MOVS r1, #2  ; 2nd arg
			MOVS r2, #3  ; 3rd arg
			MOVS r3, #4	 ; 4th arg

			BL	 multiply	; Result is stored in r0 = 0x9D80 = 0d40320 = 1*2*3*4*5*6*7*8
	
stop 		B 		stop 	; dead loop & program hangs here

			ENDP
		
			; *** SUBROUTINES ***

multiply	PROC
			PUSH {r4-r7, lr}

			MUL  r0, r0, r1	 
			MUL	 r0, r0, r2
			MUL	 r0, r0, r3	
			LDRD r1, r2, [sp, #20]
			
			MUL  r0, r0, r1
			MUL  r0, r0, r2
			LDRD r1, r2, [sp, #28]
			
			MUL  r0, r0, r1
			MUL  r0, r0, r2
			BX   LR
			ENDP
			ALIGN			

			AREA    myData, DATA, READWRITE

		END
