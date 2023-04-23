	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main						; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;*** Chapter 9, Problem 2 ***
	; Test: a = 0x ABCD ABCD ABCD ABCD, b = 0x 1111 2222 3333 4444
	; Result should be: 0x 79BD 9BDF BE01 E022 (Windows Calculator)
	; Test: a = 0x DCBA DCBA DCBA DCBA, b = 0x 4444 3333 2222 1111
	; Result should be: 0x 41FE 1FDB FDB9 DB96
		;LDR	r0, =0xABCDABCD	; a Lower
		;LDR r1, =0xABCDABCD	; a Upper
		
		;LDR r2, =0x33334444	; b Lower
		;LDR r3, =0x11112222	; b Upper
		LDR r0, =0xDCBADCBA	; a Lower
		LDR r1, =0xDCBADCBA	; a Upper
		
		LDR r2, =0x22221111	; b Lower
		LDR r3, =0x44443333	; b Upper
		
		BL	dubsum			; Solution is stored in: r5(Upper),r4(Lower)
		
stop	B  	stop	; Program hangs here.
		ENDP
	
		; *** SUBROUTINES ***
dubsum	PROC
	
		ADDS r4, r0, r2		; Add a and b Lower, update Flags
		ADC	 r5, r3, r1		; Add a and b Upper w/Flags
		
		MOV  r6, r4
		LSR	 r6, #31		; Take carry from Lower 
		
		MOV  r4, r4, LSL #1	; As 2a + 2b = 2(a + b) = 2(aLower + bLower) + 2(aUpper + bUpper)
		MOV  r5, r5, LSL #1 ; Do same for Upper
		ORR	 r5, r6			; Incorporate carry from Lower
		
		ENDP
				
		ALIGN
		AREA	myData, DATA, READWRITE

		; *** DECLARATIONS ***
		
		END