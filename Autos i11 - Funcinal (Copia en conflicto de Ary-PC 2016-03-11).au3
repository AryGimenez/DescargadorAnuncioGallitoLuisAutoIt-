
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <String.au3>
#include <IE.au3>
#include <GuiComboBox.au3>
#Include <Date.au3>


#Region ### START Precedimentos internos ### Form=form1.kxf

    $mPag_PagInicio = 0
	$SubIE = 0
	$mString_HtmlInicio = 0
	$html_Format = 0

	recargarPInicio()

	$mCanTotalArticulos = 0 ; Cantidad de articulos de la pagina
	$mCanTotalPaginas = 0; La cantidad de paginas que tiene que abrir para optener los anuncion
	$mPagActual = 1;
	$mCanAnun_X_Pagina = 0; Cantidad de anuncios por pagina
	$mCanPagSelec = 1; Cantidad de paginas seleccionadas a descargar
	$mCanAnunSelec = 0; Ctidad de anuncios a descargar
	$mFileOrigen = ""
	$mFileDestino = ""
	setCanPage ()
	$mCanAnunSelec = $mCanAnun_X_Pagina


	Func recargarPInicio()
		$mPag_PagInicio =  _IECreate("http://www.gallito.com.uy/autos/automoviles",0,0)
		$SubIE ="";
		$mString_HtmlInicio =  _IEDocReadHTML($mPag_PagInicio);Inicia el Componente
		_IELoadWait ($mPag_PagInicio)
		$html_Format = _IEFormGetCollection ($mPag_PagInicio, 0)
	EndFunc

	Func Tempo ($segundo)
		$Llave = true;
		For $i = $segundo to 0 step - 1

			Sleep(1000)

		next
	EndFunc

   Func clik ($pI)
	  $id = _StringBetween($mString_HtmlInicio,'<a id','Siguiente&nbsp;</A>')

;~ 			FileWriteLine(@ScriptDir &"\temp2.html", $id[0] )

	  If UBound ($id) > 0 Then
		 $id = _StringBetween($id[0],'<a id','>')
		 $id = StringRegExp($id[UBound($id)-1],'=(.*?) href' ,1)
		 $id = StringReplace($id[0], '"','')

;~ 				MsgBox(1,"",$id[0])

		 $html_Format = _IEFormGetCollection ($mPag_PagInicio, 0)
		 $LinkSigiente = _IEGetObjById($html_Format,$id)
		 _IEAction($LinkSigiente, "click")
	  Else
		 $pI = $mCanPagSelec
		 MsgBox(1,"FinIn","")
	  EndIf
   EndFunc

	Func _StringTrimLeft($pString)
		Local  $xSubString = "";

		for $i = 1 to StringLen($pString) Step 1
			$xSubString = StringLeft($pString,$i)
			if StringIsSpace($xSubString) == 0 Then
				Return StringTrimLeft($pString,$i - 1)
			EndIf
		Next
		return $pString
	EndFunc

	Func _StringTrimRight($pString)
		Local  $xSubString = "";

		for $i = 1 to StringLen($pString) Step 1
			$xSubString = StringRight($pString,$i)
			if StringIsSpace($xSubString) == 0 Then
				Return StringTrimRight($pString,$i - 1)
			EndIf
		Next
		return $pString
	EndFunc

	Func _StringTrim($pString)
		$pString = _StringTrimLeft($pString)
		$pString = _StringTrimRight($pString)
		Return $pString
	EndFunc

	FUNC setCanPage ()
;~ 		FileWriteLine(@ScriptDir &"\Tem.html",$mString_HtmlInicio)

		Local $xSubHTML = _StringBetween($mString_HtmlInicio,'Pag:', 'avisos</a>')

		$xSubHTML = StringReplace ($xSubHTML[0], "de", "")
		$xSubHTML = StringReplace ($xSubHTML, "|", "")

		$xSubHTML = StringRegExp($xSubHTML," (.*?) ",3)

		$mCanTotalArticulos = Int ($xSubHTML[2])
		$mCanTotalPaginas = Int ($xSubHTML[1])
		$mPagActual = Int ($xSubHTML[0])



		$mCanAnun_X_Pagina = Round($mCanTotalArticulos/$mCanTotalPaginas)

	EndFunc

	;Me retorna una cadena con el formato adecuado para el combo box en la cual posee nuemors correlativos del 1 a xCant
	Func getItemComB ($xCant)
		Local $xSepara = "" ;Separador
		Local $xRespuesta = ""

		For $i = 1 to $xCant Step 1
			$xRespuesta = $xRespuesta & $xSepara & $i
			$xSepara = "|"

		Next

		Return $xRespuesta
	EndFunc

	;Comando que carga los topes de que pagina asta que pagina ba a optener los datos
	Func calRanPagina ($pComB_Asta, $pLbl_Anuncios, $pLbl_ProgPag)
		Local  $xResto = 0;

		$mCanPagSelec = _GUICtrlComboBox_GetCurSel($pComB_Asta) + 1

		If $mCanPagSelec = $mCanTotalPaginas Then
			$xResto = Mod ($mCanTotalArticulos,$mCanAnun_X_Pagina)
			if $xResto <> 0 Then
				$xResto = $mCanAnun_X_Pagina - $xResto;
			EndIf

		EndIf

		$mCanAnunSelec = $mCanPagSelec * $mCanAnun_X_Pagina - $xResto

		GUICtrlSetData($pLbl_Anuncios, $mCanAnunSelec)
		GUICtrlSetData($pLbl_ProgPag, "1 / " & $mCanPagSelec)
	EndFunc

	Func IniciarProceso ($pPrB_Descarga, $pPrB_Pros, $pLbl_Destino, $pComB_Asta, $pLbl_Anuncios, $pLbl_ProgPag, $pInicio)
		Local $xPors, $xPors2, $i, $i2, $array, $arrayHtml, $id = "";
		$i = $pInicio;
		if StringCompare($mFileDestino, "") == 0 Then
			setDestino ($pLbl_Destino)
			if StringCompare($mFileDestino, "") == 0 Then
				MsgBox(0,"Error","Debe ingresar un destino para los anuncios")
				Return
			EndIf
		EndIf

		setCanPage()
		calRanPagina($pComB_Asta,$pLbl_Anuncios, $pLbl_ProgPag)

		FileDelete($mFileDestino)


;~       FileWriteLine(@ScriptDir &"\temp.html",$mString_HtmlInicio)

		FileDelete(@ScriptDir &"\Registro_" & StringReplace( _nowdate(),'/', '-') & ".txt")
		FileWriteLine(@ScriptDir &"\Registro_" & StringReplace( _nowdate(),'/', '-') & ".txt","Paginas seleccionadas = <" & $mCanPagSelec & ">")

		$xPors =  100 / $mCanPagSelec

		for $i = $pInicio to $mCanPagSelec Step 1

			GUICtrlSetData($pLbl_ProgPag, $i & " / " & $mCanPagSelec)

			FileWriteLine(@ScriptDir &"\Registro_" & StringReplace( _nowdate(),'/', '-') & ".txt","----------------------Linea = " & $i &" -------------------------------------------")
			FileWriteLine($mFileDestino,"----------------------Linea = " & $i &" -------------------------------------------")


;~ 			FileWriteLine(@ScriptDir &"\temp1.html",$mString_HtmlInicio)

 			;Elimina los salto de liena
			$mString_HtmlInicio = StringReplace($mString_HtmlInicio, "" & chr(10), " ");

			$mString_HtmlInicio = StringReplace($mString_HtmlInicio, "" & chr(13), " ");

;~ 			FileWriteLine(@ScriptDir &"\temp.html",$mString_HtmlInicio)


			$array = _StringBetween($mString_HtmlInicio,'<div id="grillaavisos">', '<div class="cierre">') ;; Para I11



;~ 			FileWriteLine(@ScriptDir &"\temp.html",$array[0])

;~ 			MsgBox(1,"Ary", UBound($array))



			; Optiene la secion de codigo donde esta la informacion de los autos
				$array2 = _StringBetween($array[0],'<a onclick','</a>') ;; Para I10

				If UBound ($array2) = 0 Then
					$array2 = _StringBetween($array[0],'<a style="text-decoration: none;" onclick','</a>') ;; Para I9
				EndIf

				$array = $array2
			;;;;;;;;;;;;

;~ 			FileWriteLine(@ScriptDir &"\temp3.html",$array[0])     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			clik($i)

			$xPors2 =  100 /  UBound($array)
			$SubIE = _IECreate("http://www.google.com.uy/",0,0)

			for $i2 = 0 to UBound($array) -1 Step 1



				;Captura el telefono
					$arrayTem = _StringBetween($array[$i2],'<SPAN class=thumb_telefono>', '</span>')  ;; Para I10

					If UBound ($arrayTem) = 0 Then
						$arrayTem = _StringBetween($array[$i2],'<SPAN class="thumb_telefono">', '</span>') ;; Para I9
					EndIf

				;;;;;;;;;;;;

			   IF UBound($arrayTem) > 0 Then
				  $StringTelefono = " Tel: " & $arrayTem[0]
				  $StringUbicacion = ""
				  $StringDatos = ""
				  $StringText = ""

;~ 				  fin optengo variable



				;Captura el Precio
					$arrayTem = _StringBetween ($array[$i2],'_precio>','</span>')  ;; Para I10

					If UBound ($arrayTem) = 0 Then
						$arrayTem = _StringBetween ($array[$i2],'_precio">','</span><') ;; Para I9
					 EndIf

					 If UBound ($arrayTem) <> 0 Then
						$StringPrecio = " Precio: " & StringRegExpReplace($arrayTem[0],"<(.*?)>","")
					 Else
						$StringPrecio = " Precio: --- "
					 EndIf

				;;;;;;;;;;;;


				;Captura el Titulo
					$arrayTem = _StringBetween($array[$i2],'<span class=thumb_titulo>', '</span>') ;; Para I10

					If UBound ($arrayTem) = 0 Then
						$arrayTem = _StringBetween($array[$i2],'<span class="thumb_titulo">', '</span>')  ;; Para I9
					EndIf

					$StringTitulo = $arrayTem[0]
				;;;;;;;;;;;;


				;Captura Ubicacion
					$arrayTem = _StringBetween($array[$i2],'<span class=thumb_ubicacion>', '</span>') ;; Para I10

					If UBound ($arrayTem) = 0 Then
						$arrayTem = _StringBetween($array[$i2],'<span class="thumb_ubicacion">', '</span>')   ;; Para I9
					EndIf

					IF UBound ($arrayTem) > 0 Then
						$StringUbicacion = " Ubicación: " & $arrayTem[0]
					EndIf

				;;;;;;;;;;;;


				;Captura Texto
					$arrayTem = _StringBetween($array[$i2], '_txt>', '</span>');; Para I10

					If UBound ($arrayTem) = 0 Then
						$arrayTem = _StringBetween($array[$i2], '_txt">', '</span>')  ;; Para I9
					EndIf

					IF UBound ($arrayTem) > 0 Then
						$StringText = " " & $arrayTem[0]
					EndIf

				;;;;;;;;;;;;

				;Datos Datos
					 $arrayTem = _StringBetween($array[$i2],'_datos>', '</span>')  ;; Para I10

					If UBound ($arrayTem) = 0 Then
						$arrayTem = _StringBetween($array[$i2],'_datos"">', '</span>')  ;; Para I9
					EndIf

					IF UBound ($arrayTem) > 0 Then
						$StringDatos = " " & $arrayTem[0]
					EndIf

				;;;;;;;;;;;;

			      FileWriteLine($mFileDestino, $StringTitulo & $StringDatos & $StringText & $StringPrecio & $StringUbicacion & $StringTelefono )

				  Sleep(900)
			   else
				  FileWriteLine($mFileDestino,"<-------------------------")
				  Sleep(900)
			   EndIf

			   GUICtrlSetData($pPrB_Pros, Round($xPors2 * $i2))
			Next
			Sleep(5000)
			_IEQuit($SubIE)

			GUICtrlSetData($pPrB_Pros, 0)
			GUICtrlSetData($pPrB_Descarga, Round($xPors * $i))

			$mString_HtmlInicio =  _IEDocReadHTML($mPag_PagInicio);Inicia el Componente
		Next

	    recargarPInicio()

		setCanPage ()

		GUICtrlSetData($pPrB_Descarga, 0)

	EndFunc

	Func prosURL($pURL)
;~
		Local $SubHTML, $array, $SubS_Telefono = "", $SugS_Ubicacion = "" , $SubS_Precio= "", $SubS_Veiculo = "", $SubString, $i;
		Sleep(500)
		IF _IENavigate($SubIE,$pURL) = $_IEStatus_LoadWaitTimeout Then
			Sleep(10000)
			_IEQuit($SubIE)
			$SubIE = _IECreate("http://www.google.com.uy/",0,0)
		EndIf

		$SubHTML = _IEDocReadHTML($SubIE);Inicia el Componente

		$array = _StringBetween($SubHTML, '<div id="ficha_cabezal">', '</span> </div>')

		if UBound($array) = 0 Then
			FileWriteLine(@ScriptDir &"\Error_" & StringReplace( _nowdate(),'/', '-') & ".txt",$pURL )
			return ""
		EndIf

		$SubString = $array[0]
		$SubString = $SubString & '</span>'

		$array = StringRegExp($SubString,'<span id="ficha_titulo">(.*?)</span>',1)

		if UBound($array) > 0 Then $SubS_Veiculo = $array[0]


		$array = _StringBetween($SubString, '<span id="ficha_precio">', '</span>')
		if UBound($array) > 0 Then $SubS_Precio = StringReplace ($array[0]," ","")


		$array = _StringBetween($SubString, '<span id="ficha_ubicacion">', '</span>')
		if UBound($array) > 0 Then $SugS_Ubicacion = $array[0]


		$array = _StringBetween($SubString, '<span id="ficha_telefono">', '</span>')
		if UBound($array) > 0 Then
			$SubS_Telefono = $array[0]
			if StringCompare($SubS_Telefono, "-") = 0 Then

				$SubS_Telefono = _StringBetween($SubHTML, '<div id="ficha_texto">', '</h1></div>')
				$SubS_Telefono = $SubS_Telefono[0]
				$SubS_Telefono = StringRegExpReplace($SubS_Telefono,"<(.*?)>","")

				$xPos = StringInStr($SubS_Telefono, "Tel:") - 1

				if $xPos = 0 Then
					$xPos = StringInStr($SubS_Telefono, "Tel.") - 1

					if $xPos = 0 Then return ""
				EndIf



				$SubS_Telefono = StringTrimLeft($SubS_Telefono,$xPos)

				$xarrayString = StringSplit($SubS_Telefono, "")
				$SubS_Telefono = "Tel:"

				for $i = 1 To UBound($xarrayString) - 1 Step 1



					if StringCompare($xarrayString[$i], " ") = 0 Then

						$SubS_Telefono = $SubS_Telefono & " "
					ElseIf StringIsInt($xarrayString[$i]) = 1 Then

						$SubS_Telefono = $SubS_Telefono & $xarrayString[$i]
					EndIf
				Next

				$SubS_Telefono = $SubS_Telefono & " <-----------------------------"
			EndIf
		EndIf

		return $SubS_Veiculo & " " & $SubS_Precio & " " & $SugS_Ubicacion & " " & $SubS_Telefono


	EndFunc

	Func setDestino ($pLbl_Destino)
		$mFileDestino = FileSaveDialog("Destino", @ScriptDir, "Texto (*.Txt)", 16)
		If StringCompare($mFileDestino, "") = 1 and StringRight($mFileDestino, 4) <> ".Txt" Then $mFileDestino = $mFileDestino & ".Txt"
		GUICtrlSetData($pLbl_Destino, $mFileDestino)

	EndFunc

	Func setOrigen ($pLbl_Origen)
		$mFileOrigen = FileOpenDialog("Origen", @ScriptDir, "Texto (*.Txt)", 16)
		If StringCompare($mFileOrigen, "") = 1 and StringRight($mFileOrigen, 4) <> ".Txt" Then $mFileOrigen = $mFileOrigen & ".Txt"
		GUICtrlSetData($pLbl_Origen, $mFileOrigen)

	EndFunc

	Func _Salir ()
		_IEQuit($mPag_PagInicio)
		Exit
	EndFunc

	Func importarOrigen ($Lbl_Importar, $pPrB_Descarga, $pPrB_Pros, $pLbl_Destino, $pComB_Asta, $pLbl_Anuncios, $pLbl_ProgPag)
		Local $xCanPSel, $xSubString, $mStringOrigen = "", $xInicio, $i, $xSalir = 0, $xId, $xPors, $xCon = 1


	  if StringCompare($mFileOrigen, "") == 0 Then
		 setOrigen ($Lbl_Importar)
		 if StringCompare($mFileOrigen, "") == 0 Then
			MsgBox(0,"Error","Debe seleccionar un origen de registro")
			   Return
			EndIf
	  EndIf

	  $mStringOrigen = FileRead($mFileOrigen,FileGetSize($mFileOrigen))
	  $xCanPSel = StringRegExp($mStringOrigen,"<(.*?)>",1);


	  if UBound($xCanPSel) == 0 Then
		 MsgBox(0,"Error","No ha seleccionado un archivo valido")
		 Return
	  EndIf


	  $xCanPSel = $xCanPSel[0];


	  if StringIsAlNum($xCanPSel) = False Then
		 MsgBox(0,"Error","No ha seleccionado un archivo valido")
		 Return ""
	  EndIf

	  if StringCompare($mFileDestino, "") == 0 Then
		 setDestino ($pLbl_Destino)
		 if StringCompare($mFileDestino, "") == 0 Then
			MsgBox(0,"Error","Debe ingresar un destino para los anuncios")
			Return
		 EndIf
	  EndIf

	  FileDelete($mFileDestino)

	  recargarPInicio()
	  setCanPage()

	  _GUICtrlComboBox_SetCurSel ($pComB_Asta, Int($xCanPSel) -1)
	  calRanPagina($pComB_Asta,$pLbl_Anuncios, $pLbl_ProgPag)
	  $xInicio = StringRegExp ($mStringOrigen,"Linea = (.*?) -",3)


	  $mStringOrigen = ""
	  $xInicio = Int($xInicio[UBound($xInicio) -1])

	  $xPors =  100 / $xCanPSel

	  While $xSalir <= 0

		 GUICtrlSetData($pLbl_ProgPag, $xCon & " / " & $mCanPagSelec)

		 clik($i)
		 Tempo(10)

		 $mString_HtmlInicio =  _IEDocReadHTML($mPag_PagInicio);Inicia el Componente

		 IF StringInStr($mString_HtmlInicio, "Pag: "&$xInicio&" de") > 0 Then $xSalir = 20

		 FileWriteLine(@ScriptDir &"\temp" & $xCon &".html",$mString_HtmlInicio)

		 GUICtrlSetData($pPrB_Descarga, Round($xPors * $xCon))
		 if $xInicio <> $xCon THEN $xCon = $xCon + 1

	  WEnd

	  clik($i)
	  Tempo(20)

	  $mString_HtmlInicio =  _IEDocReadHTML($mPag_PagInicio);Inicia el Componente

	  IniciarProceso ($pPrB_Descarga, $pPrB_Pros, $pLbl_Destino, $pComB_Asta, $pLbl_Anuncios, $pLbl_ProgPag, $xInicio)
	EndFunc
#EndRegion ### END Precedimentos internos ###

#Region ### START Koda GUI section ### Form=C:\Users\Ary\Dropbox\Compartido con HELP\Gallito luis\Form1.kxf
$Form1_1 = GUICreate("Gallito luis Autos", 836, 254, 191, 127)
GUISetIcon(@ScriptDir & "\IM\Cabriolet.ico", -1)
$PrB_Descarga = GUICtrlCreateProgress(16, 117, 807, 17)
$Group1 = GUICtrlCreateGroup("Origen", 128, 13, 321, 73)
$Label3 = GUICtrlCreateLabel("Cantidad", 144, 37, 54, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$Lbl_CanP = GUICtrlCreateLabel($mCanTotalPaginas, 144, 53, 54, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xFFFFE1)
$Group3 = GUICtrlCreateGroup("", 208, 21, 233, 57)
$Btn_Cargar = GUICtrlCreateButton("", 400, 28, 40, 49, $BS_ICON)
GUICtrlSetImage(-1, @ScriptDir & "\IM\button-synchronize.ico", -1)
$Label5 = GUICtrlCreateLabel("Anuncios", 344, 33, 56, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$Lbl_Anuncios = GUICtrlCreateLabel($mCanAnunSelec, 344, 53, 56, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xFFFFE1)
$Label1 = GUICtrlCreateLabel("Paginas", 218, 33, 112, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$ComB_Asta = GUICtrlCreateCombo("", 216, 53, 113, 25, BitOR($GUI_SS_DEFAULT_COMBO,$CBS_SIMPLE))
GUICtrlSetData(-1, getItemComB($mCanTotalPaginas), "1")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Label7 = GUICtrlCreateLabel("Anuncios descargados", 16, 140, 807, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$PrB_Pros = GUICtrlCreateProgress(16, 165, 807, 17)
$Btn_Inicoi = GUICtrlCreateButton("Iniciar", 16, 189, 131, 49)
$Btn_Salir = GUICtrlCreateButton("Salir", 152, 189, 219, 49)
$Pic1 = GUICtrlCreatePic(@ScriptDir & "\IM\GL.jpg", 24, 13, 92, 68)
$Group2 = GUICtrlCreateGroup("Destino", 456, 13, 369, 73)
$Label12 = GUICtrlCreateLabel("Anuncios", 464, 37, 344, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$Lbl_Destino = GUICtrlCreateLabel("", 464, 55, 320, 25)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xFFFFE1)
$Btn_Destino = GUICtrlCreateButton("...", 784, 55, 27, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Label2 = GUICtrlCreateLabel("Creado por: Ary Gimenezx                                                                                                    Cel: 098559058   Mail: argi_prog@hotmail.com", 1, 237, 839, 33)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0xC0C0C0)
$Group4 = GUICtrlCreateGroup("", 373, 182, 442, 53)
$Label10 = GUICtrlCreateLabel("Anuncios", 375, 190, 397, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$Btn_Origen = GUICtrlCreateButton("...", 746, 208, 27, 25)
$Lbl_Importar = GUICtrlCreateLabel("", 375, 208, 368, 25)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xFFFFE1)
$Btn_Importar = GUICtrlCreateButton("", 776, 189, 35, 45, $BS_ICON)
GUICtrlSetImage(-1, @ScriptDir & "\IM\hard-drive-download.ico", -1)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Label8 = GUICtrlCreateLabel("Paginar rebisadas", 16, 94, 711, 17)
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$Lbl_ProgPag = GUICtrlCreateLabel("1 / " & $mPagActual, 731, 94, 90, 17, BitOR($SS_CENTER,$SS_CENTERIMAGE,$WS_BORDER))
GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetBkColor(-1, 0xFFFFE1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Salir()
		Case $Btn_Cargar
			calRanPagina($ComB_Asta, $Lbl_Anuncios, $Lbl_ProgPag)
		Case $Btn_Salir
			_Salir()
		Case $Btn_Inicoi
			GUICtrlSetState($Btn_Inicoi, $GUI_DISABLE)
			GUICtrlSetState($Btn_Importar, $GUI_DISABLE)
			IniciarProceso ($PrB_Descarga, $PrB_Pros, $Lbl_Destino, $ComB_Asta, $Lbl_Anuncios, $Lbl_ProgPag, 1)
			GUICtrlSetState($Btn_Inicoi, $GUI_ENABLE)
			GUICtrlSetState($Btn_Importar, $GUI_ENABLE)
		Case $Btn_Destino
			setDestino ($Lbl_Destino)
		Case $Btn_Origen
			setOrigen($Lbl_Importar)
		Case $Btn_Importar
			GUICtrlSetState($Btn_Inicoi, $GUI_DISABLE)
			GUICtrlSetState($Btn_Importar, $GUI_DISABLE)
			importarOrigen ($Lbl_Importar, $PrB_Descarga, $PrB_Pros, $Lbl_Destino, $ComB_Asta, $Lbl_Anuncios, $Lbl_ProgPag)
			GUICtrlSetState($Btn_Inicoi, $GUI_ENABLE)
			GUICtrlSetState($Btn_Importar, $GUI_ENABLE)
	EndSwitch
WEnd
