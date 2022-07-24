;  Test Program?Ver.1?2022/4 by T.Shimizu
;  Modified 2022/7 by mojyack

LIST p=PIC16F84A

INCLUDE "P16F84A.INC"
; CONFIG
; __config 0xFFFA
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _CP_OFF

; variables
DIGIT1      EQU 0x0C ; represents CHARA{0..9} shown on display 1
DIGIT2      EQU 0x0D ;                                         2
DIGIT3      EQU 0x0E ;                                         3
WAIT_COUNT  EQU 0x0F ; used in WAIT

; bit definitions for seven segment display
CHARA0 EQU 0x7E
CHARA1 EQU 0x0C
CHARA2 EQU 0xB6
CHARA3 EQU 0x9E
CHARA4 EQU 0xCC
CHARA5 EQU 0xDA
CHARA6 EQU 0xF8
CHARA7 EQU 0x0E
CHARA8 EQU 0xFE
CHARA9 EQU 0xCE

ORG 0 ; image base address

MAIN
    ; initialize the board
    BSF     STATUS,RP0
    CLRF    TRISB
    MOVLW   B'11000'
    MOVWF   TRISA
    BCF     STATUS,RP0

    ; initialize variables
    CLRF DIGIT1
    CLRF DIGIT2
    CLRF DIGIT3

; main loop
LOOP
    BTFSC PORTA,3   ; read sensor A
    GOTO COND1      ; A == 1
    GOTO COND0      ; A == 0
LOOP_NEXT           ; all the conditional branches above return here
    CALL SHOWDIGIT
    GOTO LOOP

COND0
    BTFSC PORTA,4   ; read sensor B
    GOTO COND01     ; A == 0 && B == 1
    GOTO COND00     ; A == 0 && B == 0

COND1
    BTFSC PORTA,4   ; read sensor B
    GOTO COND11     ; A == 1 && B == 1
    GOTO COND10     ; A == 1 && B == 0

COND00
    MOVLW CHARA0    ; show '0' in display
    MOVWF DIGIT1    ; DIGIT1 = CHARA0
    GOTO LOOP_NEXT

COND01
    MOVLW CHARA1    ; show '1' in display
    MOVWF DIGIT1    ; DIGIT1 = CHARA1
    GOTO LOOP_NEXT

COND10
    MOVLW CHARA2    ; show '2' in display
    MOVWF DIGIT1    ; DIGIT1 = CHARA2
    GOTO LOOP_NEXT

COND11
    MOVLW CHARA3    ; show '3' in display
    MOVWF DIGIT1    ; DIGIT1 = CHARA3
    GOTO LOOP_NEXT

; disable all displays
MASKALL
    BCF PORTA,0
    BCF PORTA,1
    BCF PORTA,2
    RETURN

; display digits stored in DIGIT{1,2,3}
SHOWDIGIT
    CALL MASKALL

    MOVFW DIGIT1
    MOVWF PORTB     ; PORTB = DIGIT1
    BSF PORTA,0     ; unmask display1
    CALL WAIT       ; wait

    CALL MASKALL

    MOVFW DIGIT2
    MOVWF PORTB     ; PORTB = DIGIT2
    BSF PORTA,1     ; unmask display2
    CALL WAIT       ; wait

    MOVFW DIGIT3
    MOVWF PORTB     ; PORTB = DIGIT3
    BSF PORTA,2     ; unmask display3
    CALL WAIT       ; wait

    RETURN

WAIT
    MOVLW 0xFF ;timing adjustment
    MOVWF WAIT_COUNT

WAIT_LOOP
    NOP
    NOP
    DECFSZ WAIT_COUNT,1
    GOTO   WAIT_LOOP
    RETURN

END
