VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "rsmovenext"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Implements ITestCases

Dim codelib As New adolvl0.Common
Dim g_caseerrorobj As ModuleBase.IError
Dim g_caseprovobj As ModuleBase.IProviderInfo
Dim xModInfo As New ModInfo
Dim pifObj As ParseInitFile
Dim col As Column
Dim tracecase As Boolean
Dim provstr As String
Dim curlocstr As String
Dim rsstr As String
Dim connstr As String

Private Function ITestCases_ExecuteVariation(ByVal lIndex As Long) As ModuleBase.tagVARIATION_STATUS
    ' call variation indicated by lIndex
    ITestCases_ExecuteVariation = eVariationStatusFailed
    If tracecase Then
        g_caseerrorobj.Transmit "Inside: ITestCases_ExecuteVariation(" + CStr(lIndex) + ")" + Chr(10)
    End If
    Select Case lIndex
        Case 0
            ITestCases_ExecuteVariation = validtest()
        Case 1
            ITestCases_ExecuteVariation = invalidtest()
    End Select
End Function
Private Function ITestCases_GetDescription() As String
    ' eventually get the description from the registry
    ITestCases_GetDescription = "Recordset MoveNext Tests"
End Function
Private Function ITestCases_GetIndexOfVariationWithID(ByVal lID As Long) As Long
    If tracecase Then
        g_caseerrorobj.Transmit "Inside: ITestCases_GetIndexOfVariationWithID(" + CStr(lID) + ")" + Chr(10)
    End If
    ITestCases_GetIndexOfVariationWithID = lID + 1
End Function
Private Function ITestCases_GetName() As String
    If tracecase Then
        g_caseerrorobj.Transmit "Inside: ITestCases_GetName" + Chr(10)
    End If
    ITestCases_GetName = "rs.MoveNext"
End Function
Private Function ITestCases_GetOwningITestModule() As ModuleBase.ITestModule
    Set ITestCases_GetOwningITestModule = g_tm
End Function
Private Function ITestCases_GetProviderInterface() As ModuleBase.IProviderInfo
    Set ITestCases_GetProviderInterface = g_caseprovobj
End Function
Private Function ITestCases_GetVariationCount() As Long
    ITestCases_GetVariationCount = 1
End Function
Private Function ITestCases_GetVariationDesc(ByVal lIndex As Long) As String
    If tracecase Then
        g_caseerrorobj.Transmit "Inside: ITestCases_GetVariationDesc(" + CStr(lIndex) + ")" + Chr(10)
    End If
    Select Case lIndex
        Case 0
            ITestCases_GetVariationDesc = "MoveNext to last record, verify position"
        Case 1
            ITestCases_GetVariationDesc = "Invalid Test Case"
    End Select
End Function
Private Function ITestCases_GetVariationID(ByVal lIndex As Long) As Long
    If tracecase Then
        g_caseerrorobj.Transmit "Inside: ITestCases_GetVariationID(" + CStr(lIndex) + ")" + Chr(10)
    End If
    Select Case lIndex
        Case 0
            ITestCases_GetVariationID = 1
        Case 1
            ITestCases_GetVariationID = 2
    End Select
End Function
Private Function ITestCases_Init() As Long

Const SELECT_ALLFROMTBL = 2
Dim inistr As String
    
    ITestCases_Init = 0
    
    xModInfo.InitString = g_caseprovobj.GetInitString
    fResult = xModInfo.Init() 'Initialize CModuleInfo::Init()
    fResult = xModInfo.ParseInitString
    
    retcode = xModInfo.GetInitStringValue("FILE", inistr)
    If inistr = "" Then
        ' we don't have an ini file, we require one to run
        g_caseerrorobj.Transmit "The ADO tests require an ini file to run."
    Else
        Set pifObj = xModInfo.ParseObject

        ' build connection string and initialize pifObj
        connstr = codelib.GetConnStr(xModInfo, g_caseprovobj)
        rsstr = pifObj.GetQuery(SELECT_ALLFROMTBL)
        retcode = xModInfo.GetInitStringValue("CURSORLOC", curlocstr)
        If UCase(Trim(curlocstr)) = "CLIENT" Then
            curlocstr = "3"
        Else
            curlocstr = "2"
        End If
        If (connstr = "" Or rsstr = "") Then
            ' we don't have enough info to run
            g_caseerrorobj.Transmit "The ADO tests require a valid ini FILE and a DATASOURCE/LOCATION,USERID, and PASSWORD."
        Else
            ITestCases_Init = 1
        End If
    End If
    
End Function

Private Sub ITestCases_SyncProviderInterface()

End Sub

Private Function ITestCases_Terminate() As Boolean
    Set xModInfo = Nothing
    Set pifObj = Nothing
    ITestCases_Terminate = True
End Function
Public Sub SetCaseError(lError As ModuleBase.IError)
    Set g_caseerrorobj = lError
    tracecase = False
End Sub
Public Sub SetCaseProvider(lprov As ModuleBase.IProviderInfo)
    Set g_caseprovobj = lprov
End Sub

Public Function validtest() As ModuleBase.tagVARIATION_STATUS
    Dim connection1 As New ADODB.Connection
    Dim recset1 As New ADODB.Recordset
    On Error GoTo ErrorHandler
    
    g_caseerrorobj.SetErrorLevel (HR_STRICT)
    g_ExpError = 0

    If tracecase Then
        g_caseerrorobj.Transmit ("inside validtest" + Chr(10))
    End If

    bTestPassed = True
    
    ' open connection
    connection1.ConnectionString = connstr
    connection1.CursorLocation = CInt(curlocstr)
    connection1.Open
    
    ' open recordset
    recset1.Open rsstr, connection1, adOpenStatic
    
    rowstomove = codelib.RandRecNo(recset1)
    If rowstomove > 1 Then
        savecolumn = codelib.GetBestColumn(recset1)
        recset1.Move rowstomove
        savedata = recset1(savecolumn)
        recset1.MoveFirst
        For i = 1 To rowstomove
            recset1.MoveNext
        Next i
        If codelib.ValueCompare(recset1(savecolumn).Type, recset1(savecolumn), savedata) <> 0 Then
            g_caseerrorobj.Transmit "Method - MoveNext, did not end up on the correct record"
            bTestPassed = False
        End If
        ' Output Test pass/fail
        If (bTestPassed = False) Then
            validtest = eVariationStatusFailed
        Else
            validtest = eVariationStatusPassed
        End If
    Else
        g_caseerrorobj.Transmit "Insufficient Number of rows to test MoveNext Method - Test skipped"
        validtest = eVariationStatusNotRun
    End If
    recset1.Close
    
    connection1.Close
    Exit Function
ErrorHandler:
    ' Output error message
    bTestPassed = codelib.ErrorHandler(g_caseerrorobj, ITestCases_GetName(), g_ExpError)
    Resume Next

End Function
Public Function invalidtest() As ModuleBase.tagVARIATION_STATUS
    Dim connection1 As New ADODB.Connection
    On Error GoTo ErrorHandler

    If tracecase Then
        g_caseerrorobj.Transmit ("inside invalidtest") + Chr(10)
    End If

    Exit Function
ErrorHandler:
    ' Output error message
    bTestPassed = codelib.ErrorHandler(g_caseerrorobj, ITestCases_GetName(), g_ExpError)
    hiterror = True
    Resume Next
End Function



