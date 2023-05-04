	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	; *** HW7 - Textbook CH Problem 6 ***
	
		; System Clock Initialization!!!
		LDR r0, = RCC_BASE				; Enable High Speed Oscillator
		LDR r1, [r0, #RCC_CR]			; Taken mostly from SysClock.c
		ORR r1, r1, #RCC_CR_HSION
		STR r1, [r0, #RCC_CR]

		LDR r0, = RCC_BASE
		LDR r1, [r0, #RCC_CFGR]
		BIC r1, r1, #RCC_CFGR_SW
		STR r1, [r0, #RCC_CFGR]
		LDR r0, = RCC_BASE
		LDR r1, [r0, #RCC_CR]
		BIC r1, r1, #RCC_CR_MSIRANGE
		STR r1, [r0, #RCC_CR]
		
		LDR r0, = RCC_BASE
		LDR r1, [r0, #RCC_CR]
		BIC r1, r1, #RCC_CR_MSIRANGE
		ORR r1, r1, #RCC_CR_MSIRANGE_7
		STR r1, [r0, #RCC_CR]
		
		LDR r0, = RCC_BASE
		LDR r1, [r0, #RCC_CR]
		ORR r1, r1, #RCC_CR_MSIRGSEL
		STR r1, [r0, #RCC_CR]
		
		LDR r0, = RCC_BASE				; Enable GPIOE Clock
		LDR r1, [r0, #RCC_AHB2ENR]
		ORR r1, r1, #RCC_AHB2ENR_GPIOEEN
		STR r1, [r0, #RCC_AHB2ENR]
		
		LDR r0, = GPIOE_BASE			; Set Mode of Pin 8 to Alternate Function
		LDR r1, [r0, #GPIO_MODER]
		BIC r1, r1, #(0x03 << 16)	; Clear bit 17 and 16	
		ORR r1, r1, #(0x02 << 16)	; Set AF Mode to: 10
		
		STR r1, [r0, #GPIO_MODER]
		LDR r1, [r0, #GPIO_AFR1]		; Select Alternate Function 1 (TIM_CH1N)
		BIC r1, #0x0F				; ARF[0] for pin 0-7, ARF[1]: pin 8-15
		ORR r1, #0x01				; TIM1_CH1N defined as 01
		STR r1, [r0, #GPIO_AFR1]
		
		LDR r1, [r0, #GPIO_OSPEEDR]		; Set I/O output speed value as low
		BIC r1, r1, #(0x03<<16)			; 00 = Low
		STR r1, [r0, #GPIO_OSPEEDR]
		LDR r1, [r0, #GPIO_PUPDR]
		BIC r1, r1, #(0x03<<16)			; Set PE.8 to  No Pull Up/No Pull Down
		STR r1, [r0, #GPIO_PUPDR]
		
		LDR r0, = RCC_BASE
		LDR r1, [r0, #RCC_APB2ENR]
		ORR r1, r1, #RCC_APB2ENR_TIM1EN	; Enable timer 1 clock
		STR r1, [r0, #RCC_APB2ENR]
		
		LDR r0, =TIM1_BASE				; Interacting with TIM1
		LDR r1,[r0, #TIM_CR1]
		BIC r1, r1, #TIM_CR1_DIR		; Counting direction: 0 = up-counting, 1 = down-counting
		STR r1, [r0, #TIM_CR1]
		
		LDR r1, [r0, #TIM_PSC]			; Clock prescaler (16-bits, up to 65,535)
		LDR r1, = 8						; Problem 6
		STR r1, [r0, #TIM_PSC]
		
		LDR r1, [r0, #TIM_ARR]			; Auto-reload?
		LDR r1, = 1000-1				; ARR - 1, for problem 6
		STR r1, [r0, #TIM_ARR]
		
		LDR r1, [r0, #TIM_CCR1]			; Can be any value between 0 and 1999
		LDR r1, = 500
		STR r1, [r0, #TIM_CCR1]
		
		LDR r1, [r0, #TIM_BDTR]			; Main output enable (MOE): 0=Disable, 1=Enable
		ORR r1, r1, #TIM_BDTR_MOE
		STR r1, [r0, #TIM_BDTR]
		
		LDR r1, [r0, #TIM_CCMR1]		; Clear output compare mode bits for channel 1
		LDR r2, = TIM_CCMR1_OC1M
		BIC r1, r1, r2
		STR r1, [r0, #TIM_CCMR1]
		
		LDR r1, [r0, #TIM_CCMR1]		; Select Toggle Mode (0011)
		ORR r1, r1, #TIM_CCMR1_OC1M_0
		ORR r1, r1, #TIM_CCMR1_OC1M_1
		STR r1, [r0, #TIM_CCMR1]
		
		LDR r1, [r0, #TIM_CCER]			; Select output polarity: 0=ActiveHigh, 1=ActiveLow
		BIC r1, r1, #TIM_CCER_CC1NP
		STR r1, [r0, #TIM_CCER]
		
		LDR r1, [r0, #TIM_CCER]			; Enable Output for channel 1 complementary output
		ORR r1, r1, #TIM_CCER_CC1NE
		STR r1, [r0, #TIM_CCER]
		
		LDR r1,[r0, #TIM_CR1]			; Enable Timer 1
		ORR r1, r1, #TIM_CR1_CEN
		STR r1, [r0, #TIM_CR1]
		
		; NO DEAD LOOP OR ELSE THIS PROGRAM DOESN'T WORK!!!
				
	ALIGN
	AREA	myData, DATA, READWRITE

	; *** DECLARATIONS ***

	END
