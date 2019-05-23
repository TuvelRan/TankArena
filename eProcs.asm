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
	mov di,[oldEnemyPos] ; setting the parameter in di for old position
	mov si, offset eScrKeep ; setting the parameter of screen keeper in si
	mov cx,[eTankHeight] ; moving to cx the tank height for the parameter
	mov bx,[eTankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call retSqr ; Return last sqr to the old position
	mov di,[newEnemyPos] ; setting the parameter in di for old position
	mov si, offset eScrKeep ; setting the parameter of screen keeper in si
	mov cx,[eTankHeight] ; moving to cx the tank height for the parameter
	mov bx,[eTankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call takeSqr ; Taking new sqr from the newEnemyPos
	mov di,[newEnemyPos] ; setting the parameter in di for old position
	mov si, offset eTankMask ; setting the parameter of screen keeper in si
	mov cx,[eTankHeight] ; moving to cx the tank height for the parameter
	mov bx,[eTankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call anding
	mov di,[newEnemyPos] ; setting the parameter in di for old position
	mov si, offset eTank ; setting the parameter of screen keeper in si
	mov cx,[eTankHeight] ; moving to cx the tank height for the parameter
	mov bx,[eTankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call oring
	mov bx, [newEnemyPos]
	mov [oldEnemyPos], bx
	doPop cx, bx
	ret
endp eMoveWithSqr

proc randomMove
	; enter: Calling whenever the player dont do an action
	; exit: value to use to make an action with the robot tank
	doPush ax,bx,cx
	dec [moveEnemyTank] ; Using to calculate the speed to prevent him from moving too fast
	cmp [moveEnemyTank], 0 ; Comparing the speed value to 0 if equals set the speed back
	jne return_fromRandomMove ; if not equals return from move without action value
	mov cx, [moveEnemyTankSpeed]
resetMovingValue:
	mov [moveEnemyTank], cx
RandLoop: ; Generating random number between 0,1,2
	; 0 = move left
	; 1 = move right
	; 2 = shoot!
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
	cmp al,3 ; if al contains 3 it's not good so go make another random number
	je randAgain
	mov [eTurnValue], al ; moving the random number into eTurnValue variable
	inc bx
return_fromRandomMove:
	doPop cx,bx,ax
	ret
endp randomMove

proc eMoveShot
	; enter: calling the proc whenever the robot actions Shooting
	; exit: the shot itself moving toward the player and checking for hit, misshit or death
	doPush ax,bx,cx,dx
	cmp [moveEnemyTankSpeed], 100 ; if the speed is on the hard level
	jne setShotCoords ; if not shoot normaly without delay
countShotsDelay:
	cmp [shotWait], 0 ; check if the shot delay is equals to 0
	je setShotCoords ; if it does go shoot and set the delay back
	dec [shotWait] ; else decrease the shot delay for the next time
	jmp returnFromShot88 ; go to return from shot. without shooting of course
setShotCoords:
	mov [shotWait], 1 ; set the shot delay for the next time.
	xor ax,ax ; clearing ax
	mov dx, [enemyX] ; moving to dx the player x pos
	mov [eShotX], dx ; moving to shotx the player x pos
	add [eShotX], 9 ; adding 9 to the X to set in the center
	mov dx, [enemyY] ; moving to dx the player y pos
	mov [eShotY], dx ; moving to shoty the player y pos
	add [eShotY], 45 ; substurcting 8 to the y to set in the center
	mov cx, [eShotY] ; moving into cx the shotY
eMulShotY:
	add ax, 320 ; Adding into BX 320 (Line)
	loop eMulShotY ; Looping the times to get the Y position on screen
addXToResult88:
	add ax, [eShotX] ; adding the X into the result to get the X pos
	mov [eShotNewPos], ax ; Ax now moving into newShotPos. to print the shot
goMoving88:
	; input: getting positions enemyY + enemyX
	; output: moving the character and restoring the background and taking the new square the character is going to
	mov bx, [eShotX] ; The current position of enemyX.
	mov cx, [eShotY] ; The times we will need to loop for rows.
createR88: ; Creating the row. Adding 320 to go to the next line
	add bx, 320 ; adding bx lines by Y times
	loop createR88
	mov [delayAmount], 8 ; Making a delay with custom one, 8 times
	call delay ; do delay
returnSqr88:
	mov [eShotNewPos], bx ; The new position we got into newPos variable
	mov di,[eShotOldPos] ; setting the parameter in di for old position
	mov si, offset eShotScrKeep ; setting the parameter of screen keeper in si
	mov cx,[eShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[eShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call retSqr ; Return last sqr to the old position
	mov di,[eShotNewPos] ; setting the parameter in di for old position
	mov si, offset eShotScrKeep ; setting the parameter of screen keeper in si
	mov cx,[eShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[eShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call takeSqr ; Taking new sqr from the newPos
	mov di,[eShotNewPos] ; setting the parameter in di for old position
	mov si, offset eShotMask ; setting the parameter of screen keeper in si
	mov cx,[eShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[eShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call anding ; print the sprite
	mov di,[eShotNewPos] ; setting the parameter in di for old position
	mov si, offset eShot ; setting the parameter of screen keeper in si
	mov cx,[eShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[eShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call oring ; print the sprite
	mov bx, [eShotNewPos] ; Moving into bx the new pos we got
	mov [eShotOldPos], bx ; setting it in the old pos for the next time
	add [eShotY], 7 ; adding 7 to the shot y for the shooting to go
	dec [eShotLength] ; decrease the shot length
; Read pixel value into al
	mov bh,0h
	mov cx,[eShotX] ; Read the color in this X spot
	mov dx,[eShotY] ; Read the color in this Y spot
	mov ah,0Dh ; Call the color pixel reader
	int 10h
checkIfHitPlayer:
	cmp al, 0016 ; Compare to the tank color Pixel
	je hitPlayer ; if the colour is equals to the robot colour it's a hit go to hitEnemy label
	cmp [eShotLength], 0 ; else check if the shot has ended
	je returnFromShot88 ; if it does return from shot and reset the shot parameters
	jmp goMoving88 ; else the shot didn't ended go to goMoving label to continue the shot
hitPlayer:
	mov [note], 2000h ; sound frequency to make
	call playSound ; play the sound of hit
	call delay ; Do a small delay to make people hear the sound
	call stopSound ; Stop the soun
	dec [playerHP] ; decrease the player's health
	mov di,[eShotOldPos] ; setting the parameter in di for old position
	mov si, offset eShotScrKeep ; setting the parameter of screen keeper in si
	mov cx,[eShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[eShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call retSqr ; Remove the shot from the screen as the shot hit the player
refreshPlayersHP:
	mov bh, 0
	mov dh, 23 ; Y position of the text printed
	mov dl, 0 ; X position of the text printed
	mov ah, 2h ; set the cursor position
	int 10h
	mov	dx, offset playerHPtxt ; Use this text table for the printing
	mov ah, 9 ; print the text
	int 21h
	xor ax, ax
	mov al, [playerHP] ; the number we want to print from the variable
	call printNumber ; print number at the last cursor position
	cmp [playerHP], 0 ; check if the players's HP equals to 0
	je playerDead ; if it does goto playerDead label
	jmp returnFromShot88 ; else return from shot and reset the shot parameters
playerDead:
	doPop dx,cx,bx,ax
	jmp youLostScr ; go to lose Screen
returnFromShot88:
	mov [eShotLength], 17 ; set the shot Length for the next time
	mov ah,0Ch ; clear buffer
  xor al,al ; clear buffer
	int 21h ; clear buffer
	doPop dx,cx,bx,ax
	ret
endp eMoveShot
