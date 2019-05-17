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

proc anding
; enter: enemy Position, tank height, width and masks.
; exit: Copying the mask and pasting it afterwards
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax

and1:
	push cx
	mov cx,[width_]

xx1:
	lodsb
	and [es:di],al
	inc di
	loop xx1
	add di, 320
	sub di, [width_]
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
	mov cx,[width_]

yy1:
	lodsb
	or [es:di],al
	inc di
	loop yy1
	add di, 320
	sub di, [width_]
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
	mov cx, [width_]

takeCol1:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol1
	add di, 320
	sub di, [width_]
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
	mov cx, [width_]
retCol:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol
	add di, 320
	sub di, [width_]
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
	mov di,[oldPos]
	mov si, offset ScrKeep
	mov cx,[tankHeight]
	mov bx,[tankWidth]
	mov [width_],bx
	call retSqr ; Return last sqr to the old position
	mov di,[newPos]
	mov si, offset scrKeep
	mov cx,[tankHeight]
	mov bx,[tankWidth]
	mov [width_], bx
	call takeSqr ; Taking new sqr from the newPos
	mov di,[newPos]
	mov si, offset pTankMask
	mov cx,[tankHeight]
	mov bx,[tankWidth]
	mov [width_], bx
	call anding
	mov di,[newPos]
	mov si, offset pTank
	mov cx,[tankHeight]
	mov bx,[tankWidth]
	mov [width_], bx
	call oring
	mov bx, [newPos]
	mov [oldPos], bx
	doPop cx, bx
	ret
endp movePlayer

proc moveShot
	; enter: calling the proc whenever the user press space to shoot
	; exit: the shot itself moving toward the robot and checking for hit, misshit or death
	doPush ax,bx,cx,dx
	; Setting all of the x and y parameters from the tank to use for the shot
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
	mov [delayAmount], 40
	call delay
returnSqr12:
	mov [newShotPos], bx ; The new position we got into newPos variable
	mov di,[oldShotPos]
	mov si, offset shotScrKeep
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call retSqr ; Return last sqr to the old position
	mov di,[newShotPos]
	mov si, offset shotScrKeep
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call takeSqr ; Taking new sqr from the newPos
	mov di,[newShotPos]
	mov si, offset pShotMask
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call anding
	mov di,[newShotPos]
	mov si, offset pShot
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call oring
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
checkIfHit: ; check if the shotX and shotY equals to the color of the robot
	cmp al, 0077
	je hitEnemy ; if the color is equals to the robot color it's a hit go to hitEnemy label
	cmp [shotLength], 0 ; else check if the shot has ended
	je returnFromShot ; if it does return from shot and reset the shot parameters
	jmp goMoving ; else the shot didn't ended go to goMoving label to continue the shot
hitEnemy:
	mov [note], 2000h
	call playSound ; play the sound of hit
	call delay
	call stopSound
	dec [enemyHP] ; decrease the robot's health
	mov di,[oldShotPos]
	mov si, offset shotScrKeep
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call retSqr ; Remove the shot from the screen as the shot hit the player
	mov [hitEnemyShot],1 ; used only for the impossible MODE
refreshEnemyHPtxt: ; Printing the robot's HP counter to update his status
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
	mov [shotLength], 10 ; reset the shot length value
	doPop dx,cx,bx,ax
	ret
endp moveShot

proc delay
	; enter: called when want to delay using delayAmount
	; exit: when the loop is over
	push cx
setDelayParameter:
	mov cx, 60000
delayLooper:
	loop delayLooper
	dec [delayAmount]
	cmp [delayAmount], 0
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
	mov cx, [cDelayAmount]
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
	mov [note], 7000h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	mov [note], 4000h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	mov [fileName], offset rdyGo2File
	call bmp
	mov [note], 2500h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	ret
endp hardLvlStart

proc normalLvlStart
; enter: starting the level animation with: get ready,go!
; exit: after animation has ended going to start the game
	mov [fileName], offset getRdy1File
	call bmp
	mov [note], 7000h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	mov [note], 4000h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	mov [fileName], offset rdyGo1File
	call bmp
	mov [note], 2500h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	ret
endp normalLvlStart

proc impModeStart
; enter: starting the level animation with: get ready,go!
; exit: after animation has ended going to start the game
	mov [fileName], offset getRdy3File
	call bmp
	mov [note], 7000h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	mov [note], 4000h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	mov [fileName], offset rdyGo3File
	call bmp
	mov [note], 2500h
	call playSound
	mov [cDelayAmount], 3
	call clockDelay
	call stopSound
	call clockDelay
	ret
endp impModeStart

proc printScore
	; enter: printing the score on the screen
	; exit: score printed
	mov bh, 0
	mov dh, 22
	mov dl, 8
	mov ah, 2h
	int 10h
	mov	dx, offset scoretxt
	mov ah, 9
	int 21h
	xor ax, ax
	mov al, [score]
	call printNumber
	ret
endp printScore

proc printPlayersHP
	; enter: called to print the HP of the enemy used in moveShot
	; exit: hp printed and refreshed
	doPush ax,dx
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
	doPop dx,ax
	ret
endp printPlayersHP
