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

proc randomMove
	dec [moveEnemyTank]
	cmp [moveEnemyTank], 0
	jne return_fromRandomMove
	
resetMovingValue:
	mov [moveEnemyTank], 250
	
RandLoop:
	mov ax, 40h
	mov es, ax
	; generate random number, cx number of times
	mov ax, [Clock] 		; read timer counter
	mov ah, [byte cs:bx] 	; read one byte from memory
	xor al, ah 			; xor memory and counter
	and al, 3	; leave result between 0-2
	dec al
	mov [eTurnValue], al
	inc bx
return_fromRandomMove:
	ret
endp randomMove

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
	
setShotCoords:
	mov dx, [enemyX]
	mov [eShotX], dx
	add [eShotX], 9
	mov dx, [enemyY]
	mov [eShotY], dx
	add [eShotY], 45
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
	
	mov [delayAmount], 40
	call delay

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
	
; Read pixel value into al
	mov bh,0h
	mov cx,[eShotX]
	mov dx,[eShotY]
	mov ah,0Dh
	int 10h
	
checkIfHitPlayer:
	cmp al, 0016
	je hitPlayer
	cmp [eShotLength], 0
	je returnFromShot88
	jmp goMoving88
	
hitPlayer:
	mov [note], 2000h
	call playSound
	call delay
	call stopSound
	dec [playerHP]
	call eShotRetSqr
	
refreshPlayersHP:
	mov bh, 0
	mov dh, 23
	mov dl, 0
	mov ah, 2h
	int 10h
	mov	dx, offset playerHPtxt
	mov ah, 9
	int 21h
	xor ax, ax
	mov al, [playerHP]
	call printNumber
	cmp [playerHP], 0
	je playerDead
	jmp returnFromShot88
	
playerDead:
	mov ah,0Ch
	mov al,0
	int 21h
	doPop dx,cx,bx,ax
	jmp youLostScr
	
continueShot:
	mov ah,0Ch
	mov al,0
	int 21h
	doPop dx,cx,bx,ax
	ret
	
returnFromShot88:
	mov [eShotLength], 10
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