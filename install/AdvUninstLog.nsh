     ;_____________________________ HEADER FILE BEGIN ____________________________

     # Advanced Uninstall Log NSIS header
     # Version 1.0 2007-01-31
     # By Red Wine (http://nsis.sf.net/User:Red_Wine)
     
     # Usage: See included examples Uninstall_Log_Default_UI.nsi - Uninstall_Log_Modern_UI.nsi

!verbose push
   !verbose 3

!ifndef ADVANCED_UNINSTALL.LOG_NSH
   !define ADVANCED_UNINSTALL.LOG_NSH

!ifndef INSTDIR_REG_ROOT | INSTDIR_REG_KEY
   !error "You must properly define both INSTDIR_REG_ROOT and INSTDIR_REG_KEY"
!endif

!ifndef UNINSTALL_LOG
   !define UNINSTALL_LOG         "Uninstall"
!endif

!ifndef UNINST_LOG_VERBOSE
   !define UNINST_LOG_VERBOSE    "3"
!endif

!verbose pop

!echo "Advanced Uninstall Log NSIS header v1.0 2007-01-31 by Red Wine (http://nsis.sf.net/User:Red_Wine)"

!verbose push
   !verbose ${UNINST_LOG_VERBOSE}

!define UNINST_EXE     "$INSTDIR\${UNINSTALL_LOG}.exe"
!define UNINST_DAT     "$INSTDIR\${UNINSTALL_LOG}.dat"
!define UNLOG_PART     "$PLUGINSDIR\part."
!define UNLOG_TEMP     "$PLUGINSDIR\unlog.tmp"
!define EXCLU_LIST     "$PLUGINSDIR\exclude.tmp"
!define UNLOG_HEAD     "=========== Uninstaller Log please do not edit this file ==========="

 var unlog_tmp_0
 var unlog_tmp_1
 var unlog_tmp_2
 var unlog_tmp_3
 var unlog_error

!include FileFunc.nsh
!include TextFunc.nsh

!insertmacro Locate
!insertmacro un.Locate
!insertmacro DirState
!insertmacro un.DirState
!insertmacro FileJoin
!insertmacro TrimNewLines
!insertmacro un.TrimNewLines

;.............................. Uninstaller Macros ..............................

!macro UNINSTALL.LOG_BEGIN_UNINSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

        IfFileExists "${UNINST_DAT}" +3
        MessageBox MB_ICONSTOP|MB_OK "${UNINST_DAT} not found, unable to perform uninstall." /SD IDOK
        Quit

        StrCmp "$PLUGINSDIR" "" 0 +2
           InitPluginsDir

        CopyFiles "${UNINST_DAT}" "${UNLOG_TEMP}"
        FileOpen $unlog_tmp_2 "${UNLOG_TEMP}" r

  !verbose pop
!macroend


!macro UNINSTALL.LOG_END_UNINSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

        FileClose $unlog_tmp_2
        DeleteRegValue ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "${UNINSTALL_LOG}.dat"
        DeleteRegValue ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "${UNINSTALL_LOG}Directory"

  !verbose pop
!macroend


!macro UNINSTALL.LOG_UNINSTALL TargetDir
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

     !ifndef INTERACTIVE_UNINSTALL & UNATTENDED_UNINSTALL
        !error "You must insert either Interactive or Unattended Uninstall neither both, neither none."
     !endif

     !ifdef INTERACTIVE_UNINSTALL
        GetTempFileName $unlog_tmp_5 "$PLUGINSDIR"
        FileOpen $unlog_tmp_4 "$unlog_tmp_5" a
     !endif

        ${PerfomUninstall} "${TargetDir}" "${UnLog_Uninstall_CallBackFunc}"

     !ifdef INTERACTIVE_UNINSTALL
        FileClose $unlog_tmp_4
     !endif

  !verbose pop
!macroend


!define PerfomUninstall "!insertmacro PERFORMUNINSTALL"

!macro PERFORMUNINSTALL TargetDir UninstCallBackFunc
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

   !define ID ${__LINE__}

	${un.Locate} "${TargetDir}" "/L=F" "${UninstCallBackFunc}"

    loop_${ID}:

	StrCpy $unlog_tmp_1 0

	${un.Locate} "${TargetDir}" "/L=DE" "${UninstCallBackFunc}"
	StrCmp $unlog_tmp_1 "0" 0 loop_${ID}

        ${un.DirState} "${TargetDir}" $unlog_tmp_0
        StrCmp "$unlog_tmp_0" "0" 0 +2
        RmDir "${TargetDir}"

	IfErrors 0 +2
	MessageBox MB_ICONEXCLAMATION|MB_OK "${UNINSTALL_LOG} Log error" /SD IDOK

   !undef ID

  !verbose pop
!macroend


!macro INTERACTIVE_UNINSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}
     
     !ifdef INTERACTIVE_UNINSTALL
        !error "INTERACTIVE_UNINSTALL is already defined"
     !endif

        var unlog_tmp_4
        var unlog_tmp_5

     !define INTERACTIVE_UNINSTALL

     !ifdef INTERACTIVE_UNINSTALL & UNATTENDED_UNINSTALL
        !error "You must insert either Interactive or Unattended Uninstall neither both, neither none."
     !endif

     !ifdef UnLog_Uninstall_CallBackFunc
        !undef UnLog_Uninstall_CallBackFunc
     !endif

     !ifndef UnLog_Uninstall_CallBackFunc
        !insertmacro UNINSTALL.LOG_UNINSTALL_INTERACTIVE
        !define UnLog_Uninstall_CallBackFunc "un._LocateCallBack_Function_Interactive"
     !endif

  !verbose pop
!macroend


!macro UNATTENDED_UNINSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

     !ifdef UNATTENDED_UNINSTALL
        !error "UNATTENDED_UNINSTALL is already defined"
     !endif

     !define UNATTENDED_UNINSTALL

     !ifdef INTERACTIVE_UNINSTALL & UNATTENDED_UNINSTALL
        !error "You must insert either Interactive or Unattended Uninstall neither both, neither none."
     !endif

     !ifdef UnLog_Uninstall_CallBackFunc
        !undef UnLog_Uninstall_CallBackFunc
     !endif

     !ifndef UnLog_Uninstall_CallBackFunc
        !insertmacro UNINSTALL.LOG_UNINSTALL_UNATTENDED
        !define UnLog_Uninstall_CallBackFunc "un._LocateCallBack_Function_Unattended"
     !endif

  !verbose pop
!macroend


!macro UNINSTALL.LOG_UNINSTALL_UNATTENDED

  Function un._LocateCallBack_Function_Unattended
    start:
        FileRead $unlog_tmp_2 "$unlog_tmp_3" ${NSIS_MAX_STRLEN}
        ${un.TrimNewLines} "$unlog_tmp_3" "$unlog_tmp_3"
        StrCmp "$unlog_tmp_3" "$R9" islog
        IfErrors nolog
        goto start

    islog:
        IfFileExists "$R9\*.*" isdir

    isfile:
        Delete "$R9"
        goto end

    isdir:
        RmDir "$R9"
	IntOp $unlog_tmp_1 $unlog_tmp_1 + 1
        goto end

    nolog:
        ClearErrors
        StrCmp "$R9" "${UNINST_EXE}" isfile
        StrCmp "$R9" "${UNINST_DAT}" isfile

    end:
        FileSeek $unlog_tmp_2 0 SET
	Push $unlog_tmp_0
  FunctionEnd

!macroend


!macro UNINSTALL.LOG_UNINSTALL_INTERACTIVE

  Function un._LocateCallBack_Function_Interactive
    start:
        FileRead $unlog_tmp_2 "$unlog_tmp_3" ${NSIS_MAX_STRLEN}
        ${un.TrimNewLines} "$unlog_tmp_3" "$unlog_tmp_3"
        StrCmp "$unlog_tmp_3" "$R9" islog
        IfErrors nolog
        goto start

    islog:
        IfFileExists "$R9\*.*" isdir

    isfile:
        Delete "$R9"
        goto end

    isdir:
        RmDir "$R9"
	IntOp $unlog_tmp_1 $unlog_tmp_1 + 1
        goto end

    nolog:
        ClearErrors
	FileSeek $unlog_tmp_4 0 SET
    read:
        FileRead $unlog_tmp_4 "$unlog_tmp_3"
        ${un.TrimNewLines} "$unlog_tmp_3" "$unlog_tmp_3"
        StrCmp "$unlog_tmp_3" "$R9" end
        IfErrors +2
        goto read
        ClearErrors 
        StrCmp "$R9" "${UNINST_EXE}" isfile
        StrCmp "$R9" "${UNINST_DAT}" isfile
        IfFileExists "$R9\*.*" msgdir

	MessageBox MB_ICONQUESTION|MB_YESNO \
        'Delete File "$R9"?' /SD IDNO IDYES isfile IDNO nodel

    msgdir:
        MessageBox MB_ICONQUESTION|MB_YESNO \
        'Delete Directory "$R9"?' /SD IDNO IDYES isdir IDNO nodel

    nodel:
	FileSeek $unlog_tmp_4 0 END
	FileWrite $unlog_tmp_4 "$R9$\r$\n"

    end:
        FileSeek $unlog_tmp_2 0 SET
	Push $unlog_tmp_0
  FunctionEnd

!macroend

;................................. Installer Macros .................................

!macro UNINSTALL.LOG_INSTALL_UNATTENDED

  Function _LocateCallBack_Function_Install
    loop:
        FileRead $unlog_tmp_2 "$unlog_tmp_3" ${NSIS_MAX_STRLEN}
        ${TrimNewLines} "$unlog_tmp_3" "$unlog_tmp_3"
        IfErrors 0 +4
        ClearErrors
        FileSeek $unlog_tmp_2 0 SET
        goto next
        StrCmp "$R9" "$unlog_tmp_3" end
        goto loop
    next:
	FileWrite $unlog_tmp_1 "$R9$\r$\n"
    end:
	Push $unlog_tmp_0
  FunctionEnd

!macroend


!ifdef UnLog_Install_Func_CallBack
    !undef UnLog_Install_Func_CallBack
!endif

!ifndef UnLog_Install_Func_CallBack
    !insertmacro UNINSTALL.LOG_INSTALL_UNATTENDED
    !define UnLog_Install_Func_CallBack "_LocateCallBack_Function_Install"
!endif


!macro UNINSTALL.LOG_PREPARE_INSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

      Push $0
      Push $1
        ClearErrors
        ReadRegStr "$0"  ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "${UNINSTALL_LOG}Directory"
        IfErrors next
        ${DirState} "$0" $1
        StrCmp "$1" "-1" next
        StrCmp "$1" "0" next
        IfFileExists "$0\${UNINSTALL_LOG}.dat" next
        MessageBox MB_ICONEXCLAMATION|MB_OK \
        "Previous installation detected at $0.$\n\
        Required file ${UNINSTALL_LOG}.dat is missing.$\n$\nIt is highly recommended \
        to select an empty directory and perform a fresh installation." /SD IDOK
        StrCpy $unlog_error "error"

    next:
        ClearErrors
        StrCmp "$PLUGINSDIR" "" 0 +2
           InitPluginsDir

        GetTempFileName "$1"
        FileOpen $0 "$1" w
        FileWrite $0 "${UNLOG_HEAD}$\r$\n"
        FileClose $0
        Rename "$1" "${UNLOG_TEMP}"
      Pop $1
      Pop $0

  !verbose pop
!macroend


!macro UNINSTALL.LOG_UPDATE_INSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

        Delete "${UNINST_DAT}"
        Rename "${UNLOG_TEMP}" "${UNINST_DAT}"
        WriteUninstaller "${UNINST_EXE}"
        WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "${UNINSTALL_LOG}.dat" "${UNINST_DAT}"
        WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "${UNINSTALL_LOG}Directory" "$INSTDIR"

  !verbose pop
!macroend


!define uninstall.log_install "!insertmacro UNINSTALL.LOG_INSTALL"

!macro UNINSTALL.LOG_INSTALL FileOpenWrite FileOpenRead TargetDir
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

	FileOpen $unlog_tmp_1 "${FileOpenWrite}" w
	FileOpen $unlog_tmp_2 "${FileOpenRead}" r

	${Locate} "${TargetDir}" "/L=FD" "${UnLog_Install_Func_CallBack}"

        StrCmp $unlog_error "error" 0 +2
        ClearErrors

	IfErrors 0 +2
	MessageBox MB_ICONEXCLAMATION|MB_OK "Error creating ${UNINSTALL_LOG} Log." /SD IDOK

	FileClose $unlog_tmp_1
	FileClose $unlog_tmp_2

  !verbose pop
!macroend


!define uninstall.log_mergeID "!insertmacro UNINSTALL.LOG_MERGE"

!macro UNINSTALL.LOG_MERGE UnlogPart
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

        ${FileJoin} "${UNLOG_TEMP}" "${UnlogPart}" "${UNLOG_TEMP}"

  !verbose pop
!macroend


!macro UNINSTALL.LOG_OPEN_INSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

        StrCmp $unlog_error "error" +2
        ${uninstall.log_install} "${EXCLU_LIST}" "${UNINST_DAT}" "$OUTDIR"

  !verbose pop
!macroend


!macro UNINSTALL.LOG_CLOSE_INSTALL
  !verbose push
     !verbose ${UNINST_LOG_VERBOSE}

   !define ID ${__LINE__}

        ${uninstall.log_install} "${UNLOG_PART}${ID}" "${EXCLU_LIST}" "$OUTDIR"
        ${uninstall.log_mergeID} "${UNLOG_PART}${ID}"

   !undef ID

  !verbose pop
!macroend

!endif

!verbose pop
     ;_____________________________ HEADER FILE END ____________________________

