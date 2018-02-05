:    Seta:Gpu D {Alpha} A powerful and fast Batch Game Engine
:    Copyright (C) 2014  Honguito98, {Plus others users}
:
:    This program is free software: you can redistribute it and/or modify
:    it under the terms of the GNU General Public License as published by
:    the Free Software Foundation, either version 3 of the License, or
:    (at your option) any later version.
:
:    This program is distributed in the hope that it will be useful,
:    but WITHOUT ANY WARRANTY; without even the implied warranty of
:    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:    GNU General Public License for more details.
:
:    You should have received a copy of the GNU General Public License
:    along with this program.  If not, see <http://www.gnu.org/licenses/>.

: ALPHA RELEASE ONLY
@Echo Off
	Setlocal EnableExtensions DisableDelayedExpansion
	:: { Extension wrapping, -Seta:Dsp- } ::
	
	
	::::::::::::::::::::::::::::::::::::::::
	
	
	
	:::::: { Flush unused variables, initializing } ::::::::
	Call :Flush
	Cd "%~dp0"
	Set "Game=%~0"
	Set LF=^


	:: Above two lines are critical, do not remove!
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
	
	
	:::::::::::::: { Macro Wrapping } ::::::::::::
	:: Macro name, sensitive case
	Set Macros=Physics;
	For %%# in (%Macros%) Do (
		Call :AutoMacro %%#
	)
	Setlocal EnabledelayedExpansion
	For %%# in (%Macros%) Do (
		Set ^"%%#=!%%#:[LF]=^%LF%%LF%!"
	)
	Set "Macros="
	::::::::::::::::::::::::::::::::::::::::::::::
	
	
	
	
	:::::::::::: { Variable Types, like java } :::::::::::::::
	
	:: { Single variable treatment } ::

	:: Player = Global setting (var. not used) - Rectangle type -
	:: Player.X = x pos
	:: Player.Y = y pos
	:: Player.W = frame width
	:: Player.H = frame heigh
	:: Player.F[] = Player frame animation
	
	:: { Array-based variable treatment } ::
	
	:: Goomba[] = Array based, eg:
	::            Goomba[0]=Y X FrameCount
	:: Goomba.W = frame width
	:: Goomba.H = frame height
	:: Goomba.F[] = Goomba frame animation
	
	
	:: TEMP:   /----- enemy number
	::        v
	:: Goomba[0] = Y X CurrFrame MaxFrame
	
	::           /----- frame number
	::          v
	:: Goomba.F[0] = G_0.spr
	:: Goomba.F[1] = G_1.spr
	:: Goomba.F[2] = G_2.spr
	
	:: Some notes:
	:: 'Call' = set errorlevel to 1
	:: 'Call ' = Set errorlevel to 0

	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:Menu
	Seta_Core.dll Font 2
	Echo; Press any key to play^!^!
	Pause > Nul
	Cls
	
	Set Star.F[0]=Star

	
	:: Setting up 'star' size and pos.
	Set /a Star.X=6, Star.Y=0, Star.W=13, Star.H=14
	
	:: Setting up 'squares' size ans pos array
	::Set "Squares=0.0;0.15;0.30;0.45;"
	
	Set Square[0]=0 0 0
	Set Square[1]=0 15 0
	Set Square[2]=0 30 0
	Set Square[3]=0 45 0

	Set Square.W=13
	Set Square.H=14
	Set Square.F[0]=Blue
	Set Square.F[1]=Red
	Set Cl=0
	
	
	
	:Main
	For /L %%! in  (1,1,256) Do (
	rem cls
	
		Set "__Sq="
		For /L %%S in (0,1,3) Do (
			For /F "Tokens=1-3" %%A in ("!Square[%%S]!") Do (
				Set "__Sq=!__Sq!%%A %%B rsrc\!Square.F[%%C]!.spr "
			)
		)

		
		
		Draw.dll ^
		!__Sq! ^
		!Star.Y! !Star.X! rsrc\%Star.F[0]%.spr
		
		Seta_core.dll _kbd
		If !Errorlevel! Equ 332 Set /a Star.X+=1
		If !Errorlevel! Equ 330 Set /a Star.X-=1
		If !Errorlevel! Equ 327 Set /a Star.Y-=1
		If !Errorlevel! Equ 335 Set /a Star.Y+=1
		If !Errorlevel! Equ 32 Set >tmp.txt
		
		For /L %%S in (0,1,3) Do (
			Set "Square=!Square[%%S]!"
			
			
			%Physics% Star Square

			If !Errorlevel! Equ 0 (
				For /F "Tokens=1-3" %%A in ("!Square[%%S]!") Do (
					Set Square[%%S]=%%A %%B 0
				)
			) Else (
				For /F "Tokens=1-3" %%A in ("!Square[%%S]!") Do (
					Set Square[%%S]=%%A %%B 1
				)
			)
		)
	)
	Goto :Main
	
	


	:: { Macro area. Put your macros here } ::
	
	:: [Physics] - test if an sprite touch another object/sprite ::
	::  * Usage:
	::     %Physics% Player SpriteObj
	::   Player = pos. and size data from player sprite
	::   SpriteObj = same as player, but with another sprite
	::
	::  * Return values: boolean
	::  * Example:
	::
	::  %Physics% Player Goomba
	::  If !Errorlevel! 1 (Echo; Player touchs a goomba) Else (Echo;nothing)
	::
	:: * Notes:
	:: Physics process only a same sprite type per invocation
	
<Macro=Physics|2>
	Set /a^
	"__W_p=%1.W + %1.X,"^
	"__H_p=%1.H + %1.Y,"^
	"__X_p=%1.X,"^
	"__Y_p=%1.Y"
	
	For /F "Tokens=1-2" %X in ("!%2!") Do (
		Set /a^
		"__W_e=%2.W + %Y,"^
		"__H_e=%2.H + %X,"^
		"__X_e=%Y,"^
		"__Y_e=%X,"^
		"__C1=0,"^
		"__C2=0"
		
		Rem X
		If !__W_p! Gtr !__X_e! (
			If !__W_p! Lss !__W_e! (
				Set __C1=1
			) Else (
				If !__X_p! Lss !__W_e! Set __C1=1
			)
		)
		Rem Y
		If !__H_p! Gtr !__Y_e! (
			If !__H_p! Lss !__H_e! (
				Set __C2=1
			) Else (
				If !__Y_p! Lss !__H_e! Set __C2=1
			)
		)
		
		If "!__C1!!__C2!" == "11" (Call) Else (Call )
	)
	
</Macro=Physics>
	
	



:Flush
	For /f "Tokens=1 Delims==" %%a in ('Set') Do (
	If /i "%%a" Neq "Comspec" (
	If /i "%%a" Neq "Tmp" (
	If /i "%%a" Neq "Userprofile" (
	IF /i "%%a" Neq "SystemRoot" (
	IF /i "%%a" Neq "SystemDrive" (
	Set "%%a=")))))
	)
	Set "Path=%comspec:~0,-8%;%SystemRoot%;%Comspec:~0,-8%\Wbem"
	Goto :Eof

:: -> AutoMacro helps you to set variables with functions then be ready to use <- ::
:: -> Type 1: Without Argument pharsing <- ::
:: -> Type 2: With Argument pharsing    <- ::
:AutoMacro
	Set "Start="
	set "Tm=%Tmp%\Tmp.dat"
	Set "End="
	Set "%~1="
	For /F "Tokens=1,3 Delims=>|:" %%a in ('Findstr /N /B "</*Macro=%~1" "%Game%"') Do (
		If Not Defined Start (
			Set Start=%%a
			Set Type=%%b
		) Else (
			Set End=%%a
		)
	)

	If %Type% Equ 1 (
		<Nul Set/p=([LF]>"%Tm%"
	)
	If %Type% Equ 2 (
		<Nul Set/p=For %%` in (0;1^) Do If %%` Equ 1 (For /F "Tokens=1-9" %%1 in ("!Argv!"^) Do ([LF]>"%Tm%"
	)
	Set/a Start+=2
	For /F "Tokens=1* Skip=%Start% Delims=[]" %%a in ('Find /N /V "" "%Game%"') do (
		If %%a Geq %End% Goto :End
		If "%%b" Neq "" <Nul Set/p "=%%b[LF]">>"%Tm%"
	)
:End
	If %Type% Equ 1 (
		<Nul Set/p=^)>>"%Tm%"
	)
	If %Type% Equ 2 (
		<Nul Set/p=^)^) Else Set Argv=>>"%Tm%"
	)

	(
	For /F "Delims=" %%a in ('Type "%Tm%"') Do Set "%~1=%%a"
	) >Nul 2>&1 || Goto :ErrMacro
	Del "%Tm%">Nul 2>&1
	Set Tm=& Set Start=& Set End=
	Goto :Eof
:ErrMacro
	Set/a Start-=2
	For %%a in (
	"Macro Setup Failure from line:"
	"	Start: '%Start%'"
	"	End:   '%End%'"
	"	Expected '%~1' macro with size less than 8KB {8010B} (8100 Letters)"
	) Do Echo;%%~a
	Pause>Nul
	Exit