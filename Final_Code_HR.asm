.model tiny

;8255 for data transfer
pa equ 08h
pb equ 0ah
pc equ 0ch
creg equ 0eh ;control register

;8255 for LCD
porta equ 10h
portb equ 12h
portc equ 14h
creg1 equ 16h ;control register

;8253
count0 equ 00h
count1 equ 02h
count2 equ 04h
creg2 equ 06h ;control register


.code
.startup


;initialising 8253
;Here we set the mode of 8253 to be equal to 3
;The count of counter 0  is set to 17 to get 9 low pulses
;and 8 low pulses of 40 millisecs each


start1: mov al, 00110110b
out creg2, al
mov al, 11h
out count0, al
mov al, 00h
out count0, al

mov cx,0

; for 8255 1st which we use for data transaction between processor and lcd

mov al,10000000b
out creg1,al




; for 8255 1st which we use for data transaction between processor and ROM
mov al, 10001001b
out creg, al

in al, pc
and al, 00000001B	;Here we check whether C0 is set to 1 which indicates
				 	;which ROM is being programmed
cmp al, 00h			;If C0 is zero,EPROM1 is being programmed
jz rom1

rom2: 

mov al, 10000010b
out creg, al		;control register programmed
loop1: in al, pb
		cmp al,0
		je loop1	;this loop ensures that program doesnt proceed forward
					;when address stablisation in being done

cmp al, 0ffh 		;comparision to see whether the location is empty i.e. all 1's
jz x1

;There is nothing specified in the problem on what to do if the location content
;is not found to be FFh. So we have left the space as it is.
;Although some minor operation like glowing a LED can be done.

x1: mov al, 80h
out creg, al
mov al, 00h
out pb, al
inc cx

;compare count with maxcount so that the loop can be exited if all the locations have been accessed
cmp cx,1fffh
jnz rom2
jz lcdrom2




rom1:

mov al, 10010000b
out creg, al
loop2 : in al,pa
		cmp al,0
		je loop2 		;this loop ensures that program doesnt proceed forward
						;when address stablisation in being done

cmp al, 0ffh 			;comparision to see whether the location is empty i.e. all 1's
jz x2

;There is nothing specified in the problem on what to do if the location content
;is not found to be FFh. So we have left the space as it is.
;Although some minor operation like glowing a LED can be done.

x2: mov al, 80h
out creg, al
mov al, 00h
out pa, al
inc cx

;compare count with maxcount so that the loop can be exited if all the locations have been accessed
cmp cx,07FFh

jnz rom1
jz lcdrom1



lcdrom1:

; initialise hardware
	; initialise the lcd
	; check for busy status
	; clear the screen
	; display 'empty'
	;call init_motor
	
	
	;writing on the command register for initialization
	
	CALL LCD_INIT ;calling lcd initialization
	CALL WRITE_2716
	JMP lastcode

WRITE_2716 PROC NEAR
	CALL CLS
	MOV AL, '2' ;display ‘2’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait before issuing the next character
	MOV AL, '7' ;display ‘7’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait before issuing the next character
	MOV AL, '1' ;display ‘1’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, '6' ;display ‘6’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, ' ' ;display ‘ ’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'P' ;display ‘P’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'R' ;display ‘R’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'O' ;display ‘O’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'G' ;display ‘G’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	RET
WRITE_2716 ENDP


lcdrom2:
; initialise hardware
	; initialise the lcd
	; check for busy status
	; clear the screen
	; display 'empty'
	;call init_motor
	
	
	;writing on the command register for initialization
	
	CALL LCD_INIT ;calling lcd initialization
	CALL WRITE_2764
	JMP  lastcode


LCD_INIT PROC NEAR
	MOV AL, 38H ;initialize LCD for 2 lines & 5*7 matrix
	CALL COMNDWRT ;write the command to LCD
	CALL DELAY ;wait before issuing the next command
	CALL DELAY ;this command needs lots of delay
	CALL DELAY
	MOV AL, 0EH ;send command for LCD on, cursor on	
	CALL COMNDWRT
	CALL DELAY
	MOV AL, 01  ;clear LCD
	CALL COMNDWRT	
	CALL DELAY
	MOV AL, 06  ;command for shifting cursor right
	CALL COMNDWRT
	CALL DELAY
	RET
LCD_INIT ENDP

CLS PROC 
	MOV AL, 01  ;clear LCD
	CALL COMNDWRT
	CALL DELAY
	CALL DELAY
	RET
CLS ENDP

COMNDWRT PROC ;this procedure writes commands to LCD
	MOV DX, PORTA
	OUT DX, AL  ;send the code to Port A
	MOV DX, PORTB 	
	MOV AL, 00000100B ;RS=0,R/W=0,E=1 for H-To-L pulse
	OUT DX, AL
	NOP
	NOP	
	MOV AL, 00000000B ;RS=0,R/W=0,E=0 for H-To-L pulse
	OUT DX, AL
	RET
COMNDWRT ENDP

WRITE_2764 PROC NEAR
	CALL CLS
	MOV AL, '2' ;display ‘2’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait before issuing the next character
	MOV AL, '7' ;display ‘7’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait before issuing the next character
	MOV AL, '1' ;display ‘6’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, '6' ;display ‘4’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, ' ' ;display ‘ ’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'P' ;display ‘P’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'R' ;display ‘R’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'O' ;display ‘O’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	MOV AL, 'G' ;display ‘G’ letter
	CALL DATWRIT ;issue it to LCD
	CALL DELAY ;wait before issuing the next character
	CALL DELAY ;wait
	RET
WRITE_2764 ENDP

DATWRIT PROC
	PUSH DX  ;save DX
	MOV DX,PORTA  ;DX=port A address
	OUT DX, AL ;issue the char to LCD
	MOV AL, 00000101B ;RS=1, R/W=0, E=1 for H-to-L pulse
	MOV DX, PORTB ;port B address
	OUT DX, AL  ;make enable high
	MOV AL, 00000001B ;RS=1,R/W=0 and E=0 for H-to-L pulse
	OUT DX, AL
	POP DX
	RET
DATWRIT ENDP ;writing on the lcd ends 

;delay in the circuit here the delay of 20 millisecond is produced
DELAY PROC
	MOV CX, 1325 ;1325*15.085 usec = 20 msec
	W1: 
		NOP
		NOP
		NOP
		NOP
		NOP
	LOOP W1
	RET
DELAY ENDP

lastcode: NOP

.exit
END