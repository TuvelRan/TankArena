
; All variables for the game:

		include "masks.asm" ; all masks: sprites
		note					dw 2000h ; The sound Hz volume value
		selectedLvl		db 0 ; The value of the level selected: 1,2,3
		width_				dw ? ; width global variable to use for every proc using width
		getRdyFile		db ? ; file to the level start global
		rdyGoFile			db ? ; file to the level start global
		whatFileToPlay	db 3 ; what file to play for each level start animation
;------------------------------------------------------------------------------------------------------------------
; All delay and clock variables:
		divisorTable 	db 10,1,0 ; The table concept used for the display size
		Clock 				equ es:6Ch ; Clock address in the memory
		delayAmount		db ? ; Delay variable
		cDelayAmount	dw 0 ; Clock delay variable
;------------------------------------------------------------------------------------------------------------------
; All Screens:
		impModeFile		db 'Screens\impMode.bmp',0 ; impossible level screen file name to load
		getRdy3File		db 'Screens\getRdy3.bmp',0 ; get ready! level 3 screen file name to load
		rdyGo3File		db 'Screens\rdyGo3.bmp',0 ; go! level 3 screen file name to load
		getRdy1File		db 'Screens\getRdy1.bmp',0 ; get ready! level 1 screen file name to load
		rdyGo1File		db 'Screens\rdyGo1.bmp',0 ; go! level 1 screen file name to load
		getRdy2File		db 'Screens\getRdy2.bmp',0 ; get ready! level 2 screen file name to load
		rdyGo2File		db 'Screens\rdyGo2.bmp',0 ; go! level 2 screen file name to load
		tryAgainFile	db 'Screens\tryAgain.bmp',0 ; play again screen file name to load
		selectLvlFile	db 'Screens\selector.bmp',0 ; select difficulty screen file name to load
		lostFile			db 'Screens\lostScr.bmp',0 ; lose screen file name to load
		hardLvlFile		db 'Screens\hardLvl.bmp',0 ; hard level screen file name to load
		pauseFile			db 'Screens\pauseScr.bmp',0 ; pause screen file name to load
		wonFile				db 'Screens\winScr.bmp',0 ; Win screen file name to load
		mainScrFile		db 'Screens\mainScr.bmp',0 ; MainScreen file name to load
		helpScrFile		db 'Screens\helpScr.bmp',0 ; Instructions file name to load
		gameBack 			db 'Screens\gameBack.bmp',0 ; normal level screen file name to load
;------------------------------------------------------------------------------------------------------------------
; openFile.asm Variables - BMP loader:
		fileName		dw  ? ; contains the File name to load bmp
		filehandle 	dw ? ; file handle for BMP image
		Header 			db 54 	dup (0) ; Header for bmp image
		Palette 		db 256*4 dup (0) ; The color palette for bmp image
		ScrLine 		db 320 dup (0) ; The Width of the screen (pixels for each line)
		ErrorMsg 		db 'Error', 13, 10,'$' ; Error message if bmp couldn't be loaded
;------------------------------------------------------------------------------------------------------------------
; All variables that affect the player:
		shotX					dw ? ; player shot X position
		shotY					dw ? ; player shot Y position
		newPos				dw	? ; Recent player position to use later to restore location
		oldPos				dw	? ; Position to return the scrKeep to
		x							dw	? ; X position of player
		y							dw	? ; Y position of player
		tankHeight		dw	42 ; Player's tank height
		tankWidth			dw	21 ; Player's tank width
		newShotPos		dw ? ; Recent shot position to use later to restore location
		oldShotPos		dw ? ; Position to return the scrKeep to
		pShotHeight		dw	8 ; Player's shot height
		pShotWidth		dw	3 ; Player's shot width
		score					db 0 ; players score in the current game
		shotScrKeep		db 99*57 dup(?) ; Shot scrKeep
		playerHP			db 3 ; Player's hitpoints
		hitEnemyShot	db 0 ; If equals to 1 it means the player has hit the robot
		scrKeep				db	99*57 dup(?) ; Keeping the screen of the oldPos for The player
;------------------------------------------------------------------------------------------------------------------
; All variables that affect the enemy (robot):
		eTurnValue 		db ? ; The random robot move, each number move to other side
		eShotX 				dw ? ; robot shot X position
		eShotY 				dw ? ; robot shot Y position
		eShotNewPos		dw ? ; Recent enemy shot position to use later to restore location
		eShotOldPos		dw ? ; Position to
		eShotHeight		dw	8 ; Enemys shot height
		eShotWidth		dw	3 ; Enemys shot width
		shotLength		dw	10 ; Player's shot length
		eShotLength		dw	10 ; Enemy's shot length
		eShotScrKeep	db 99*57 dup(?) ; enemy shot scrKeep
		newEnemyPos		dw	? ; Recent enemy position to use later to restore location
		oldEnemyPos		dw	? ; Position to return the scrKeep to
		enemyX				dw	? ; X position for the robot
		enemyY				dw	? ; Y position for the robot
		eTankHeight		dw	42 ; My tank height
		eTankWidth		dw	21 ; My tank width
		eScrKeep			db	99*57 dup(?) ; Keeping the screen of the oldPos for The robot
		enemyHP				db 3 ; Enemy's hitpoints
		shotWait			db 1 ; Counter of when equals to 0 enemy shoot and restore to 3
		moveEnemyTank	dw 250 ; Enemy tank speed
		randCodeByte	dw 1 ; Contains the search point in es: for the random number in randomMove proc
		moveEnemyTankSpeed	dw	? ; Variable to compare to 0 for actions, Will change for some levels
;------------------------------------------------------------------------------------------------------------------
; All text variables that use to print the text:
		scoretxt			db 'You Won With Shooting: ','$' ; Used to print the score.
		playerHPtxt		db 'HP: ','$' ; Variable for printing the player's HP
		enemyHPtxt		db 'HP: ','$' ; Variable for printing the enemy's HP
		goodByeMsg 		db 'Thank you for playing$' ; When closing the game this message will appear
;------------------------------------------------------------------------------------------------------------------
