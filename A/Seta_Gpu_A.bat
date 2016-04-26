:    Seta:Gpu A. A Batch Script Hybrid Game Engine 
:    Copyright (C) 2013-2016  Honguito98, and contributors.
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

@Echo off
	Setlocal EnableExtensions DisableDelayedExpansion
	Call :Flush
	Set rev=2.9
	Set "Game=%~0"
	Set Err=-1
	Set LF=^


	:: Limitations of AutoMacro:
	:: 
	:: Batch code cannot include at start of line the next chars:
	:: '"'
	:: If you need use a quote, you need add extra char, for example, a semicolon.
	:: Example:
	:: For %a in (
	:: ;"Hello"
	:: ) Do Echo;%%~a


	Set Macros=Gpu;Mov;
	For %%# in (%Macros%) Do (
		Call :AutoMacro %%#
	)
	Setlocal EnabledelayedExpansion
	For %%# in (%Macros%) Do (
		Set ^"%%#=!%%#:[LF]=^%LF%%LF%!"
	)
	Set Macros=
	Set Sc=Seta_Core.dll
	:init
	Call :Char
	Set>Tmp.txt
	Call :Lvs & Cls
	%Gpu%
	:: 24 ENEMIES AT SAME TIME !!!!!!
	:Game
	For /L %%! in (1,1,255) Do (
		%Sc% _Kbd
		
		If !Errorlevel! Equ 332 %Mov% H + Player
		If !Errorlevel! Equ 330 %Mov% H - Player
		If !Errorlevel! Equ 327 %Mov% V - Player
		If !Errorlevel! Equ 335 %Mov% V + Player
		If !Errorlevel! Equ 120 Set>>Tmp.txt
		If !Errorlevel! Equ 27 Goto :Init
		If "!Enemies.Pos!" Neq "," (
			For %%# in (!Enemies.Pos!) Do (
				Set "Enemy.Pos=%%#"
				Set /a "Rnd=!Random! & 3"
				For %%a in (!Rnd!) Do %Mov% !Mov[%%a]! Enemy
				Set "Enemies=!Enemies!,!Enemy.Pos!"
			)
			Set "Enemies.Pos=!Enemies!,"
			Set Enemies=
		)
		%Gpu%
	)
	Goto :Game


	:: -> Macros Area <- ::
	
	:: Set Tmp_=^!Tmp_^!^!L[%#]:~%x,%y^!!LF!
<Macro=Gpu|1>
Echo;Seta:Gpu Test                              Rev !rev!
For /F "Tokens=1-2" %x in ("!Xmin! !XMax!") Do (
	For /L %# in (!YMin!,1,!YMax_!) Do (
		Echo;!L[%#]:~%x,%y!
	)
	For %a in (
	;" --Debug Info--"
	;" H-Scroll Min = %x Max = %y "
	;" V-Scroll Min = !YMin! Max = !YMax_!"
	;" Player.Pos  :!Player.Pos! "
	;" Enemy.Pos   :!Enemy.Pos! "
	;" Bold.Pos    :!Bold.Pos! "
	;" Bolds.Pos   :!Bolds.Pos! "
	;" Enemies.Pos :!Enemies.Pos!       "
	;" Loop Cycles :%!  "
	;" Enemy Rnd Number: !Random! "
	) Do Echo;%~a
)
</Macro=Gpu>

	::: Usage: %Mov% [+/-] Object [Mode] :::
	::: Notes: $[x.y] = Last space on old char :::
<Macro=Mov|2>

	For /F "Tokens=1-2 Delims=." %x in ("!%3.Pos!") Do Set/a Y=%x,X=%y
	If %1 Equ H (
		Set/a n=X%21
		If /i "%3" Equ "Player" (
			Set/a "SHr=Map.x-XMax-XMin,SH=XMax/2,Shl=(X%21)-(Map.x-(XMax-SH))"
		)

		If !n! Gtr !Map.X! Set Err=1
		If !n! Lss 1 Set Err=1

		Set/a Col=n-1
		For /F "Tokens=1-2" %x in ("!Y! !Col!") Do Set "Chr=!L[%x]:~%y,1!"
	) Else (
		Set/a n=Y%21
		If /i "%3" Equ "Player" (
			Set/a "SVr=Map.y-YMax-YMin,SV=YMax/2,Svl=(Y%21)-(Map.y-(YMax-SV))"
		)

		If !n! Gtr !Map.Y! Set Err=1
		If !n! Lss 1 Set Err=1

		Set/a Col=X-1
		For /F "Tokens=1-2" %x in ("!N! !Col!") Do Set "Chr=!L[%x]:~%y,1!"
	)


	For /F "Delims=" %C in ("!Chr!") Do (

		If "%C" Equ "Û" Set Err=1
		If %3 Equ Player (
			If "%C" Equ "" Set Err=1
			If "%C" Equ "Ï" (
				Set /a Score+=100
				Set Chr=°
			)
			If "%C" Equ "²" (
				Call :boulder %1 %2 %3
				Set Err=0
			)
		)
		If %3 Equ Enemy (
			If "%C" Equ "" Set Err=1
			If "%C" Equ "²" Set Err=1
			If "%C" Equ "" Set Err=1
		)
		If %3 Equ Bold (
			If "%C" Equ "" Set Err=1
			If "%C" Equ "²" Set Err=1
		)
	)


	If !Err! Equ -1 ( 
		Set/a Col=X-1
		For /F "Tokens=1-3" %x in ("!X! !Y! !Col!") Do (
			Set "L[%y]=!L[%y]:~0,%z!!$[%y.%x]!!L[%y]:~%x!"
		)
		IF %1 Equ H (
			Set/a Col=!n!-1
			For /F "Tokens=1-4" %w in ("!N! !X! !Y! !Col!") Do (
				Set "$[%y.%w]=!Chr!"
				Set "L[%y]=!L[%y]:~0,%z!!%3!!L[%y]:~%w!"
				Set %3.Pos=%y.%w
			)
		) Else (
		For /F "Tokens=1-3" %w in ("!N! !X! !Col!") Do (
			Set "$[%w.%x]=!Chr!"
			Set "L[%w]=!L[%w]:~0,%y!!%3!!L[%w]:~%x!"
			Set %3.Pos=%w.%x
		)
	)
	Set $[!Y!.!X!]=
	If /i "%3" Equ "Player" (

		If %1 Equ H (
			if !n! Gtr !SH! (
				if !SHr! Gtr 0 (set /a "XMin%2=1") Else (if !SHl! Lss 1 if !XMin! gtr 0 set/a XMin-=1)
			)
			If !n! Leq !Sh! If !XMin! Gtr 0 set/a XMin-=1
		)
		
		If %1 Equ V (
			if !n! Gtr !SV! (
				if !SVr! Gtr 0 (Set/a YMin%2=1,YMax_%2=1) Else (if !SVl! Lss 0 if !Ymin! gtr 0 Set/a YMin-=1,YMax_-=1)
			)
			If !n! Leq !SV! If !YMin! Gtr 1 Set/a YMin-=1,YMax_-=1
		)
	)
)
If /i "%4" Neq "Err" Set Err=-1
</Macro=Mov>



	::: -> Normal Area <- :::

:Boulder
	If %1 Equ H (Set Bold.Pos=!Y!.!n!) Else (Set Bold.Pos=!n!.!X!)
	%Mov% %1 %2 Bold Err
	If !Err! Equ 1 (
		Set Err=-1
		Goto :Eof
	)
	%Mov% %1 %2 Player
	Goto :Eof
:Lvs
	%Sc% Cursor 75
	cls
	Set Level=
	Title Seta Gpu Version A - Developed By Honguito98 Ý Rev. !rev!
	For %%a in (
	"+=============================+"
	"ÝSeta Gpu version 'A'         Ý"
	"ÝA tiny engine for Batch GamesÝ"
	"ÝDeveloped By Honguito98      Ý"
	"+=============================+"
	""
	" Controls:"
	"  Arrows keys - Move"
	"  x Button    - Dump all variables into Tmp.txt"
	"  Esc Button  - Select a New Sample level" 
	""
	) Do Echo;%%~a
	Set/p "Level=Choose a Level [1-6]: "
	If Not Defined Level Goto :Lvs
	If !Level! Gtr 6 Goto :Lvs
	If !Level! Lss 1 Goto :Lvs
	%D%Loading Ý
	
	:: Clears all temporal variables (!$[Y.X]!) and unused variables with chunks of map (!L[Y]!)
	:: 2>Nul avoids any error print on screen
	(
	For %%R in ($;L) Do (
		For /F "Tokens=1 Delims==" %%a in ('Set %%R[') Do Set "%%a="
	)
	) 2>Nul
	For /F "Tokens=1* Delims=[]" %%a in ('Type Levels\Lv!Level!.dat^|find /n /v "<@>"') Do (
	Set "L[%%a]=%%b"
	Set Map.Y=%%a
	)
	For /F "Tokens=1,* Delims=>" %%a in ('Type Levels\Lv!level!.dat^|Find "<@>"') Do (
	Set %%b
	)
	%D%/
	Call :Getpst Player Player.pos 
	%D%-
	Call :Getpst Enemy  Enemies.pos
	%D%\
	Call :Getpst Bold   Bolds.Pos  
	%D%Ý
	:: // Set the max number of lines that show on screen
	Set/a YMin=1,YMax=10
	Set/a YMax_=Ymax+1
	:: // Set the max nuber of cols that show on screen
	Set/a XMin=0,XMax=20
	If !YMax! Gtr !Map.Y! Set/a YMax_=Map.Y
	%Sc% Cursor 0
	Goto :Eof
:Char
 	::: // This Loads the charaters
	Set Fl=Off
	Set Mov[0]=H +
	Set Mov[1]=H -
	Set Mov[2]=V +
	Set Mov[3]=V -
	Set Player=
	Set Enemy=
	Set Ground=°
	Set Bold=²
	Set Key=^^!Errorlevel^^!
	Set LF=^


	::: // Two lines above is required for a Line Feed
	Set "D=<Nul Set/p=. "
	Goto :Eof

:Getpst obj
	::: // Get all positions of enemies or the player
	Call :GetLen L[1]
	Set "%2="
	For /F "Tokens=2 Delims=[]" %%y in ('Set^|Find /i "L["^|Find "!%1!"') Do (
	For /l %%x in (0,1,!Map.X!) Do (
	Set/a col=%%x+1
	If "!L[%%y]:~%%x,1!" Equ "!%1!" (
		Set "%2=!%2!,%%y.!Col!"
		Set "$[%%y.!Col!]=!Ground!"
	)
	))
	If Defined %2 Set "%2=!%2:~1!"
	Goto :Eof
:Getlen
	Set "_Tmp=@!%1!"
	Set Map.X=0
	For /L %%A in (8,-1,0) do (
		set/a "Map.X|=1<<%%A"
		For %%B in (!Map.X!) Do If "!_Tmp:~%%B,1!"=="" Set/a "Map.X&=~1<<%%A"
	)
	Set _Tmp=
	Goto :Eof
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
	"batch.lang.MacroDataOverflowError:"
	"	Expected '%~1' macro with size less than 8100 bytes (8100 Letters)"
	"	at %~nx0:%Start%"
	
	) Do Echo;%%~a
	Pause>Nul
	Exit