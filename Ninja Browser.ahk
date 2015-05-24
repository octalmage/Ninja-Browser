#singleinstance force

onexit, cleanup
trans=250
noimg=0

if !fileexist("ninja.ini")
{
	IniWrite, !^n, ninja.ini, Settings, unhide
	IniWrite, 1, ninja.ini, Settings, level
	IniWrite, 1, ninja.ini, Settings, mouseoff
}

IniRead, unhidehotkey, ninja.ini, Settings, unhide
IniRead, hidinglevel, ninja.ini, Settings, level
IniRead, mouseoff, ninja.ini, Settings, mouseoff
Hotkey, %unhidehotkey% , unhide
Hotkey, %unhidehotkey% , off


if hidinglevel=1
	trans=250
else if hidinglevel=2
	trans=200
else if hidinglevel=3
	trans=150
else if hidinglevel=4
	trans=100
else
	trans=50


menu, tray, NoStandard
menu,tray,add,Hide Icon,hideicon
Menu, HidingLevels, add, Hiding Level 1, level1
Menu, HidingLevels, add, Hiding Level 2, level2
Menu, HidingLevels, add, Hiding Level 3, level3
Menu, HidingLevels, add, Hiding Level 4, level4
Menu, HidingLevels, add, Hiding Level 5, level5
Menu, HidingLevels,Check, Hiding Level %hidinglevel%
menu,tray,add,Hiding Level, :HidingLevels
menu,tray,add,About,About
menu,tray,add,Settings,Settings
menu,tray,add,
menu,tray,add,Exit,cleanup

settimer,setbuttons,500


wait:
{
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen
	screenwidth:=A_ScreenWidth-1
	loop
	{
		sleep 100
		MouseGetPos,xx
		if (xx=0)
		{
			ss=%ss%1
			SetTimer, clear,2000
			loop
			{
				MouseGetPos,xx
				if xx<>0
					break
			}
		}
		else if (xx=screenwidth)
		{
			ss=%ss%2
			SetTimer, clear,2000
			loop
			{
				MouseGetPos,xx
				if xx<>%screenwidth%
					break
			}
		}
		StringRight, check, ss, 3
		if (check=121) or (check=212)
		{
			break
		}
	}


	check=
	ss=
	gosub show
}
return


~lbutton::
{
	ifwinnotactive --Ninja Browser--
	{
		gui,hide
	}
}
return


mouseoff:
#IfWinActive, --Ninja Browser--
MouseGetPos, xpos, ypos
show_x2:=show_x+best_width
show_y2:=show_y+best_height
if xpos<%show_x% and ypos<%show_y% or xpos>%show_x2% and ypos>%show_y2%
{

}
#IfWinActive
return


urlfixer:
furl:=Gui_IEGetURL()
ControlSetText ,Edit1, %furl%, --Ninja Browser--
return


about:
gui 9:add,text,,To display Ninja Browser, do the following:	`ntouch the LEFT edge of the entire screen with your mouse cursor; `nthen move it all the way across to touch the RIGHT edge; `nthen again move it all the way across to touch the LEFT edge of the screen. `nThis is the signal for the browser, which has been hidden but listening, to come out.
gui 9:add,button,gcloseabout,Close
gui 9:show
return


closeabout:
gui 9: destroy
return


cleanup:
IniWrite, %hidinglevel%, ninja.ini, Settings, level
exitapp


settings:
gui 7: add,text,,Select a hotkey to unhide Ninja Browser's tray icon.
gui 7: add,hotkey,vnewunhidehotkey, %unhidehotkey%
gui 7: add,button,gsavesettings,Save
gui 7: show
return


7guiclose:
gui 7: destroy
return


savesettings:
gui 7: submit
gui 7: destroy
if newunhidehotkey!=%unhidehotkey%
{
	Hotkey, %newunhidehotkey% , unhide
	Hotkey, %newunhidehotkey% , off
	unhidehotkey=%newunhidehotkey%
	IniWrite, %unhidehotkey%, ninja.ini, Settings, unhide
}
return


level1:
trans=250
Menu, HidingLevels,UnCheck, Hiding Level 2
Menu, HidingLevels,UnCheck, Hiding Level 3
Menu, HidingLevels,UnCheck, Hiding Level 4
Menu, HidingLevels,UnCheck, Hiding Level 5
Menu, HidingLevels,Check, Hiding Level 1
IniWrite, 1, ninja.ini, Settings, level
hidinglevel=1
return

level2:
trans=200
Menu, HidingLevels,Check, Hiding Level 2
Menu, HidingLevels,UnCheck, Hiding Level 3
Menu, HidingLevels,UnCheck, Hiding Level 4
Menu, HidingLevels,UnCheck, Hiding Level 5
Menu, HidingLevels,unCheck, Hiding Level 1
IniWrite, 2, ninja.ini, Settings, level
hidinglevel=2
return


level3:
trans=150
Menu, HidingLevels,UnCheck, Hiding Level 2
Menu, HidingLevels,Check, Hiding Level 3
Menu, HidingLevels,UnCheck, Hiding Level 4
Menu, HidingLevels,UnCheck, Hiding Level 5
Menu, HidingLevels,UnCheck, Hiding Level 1
IniWrite, 3, ninja.ini, Settings, level
hidinglevel=3
return


level4:
trans=100
Menu, HidingLevels,UnCheck, Hiding Level 2
Menu, HidingLevels,UnCheck, Hiding Level 3
Menu, HidingLevels,Check, Hiding Level 4
Menu, HidingLevels,UnCheck, Hiding Level 5
Menu, HidingLevels,unCheck, Hiding Level 1
IniWrite, 4, ninja.ini, Settings, level
hidinglevel=4
return


level5:
trans=50
Menu, HidingLevels,UnCheck, Hiding Level 2
Menu, HidingLevels,UnCheck, Hiding Level 3
Menu, HidingLevels,UnCheck, Hiding Level 4
Menu, HidingLevels,Check, Hiding Level 5
Menu, HidingLevels,unCheck, Hiding Level 1
IniWrite, 5, ninja.ini, Settings, level
hidinglevel=5
return


hideicon:
menu,tray,NoIcon
Hotkey, %unhidehotkey% , on
StringReplace, DisplayKey, unhidehotkey, ^ , Control%a_space% , All
StringReplace, DisplayKey, DisplayKey, ! , Alt%a_space% , All
StringReplace, DisplayKey, DisplayKey, + ,Shift%a_space% , All
msgbox The icon will now be hidden, press %DisplayKey% to unhide.
return


unhide:
menu,tray,Icon
Hotkey, %unhidehotkey% , off
return


show:
{
	WinGetActiveTitle, title
	if title = Ninja Browser
		Goto, wait
	if title = program manager
		Goto, wait
	best_area=0
	old_area=-1
	old_width=0
	old_height=0
	winid := WinExist("A")
	WinGet, controls , ControlList, ahk_id %winid%
	Loop, parse, controls, `n
	{
		if A_LoopField=SHELLDLL_DefView1
			continue
		if A_LoopField=DUIViewWndClassName1
			continue
		if A_LoopField=DirectUIHWND1
			continue
		if A_LoopField=MozillaWindowClass1
			continue
		new_x=
		new_y=
		new_height=
		new_width=
		new_area=
		ControlGetPos , new_x, new_y, new_width,  new_height,  %A_LoopField%, ahk_id %winid%
		new_area:=new_height*new_width
		if new_area>%best_area%
		{
			best= %A_LoopField%
			best_x:=new_x
			best_y:=new_y
			best_height:=new_height
			best_width:=new_width
			best_area:=new_width*new_height
		}
		old_height=new_height
		old_width=new_width
		old_area=new_area
	}
	gui,-caption +toolwindow
	WinGetPos ,win_x , win_y,,, ahk_id %winid%
	Gui,  +LastFound
	mgH := WinExist()
	ie_height:=best_height-5
	ie_width:=best_width
	if !time
	{
		edit_width:=best_width/95
		gui,add,button,x0 y0 disabled gback,Back
		gui,add,button,x40 y0 disabled gfoward,Foward
		gui,add,button, x90 y0 grefresh,Refresh
		gui,add,button, x142 y0 gstop,Stop
		gui,add,edit,x200 y0 w200 vurl,
		gui,add,button,x400 y0 default  ggo ,GO
		gui add, ActiveX, x0 y23 w%ie_width% h%ie_height% vWB, Shell.Explorer

		h=
		(
		<html>
		<head>
		<title>
		</title>
		</head>
		<body>
		<center>
		<img src="http://cldup.com/qwzfqh6ZOn.png"><br><br>
		<font size="24">Ninja Browser</font>
		</center>
		</body>
		</html>
		)
		
		WB.Navigate("https://www.google.com")

		;	ControlSetText ,Edit1, %furl%, --Ninja Browser--
		;	SetTimer, updateurl, 500
			time=1
	}
	else
	{
	}

	;WinMove, % "ahk_id " . COM_AtlAxGetContainer(pwb), , 0,23, ie_width, ie_height
	show_x:=win_x+best_x
	show_y:=win_y+best_y
	gui,show,  x%show_x% y%show_y% h%best_height% w%best_width%, --Ninja Browser--
	WinGet, id , id, --Ninja Browser--
	WinSet, Transparent, %trans% , --Ninja Browser--
	show=1
}
sleep 2000
gosub wait
return

stop:
{
	COM_Invoke(pwb, "Stop")
}
return

~esc::
{
	ifwinactive --Ninja Browser--
	{
		gui,hide
		show=0
	}
}
return


clear:
{
	ss=
}
return

refresh:
	COM_Invoke(pwb, "Refresh2")
return

back:
	WB.GoBack()
gosub setbuttons
return

foward:
	WB.GoForward()
	gosub setbuttons
return

hide:
{
	ifwinnotactive ghostzilla11
	{
		winhide,ghostzilla11
	}
}
return


hide2:
	gui,hide
return

^q::
{
	exitapp
}
return


go:
{
	gui,submit,nohide

	WB.Navigate(url)
	if noimg
	{
		jsAlert:=""
		COM_Invoke(pwb, "Navigate", "javascript:var x=document.images.length; for (i=0;i < x;++i){document.images(i).src=''}; void(0);",0x0400)
		style=
		(
		javascript: var style=document.createElement('style'); style.innerHTML = 'img { background-color: #000000; position: absolute; top: 0; left: 0; z-index: 100; filter: alpha(opacity=20); -moz-opacity: 0.2; opacity: 0.2;}; document.head.appendChild(style);';
		)
	}
	gosub setbuttons
	control,disable,,Button2,--Ninja Browser--
}
return


updateurl:
ControlGetFocus, fcontrol, --Ninja Browser--
IfNotEqual fcontrol, Edit1
{
	furl:=COM_Invoke(WB, "LocationURL")
	ControlSetText ,Edit1, %furl%, --Ninja Browser--
}
return


WM_KEYDOWN(wParam, lParam, nMsg, hWnd)
{
	If  (wParam = 0x09 || wParam = 0x0D || wParam = 0x2E || wParam = 0x26 || wParam = 0x28)
	{
		WinGetClass, Class, ahk_id %hWnd%
		If  (Class = "Internet Explorer_Server")
		{
			Global pipa
			VarSetCapacity(Msg, 28)
			NumPut(hWnd,Msg), NumPut(nMsg,Msg,4), NumPut(wParam,Msg,8), NumPut(lParam,Msg,12)
			NumPut(A_EventInfo,Msg,16), NumPut(A_GuiX,Msg,20), NumPut(A_GuiY,Msg,24)
			DllCall(NumGet(NumGet(1*pipa)+20), "Uint", pipa, "Uint", &Msg)
			Return 0
		}
	}
}

setbuttons:
if true
{
	control,enable,,Button1, --Ninja Browser--
}
else
{
	control,disable,,Button1, --Ninja Browser--
}
if Gui_IECanGoForward()
{
	control,enable,,Button2, --Ninja Browser--
}
else
{
	control,disable,,Button2, --Ninja Browser--
}
return


Gui_IEAdd(mgH, x, y, w, h, u, b=1)
{
ieM := DllCall("LoadLibrary", "Str", "lbbrowse3.dll")
r := DllCall("lbbrowse3\CreateBrowser"
, "UInt", mgH
, "Int", x
, "Int", y
, "Int", w
, "Int", h
, "Str", u
, "Int", b)
Return ieM
}
Gui_IEMove(x, y, w, h)
{
r := DllCall("lbbrowse3\MoveBrowser"
, "Int", x
, "Int", y
, "Int", w
, "Int", h)
}
Gui_IELoadURL(u)
{
r := DllCall("lbbrowse3\Navigate", "str", u)
}
Gui_IELoadHTML(h)
{
r := DllCall("lbbrowse3\BrowserString", "str", h)
}
Gui_IECanGoBack()
{
r := DllCall("lbbrowse3\CanGoBack")
Return r
}
Gui_IECanGoForward()
{
r := DllCall("lbbrowse3\CanGoForward")
Return r
}
Gui_IEDLLVersion()
{
r := DllCall("lbbrowse3\DLLVersion")
Return r
}
Gui_IEShowStatusbar()
{
r := DllCall("lbbrowse3\ShowStatusbar", "int", 1)
}
Gui_IEHideStatusbar()
{
r := DllCall("lbbrowse3\ShowStatusbar", "int", 0)
}
Gui_IEGetURL()
{
VarSetCapacity(cU, 1000)
r := DllCall("lbbrowse3\GetURL", "str", cU)
Return cU
}
Gui_IEGetHistory()
{
VarSetCapacity(cH, 32000)
r := DllCall("lbbrowse3\GetHistory", "str", cH)
StringReplace, cH, cH, %A_Space%, |, A
Return cH
}
Gui_IEClearHistory()
{
r := DllCall("lbbrowse3\ClearHistory")
}
Gui_IEGetTitle()
{
VarSetCapacity(cT, 1000)
r := DllCall("lbbrowse3\GetTitle", "str", cT)
Return cT
}
Gui_IEGetStatusText()
{
VarSetCapacity(cS, 1000)
r := DllCall("lbbrowse3\GetStatusText", "str", cS)
Return cS
}
Gui_IEPrint()
{
r := DllCall("lbbrowse3\BrowserPrint")
}
Gui_IEGoBack()
{
r := DllCall("lbbrowse3\Back")
}
Gui_IEGoForward()
{
r := DllCall("lbbrowse3\Forward")
}
Gui_IEGoStop()
{
r := DllCall("lbbrowse3\Cancel")
}
Gui_IEGoRefresh()
{
r := DllCall("lbbrowse3\Refresh")
}
Gui_IEGoHome()
{
r := DllCall("lbbrowse3\Home")
}
Gui_IEGoSearch()
{
r := DllCall("lbbrowse3\Search")
}
Gui_IEPrintPreview()
{
r := DllCall("lbbrowse3\PrintPreview")
}
Gui_IEPageSetup()
{
r := DllCall("lbbrowse3\PageSetup")
}
Gui_IEProperties()
{
r := DllCall("lbbrowse3\Properties")
}
Gui_IEMakeDesktopShortcut()
{
r := DllCall("lbbrowse3\MakeDesktopShortcut")
}
Gui_IESendEMail()
{
r := DllCall("lbbrowse3\SendEMail")
}
Gui_IEAddToFavorites()
{
r := DllCall("lbbrowse3\AddToFavorites")
}
Gui_IEViewSource()
{
r := DllCall("lbbrowse3\ViewSource")
}
Gui_IEInternetOptions()
{
r := DllCall("lbbrowse3\InternetOptions")
}
Gui_IEDoFontSize(s)
{
r := DllCall("lbbrowse3\DoFontSize", "int", s)
}
Gui_IECleanup(ieM)
{
DllCall("lbbrowse3\DestroyBrowser")
DllCall("FreeLibrary", "UInt", ieM)
}
COM_Init()
{
Return	DllCall("ole32\OleInitialize", "Uint", 0)
}
COM_Term()
{
Return	DllCall("ole32\OleUninitialize")
}
COM_VTable(ppv, idx)
{
Return	NumGet(NumGet(1*ppv)+4*idx)
}
COM_QueryInterface(ppv, IID = "")
{
If	DllCall(NumGet(NumGet(1*ppv)+0), "Uint", ppv, "Uint", COM_GUID4String(IID,IID ? IID : IID=0 ? "{00000000-0000-0000-C000-000000000046}" : "{00020400-0000-0000-C000-000000000046}"), "UintP", ppv)=0
Return	ppv
}
COM_AddRef(ppv)
{
Return	DllCall(NumGet(NumGet(1*ppv)+4), "Uint", ppv)
}
COM_Release(ppv)
{
Return	DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv)
}
COM_QueryService(ppv, SID, IID = "")
{
DllCall(NumGet(NumGet(1*ppv)+4*0), "Uint", ppv, "Uint", COM_GUID4String(IID_IServiceProvider,"{6D5140C1-7436-11CE-8034-00AA006009FA}"), "UintP", psp)
DllCall(NumGet(NumGet(1*psp)+4*3), "Uint", psp, "Uint", COM_GUID4String(SID,SID), "Uint", IID ? COM_GUID4String(IID,IID) : &SID, "UintP", ppv:=0)
DllCall(NumGet(NumGet(1*psp)+4*2), "Uint", psp)
Return	ppv
}
COM_FindConnectionPoint(pdp, DIID)
{
DllCall(NumGet(NumGet(1*pdp)+ 0), "Uint", pdp, "Uint", COM_GUID4String(IID_IConnectionPointContainer, "{B196B284-BAB4-101A-B69C-00AA00341D07}"), "UintP", pcc)
DllCall(NumGet(NumGet(1*pcc)+16), "Uint", pcc, "Uint", COM_GUID4String(DIID,DIID), "UintP", pcp)
DllCall(NumGet(NumGet(1*pcc)+ 8), "Uint", pcc)
Return	pcp
}
COM_GetConnectionInterface(pcp)
{
VarSetCapacity(DIID, 16, 0)
DllCall(NumGet(NumGet(1*pcp)+12), "Uint", pcp, "Uint", &DIID)
Return	COM_String4GUID(&DIID)
}
COM_Advise(pcp, psink)
{
DllCall(NumGet(NumGet(1*pcp)+20), "Uint", pcp, "Uint", psink, "UintP", nCookie)
Return	nCookie
}
COM_Unadvise(pcp, nCookie)
{
Return	DllCall(NumGet(NumGet(1*pcp)+24), "Uint", pcp, "Uint", nCookie)
}
COM_Enumerate(penum, ByRef Result, ByRef vt = "")
{
VarSetCapacity(varResult,16,0)
If (0 =	hr:=DllCall(NumGet(NumGet(1*penum)+12), "Uint", penum, "Uint", 1, "Uint", &varResult, "UintP", 0))
Result:=(vt:=NumGet(varResult,0,"Ushort"))=9||vt=13 ? NumGet(varResult,8):vt=8||vt<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0 ? COM_Ansi4Unicode(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8)
Return	hr
}
COM_Invoke(pdsp,name="",prm0="vT_NoNe",prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
{
If	name=
Return	COM_Release(pdsp)
If	name contains .
{
SubStr(name,1,1)!="." ? name.=".":name:=SubStr(name,2) . ".",COM_AddRef(pdsp)
Loop,	Parse,	name, .
{
If	A_Index=1
{
name :=	A_LoopField
Continue
}
Else If	name not contains [,(
prmn :=	""
Else If	InStr("])",SubStr(name,0))
Loop,	Parse,	name, [(,'")]
If	A_Index=1
name :=	A_LoopField
Else	prmn :=	A_LoopField
Else
{
name .=	"." . A_LoopField
Continue
}
If	A_LoopField!=
pdsp:=	COM_Invoke(pdsp,name,prmn!="" ? prmn:"vT_NoNe")+COM_Release(pdsp)*0,name:=A_LoopField
Else	Return	prmn!="" ? COM_Invoke(pdsp,name,prmn,prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8):COM_Invoke(pdsp,name,prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8,prm9),COM_Release(pdsp)
}
}
sParams	:= "0123456789"
Loop,	Parse,	sParams
If	(prm%A_LoopField% == "vT_NoNe")
{
sParams	:= SubStr(sParams,1,A_Index-1)
Break
}
VarSetCapacity(varg,16*nParams:=StrLen(sParams),0), VarSetCapacity(DispParams,16,0), VarSetCapacity(varResult,32,0), VarSetCapacity(ExcepInfo,32,0)
Loop, 	Parse,	sParams
If	prm%A_LoopField% is not integer
NumPut(COM_SysString(prm%A_LoopField%,prm%A_LoopField%),NumPut(8,varg,(nParams-A_Index)*16),4)
Else	NumPut(SubStr(prm%A_LoopField%,1,1)="+" ? 9:prm%A_LoopField%=="-0" ? (prm%A_LoopField%:=0x80020004)*0+10:3,NumPut(prm%A_LoopField%,varg,(nParams-A_Index)*16+8),-12,"Ushort")
If	nParams
NumPut(nParams,NumPut(&varg,DispParams),4)
If	(nvk :=	SubStr(name,0)="=" ? 12:3)=12
name :=	SubStr(name,1,-1),NumPut(1,NumPut(NumPut(-3,varResult,4)-4,DispParams,4),4)
Global	COM_HR, COM_LR:=""
If	(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+20),"Uint",pdsp,"Uint",&varResult+16,"UintP",COM_SysString(wname,name),"Uint",1,"Uint",1024,"intP",dispID,"Uint"))=0&&(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",dispID,"Uint",&varResult+16,"Uint",1024,"Ushort",nvk,"Uint",&DispParams,"Uint",&varResult,"Uint",&ExcepInfo,"Uint",0,"Uint"))!=0&&nParams&&nvk!=12&&(COM_LR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",dispID,"Uint",&varResult+16,"Uint",1024,"Ushort",12,"Uint",NumPut(1,NumPut(NumPut(-3,varResult,4)-4,DispParams,4),4)-16,"Uint",0,"Uint",0,"Uint",0,"Uint"))=0
COM_HR:=0
Global	COM_VT := NumGet(varResult,0,"Ushort")
Return	COM_HR=0 ? COM_VT>1 ? COM_VT=9||COM_VT=13 ? NumGet(varResult,8):COM_VT=8||COM_VT<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0 ? COM_Ansi4Unicode(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8):"":COM_Error(COM_HR,COM_LR,&ExcepInfo,name)
}
COM_Invoke_(pdsp,name,typ0="",prm0="",typ1="",prm1="",typ2="",prm2="",typ3="",prm3="",typ4="",prm4="",typ5="",prm5="",typ6="",prm6="",typ7="",prm7="",typ8="",prm8="",typ9="",prm9="")
{
If	name contains .
{
SubStr(name,1,1)!="." ? name.=".":name:=SubStr(name,2) . ".", COM_AddRef(pdsp)
Loop,	Parse,	name, .
{
If	A_Index=1
{
name :=	A_LoopField
Continue
}
Else If	name not contains [,(
prmn :=	""
Else If	InStr("])",SubStr(name,0))
Loop,	Parse,	name, [(,'")]
If	A_Index=1
name :=	A_LoopField
Else	prmn :=	A_LoopField
Else
{
name .=	"." . A_LoopField
Continue
}
If	A_LoopField!=
pdsp:=	COM_Invoke(pdsp,name,prmn!="" ? prmn:"vT_NoNe")+COM_Release(pdsp)*0,name:=A_LoopField
Else	Return	COM_Invoke_(pdsp,name,typ0,prm0,typ1,prm1,typ2,prm2,typ3,prm3,typ4,prm4,typ5,prm5,typ6,prm6,typ7,prm7,typ8,prm8,typ9,prm9),COM_Release(pdsp)
}
}
sParams	:= "0123456789"
Loop,	Parse,	sParams
If	(typ%A_LoopField% = "")
{
sParams	:= SubStr(sParams,1,A_Index-1)
Break
}
VarSetCapacity(varg,16*nParams:=StrLen(sParams),0), VarSetCapacity(DispParams,16,0), VarSetCapacity(varResult,32,0), VarSetCapacity(ExcepInfo,32,0)
Loop,	Parse,	sParams
NumPut(typ%A_LoopField%,varg,(nParams-A_Index)*16,"Ushort"),typ%A_LoopField%&0x4000=0 ? NumPut(typ%A_LoopField%=8 ? COM_SysString(prm%A_LoopField%,prm%A_LoopField%):prm%A_LoopField%,varg,(nParams-A_Index)*16+8,typ%A_LoopField%=5 ? "double":"int64"):(VarSetCapacity(_ref_%A_LoopField%,8,0),NumPut(&_ref_%A_LoopField%,varg,(nParams-A_Index)*16+8),NumPut((prmx:=prm%A_LoopField%)&&typ%A_LoopField%=0x4008 ? COM_SysAllocString(%prmx%):%prmx%,_ref_%A_LoopField%,0,typ%A_LoopField%=0x4005 ? "double":"int64"))
If	nParams
NumPut(nParams,NumPut(&varg,DispParams),4)
If	(nvk :=	SubStr(name,0)="=" ? 12:3)=12
name :=	SubStr(name,1,-1),NumPut(1,NumPut(NumPut(-3,varResult,4)-4,DispParams,4),4)
Global	COM_HR, COM_LR:=""
If	(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+20),"Uint",pdsp,"Uint",&varResult+16,"UintP",COM_SysString(wname,name),"Uint",1,"Uint",1024,"intP",dispID,"Uint"))=0&&(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",dispID,"Uint",&varResult+16,"Uint",1024,"Ushort",nvk,"Uint",&DispParams,"Uint",&varResult,"Uint",&ExcepInfo,"Uint",0,"Uint"))!=0&&nParams&&nvk!=12&&(COM_LR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",dispID,"Uint",&varResult+16,"Uint",1024,"Ushort",12,"Uint",NumPut(1,NumPut(NumPut(-3,varResult,4)-4,DispParams,4),4)-16,"Uint",0,"Uint",0,"Uint",0,"Uint"))=0
COM_HR:=0
Loop,	Parse,	sParams
typ%A_LoopField%&0x4000 ? (prmx:=prm%A_LoopField%,%prmx%:=typ%A_LoopField%=0x4008 ? COM_Ansi4Unicode(prmx:=NumGet(_ref_%A_LoopField%)) . COM_SysFreeString(prmx):NumGet(_ref_%A_LoopField%,0,typ%A_LoopField%=0x4005 ? "double":"int64")):""
Global	COM_VT := NumGet(varResult,0,"Ushort")
Return	COM_HR=0 ? COM_VT>1 ? COM_VT=9||COM_VT=13 ? NumGet(varResult,8):COM_VT=8||COM_VT<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0 ? COM_Ansi4Unicode(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8):"":COM_Error(COM_HR,COM_LR,&ExcepInfo,name)
}
COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
{
Critical
If	A_EventInfo = 6
hr:=DllCall(NumGet(NumGet(0+p:=NumGet(this+8))+28),"Uint",p,"Uint",prm1,"UintP",pname,"Uint",1,"UintP",0), hr==0 ? (VarSetCapacity(sfn,63),DllCall("user32\wsprintfA","str",sfn,"str","%s%S","Uint",this+40,"Uint",pname,"Cdecl"),COM_SysFreeString(pname),%sfn%(prm5,this,prm6)):""
Else If	A_EventInfo = 5
hr:=DllCall(NumGet(NumGet(0+p:=NumGet(this+8))+40),"Uint",p,"Uint",prm2,"Uint",prm3,"Uint",prm5)
Else If	A_EventInfo = 4
NumPut(0*hr:=0x80004001,prm3+0)
Else If	A_EventInfo = 3
NumPut(0,prm1+0)
Else If	A_EventInfo = 2
NumPut(hr:=NumGet(this+4)-1,this+4)
Else If	A_EventInfo = 1
NumPut(hr:=NumGet(this+4)+1,this+4)
Else If	A_EventInfo = 0
COM_IsEqualGUID(this+24,prm1)||InStr("{00020400-0000-0000-C000-000000000046}{00000000-0000-0000-C000-000000000046}",COM_String4GUID(prm1)) ? NumPut(NumPut(NumGet(this+4)+1,this+4)-8,prm2+0):NumPut(0*hr:=0x80004002,prm2+0)
Return	hr
}
COM_DispGetParam(pDispParams, Position = 0, vt = 8)
{
VarSetCapacity(varResult,16,0)
DllCall("oleaut32\DispGetParam", "Uint", pDispParams, "Uint", Position, "Ushort", vt, "Uint", &varResult, "UintP", nArgErr)
Return	NumGet(varResult,0,"Ushort")=8 ? COM_Ansi4Unicode(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8)
}
COM_DispSetParam(val, pDispParams, Position = 0, vt = 8)
{
Return	NumPut(vt=8 ? COM_SysAllocString(val):val,NumGet(NumGet(pDispParams+0)+(NumGet(pDispParams+8)-Position)*16-8),0,vt=11||vt=2 ? "short":"int")
}
COM_Error(hr = "", lr = "", pei = "", name = "")
{
Static	bDebug:=1
If Not	pei
{
bDebug:=hr
Global	COM_HR, COM_LR
Return	COM_HR&&COM_LR ? COM_LR<<32|COM_HR:COM_HR
}
Else If	!bDebug
Return
hr ? (VarSetCapacity(sError,1023),VarSetCapacity(nError,10),DllCall("kernel32\FormatMessageA","Uint",0x1000,"Uint",0,"Uint",hr<>0x80020009 ? hr : (bExcep:=1)*(hr:=NumGet(pei+28)) ? hr : hr:=NumGet(pei+0,0,"Ushort")+0x80040200,"Uint",0,"str",sError,"Uint",1024,"Uint",0),DllCall("user32\wsprintfA","str",nError,"str","0x%08X","Uint",hr,"Cdecl")) : sError:="The COM Object may not be a valid Dispatch Object!`n`tFirst ensure that COM Library has been initialized through COM_Init().`n", lr ? (VarSetCapacity(sError2,1023),VarSetCapacity(nError2,10),DllCall("kernel32\FormatMessageA","Uint",0x1000,"Uint",0,"Uint",lr,"Uint",0,"str",sError2,"Uint",1024,"Uint",0),DllCall("user32\wsprintfA","str",nError2,"str","0x%08X","Uint",lr,"Cdecl")) : ""
MsgBox, 260, COM Error Notification, % "Function Name:`t""" . name . """`nERROR:`t" . sError . "`t(" . nError . ")" . (bExcep ? SubStr(NumGet(pei+24) ? DllCall(NumGet(pei+24),"Uint",pei) : "",1,0) . "`nPROG:`t" . COM_Ansi4Unicode(NumGet(pei+4)) . COM_SysFreeString(NumGet(pei+4)) . "`nDESC:`t" . COM_Ansi4Unicode(NumGet(pei+8)) . COM_SysFreeString(NumGet(pei+8)) . "`nHELP:`t" . COM_Ansi4Unicode(NumGet(pei+12)) . COM_SysFreeString(NumGet(pei+12)) . "," . NumGet(pei+16) : "") . (lr ? "`n`nERROR2:`t" . sError2 . "`t(" . nError2 . ")" : "") . "`n`nWill Continue?"
IfMsgBox, No, Exit
}
COM_CreateIDispatch()
{
Static	IDispatch
If Not	VarSetCapacity(IDispatch)
{
VarSetCapacity(IDispatch,28,0),   nParams=3112469
Loop,   Parse,   nParams
NumPut(RegisterCallback("COM_DispInterface","",A_LoopField,A_Index-1),IDispatch,4*(A_Index-1))
}
Return &IDispatch
}
COM_GetDefaultInterface(pdisp)
{
DllCall(NumGet(NumGet(1*pdisp) +12), "Uint", pdisp , "UintP", ctinf)
If	ctinf
{
DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", 1024, "UintP", ptinf)
DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
DllCall(NumGet(NumGet(1*pdisp)+ 0), "Uint", pdisp, "Uint" , pattr, "UintP", ppv)
DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
If	ppv
DllCall(NumGet(NumGet(1*pdisp)+ 8), "Uint", pdisp),	pdisp := ppv
}
Return	pdisp
}
COM_GetDefaultEvents(pdisp)
{
DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", 1024, "UintP", ptinf)
DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
VarSetCapacity(IID,16), DllCall("RtlMoveMemory", "Uint", &IID, "Uint", pattr, "Uint", 16)
DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
Loop, %	DllCall(NumGet(NumGet(1*ptlib)+12), "Uint", ptlib)
{
DllCall(NumGet(NumGet(1*ptlib)+20), "Uint", ptlib, "Uint", A_Index-1, "UintP", TKind)
If	TKind <> 5
Continue
DllCall(NumGet(NumGet(1*ptlib)+16), "Uint", ptlib, "Uint", A_Index-1, "UintP", ptinf)
DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
nCount:=NumGet(pattr+48,0,"Ushort")
DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
Loop, %	nCount
{
DllCall(NumGet(NumGet(1*ptinf)+36), "Uint", ptinf, "Uint", A_Index-1, "UintP", nFlags)
If	!(nFlags & 1)
Continue
DllCall(NumGet(NumGet(1*ptinf)+32), "Uint", ptinf, "Uint", A_Index-1, "UintP", hRefType)
DllCall(NumGet(NumGet(1*ptinf)+56), "Uint", ptinf, "Uint", hRefType , "UintP", prinf)
DllCall(NumGet(NumGet(1*prinf)+12), "Uint", prinf, "UintP", pattr)
nFlags & 2 ? DIID:=COM_String4GUID(pattr) : bFind:=COM_IsEqualGUID(pattr,&IID)
DllCall(NumGet(NumGet(1*prinf)+76), "Uint", prinf, "Uint" , pattr)
DllCall(NumGet(NumGet(1*prinf)+ 8), "Uint", prinf)
}
DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
If	bFind
Break
}
DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
Return	bFind ? DIID : "{00000000-0000-0000-0000-000000000000}"
}
COM_GetGuidOfName(pdisp, Name)
{
DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", 1024, "UintP", ptinf)
DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf:=0
DllCall(NumGet(NumGet(1*ptlib)+44), "Uint", ptlib, "Uint", COM_SysString(Name,Name), "Uint", 0, "UintP", ptinf, "UintP", memID, "UshortP", 1)
DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
GUID := COM_String4GUID(pattr)
DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
Return	GUID
}
COM_GetTypeInfoOfGuid(pdisp, GUID)
{
DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", 1024, "UintP", ptinf)
DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf := 0
DllCall(NumGet(NumGet(1*ptlib)+24), "Uint", ptlib, "Uint", COM_GUID4String(GUID,GUID), "UintP", ptinf)
DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
Return	ptinf
}
COM_ConnectObject(psource, prefix = "", DIID = "")
{
If Not	DIID
0+(pconn:=COM_FindConnectionPoint(psource,"{00020400-0000-0000-C000-000000000046}")) ? (DIID:=COM_GetConnectionInterface(pconn))="{00020400-0000-0000-C000-000000000046}" ? DIID:=COM_GetDefaultEvents(psource) : "" : pconn:=COM_FindConnectionPoint(psource,DIID:=COM_GetDefaultEvents(psource))
Else	pconn:=COM_FindConnectionPoint(psource,SubStr(DIID,1,1)="{" ? DIID : DIID:=COM_GetGuidOfName(psource,DIID))
If	!pconn || !ptinf:=COM_GetTypeInfoOfGuid(psource,DIID)
{
MsgBox, No Event Interface Exists!
Return
}
psink:=COM_CoTaskMemAlloc(40+StrLen(prefix)+1), NumPut(1,NumPut(COM_CreateIDispatch(),psink+0)), NumPut(psource,NumPut(ptinf,psink+8))
DllCall("RtlMoveMemory", "Uint", psink+24, "Uint", COM_GUID4String(DIID,DIID), "Uint", 16)
DllCall("RtlMoveMemory", "Uint", psink+40, "Uint", &prefix, "Uint", StrLen(prefix)+1)
NumPut(COM_Advise(pconn,psink),NumPut(pconn,psink+16))
Return	psink
}
COM_DisconnectObject(psink)
{
Return	COM_Unadvise(NumGet(psink+16),NumGet(psink+20))=0 ? (0,COM_Release(NumGet(psink+16)),COM_Release(NumGet(psink+8)),COM_CoTaskMemFree(psink)) : 1
}
COM_CreateObject(CLSID, IID = "", CLSCTX = 5)
{
DllCall("ole32\CoCreateInstance", "Uint", SubStr(CLSID,1,1)="{" ? COM_GUID4String(CLSID,CLSID) : COM_CLSID4ProgID(CLSID,CLSID), "Uint", 0, "Uint", CLSCTX, "Uint", COM_GUID4String(IID,IID ? IID : IID=0 ? "{00000000-0000-0000-C000-000000000046}" : "{00020400-0000-0000-C000-000000000046}"), "UintP", ppv)
Return	ppv
}
COM_ActiveXObject(ProgID)
{
DllCall("ole32\CoCreateInstance", "Uint", SubStr(ProgID,1,1)="{" ? COM_GUID4String(ProgID,ProgID) : COM_CLSID4ProgID(ProgID,ProgID), "Uint", 0, "Uint", 5, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
Return	COM_GetDefaultInterface(pdisp)
}
COM_GetObject(Moniker)
{
DllCall("ole32\CoGetObject", "Uint", COM_SysString(Moniker,Moniker), "Uint", 0, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
Return	COM_GetDefaultInterface(pdisp)
}
COM_GetActiveObject(ProgID)
{
DllCall("oleaut32\GetActiveObject", "Uint", SubStr(ProgID,1,1)="{" ? COM_GUID4String(ProgID,ProgID) : COM_CLSID4ProgID(ProgID,ProgID), "Uint", 0, "UintP", punk)
DllCall(NumGet(NumGet(1*punk)+0), "Uint", punk, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)
DllCall(NumGet(NumGet(1*punk)+8), "Uint", punk)
Return	COM_GetDefaultInterface(pdisp)
}
COM_CLSID4ProgID(ByRef CLSID, ProgID)
{
VarSetCapacity(CLSID, 16)
DllCall("ole32\CLSIDFromProgID", "Uint", COM_SysString(ProgID,ProgID), "Uint", &CLSID)
Return	&CLSID
}
COM_GUID4String(ByRef CLSID, String)
{
VarSetCapacity(CLSID, 16)
DllCall("ole32\CLSIDFromString", "Uint", COM_SysString(String,String), "Uint", &CLSID)
Return	&CLSID
}
COM_ProgID4CLSID(pCLSID)
{
DllCall("ole32\ProgIDFromCLSID", "Uint", pCLSID, "UintP", pProgID)
Return	COM_Ansi4Unicode(pProgID) . COM_CoTaskMemFree(pProgID)
}
COM_String4GUID(pGUID)
{
VarSetCapacity(String, 38 * 2 + 1)
DllCall("ole32\StringFromGUID2", "Uint", pGUID, "Uint", &String, "int", 39)
Return	COM_Ansi4Unicode(&String, 38)
}
COM_IsEqualGUID(pGUID1, pGUID2)
{
Return	DllCall("ole32\IsEqualGUID", "Uint", pGUID1, "Uint", pGUID2)
}
COM_CoCreateGuid()
{
VarSetCapacity(GUID, 16, 0)
DllCall("ole32\CoCreateGuid", "Uint", &GUID)
Return	COM_String4GUID(&GUID)
}
COM_CoTaskMemAlloc(cb)
{
Return	DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
}
COM_CoTaskMemFree(pv)
{
DllCall("ole32\CoTaskMemFree", "Uint", pv)
}
COM_CoInitialize()
{
Return	DllCall("ole32\CoInitialize", "Uint", 0)
}
COM_CoUninitialize()
{
DllCall("ole32\CoUninitialize")
}
COM_SysAllocString(astr)
{
Return	DllCall("oleaut32\SysAllocString", "Uint", COM_SysString(astr,astr))
}
COM_SysFreeString(bstr)
{
DllCall("oleaut32\SysFreeString", "Uint", bstr)
}
COM_SysStringLen(bstr)
{
Return	DllCall("oleaut32\SysStringLen", "Uint", bstr)
}
COM_SafeArrayDestroy(psar)
{
Return	DllCall("oleaut32\SafeArrayDestroy", "Uint", psar)
}
COM_VariantClear(pvar)
{
DllCall("oleaut32\VariantClear", "Uint", pvar)
}
COM_VariantChangeType(pvarDst, pvarSrc, vt = 8)
{
Return	DllCall("oleaut32\VariantChangeTypeEx", "Uint", pvarDst, "Uint", pvarSrc, "Uint", 1024, "Ushort", 0, "Ushort", vt)
}
COM_SysString(ByRef wString, sString)
{
VarSetCapacity(wString,3+2*nLen:=1+StrLen(sString))
Return	NumPut(DllCall("kernel32\MultiByteToWideChar","Uint",0,"Uint",0,"Uint",&sString,"int",nLen,"Uint",&wString+4,"int",nLen,"Uint")*2-2,wString)
}
COM_AccInit()
{
COM_Init()
If Not	DllCall("GetModuleHandle", "str", "oleacc")
Return	DllCall("LoadLibrary", "str", "oleacc")
}
COM_AccTerm()
{
COM_Term()
If h:=	DllCall("GetModuleHandle", "str", "oleacc")
Return	DllCall("FreeLibrary", "Uint", h)
}
COM_AccessibleChildren(pacc, cChildren, ByRef varChildren)
{
VarSetCapacity(varChildren,cChildren*16,0)
If	DllCall("oleacc\AccessibleChildren", "Uint", pacc, "Uint", 0, "Uint", cChildren+0, "Uint", &varChildren, "UintP", cChildren:=0)=0
Return	cChildren
}
COM_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_="")
{
VarSetCapacity(varChild,16,0)
If	DllCall("oleacc\AccessibleObjectFromEvent", "Uint", hWnd, "Uint", idObject, "Uint", idChild, "UintP", pacc, "Uint", &varChild)=0
Return	pacc, _idChild_:=NumGet(varChild,8)
}
COM_AccessibleObjectFromPoint(x, y, ByRef _idChild_="")
{
VarSetCapacity(varChild,16,0)
If	DllCall("oleacc\AccessibleObjectFromPoint", "int", x, "int", y, "UintP", pacc, "Uint", &varChild)=0
Return	pacc, _idChild_:=NumGet(varChild,8)
}
COM_AccessibleObjectFromWindow(hWnd, idObject=-4, IID = "")
{
If	DllCall("oleacc\AccessibleObjectFromWindow", "Uint", hWnd, "Uint", idObject, "Uint", COM_GUID4String(IID, IID ? IID : idObject&0xFFFFFFFF==0xFFFFFFF0 ? "{00020400-0000-0000-C000-000000000046}":"{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pacc)=0
Return	pacc
}
COM_WindowFromAccessibleObject(pacc)
{
If	DllCall("oleacc\WindowFromAccessibleObject", "Uint", pacc, "UintP", hWnd)=0
Return	hWnd
}
COM_GetRoleText(nRole)
{
nSize:=	DllCall("oleacc\GetRoleTextA", "Uint", nRole, "Uint", 0, "Uint", 0)
VarSetCapacity(sRole,nSize)
If	DllCall("oleacc\GetRoleTextA", "Uint", nRole, "str", sRole, "Uint", nSize+1)
Return	sRole
}
COM_GetStateText(nState)
{
nSize:=	DllCall("oleacc\GetStateTextA", "Uint", nState, "Uint", 0, "Uint", 0)
VarSetCapacity(sState,nSize)
If	DllCall("oleacc\GetStateTextA", "Uint", nState, "str", sState, "Uint", nSize+1)
Return	sState
}
COM_AtlAxWinInit(Version = "")
{
COM_Init()
If Not	DllCall("GetModuleHandle", "str", "atl" . Version)
DllCall("LoadLibrary", "str", "atl" . Version)
Return	DllCall("atl" . Version . "\AtlAxWinInit")
}
COM_AtlAxWinTerm(Version = "")
{
COM_Term()
If h:=	DllCall("GetModuleHandle", "str", "atl" . Version)
Return	DllCall("FreeLibrary", "Uint", h)
}
COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
{
Return	DllCall("atl" . Version . "\AtlAxAttachControl", "Uint", punk:=COM_QueryInterface(pdsp,0), "Uint", hWnd, "Uint", 0), COM_Release(punk)
}
COM_AtlAxCreateControl(hWnd, Name, Version = "")
{
If	DllCall("atl" . Version . "\AtlAxCreateControl", "Uint", COM_SysString(Name,Name), "Uint", hWnd, "Uint", 0, "Uint", 0)=0
Return	COM_AtlAxGetControl(hWnd, Version)
}
COM_AtlAxGetControl(hWnd, Version = "")
{
If	DllCall("atl" . Version . "\AtlAxGetControl", "Uint", hWnd, "UintP", punk)=0
pdsp:=COM_QueryInterface(punk), COM_Release(punk)
Return	pdsp
}
COM_AtlAxGetHost(hWnd, Version = "")
{
If	DllCall("atl" . Version . "\AtlAxGetHost", "Uint", hWnd, "UintP", punk)=0
pdsp:=COM_QueryInterface(punk), COM_Release(punk)
Return	pdsp
}
COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
{
Return	DllCall("CreateWindowEx", "Uint",0x200, "str", "AtlAxWin" . Version, "Uint", Name ? &Name : 0, "Uint", 0x54000000, "int", l, "int", t, "int", w, "int", h, "Uint", hWnd, "Uint", 0, "Uint", 0, "Uint", 0)
}
COM_AtlAxGetContainer(pdsp, bCtrl = "")
{
DllCall(NumGet(NumGet(1*pdsp)+ 0), "Uint", pdsp, "Uint", COM_GUID4String(IID_IOleWindow,"{00000114-0000-0000-C000-000000000046}"), "UintP", pwin)
DllCall(NumGet(NumGet(1*pwin)+12), "Uint", pwin, "UintP", hCtrl)
DllCall(NumGet(NumGet(1*pwin)+ 8), "Uint", pwin)
Return	bCtrl ? hCtrl : DllCall("GetParent", "Uint", hCtrl)
}
COM_Ansi4Unicode(pString, nSize = "")
{
If (nSize = "")
nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
VarSetCapacity(sString, nSize)
DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
Return	sString
}
COM_Unicode4Ansi(ByRef wString, sString, nSize = "")
{COM_AtlAxWinInit()
If (nSize = "")
nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
VarSetCapacity(wString, nSize * 2 + 1)
DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
Return	&wString
}
COM_Ansi2Unicode(ByRef sString, ByRef wString, nSize = "")
{
If (nSize = "")
nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
VarSetCapacity(wString, nSize * 2 + 1)
DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
Return	&wString
}
COM_Unicode2Ansi(ByRef wString, ByRef sString, nSize = "")
{
pString := wString + 0 > 65535 ? wString : &wString
If (nSize = "")
nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
VarSetCapacity(sString, nSize)
DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
Return	&sString
}
COM_ScriptControl(sCode, sLang = "", bEval = False, sFunc = "", sName = "", pdisp = 0, bGlobal = False)
{
COM_Init()
psc  :=	COM_CreateObject("MSScriptControl.ScriptControl")
COM_Invoke(psc, "Language", sLang ? sLang : "VBScript")
sName ?	COM_Invoke(psc, "AddObject", sName, "+" . pdisp, bGlobal) : ""
sFunc ?	COM_Invoke(psc, "AddCode", sCode) : ""
ret  :=	COM_Invoke(psc, bEval ? "Eval" : "ExecuteStatement", sFunc ? sFunc : sCode)
COM_Release(psc)
COM_Term()
Return	ret
}