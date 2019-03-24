include mPushPop.asm
IDEAL
MODEL small
STACK 100h
DATASEG

; ------------------------------

	include "pTank.asm" ; Character file handler
	newPos		dw	?
	oldPos		dw	?
	x			dw	?
	y			dw	?
	tankHeight	dw	50 ; My tank height
	tankWidth	dw	30 ; My tank width
	scrKeep	db	100 dup(?)
	filename db 'blueScr.bmp',0
    filehandle dw ?
    Header db 54 dup (0)
    Palette db 256*4 dup (0)
    ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10,'$'
	goodByeMsg db 'Hope you enjoyed. Goodbye!$'
	
; ------------------------------

CODESEG
	include "openFile.asm"
	
proc anding
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newPos]
	mov si, offset pTankMask
	mov cx,[tankHeight]
	
and1:
	push cx
	mov cx,[tankWidth]
	
xx:
	lodsb
	and [es:di],al
	inc di
	loop xx
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop and1
	doPop cx, si, di, es, ax
	ret
endp anding

proc oring
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newPos]
	mov si, offset pTank
	mov cx,[tankHeight]
	
or1:
	push cx
	mov cx,[tankWidth]
	
yy:
	lodsb
	or [es:di],al
	inc di
	loop yy
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop or1
	doPop cx, si, di, es, ax
	ret
endp oring

proc takeSqr
	; input: taking the current position into newPos variable
	; output: taking the sqr size into scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [newPos]
	mov si, offset scrKeep
	mov cx, [tankHeight]
	
takeLine:
	push cx
	mov cx, [tankWidth]
	
takeCol:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop takeLine
	doPop cx, di, si, ax, es
	ret
endp takeSqr

proc retSqr
	; input: the last position into oldPos variable
	; output: restoring the last sqr in scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[oldPos]
	mov si, offset scrKeep
	mov cx, [tankHeight]
	
retLine:
	push cx
	mov cx, [tankWidth]
	
retCol:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop retLine
	doPop cx, di, si, ax, es
	ret
endp retSqr

proc moveWithSqr
	; input: getting positions y + x
	; output: moving the character and restoring the background and taking the new square the character is going to
	doPush bx, cx
	mov bx, [x] ; The current position of X.
	mov cx, [y] ; The times we will need to loop for rows.
	
createR: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR

returnSqr:
	mov [newPos], bx ; The new position we got into newPos variable
	call retSqr ; Return last sqr to the old position
	call takeSqr ; Taking new sqr from the newPos
	call anding
	call oring
	mov bx, [newPos]
	mov [oldPos], bx
	doPop cx, bx
	ret
endp moveWithSqr

start:
	mov ax, @data
	mov ds, ax
	
; ------------------------------

	; Entering graphic mode:
	mov ax, 13h
	int 10h

	; Print background:
	call bmp

	; Printing the character && getting the first pos:
	mov [newPos], 320*150+135 ; Middle Screen
	call takeSqr ; Take the first square before printing the character
	mov [oldPos], 320*150+135 ; Middle Screen
	mov [x], 142 ; Using X + Y to control the character
	mov [y], 150 ; Using X + Y to control the character
	; Printing the sprite:
	call anding
	call oring

checkKey:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if right arrow:
	cmp al, 4Dh
	je arrowRight
	; Check if left arrow:
	cmp al, 4Bh
	je arrowLeft
	; Check if space key:
	cmp al, 20h
	je ifSpaceGoCenter
	; Check if esc key:
	cmp al, 1Bh
	je endProgram
	jmp checkKey

arrowRight:
	cmp [x], 320-60
	jae	checkKey
	add [x], 40
	call moveWithSqr
	jmp checkKey

arrowLeft:
	sub [newPos], 25
	cmp [x], 60
	jbe	checkKey
	sub [x], 40
	call moveWithSqr
	jmp checkKey

ifSpaceGoCenter:
	mov [x], 142
	mov [y], 150
	call moveWithSqr
	jmp checkKey
	
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


