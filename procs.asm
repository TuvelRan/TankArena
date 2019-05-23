proc printNumber
; enter – number in dx:ax
; exit – printing the number
	doPush ax,bx,dx
	mov bx,offset divisorTable
nextDigit:
	xor ah,ah 	; dx:ax = number
	div [byte ptr bx]	 ; al = quotient, ah = remainder
	add al,'0' ; Adding the ascii of '0'
	call printCharacter 	; Display the quotient
	mov al,ah 	; ah = remainder
	add bx,1 		; bx = address of next divisor
	cmp [byte ptr bx],0 ; Have all divisors been done?
	jne nextDigit ; if not equals got and get again
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

proc anding
; enter: enemy Position, tank height, width and masks.
; exit: Copying the mask and pasting it afterwards
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax

and1:
	push cx
	mov cx,[width_] ; Moving the global width variable set for the mask called

xx1:
	lodsb ; MOV AL, DS:[SI] INC SI
	and [es:di],al
	inc di ; increase di
	loop xx1
	add di, 320 ; add another line to di
	sub di, [width_] ; remove the width value of di
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

or1:
	push cx
	mov cx,[width_] ; Moving the global width variable set for the mask called

yy1:
	lodsb ; MOV AL, DS:[SI] INC SI
	or [es:di],al
	inc di ; increase di
	loop yy1
	add di, 320 ; add another line to di
	sub di, [width_] ; remove the width value of di
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

takeLine1:
	push cx
	mov cx, [width_] ; Moving the global width variable set for the mask called

takeCol1:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di ; increase di
	loop takeCol1
	add di, 320 ; add another line to di
	sub di, [width_] ; remove the width value of di
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
retLine:
	push cx
	mov cx, [width_] ; Moving the global width variable set for the mask called
retCol:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di ; increase di
	loop retCol
	add di, 320 ; add another line to di
	sub di, [width_] ; remove the width value of di
	pop cx
	loop retLine
	doPop cx, di, si, ax, es
	ret
endp retSqr

proc movePlayer
	; input: getting positions y + x
	; output: moving the character and restoring the background and taking the new square the character is going to
	mov bx, [x] ; The current position of X.
	mov cx, [y] ; The times we will need to loop for rows.

createR2: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR2 ; Loop counter = [y]

FirstTick1: ; counting first tick
	cmp ax, [Clock] ; comparing the value of ticks to the first tick
	je FirstTick1 ; if equals the tick hasn't changed go check again
	mov cx, 1 ; mov CX, The time we want the delay to work
DelayLoop1:
	mov ax, [Clock] ; move to ax, the value of ticks the amount of time we need
Tick1:
	cmp ax, [Clock] ; compare to clock
	je Tick1 ; if the tick hasn't change go check again
	loop DelayLoop1 ; if the tick has changed go to get another tick
	doPush bx, cx
returnSqr2:
	mov [newPos], bx ; The new position we got into newPos variable
	mov di,[oldPos] ; setting the parameter in di for old position
	mov si, offset ScrKeep ; setting the parameter of screen keeper in si
	mov cx,[tankHeight] ; moving to cx the tank height for the parameter
	mov bx,[tankWidth] ; getting the width and moving it into bx
	mov [width_],bx ; moving the width in bx into a global width variable
	call retSqr ; Return last sqr to the old position
	mov di,[newPos] ; setting the parameter in di for old position
	mov si, offset scrKeep ; setting the parameter of screen keeper in si
	mov cx,[tankHeight] ; moving to cx the tank height for the parameter
	mov bx,[tankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call takeSqr ; Taking new sqr from the newPos
	mov di,[newPos] ; setting the parameter in di for old position
	mov si, offset pTankMask ; setting the parameter of screen keeper in si
	mov cx,[tankHeight] ; moving to cx the tank height for the parameter
	mov bx,[tankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call anding ; printing the sprite
	mov di,[newPos] ; setting the parameter in di for old position
	mov si, offset pTank ; setting the parameter of screen keeper in si
	mov cx,[tankHeight] ; moving to cx the tank height for the parameter
	mov bx,[tankWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call oring ; printing the sprite
	mov bx, [newPos] ; move into bx the new position of the sprite
	mov [oldPos], bx ; move the new pos to be used in the old pos next time
	doPop cx, bx
	ret
endp movePlayer

proc moveShot
	; enter: calling the proc whenever the user press space to shoot
	; exit: the shot itself moving toward the robot and checking for hit, misshit or death
	doPush ax,bx,cx,dx
	; Setting all of the x and y parameters from the tank to use for the shot
	xor ax,ax ; clearing ax
	mov dx, [x] ; moving to dx the player x pos
	mov [shotX], dx ; moving to shotx the player x pos
	add [shotX], 9 ; adding 9 to the X to set in the center
	mov dx, [y] ; moving to dx the player y pos
	mov [shotY], dx ; moving to shoty the player y pos
	sub [shotY], 8 ; substurcting 8 to the y to set in the center
	mov cx, [shotY] ; moving into cx the shotY
mulShotY:
	add ax, 320 ; Adding into BX 320 (Line)
	loop mulShotY ; Looping the times to get the Y position on screen
addXToResult:
	add ax, [shotX] ; adding the X into the result to get the X pos
	mov [newShotPos], ax ; Ax now moving into newShotPos. to print the shot
goMoving:
	; input: getting positions y + x
	; output: moving the character and restoring the background and taking the new square the character is going to
	mov bx, [shotX] ; The current position of X.
	mov cx, [shotY] ; The times we will need to loop for rows.
createR12: ; Creating the row. Adding 320 to go to the next line
	add bx, 320 ; adding bx lines by Y times
	loop createR12
	mov [delayAmount], 8 ; Making a delay with custom one, 8 times
	call delay ; do delay
returnSqr12:
	mov [newShotPos], bx ; The new position we got into newPos variable
	mov di,[oldShotPos] ; setting the parameter in di for old position
	mov si, offset shotScrKeep ; setting the parameter of screen keeper in si
	mov cx,[pShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[pShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call retSqr ; Return last sqr to the old position
	mov di,[newShotPos] ; setting the parameter in di for old position
	mov si, offset shotScrKeep ; setting the parameter of screen keeper in si
	mov cx,[pShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[pShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call takeSqr ; Taking new sqr from the newPos
	mov di,[newShotPos] ; setting the parameter in di for old position
	mov si, offset pShotMask ; setting the parameter of screen keeper in si
	mov cx,[pShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[pShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call anding ; printing the sprite
	mov di,[newShotPos] ; setting the parameter in di for old position
	mov si, offset pShot ; setting the parameter of screen keeper in si
	mov cx,[pShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[pShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call oring
	mov bx, [newShotPos] ; Moving into bx the new pos we got
	mov [oldShotPos], bx ; setting it in the old pos for the next time
	sub [shotY], 5 ; sub 5 from shot y to make the shot going
	dec [shotLength] ; decrease Shot Length
; Read pixel value into al
	mov bh,0h
	mov cx,[shotX] ; Read the color in this X spot
	mov dx,[shotY] ; Read the color in this Y spot
	mov ah,0Dh ; Call the color pixel reader
	int 10h
checkIfHit: ; check if the shotX and shotY equals to the colour of the robot
	cmp al, 0077 ; Compare to the tank color Pixel
	je hitEnemy ; if the colour is equals to the robot colour it's a hit go to hitEnemy label
	cmp [shotLength], 0 ; else check if the shot has ended
	je returnFromShot ; if it does return from shot and reset the shot parameters
	jmp goMoving ; else the shot didn't ended go to goMoving label to continue the shot
hitEnemy:
	mov [note], 2000h ; sound frequency to make
	call playSound ; play the sound of hit
	call delay ; Do a small delay to make people hear the sound
	call stopSound ; Stop the sound
	dec [enemyHP] ; decrease the robot's health
	mov di,[oldShotPos] ; setting the parameter in di for old position
	mov si, offset shotScrKeep ; setting the parameter of screen keeper in si
	mov cx,[pShotHeight] ; moving to cx the tank height for the parameter
	mov bx,[pShotWidth] ; getting the width and moving it into bx
	mov [width_], bx ; moving the width in bx into a global width variable
	call retSqr ; Remove the shot from the screen as the shot hit the player
	mov [hitEnemyShot],1 ; used only for the impossible MODE
refreshEnemyHPtxt: ; Printing the robot's HP counter to update his status
	mov bh, 0
	mov dh, 1 ; Y position of the text printed
	mov dl, 0 ; X position of the text printed
	mov ah, 2h ; set the cursor position
	int 10h
	mov	dx, offset enemyHPtxt ; Use this text table for the printing
	mov ah, 9 ; print the text
	int 21h
	xor ax, ax
	mov al, [enemyHP] ; the number we want to print from the variable
	call printNumber ; print number at the last cursor position
	cmp [enemyHP], 0 ; check if the robot's HP equals to 0
	je enemyDead ; if it does goto enemyDead label
	jmp returnFromShot ; else return from shot and reset the shot parameters
enemyDead:
	doPop dx,cx,bx,ax
	jmp wonScr ; go to win Screen
returnFromShot:
	cmp [selectedLvl],3 ; check if the selected level is 3 = impossible
	jne fullyReturn ; if not we can skip the next part and goto fullyReturn
	cmp [hitEnemyShot],1 ; check if hit enemy
	je fullyReturn ; if hit enemy goto fullyReturn
impModeHP:
	mov [enemyHP],7 ; else it means the player have missed the reset the HP to 7
	call printPlayersHP ; refresh EnemyHP to update the status
fullyReturn:
	mov [hitEnemyShot],0 ; make hit status equals to 0
	inc [score] ; inc the score (shot counter)
	mov [shotLength], 20 ; reset the shot length value
	doPop dx,cx,bx,ax
	ret
endp moveShot

proc delay
	; enter: called when want to delay using delayAmount
	; exit: when the loop is over
	push cx
setDelayParameter:
	mov cx, 60000 ; biggest loop we can possibly do
delayLooper:
	loop delayLooper ; loop
	dec [delayAmount]
	cmp [delayAmount], 0 ; use the delay amount for the times
	ja setDelayParameter
	pop cx
	ret
endp delay

proc playSound
	; enter: called to play sound from the system using the value in [note]
	; exit: sound is on with the frequency in [note]
	push ax
	; open speaker
	in al,61h
	or al,00000011b
	out 61h,al
	; send control word to change frequency
	mov al,0b6h
	out 43h,al
	; play frequency
	mov ax,[note]
	out 42h,al	; sending lower byte
	mov al,ah
	out 42h,al	; sending upper byte
	pop ax
	ret
endp playSound

proc stopSound
	; enter: called to stop the sound frequency
	; exit: sound is off
	push ax
	; close the speaker
	in al,61h
	and al,11111100b
	out 61h,al
	pop ax
	ret
endp stopSound

proc clockDelay
	; enter: called to do delay using the clock and the amount of delay is [cDelayAmount]
	; exit: after delay loop ended
	doPush ax,cx
	; initializing:
	mov ax, 40h
	mov es, ax
	mov cx, 1
	mov bx, 0
FirstTick:
	cmp ax, [Clock]
	je FirstTick
	mov cx, [cDelayAmount] ; same as all clock delays moving the time to use
DelayLoop:
	mov ax, [Clock]
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	doPop ax,cx
	ret
endp clockDelay

proc hardLvlStart
	; enter: starting the level animation with: get ready,go!
	; exit: after animation has ended going to start the game
	mov [fileName], offset getRdy2File
	call bmp
	mov [note], 7000h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	mov [note], 4000h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	mov [fileName], offset rdyGo2File
	call bmp
	mov [note], 2500h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	ret
endp hardLvlStart

proc normalLvlStart
; enter: starting the level animation with: get ready,go!
; exit: after animation has ended going to start the game
	mov [fileName], offset getRdy1File
	call bmp
	mov [note], 7000h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	mov [note], 4000h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	mov [fileName], offset rdyGo1File
	call bmp
	mov [note], 2500h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	ret
endp normalLvlStart

proc impModeStart
; enter: starting the level animation with: get ready,go!
; exit: after animation has ended going to start the game
	mov [fileName], offset getRdy3File
	call bmp
	mov [note], 7000h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	mov [note], 4000h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	mov [fileName], offset rdyGo3File
	call bmp
	mov [note], 2500h ; sound frequency
	call playSound ; play sound
	mov [cDelayAmount], 3 ; do delay of playing sound
	call clockDelay
	call stopSound ; stop sound
	call clockDelay
	ret
endp impModeStart

proc printScore
	; enter: printing the score on the screen
	; exit: score printed
	mov bh, 0
	mov dh, 22 ; x of the cursor pos
	mov dl, 14 ; y of the cursor pos
	mov ah, 2h ; set the cursor position
	int 10h
	mov	dx, offset scoretxt ; use this text as the table
	mov ah, 9 ; print the text
	int 21h
	xor ax, ax
	mov al, [score] ; use score as the number
	call printNumber ; print the number at the last cursor position
	ret
endp printScore

proc printPlayersHP
	; enter: called to print the HP of the enemy used in moveShot
	; exit: hp printed and refreshed
	doPush ax,dx
	xor bh,bh
	mov dh, 1 ; x of the cursor pos
	xor dl,dl ; y of the cursor pos
	mov ah, 2h ; set the cursor position
	int 10h
	mov	dx, offset enemyHPtxt ; use this text as the table
	mov ah, 9 ; print the text
	int 21h
	xor ax, ax
	mov al, [enemyHP] ; use score as the number
	call printNumber ; print the number at the last cursor position
	doPop dx,ax
	ret
endp printPlayersHP
