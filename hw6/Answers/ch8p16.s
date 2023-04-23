	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main						; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;*** Chapter 8, Problem 16 ***
		;ADD r0, #0			; weird memory alignment trick
		LDR r0, =array		; r0 stores the resulting cardinality
		LDR r1, =size
		LDR r1, [r1]
		
		MOV r6, #0			; RESULT IS STORED IN r6
		CMP r1, #0			; if array has no elements, cardinality is 0.
		BEQ skippie
		
		B  crdnlty			; Resulting cardinality is in r6 (1, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8) should give 8

skippie
post_c	

stop 	B 	stop     ; dead loop & program hangs here

		ENDP
	
		; *** SUBROUTINES ***
		; Let r2 = i, r3 = j, r12 = test (indicates total number of iterations: i*j)
crdnlty PROC
		MOV	r2, #0			; i = 0
		MOV r12, #0			; test = 0
		B iLoop		
post_i  
		B post_c
			
iLoop	
		MOV r3, r2			; j = i
		MOV r11, #1			; Let r11 = uniqueness, where 1 = unique, 0 = not unique
		B jLoop
post_j		
		CMP r11, #0
		ADDNE r6, #1		; if unique, cardinality++
		ADD r2, #1
		CMP r2, r1			; if i > size, exit iLoop
		BLT iLoop 
		B 	post_i


jLoop	
		CMP r2, r3			; check if i == j, go to next iteration if equal
		BEQ skip
		MOV r4, r0			; r4 gets array address
		ADD r4, r2, LSL #2  ; array's address + i
		LDR r4, [r4]		; load array[i]
		MOV r5, r0			; r5 gets array address
		ADD r5, r3, LSL #2  ; array's address + j
		LDR r5, [r5]		; load array[j]
		CMP r4, r5
		MOVEQ r11, #0		; if not unique, set to 0
skip
		ADD r12, #1			; test++
		ADD r3, #1
		CMP r3, r1			; if j > size, exit jLoop
		BLT jLoop
		B	post_j		
		
		ENDP

		ALIGN
		AREA	myData, DATA, READWRITE

		; *** DECLARATIONS ***
array 	DCD		1, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8
size  	DCD		11

		END
