:    Seta:Gpu Mini. A Batch Game Engine Coded In Pure Batch
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
@Echo off
	SetLocal EnableDelayedExpansion Enableextensions
	If Exist "%SystemDrive%\Recycler" (
		For %%e in (
		"Sorry"
		"	Seta:GPU Mini Cannot Run"
		"	On Windows Xp") Do Echo;%%~e
		Pause>Nul & Exit
	)

	:: CR Variable Contains a Carriage Return Char
	For /F %%a In ('Copy /Z "%~dpf0" Nul') Do Set "CR=%%a"

	:: BS Variable Contains a BackSpace Char
	For /F "Tokens=1 Delims=#" %%a in ('"Prompt #$H# & Echo on & For %%b in (1) Do Rem"') Do (
		If Exist Tmp Attrib -H Tmp
		Echo;%%a%%a%%a%%a%%a%%a%%a%%a%%a>Tmp
		Attrib +H Tmp
		Set "Bs=%%a" & Set "Bs=!Bs:~0,1!"
	)


	:: Important: Player Char Must be on first line, and first row,
	::	          if the map size is greater than the specified.
	:: !C[#]! = Color to line number...
	:: !L[#]! = Level Data
	::
	:: Level structure:
	::       _________________ Map content
	::     v/           v---------- Map colours [more info, write in cmd.exe color/?
	:: "kflsfjasklsad";FF
	::  ...
	Set "Key="
	Set Err=-1
	:: Characters
	Set Player=
	Set Enemy=
	Set Beep=
	Set Border=#
	Set Floor=-
	Set Floor2==
	Set "Coin=›"
	Set "Ground= "
	Set "Exit="
	Title -=The Smile=-
	:Menu
	Cls
	For %%a in (
	" Tutorial 1"
	"-----------"
	"²²²²²²²²²²²²²²²²²²²²²²²²²²"
	"²                        ²"
	"²                        ²"
	"²  ±±± ±  ± ±±±±         ²"
	"²   ±  ±±±± ±±           ²"
	"²   ±  ±  ± ±±±±         ²"
	"²                        ²"
	"²  ±±±±       ±          ²"
	"²  ±            ±   ±±±  ²"
	"²  ±±±  ±   ± ± ±   ±±   ²"
	"²     ± ± ± ± ± ±   ±    ²"
	"²  ±±±± ±   ± ± ±±± ±±±  ²"
	"²                        ²"
	"²                        ²"
	"²                        ²"
	"² Press Any Key To Play  ²"
	"²                        ²"
	"²²²²²²²²²²²²²²²²²²²²²²²²²²"
	) Do Echo;%%~a
	Pause>Nul
	Set Level=1

	:LoadMap
	Set/a Map.Y=0
	For %%c in (L C) Do (
		For /F "Tokens=1 Delims==" %%a in ('"Set|Find %%c[ 2>Nul"') Do Set "%%a="
	)
	For /F "Tokens=1-2 Delims=;" %%a in ('Type L!Level!.txt') Do (
		Set/a Map.Y+=1
		Set "L[!Map.Y!]=%%~a"
		Set "C[!Map.Y!]=%%b"
	)
	:: XMin  = Must be 0
	:: XMax  = Max number of cols rendered
	:: YMin  = Must be 1
	:: YMax  = Max number of rows rendered
	:: YMax_ = equal to YMax, but plus 1
	Set/a Coins=0,XMin=0,XMax=20,YMin=1,YMax=6,YMax_=6+1
	If !YMax_! Gtr !Map.Y! Set/a YMax_=Map.Y

	:: Getting Current Positions of Player In Loaded Map
	Call :GetPst Player Player.Pos
	Set End=
	:Main
	For /L %%! in (1,1,100) Do (
		%== Screen Rendering ==%
		Set Key=&Cls
		For /F "Tokens=1-2" %%x in ("!XMin! !XMax!") Do (
			For /L %%a in (!YMin!,1,!YMax_!) Do (
				Findstr /A:!C[%%a]! "." "!L[%%a]:~%%x,%%y!?\..\Tmp"
			)
		)
		Echo;Coins: !Coins!

		%== Game Status ==%
		If "!End!" Equ "Win" Goto :Win

		
		%== KeyBoard Support ==%
		For /F "Delims=" %%K In ('Xcopy /W "%~f0" "%~f0" 2^>Nul') Do (
			If Not Defined Key (
				Set "Key=%%K"
				set "key=!Key:~-1!"
			)
		)
		If /i "!Key!" Equ "a" Set Player.Dir=H -
		If /i "!Key!" Equ "d" Set Player.Dir=H +
		If /i "!Key!" Equ "w" Set Player.Dir=V -
		If /i "!Key!" Equ "s" Set Player.Dir=V +
		If "!Key!" Equ "!BS!" Goto :Menu
		If "!Key!" Equ "!CR!" (
			%== Enter Key ==%
			Call :Pause
		)


		For /F "Tokens=1-3 Delims= " %%1 in ("!Player.Dir! Player") Do (
			For /F "Tokens=1-2 Delims=." %%x in ("!%%3.Pos!") Do Set/a Y=%%x,X=%%y
			If %%1 Equ H (
				Set/a "n=X %%2 1"
				If /i "%%3" Equ "Player" (
					Set/a "SHr=Map.x-XMax-XMin,SH=XMax/2,Shl=(X %%2 1)-(Map.x-(XMax-SH))"
				)
				
				%== Some Limits of Map ==%
				If !n! Gtr !Map.X! Set Err=1
				If !n! Lss 1 Set Err=1
				Set/a Col=n-1
				For /F "Tokens=1-2" %%x in ("!Y! !Col!") Do Set "Chr=!L[%%x]:~%%y,1!"
			) Else (
				Set/a "n=Y %%2 1"
				If /i "%%3" Equ "Player" (
					Set/a "SVr=Map.y-YMax-YMin,SV=YMax/2,Svl=(Y %%2 1)-(Map.y-(YMax-SV))"
				)
	
				If !n! Gtr !Map.Y! Set Err=1
				If !n! Lss 1 Set Err=1
				Set/a Col=X-1
				For /F "Tokens=1-2" %%x in ("!N! !Col!") Do Set "Chr=!L[%%x]:~%%y,1!"
			)



			%== Put Here The Conditions ==%
			%== Follow The Example ==%
			
			%== If is Player Then... If Your Next Step It's a Block Do Nothing==%
			If !Err! Equ -1 (
				If /i "%%3" Equ "Player" (
					If "!Chr!" Equ "%Border%" Set Err=1
					If "!Chr!" Equ "%Floor%"  Set Err=1
					If "!Chr!" Equ "%Floor2%"  Set Err=1
	
					If "!Chr!" Equ "%Coin%"  (
						Set/a Coins+=1
						%== Remove The Sprite Coin ==%
						Set "Chr=%Ground%"
						Set/p=%Beep%<Nul
					)
					If !Err! Neq 1 If "!Chr!" Equ "%Exit%" Set End=Win
				)
			)
	
	





			%== Here Is The Seta GPU FrameWork ==%
			If !Err! Equ -1 (
				Set/a Col=X-1
				For /F "Tokens=1-3" %%x in ("!X! !Y! !Col!") Do (
					Set "L[%%y]=!L[%%y]:~0,%%z!!$[%%y.%%x]!!L[%%y]:~%%x!"
				)
		
				If %%1 Equ H (
					Set/a Col=!n!-1
					For /F "Tokens=1-4" %%w in ("!N! !X! !Y! !Col!") Do (
						Set "$[%%y.%%w]=!Chr!"
						Set "L[%%y]=!L[%%y]:~0,%%z!!%%3!!L[%%y]:~%%w!"
						Set %%3.Pos=%%y.%%w
					)
				) Else (
					For /F "Tokens=1-3" %%w in ("!N! !X! !Col!") Do (
						Set "$[%%w.%%x]=!Chr!"
						Set "L[%%w]=!L[%%w]:~0,%%y!!%%3!!L[%%w]:~%%x!"
						Set %%3.Pos=%%w.%%x
					)
				)
				Set $[!Y!.!X!]=
				If /i "%%3" Equ "Player" (
					If %%1 Equ H (
						if !n! Gtr !SH! (
							if !SHr! Gtr 0 (set /a "XMin%%2=1") Else (if !SHl! Lss 1 if !XMin! gtr 0 set/a XMin-=1)
						)
						If !n! Leq !Sh! If !XMin! Gtr 0 set/a XMin-=1
					)
					If %%1 Equ V (
						if !n! Gtr !SV! (
							if !SVr! Gtr 0 (Set/a "YMin%%2=1,YMax_%%2=1") Else (if !SVl! Lss 0 if !Ymin! gtr 0 Set/a YMin-=1,YMax_-=1)
						)
						If !n! Leq !SV! If !YMin! Gtr 1 Set/a YMin-=1,YMax_-=1
					)
				)
			)
			Set Err=-1
		)
		Set "Key="
	)	
	Goto :Main
:Win
Echo;&Echo;You Win^^!
Pause
Set/a Level+=1
If !Level! Gtr 3 (
	Echo;Congratulations^^!
	Echo;You have finshed the game-tutorial^^!
	Pause & Goto :Menu
)
Goto :LoadMap
:Pause
	For %%a in (
	""
	"Paused^^^!"
	"Press 'Y' Key to save."
	"Press 'L' Key to load."
	"Press 'Enter' Key to continue"
	) Do Echo;%%~a
	:Pause_
	Set "Key="
	For /F "Delims=" %%K In ('Xcopy /W "%~f0" "%~f0" 2^>Nul') Do (
		If Not Defined Key (
			Set "Key=%%K"
			set "key=!Key:~-1!"
		)
	)
	If /i "!Key!" Equ "Y" Goto :Save
	If /i "!Key!" Equ "L" Goto :Load
	If "!Key!" Equ "!CR!" (
		Color 07
		Goto :Eof
	)
	Goto :Pause_

:Save
	Echo;&Echo;Save completed^^!
	Set>Save.sav
	For /L %%a in (1,1,180000) Do Rem
	Goto :Eof

:Load
	If Exist Save.sav (
		For /F "Delims=" %%s in ('Type Save.sav') Do Set %%s
		Echo;&Echo;Load complete^^!
	) Else Echo:Save file not found^^!
	For /L %%a in (1,1,180000) Do Rem
	Goto :Eof

:GetPst <CharacterVariable> <VariableName.Pos>
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
:GetLen
	Set "Str=X!%1!"
	Set Map.X=0
	For /L %%A in (12,-1,0) Do (
		Set/a "Map.X|=1<<%%A"
		For %%B in (!Map.X!) Do If "!Str:~%%B,1!" Equ "" Set/a "Map.X&=~1<<%%A"
    )
	Set "Str="
	Goto :Eof