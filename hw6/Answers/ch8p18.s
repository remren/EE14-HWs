	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main						; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;*** Chapter 8, Problem 18 ***
		MOV r0, #6		; r0 should ultimately return F(n), fib number
		BL 	fib
		
stop	B  	stop		; Program hangs here.
		ENDP
	
		; *** SUBROUTINES ***
fib		PROC
		
		PUSH{r4, r5, lr}
		MOV	r4, r0
		CMP r4, #2
		
		BHS else		; Calls on smaller problem, if n\geq 2

return	
		POP	{r4,r5,pc}
else
		SUB r0, r4, #1	; Smaller problem
		BL	fib
		MOV	r5, r0
		SUB r0, r4, #2	; Smaller problem
		BL	fib
		
		ADD r0, r5, r0	; F(n) = F(n-1)+F(n-2)
		B	return
		
		ENDP
				
		ALIGN
		AREA	myData, DATA, READWRITE

		; *** DECLARATIONS ***
		
		END
