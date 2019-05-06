include mPushPop.asm
IDEAL
MODEL small
STACK 100h
DATASEG

; ------------------------------

	include "vars.asm" ; All variables for project
	
	
	stam		dw 9999
	
; ------------------------------

CODESEG
	include "openFile.asm" ; File opener of bmp images
	include "procs.asm" ; All procs for the game
	include "eProcs.asm" ; All Robot procs for the game

start:
	mov ax, @data
	mov ds, ax
	
; ------------------------------

	; Entering graphic mode:
	mov ax, 13h
	int 10h

	; Loading the mainScreen for the game
mainScr:
	mov [fileName], offset mainScrFile
	call bmp
	
reciveInput:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if p key:
	cmp al, 50h
	je gameScr
	cmp al, 70h
	je gameScr
	; Check if i key:
	cmp al, 49h
	je helpScr
	cmp al, 69h
	je helpScr
	; Check if s key:
	cmp al, 53h
	je scoreList
	cmp al, 73h
	je scoreList
	; Check if esc key:
	cmp al, 1Bh
	jne reciveInput
	
goEndProgram2:
	jmp endProgram
	
helpScr:
	mov [fileName], offset helpScrFile
	call bmp
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if esc key
	cmp al, 1Bh
	je mainScr
	jmp helpScr

scoreList:
	
gameScr:
	; Print background:
	mov [fileName], offset mainfilename
	call bmp
	
	; initializing:
	mov ax, 40h
	mov es, ax
	mov cx, 1
	mov bx, 0

	; Printing the character && getting the first pos:
	mov [newPos], 320*125+150 ; Middle Screen
	call takeSqr ; Take the first square before printing the character
	mov [oldPos], 320*125+150 ; Middle Screen
	mov [x], 150 ; Using X + Y to control the character
	mov [y], 125 ; Using X + Y to control the character
	; Printing the sprite:
	call anding
	call oring
	
printCharacterEnemy:
	; Printing the character && getting the first position:
	mov [newEnemyPos], 320*35+150 ; Middle Screen
	call eTakeSqr ; Take the first square before printing the character
	mov [oldEnemyPos], 320*35+150 ; Middle Screen
	mov [enemyX], 150 ; Using enemyX + enemyY to control the character
	mov [enemyY], 35 ; Using enemyX + enemyY to control the character
	; Printing the sprite:
	call eAnding
	call eOring
	
	; Print the players Hit-points
showPlayersHP:
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
	
	; Print the robots Hit-points
showEnemysHP:
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

mainLoop:
; The main code loop to run the gameplay
	dec [stam]
checkKey:
	; Check if there is any key
	mov ah,1
	int 16h
	jnz contGetKey ; If there is any key go to contGetKey
	cmp [stam],0
	jne mainLoop
goRandom:
	mov [stam],9999
	; Move the robot randomly do actions
	call randomMove
	cmp [moveEnemyTank],250
	je controlls
	jmp mainLoop
	
contGetKey:
	; Get a key (1 symbol):
	mov ah, 0
	int 16h
	; Check if right arrow:
	cmp ah, 4Dh
	je arrowRight
	; Check if left arrow:
	cmp ah, 4Bh
	je arrowLeft
	; Check if space key:
	cmp ah, 39h
	je ifSpaceShoot
	; Check if esc key:
	cmp ah, 01h
	je gotoMainScr
	jmp mainLoop
	
gotoMainScr:
	jmp mainScr
	
goEndProgram:
	; Shortcut to jump to label endProgram
	jmp endProgram

arrowRight:
	; Moving the player tank to right
	cmp [x], 320-60
	jae	mainLoop
	add [x], 40
	call movePlayer
	jmp mainLoop

arrowLeft:
	; Moving the player tank to left
	sub [newPos], 25
	cmp [x], 60
	jbe	mainLoop
	sub [x], 40
	call movePlayer
	jmp mainLoop

ifSpaceShoot:
	call enemyAvoidShot
	call shotTakeSqr
	call moveShot
	call shotRetSqr
	jmp mainLoop
	
controlls:
	; if got 0 move enemy to left
	cmp [eTurnValue], 0
	je enemyLeft
	; if got 1 move enemy to right
	cmp [eTurnValue], 1
	je enemyRight
	; if got 2 enemy Shoot!
	cmp [eTurnValue], 2
	je enemyShoot
	
enemyLeft:
	; Moving the enemy tank to left
	sub [newEnemyPos], 25
	cmp [enemyX], 60
	jbe	gotoMain
	sub [enemyX], 40
	call eMoveWithSqr
	jmp mainLoop

enemyRight:
	; Moving the enemy tank to right
	cmp [enemyX], 320-60
	jae	gotoMain
	add [enemyX], 40
	call eMoveWithSqr
	jmp mainLoop

enemyShoot:
	; Making the enemy tank to shoot
	call eShotTakeSqr
	call eMoveShot
	call eShotRetSqr
	jmp mainLoop
	
gotoMain:
	; Shortcut to mainLoop
	jmp mainLoop
	
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


