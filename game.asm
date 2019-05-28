include mPushPop.asm
IDEAL
MODEL small
STACK 100h
DATASEG

; ------------------------------

	include "vars.asm" ; All variables for project
	InputTime		dw 9999 ; The time you got to input

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
	call bmp ; Printing the bmp for the main screen

reciveInput:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if p key:
	cmp al, 50h
	je selectLvlScr
	cmp al, 70h
	je selectLvlScr
	; Check if i key:
	cmp al, 49h
	je helpScr
	cmp al, 69h
	je helpScr
	; Check if s key: Not Available Currently
	; cmp al, 53h
	; je scoreList, not available
	; cmp al, 73h
	; je scoreList, not available
	; Check if esc key:
	cmp al, 1Bh
	je goEndProgram2
	jmp reciveInput ; Go check again as no input

selectLvlScr: ; Select difficulty Screen
	mov [fileName], offset selectLvlFile
	call bmp
reciveSelectInput:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if n key:
	cmp al, 6Eh
	je setDifficultyChoose1
	cmp al, 4Eh
	je setDifficultyChoose1
	; Check if h key:
	cmp al, 68h
	je setDifficultyChoose2
	cmp al, 48h
	je setDifficultyChoose2
	cmp al, 1Bh
	je mainScr
	; TOP SECRET IMPOSSIBLE MODE:
	; check if i key
	cmp al, 49h
	je setDifficultyChoose3
	cmp al, 69h
	je setDifficultyChoose3
	jmp reciveSelectInput

setDifficultyChoose1:
	mov [selectedLvl], 1 ; 1 means level1 has been selected
	mov [moveEnemyTankSpeed], 350 ; the Speed of the tank for level1
	jmp level1Scr ; goto start the level game

setDifficultyChoose2:
	mov [selectedLvl], 2 ; 2 means level2 has been selected
	mov [moveEnemyTankSpeed], 200 ; the Speed of the tank for level2
	jmp level1Scr ; goto start the level game

setDifficultyChoose3:
	mov [selectedLvl], 3 ; 3 means level3 has been selected
	mov [moveEnemyTankSpeed], 125 ; the Speed of the tank for level3 same as hard
	jmp level1Scr ; goto start the level game

goEndProgram2:
	jmp endProgram

helpScr:
	mov [fileName], offset helpScrFile
	call bmp
getHelpInput:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if p key
	cmp al, 50h
	je selectLvlScr
	cmp al, 70h
	je selectLvlScr
	; Check if esc key
	cmp al, 1Bh
	je gotoMainScr
	jmp getHelpInput

pauseScr:
	mov [fileName], offset pauseFile
	call bmp
getPauseInput:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if ESC key
	cmp al, 1Bh
	je resumeToLvl
	; Check if r key
	cmp al, 72h
	je restartGame
	cmp al, 52h
	je restartGame
	; Check if e key
	cmp al, 45h
	je gotoMainScr
	cmp al, 65h
	je gotoMainScr
	; Check if c key
	cmp al, 43h
	je gotoSelectLvl
	cmp al, 63h
	je gotoSelectLvl
	jmp getPauseInput

gotoSelectLvl: ; shortcut for select level screen as it out of range
	jmp selectLvlScr

gotoPrintMap1: ; shortcut for printMap1 screen as it out of range
	jmp printMap1

resumeToLvl:
	cmp [selectedLvl], 1 ; If level = 1 then resume to level1
	je gotoPrintMap1
	cmp [selectedLvl], 2 ; If level = 2 then resume to level2
	je printMap2
	cmp [selectedLvl], 3 ; If level = 3 then resume to level3
	je printMap3

gotoMainScr: ; shortcut for main screen as it out of range
	jmp mainScr

tryAgainScr:
	mov [fileName], offset tryAgainFile
	call bmp
tryAgainInput:
	; Get a symbol input:
	mov ah, 7h
	int 21h
	; Check if p key:
	cmp al, 50h
	je level1Scr
	cmp al, 70h
	je level1Scr
	; Check if c key:
	cmp al, 43h
	je gotoSelectLvlScr
	cmp al, 63h
	je gotoSelectLvlScr
	; Check if e key:
	cmp al, 1Bh
	je gotoMainScr
	jmp tryAgainInput

gotoSelectLvlScr:
	jmp selectLvlScr

restartGame: ; reset level1
	mov [playerHP], 3
	mov [enemyHP], 3

level1Scr:
	cmp [selectedLvl], 1 ; Check if level1 is selected
	je startMap1 ; if so go to startMap1
	cmp [selectedLvl], 2 ; Check if level2 is selected
	je startMap2 ; if so go to startMap2
	; else startMap3

startMap3:
	call impModeStart ; Start animation for level3 then set hitpoints
	mov [playerHP], 1
	mov [enemyHP], 7

printMap3:
	mov [fileName], offset impModeFile
	call bmp
	jmp startGame

startMap2:
	call hardLvlStart ; Start animation for level2 then set hitpoints
	mov [playerHP], 1
	mov [enemyHP], 5

printMap2:
	mov [fileName], offset hardLvlFile
	call bmp
	jmp startGame

startMap1:
	call normalLvlStart ; Start animation for level1 then set hitpoints
	mov [playerHP], 3
	mov [enemyHP], 3

printMap1:
	mov [fileName], offset gameBack
	call bmp

startGame:
	; initializing:
	mov ax, 40h
	mov es, ax
	mov cx, 1
	mov bx, 0

	; Printing the character && getting the first pos:
	mov [newPos], 320*125+230 ; Middle Screen
	mov di,[newPos]
	mov si, offset scrKeep
	mov cx,[tankHeight]
	mov bx,[tankWidth]
	mov [width_], bx
	call takeSqr ; Take the first square before printing the character
	mov [oldPos], 320*125+230 ; Middle Screen
	mov [x], 230 ; Using X + Y to control the character
	mov [y], 125 ; Using X + Y to control the character
	; Printing the sprite:
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
	mov [width_],bx
	call oring

	; Printing the character && getting the first position:
	mov [newEnemyPos], 320*35+70 ; Middle Screen
	mov di,[newEnemyPos]
	mov si, offset eScrKeep
	mov cx,[eTankHeight]
	mov bx,[eTankWidth]
	mov [width_], bx
	call takeSqr ; Take the first square before printing the character
	mov [oldEnemyPos], 320*35+70 ; Middle Screen
	mov [enemyX], 70 ; Using enemyX + enemyY to control the character
	mov [enemyY], 35 ; Using enemyX + enemyY to control the character
	; Printing the sprite:
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

	mov [shotLength], 20
	mov [score], 0

level1:

	dec [InputTime]
checkKey:
	; Check if there is any key
	mov ah,1
	int 16h
	jnz contGetKey ; If there is any key go to contGetKey
	cmp [InputTime],0
	jne level1
goRandom:
	mov [InputTime],9999
	; Move the robot randomly do actions
	call randomMove
	mov ax, [moveEnemyTankSpeed]
	cmp [moveEnemyTank], ax
	je gotoControls
	jmp level1

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
	je gotoPause
	jmp level1

gotoControls: ; shortcut for controlls
	jmp controlls

gotoPause: ; shortcut for pause
	jmp pauseScr

goEndProgram:	; Shortcut to jump to label endProgram
	jmp endProgram

arrowRight:
	; Moving the player tank to right
	cmp [x], 320-60 ; check that the tank is not on the last-right block
	jae	level1 ; if it is go to get another input
	add [x], 40 ; else add to player [x] 40
	call movePlayer ; move the player with the [x]
	mov ah, 0Ch ; clean buffer
	xor al,al ; clean buffer
	int 21h ; clean buffer
	jmp level1 ; goto get another input

arrowLeft:
	; Moving the player tank to left
	cmp [x], 60 ; check that the tank is not on the last-left block
	jbe	level1 ; if it is go to get another input
	sub [x], 40 ; else sub from player [x] 40
	call movePlayer ; move the player with the [x]
	mov ah, 0Ch ; clean buffer
	xor al,al ; clean buffer
	int 21h ; clean buffer
	jmp level1 ; goto get another input

ifSpaceShoot:
	mov di,[newShotPos]
	mov si, offset shotScrKeep
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call takeSqr ; Take the square that the shot is going to be on for restoration
	call moveShot ; move the shot check hit not hit and death...
	mov di,[oldShotPos]
	mov si, offset shotScrKeep
	mov cx,[pShotHeight]
	mov bx,[pShotWidth]
	mov [width_], bx
	call retSqr ; return the square that the shot was on.
	mov ah, 0Ch
	xor al,al
	int 21h
	jmp level1 ; goto get another input

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

enemyLeft: ; same thing as applied to player but for the robot
	; Moving the enemy tank to left
	sub [newEnemyPos], 25
	cmp [enemyX], 60
	jbe	gotoMain
	sub [enemyX], 40
	call eMoveWithSqr
	jmp level1

enemyRight: ; same thing as applied to player but for the robot
	; Moving the enemy tank to right
	cmp [enemyX], 320-60
	jae	gotoMain
	add [enemyX], 40
	call eMoveWithSqr
	jmp level1

enemyShoot: ; same thing as applied to player but for the robot
	; Making the enemy tank to shoot
	mov di,[eShotNewPos]
	mov si, offset eShotScrKeep
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call takeSqr
	call eMoveShot
	mov di,[eShotOldPos]
	mov si, offset eShotScrKeep
	mov cx,[eShotHeight]
	mov bx,[eShotWidth]
	mov [width_], bx
	call retSqr
	jmp level1

gotoMain:
	; Shortcut to level1
	jmp level1

wonScr:
	mov [fileName], offset wonFile
	call bmp
	inc [score] ; increase the score for the last shot
	call printScore
	; Block spamming to skip the screen
	mov [cDelayAmount], 15 ; clock delay amount
	call clockDelay
	mov ah,0Ch ; clear buffer
	xor al,al ; clear buffer
	int 21h ; clear buffer
	; Wait for any key
	mov ax, 13; Wait for any key
	int 16h; Wait for any key
	jmp tryAgainScr

youLostScr:
	mov [fileName], offset lostFile
	call bmp
	call printScore
	; Block spamming to skip the screen
	mov [cDelayAmount], 15 ; clock delay amount
	call clockDelay
	mov ah,0Ch ; clear buffer
	xor al,al ; clear buffer
	int 21h ; clear buffer
	; Wait for any key
	mov ax, 13; Wait for any key
	int 16h; Wait for any key
	jmp tryAgainScr

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
