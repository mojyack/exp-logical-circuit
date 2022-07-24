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
COUNT0      EQU 0x1F ; used to slow down the count-up {0..255}
COUNT1      EQU 0x10 ; first digit counter {0..9}
COUNT2      EQU 0x11 ; second digit counter {0..9}
COUNT3      EQU 0x12 ; third digit counter {0..9}
TEMP        EQU 0x13 ; temporary variable
WAIT_COUNT  EQU 0x14 ; used in WAIT 

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
    CLRF COUNT0
    CLRF COUNT1
    CLRF COUNT2
    CLRF COUNT3

; main loop
LOOP 
    ; set the DIGIT variables according to the COUNT variables

    MOVFW COUNT1    ; W = COUNT1
    CALL  LOADCHARA ; W = CHARAn
    MOVWF DIGIT1    ; DIGIT1 = CHARAn

    MOVFW COUNT2
    CALL  LOADCHARA
    MOVWF DIGIT2

    MOVFW COUNT3
    CALL  LOADCHARA
    MOVWF DIGIT3

    ; now all DIGIT variables are set, display them
    CALL  SHOWDIGIT

    ; count-up

    INCF  COUNT0    ; COUNT0 += 1
    MOVFW COUNT0
    SUBLW 0xFF
    BTFSC STATUS,2  ; if COUNT0 == 0xFF,
    INCF  COUNT1    ; COUNT1 += 1

    MOVFW COUNT1
    SUBLW 0x0A
    BTFSC STATUS,2  ; if COUNT1 == 10,
    CALL OVERFLOW_1 ; COUNT1 = 0; COUNT2 += 1

    MOVFW COUNT2
    SUBLW 0x0A
    BTFSC STATUS,2  ; if COUNT2 == 10,
    CALL OVERFLOW_2 ; COUNT2 = 0; COUNT3 += 1

    MOVFW COUNT3
    SUBLW 0x10
    BTFSC STATUS,2  ; if COUNT3 == 10,
    CALL OVERFLOW_3 ; COUNT3 = 0

    GOTO  LOOP

OVERFLOW_1
    MOVLW 0
    MOVWF COUNT1
    INCF COUNT2
    RETURN

OVERFLOW_2
    MOVLW 0
    MOVWF COUNT2
    INCF COUNT3
    RETURN

OVERFLOW_3
    CLRF COUNT3
    RETURN

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

; load character from W into W
; i.e. W = (W == n ? CHARAn)
LOADCHARA
    MOVWF TEMP          ; save W

    SUBLW 0
    BTFSC STATUS,2
    GOTO LOADCHARA_0

    MOVFW TEMP
    SUBLW 1
    BTFSC STATUS,2
    GOTO LOADCHARA_1

    MOVFW TEMP
    SUBLW 2
    BTFSC STATUS,2
    GOTO LOADCHARA_2

    MOVFW TEMP
    SUBLW 3
    BTFSC STATUS,2
    GOTO LOADCHARA_3

    MOVFW TEMP
    SUBLW 4
    BTFSC STATUS,2
    GOTO LOADCHARA_4

    MOVFW TEMP
    SUBLW 5
    BTFSC STATUS,2
    GOTO LOADCHARA_5

    MOVFW TEMP
    SUBLW 6
    BTFSC STATUS,2
    GOTO LOADCHARA_6

    MOVFW TEMP
    SUBLW 7
    BTFSC STATUS,2
    GOTO LOADCHARA_7

    MOVFW TEMP
    SUBLW 8
    BTFSC STATUS,2
    GOTO LOADCHARA_8

    MOVFW TEMP
    SUBLW 9
    BTFSC STATUS,2
    GOTO LOADCHARA_9

    MOVFW TEMP
    RETURN

LOADCHARA_0
    MOVLW CHARA0
    RETURN

LOADCHARA_1
    MOVLW CHARA1
    RETURN

LOADCHARA_2
    MOVLW CHARA2
    RETURN

LOADCHARA_3
    MOVLW CHARA3
    RETURN

LOADCHARA_4
    MOVLW CHARA4
    RETURN

LOADCHARA_5
    MOVLW CHARA5
    RETURN

LOADCHARA_6
    MOVLW CHARA6
    RETURN

LOADCHARA_7
    MOVLW CHARA7
    RETURN

LOADCHARA_8
    MOVLW CHARA8
    RETURN

LOADCHARA_9
    MOVLW CHARA9
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
