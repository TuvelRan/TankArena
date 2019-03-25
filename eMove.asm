include mPushPop.asm
IDEAL
MODEL small
STACK 100h
DATASEG

; ------------------------------

	include "eTank.asm" ; Character file handler
	newEnemyPos		dw	?
	oldEnemyPos		dw	?
	enemyX			dw	?
	enemyY			dw	?
	eTankHeight	dw	50 ; My tank height
	eTankWidth	dw	30 ; My tank width
	scrKeep	db	100 dup(?)
	filename db 'blueScr.bmp',0
    filehandle dw ?
    Header db 54 dup (0)
    Palette db 256*4 dup (0)
    ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10,'$'
	goodByeMsg db 'Hope you enjoyed. Goodbye!$'
	divisorTable db 10,1,0
	Clock equ es:6Ch
	EndMessage db 13,10,'$'
	eTurnValue db ?
	eShotX dw ?
	eShotY dw ?
	color db 0078
	
; ------------------------------

CODESEG
	include "openFile.asm"
	
proc eAnding
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newEnemyPos]
	mov si, offset eTankMask
	mov cx,[eTankHeight]
	
and1:
	push cx
	mov cx,[eTankWidth]
	
xx:
	lodsb
	and [es:di],al
	inc di
	loop xx
	add di, 320
	sub di, [eTankWidth]
	pop cx
	loop and1
	doPop cx, si, di, es, ax
	ret
endp eAnding

proc eOring
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newEnemyPos]
	mov si, offset eTank
	mov cx,[eTankHeight]
	
or1:
	push cx
	mov cx,[eTankWidth]
	
yy:
	lodsb
	or [es:di],al
	inc di
	loop yy
	add di, 320
	sub di, [eTankWidth]
	pop cx
	loop or1
	doPop cx, si, di, es, ax
	ret
endp eOring

proc eTakeSqr
	; input: taking the current position into newEnemyPos variable
	; output: taking the sqr size into scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [newEnemyPos]
	mov si, offset scrKeep
	mov cx, [eTankHeight]
	
takeLine:
	push cx
	mov cx, [eTankWidth]
	
takeCol:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol
	add di, 320
	sub di, [eTankWidth]
	pop cx
	loop takeLine
	doPop cx, di, si, ax, es
	ret
endp eTakeSqr

proc eRetSqr
	; input: the last position into oldEnemyPos variable
	; output: restoring the last sqr in scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[oldEnemyPos]
	mov si, offset scrKeep
	mov cx, [eTankHeight]
	
retLine:
	push cx
	mov cx, [eTankWidth]
	
retCol:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol
	add di, 320
	sub di, [eTankWidth]
	pop cx
	loop retLine
	doPop cx, di, si, ax, es
	ret
endp eRetSqr

proc eMoveWithSqr
	; input: getting positions enemyY + enemyX
	; output: moving the character and restoring the background and taking the new square the character is going to
	doPush bx, cx
	mov bx, [enemyX] ; The current position of enemyX.
	mov cx, [enemyY] ; The times we will need to loop for rows.
	
createR: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR

returnSqr:
	mov [newEnemyPos], bx ; The new position we got into newEnemyPos variable
	call eRetSqr ; Return last sqr to the old position
	call eTakeSqr ; Taking new sqr from the newEnemyPos
	call eAnding
	call eOring
	mov bx, [newEnemyPos]
	mov [oldEnemyPos], bx
	doPop cx, bx
	ret
endp eMoveWithSqr

proc printNumber
; enter – number in dx:ax
; exit – printing the number
	doPush ax,bx,dx
	mov bx,offset divisorTable
nextDigit:
	xor ah,ah 	; dx:ax = number
	div [byte ptr bx]	 ; al = quotient, ah = remainder	
	add al,'0'
	call printCharacter 	; Display the quotient
	mov al,ah 	; ah = remainder
	add bx,1 		; bx = address of next divisor
	cmp [byte ptr bx],0 ; Have all divisors been done?
	jne nextDigit
	mov ah,2
	mov dl,13
	int 21h
	mov dl,10
	int 21h	
	doPop dx,bx,ax
	ret
endp printNumber

proc printCharacter
; enter – character in al
; exit – printing the character
	doPush ax,dx
	mov ah,2
	mov dl, al
	int 21h
	doPop dx,ax
	ret
endp printCharacter

proc randomMove
	RandLoop:
	; generate random number, cx number of times
	mov ax, [Clock] 		; read timer counter
	mov ah, [byte cs:bx] 	; read one byte from memory
	xor al, ah 			; xor memory and counter
	and al, 00000001b	; leave result between 0-15
	add [eTurnValue], al
	inc bx

FirstTick: 
	cmp ax, [Clock]
	je FirstTick
	; count 10 sec
	mov cx, 9
DelayLoop:
	mov ax, [Clock]
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	cmp [eTurnValue], 1
	je arrowRight
	cmp [eTurnValue], 0
	je arrowLeft
	ret
endp randomMove

proc drawPixel
	mov bh, 0h
	mov cx, [eShotX]
	mov dx, [eShotY]
	mov al, [color]
	mov ah, 0Ch
	int 10h
	ret
endp drawPixel


start:
	mov ax, @data
	mov ds, ax
	
; ------------------------------

	; Entering graphic mode:
	mov ax, 13h
	int 10h

	; Print background:
	call bmp
	
	; intializing:
	mov ax, 40h
	mov es, ax
	mov cx, 1
	mov bx, 0

	; Printing the character && getting the first pos:
	mov [newEnemyPos], 320*10+142 ; Middle Screen
	call eTakeSqr ; Take the first square before printing the character
	mov [oldEnemyPos], 320*10+142 ; Middle Screen
	mov [enemyX], 142 ; Using enemyX + enemyY to control the character
	mov [enemyY], 10 ; Using enemyX + enemyY to control the character
	; Printing the sprite:
	call eAnding
	call eOring

checkKey:
	in al, 64h
	cmp al, 10b
	je checkKey
	in al, 60h
	; Check if esc key:
	cmp al, 1h
	je endProgram
	
goRandom:
	call randomMove

arrowRight:
	mov [eTurnValue], 0
	cmp [enemyX], 320-60
	jae	checkKey
	add [enemyX], 40
	call eMoveWithSqr
	jmp checkKey

arrowLeft:
	mov [eTurnValue], 0
	sub [newEnemyPos], 25
	cmp [enemyX], 60
	jbe	checkKey
	sub [enemyX], 40
	call eMoveWithSqr
	jmp checkKey
	
enemyShoot:
	mov bx, [enemyX]
	mov [eShotX], bx
	; Continue shooting
	
endProgram:
	; Entering text mode
	mov ax, 3h
	int 10h
	; Print goodbye message
	mov dx, offset goodByeMsg
	mov ah, 9h
	int 21h
	
; ------------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start