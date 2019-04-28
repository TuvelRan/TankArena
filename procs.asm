proc eAnding
; enter: enemy Position, tank height, width and masks.
; exit: Copying the mask and pasting it afterwards
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newEnemyPos]
	mov si, offset eTankMask
	mov cx,[eTankHeight]
	
and2:
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
	loop and2
	doPop cx, si, di, es, ax
	ret
endp eAnding

proc eOring
; enter: parameters of the new pos to paste the mask in
; exit: pasting the mask in the new position
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newEnemyPos]
	mov si, offset eTank
	mov cx,[eTankHeight]
	
or2:
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
	loop or2
	doPop cx, si, di, es, ax
	ret
endp eOring

proc eTakeSqr
	; input: taking the current position into newEnemyPos variable
	; output: taking the sqr size into eScrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [newEnemyPos]
	mov si, offset eScrKeep
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
	; output: restoring the last sqr in eScrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[oldEnemyPos]
	mov si, offset eScrKeep
	mov cx, [eTankHeight]
	
retLine3:
	push cx
	mov cx, [eTankWidth]
	
retCol3:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol3
	add di, 320
	sub di, [eTankWidth]
	pop cx
	loop retLine3
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
	and al, 3	; leave result between 0-15
	mov [eTurnValue], al
	inc bx
FirstTick: 
	cmp ax, [Clock]
	je FirstTick
	mov cx, 4
DelayLoop:
	mov ax, [Clock]
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	
go_to_controlls:
	jmp controlls
	
return_fromRandomMove:
	ret
endp randomMove

proc anding
; enter: enemy Position, tank height, width and masks.
; exit: Copying the mask and pasting it afterwards
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newPos]
	mov si, offset pTankMask
	mov cx,[tankHeight]
	
and1:
	push cx
	mov cx,[tankWidth]
	
xx1:
	lodsb
	and [es:di],al
	inc di
	loop xx1
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop and1
	doPop cx, si, di, es, ax
	ret
endp anding

proc oring
; enter: parameters of the new pos to paste the mask in
; exit: pasting the mask in the new position
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newPos]
	mov si, offset pTank
	mov cx,[tankHeight]
	
or1:
	push cx
	mov cx,[tankWidth]
	
yy1:
	lodsb
	or [es:di],al
	inc di
	loop yy1
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
	
takeLine1:
	push cx
	mov cx, [tankWidth]
	
takeCol1:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol1
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop takeLine1
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
	
createR1: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR1

returnSqr1:
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

proc movePlayer
	; input: getting positions y + x
	; output: moving the character and restoring the background and taking the new square the character is going to
	mov bx, [x] ; The current position of X.
	mov cx, [y] ; The times we will need to loop for rows.
	
createR2: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR2

FirstTick1:
	cmp ax, [Clock]
	je FirstTick1
	mov cx, 1
DelayLoop1:
	mov ax, [Clock]
Tick1:
	cmp ax, [Clock]
	je Tick1
	loop DelayLoop1
	doPush bx, cx
returnSqr2:
	mov [newPos], bx ; The new position we got into newPos variable
	call retSqr ; Return last sqr to the old position
	call takeSqr ; Taking new sqr from the newPos
	call anding
	call oring
	mov bx, [newPos]
	mov [oldPos], bx
	doPop cx, bx
	ret
endp movePlayer


proc moveShot
	doPush ax,bx,cx,dx
	mov dx, [x]
	mov [shotX], dx
	add [shotX], 9
	mov dx, [y]
	mov [shotY], dx
	sub [shotY], 8
	mov cx, [shotY]
mulShotY:
	add ax, 320
	loop mulShotY
addXToResult:
	add ax, [shotX]
	mov [newShotPos], ax
goMoving:
	; input: getting positions y + x
	; output: moving the character and restoring the background and taking the new square the character is going to
	mov bx, [shotX] ; The current position of X.
	mov cx, [shotY] ; The times we will need to loop for rows.
	
createR12: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR12
	
FirstTick12:
	cmp ax, [Clock]
	je FirstTick12
	mov cx, 1
DelayLoop12:
	mov ax, [Clock]
Tick12:
	cmp ax, [Clock]
	je Tick12
	loop DelayLoop12

returnSqr12:
	mov [newShotPos], bx ; The new position we got into newPos variable
	call shotRetSqr ; Return last sqr to the old position
	call shotTakeSqr ; Taking new sqr from the newPos
	call shotAnding
	call shotOring
	mov bx, [newShotPos]
	mov [oldShotPos], bx
	sub [shotY], 13
	dec [shotLength]

; Read pixel value into al
	mov bh,0h
	mov cx,[shotX]
	mov dx,[shotY]
	mov ah,0Dh
	int 10h
	
checkIfHit:
	cmp al, 0077
	je hitEnemy
	cmp [shotLength], 0
	je returnFromShot
	jmp goMoving
	
hitEnemy:
	dec [enemyHP]
	call shotRetSqr
refreshEnemyHPtxt:
	mov bh, 0
	mov dh, 1
	mov dl, 0
	mov ah, 2h
	int 10h
	mov	dx, offset enemyHPtxt
	mov ah, 9
	int 21h
	xor ax, ax
	mov al, [enemyHP]
	call printNumber
	cmp [enemyHP], 0
	je enemyDead
	jmp returnFromShot
	
enemyDead:
	jmp endProgram
	
returnFromShot:
	mov [shotLength], 10
	mov ah,0Ch
	mov al,0
	int 21h
	doPop dx,cx,bx,ax
	ret
endp moveShot

proc shotAnding
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newShotPos]
	mov si, offset pShotMask
	mov cx,[pShotHeight]
	
and5:
	push cx
	mov cx,[pShotWidth]
	
xx5:
	lodsb
	and [es:di],al
	inc di
	loop xx5
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop and5
	doPop cx, si, di, es, ax
	ret
endp shotAnding

proc shotOring
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newShotPos]
	mov si, offset pShot
	mov cx,[pShotHeight]
	
or5:
	push cx
	mov cx,[pShotWidth]
	
yy5:
	lodsb
	or [es:di],al
	inc di
	loop yy5
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop or5
	doPop cx, si, di, es, ax
	ret
endp shotOring

proc shotTakeSqr
	; input: taking the current position into newShotPos variable
	; output: taking the sqr size into scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [newShotPos]
	mov si, offset shotScrKeep
	mov cx, [pShotHeight]
	
takeLine5:
	push cx
	mov cx, [pShotWidth]
	
takeCol5:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol5
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop takeLine5
	doPop cx, di, si, ax, es
	ret
endp shotTakeSqr

proc shotRetSqr
	; input: the last position into oldShotPos variable
	; output: restoring the last sqr in scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[oldShotPos]
	mov si, offset shotScrKeep
	mov cx, [pShotHeight]
	
retLine5:
	push cx
	mov cx, [pShotWidth]
	
retCol5:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol5
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop retLine5
	doPop cx, di, si, ax, es
	ret
endp shotRetSqr

proc enemyAvoidShot
RandLoop55:
	doPush ax,bx,cx
	; generate random number, cx number of times
	mov ax, [Clock] 		; read timer counter
	mov ah, [byte cs:bx] 	; read one byte from memory
	xor al, ah 			; xor memory and counter
	and al, 2	; leave result between 0,1,2
	mov [eTurnValue], al
	inc bx
FirstTick55: 
	cmp ax, [Clock]
	je FirstTick55
	mov cx, 4
DelayLoop55:
	mov ax, [Clock]
Tick55:
	cmp ax, [Clock]
	je Tick55
	loop DelayLoop55
	; if got 0 or dice move enemy to left
	cmp [eTurnValue], 0
	je enemyLeftNow
	; if got 1 or dice move enemy to right
	cmp [eTurnValue], 1
	je enemyRightNow
	
enemyLeftNow:
	mov [eTurnValue], 0
	jmp enemyAvoidLeft
enemyRightNow:
	mov [eTurnValue], 0
	jmp enemyAvoidRight
	
enemyAvoidLeft:
	; Moving the enemy tank to left
	sub [newEnemyPos], 25
	cmp [enemyX], 60
	jbe	enemyAvoidRight
	sub [enemyX], 40
	call eMoveWithSqr
	jmp returnFromAvoiding

enemyAvoidRight:
	; Moving the enemy tank to right
	cmp [enemyX], 320-60
	jae	enemyAvoidLeft
	add [enemyX], 40
	call eMoveWithSqr
	
returnFromAvoiding:
	doPop cx,bx,ax
	ret
endp enemyAvoidShot

proc eMoveShot
	doPush ax,bx,cx,dx
	mov dx, [enemyX]
	mov [eShotX], dx
	mov dx, [enemyY]
	mov [eShotY], dx
	mov cx, [eShotY]
eMulShotY:
	add ax, 320
	loop eMulShotY
addXToResult88:
	add ax, [eShotX]
	mov [eShotNewPos], ax
goMoving88:
	; input: getting positions enemyY + enemyX
	; output: moving the character and restoring the background and taking the new square the character is going to
	mov bx, [eShotX] ; The current position of enemyX.
	mov cx, [eShotY] ; The times we will need to loop for rows.
	
createR88: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR88
	
FirstTick88:
	cmp ax, [Clock]
	je FirstTick88
	mov cx, 1
DelayLoop88:
	mov ax, [Clock]
Tick88:
	cmp ax, [Clock]
	je Tick88
	loop DelayLoop88

returnSqr88:
	mov [eShotNewPos], bx ; The new position we got into newPos variable
	call eShotRetSqr ; Return last sqr to the old position
	call eShotTakeSqr ; Taking new sqr from the newPos
	call eShotAnding
	call eShotOring
	mov bx, [eShotNewPos]
	mov [eShotOldPos], bx
	add [eShotY], 13
	dec [eShotLength]
	
returnFromShot88:
	mov [eShotLength], 12
	mov ah,0Ch
	mov al,0
	int 21h
	doPop dx,cx,bx,ax
	ret
endp eMoveShot

proc eShotTakeSqr
	; input: taking the current position into newShotPos variable
	; output: taking the sqr size into scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [eShotNewPos]
	mov si, offset eShotScrKeep
	mov cx, [eShotHeight]
	
takeLine23:
	push cx
	mov cx, [eShotWidth]
	
takeCol23:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol23
	add di, 320
	sub di, [eShotWidth]
	pop cx
	loop takeLine23
	doPop cx, di, si, ax, es
	ret
endp eShotTakeSqr

proc eShotRetSqr
	; input: the last position into oldShotPos variable
	; output: restoring the last sqr in scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[eShotOldPos]
	mov si, offset eShotScrKeep
	mov cx, [eShotHeight]
	
retLine24:
	push cx
	mov cx, [eShotWidth]
	
retCol24:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol24
	add di, 320
	sub di, [eShotWidth]
	pop cx
	loop retLine24
	doPop cx, di, si, ax, es
	ret
endp eShotRetSqr

proc eShotAnding
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[eShotNewPos]
	mov si, offset eShotMask
	mov cx,[eShotHeight]
	
and24:
	push cx
	mov cx,[eShotWidth]
	
xx24:
	lodsb
	and [es:di],al
	inc di
	loop xx24
	add di, 320
	sub di, [eShotWidth]
	pop cx
	loop and24
	doPop cx, si, di, es, ax
	ret
endp eShotAnding

proc eShotOring
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[eShotNewPos]
	mov si, offset eShot
	mov cx,[eShotHeight]
	
or24:
	push cx
	mov cx,[eShotWidth]
	
yy24:
	lodsb
	or [es:di],al
	inc di
	loop yy24
	add di, 320
	sub di, [eShotWidth]
	pop cx
	loop or24
	doPop cx, si, di, es, ax
	ret
endp eShotOring