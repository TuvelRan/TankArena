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
	mov di,[oldEnemyPos]
	mov si, offset eScrKeep
	mov cx,[eTankHeight]
	mov bx,[eTankWidth]
	mov [width_], bx
	call retSqr ; Return last sqr to the old position
	mov di,[newEnemyPos]
	mov si, offset eScrKeep
	mov cx,[eTankHeight]
	mov bx,[eTankWidth]
	mov [width_], bx
	call takeSqr ; Taking new sqr from the newEnemyPos
	mov di,[newEnemyPos]
	mov si, offset eTankMask
	mov cx,[eTankHeight]
	mov bx,[eTankWidth]
	mov [width_], bx
	call anding
	mov di,[newEnemyPos]
	mov si, offset eTank
	mov cx,[eTankHeight]
	mov bx,[eTankWidth]
	mov [width_], bx
	call oring
	mov bx, [newEnemyPos]
	mov [oldEnemyPos], bx
	doPop cx, bx
	ret
endp eMoveWithSqr

proc randomMove
	doPush ax,bx,cx
	dec [moveEnemyTank]
	cmp [moveEnemyTank], 0
	jne return_fromRandomMove

	mov cx, [moveEnemyTankSpeed]

resetMovingValue:
	mov [moveEnemyTank], cx

RandLoop:
	mov ax, 40h
	mov es, ax
randAgain:
	mov bx,[randCodeByte]
	inc [randCodeByte]
	; generate random number, cx number of times
	mov ax, [Clock] 		; read timer counter
	mov ah, [byte cs:bx] 	; read one byte from memory
	xor al, ah 			; xor memory and counter
	and al, 3	; leave result between 0-2
	cmp al,3
	je randAgain
	mov [eTurnValue], al
	inc bx
return_fromRandomMove:
	doPop cx,bx,ax
	ret
endp randomMove

proc eMoveShot
	doPush ax,bx,cx,dx

	cmp [moveEnemyTankSpeed], 100
	jne setShotCoords

countShotsDelay:
	cmp [shotWait], 0
	je setShotCoords
	dec [shotWait]
	jmp returnFromShot88

setShotCoords:
	mov [shotWait], 1
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
	mov di,[eShotOldPos]
	mov si, offset eShotScrKeep
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call retSqr ; Return last sqr to the old position
	mov di,[eShotNewPos]
	mov si, offset eShotScrKeep
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call takeSqr ; Taking new sqr from the newPos
	mov di,[eShotNewPos]
	mov si, offset eShotMask
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call anding
	mov di,[eShotNewPos]
	mov si, offset eShot
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call oring
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
	mov di,[eShotOldPos]
	mov si, offset eShotScrKeep
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call retSqr

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
