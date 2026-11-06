**free
//===============================================================*
//                                                               *
//  erstellt :  9.11.2007                                        *
//                                                               *
//===============================================================*
//                                                               *
//  Kurzdokumentation :                                          *
//                                                               *
//  Rahmentestprogramm mit Protokollausgabe                      *
//  Thema:                                                       *
//     Tool: Ping Port                                           *
//                                                               *
//===============================================================*
// >>PRE-COMPILER<<                                              *
//                                                               *
//   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                   *
//                           SRCFILE(&SL/&SF) +                  *
//                           SRCMBR(&SM);                        *
//                                                               *
//   >>COMPILE<<                                                 *
//     >>PARM<< TRUNCNBR(*NO);                                   *
//     >>PARM<< DBGVIEW(*LIST);                                  *
//   >>END-COMPILE<<                                             *
//                                                               *
//   >>EXECUTE<<                                                 *
//                                                               *
//   >>CMD<<    CRTPGM       PGM(&LI/&OB) +                      *
//                           MODULE(&LI/&OB          +           *
//                                          ) +                  *
//                           BNDSRVPGM(*LIBL/BASICS1      +      *
//                                     *LIBL/PRTLOG       +      *
//                                          ) +                  *
//                           BNDDIR(*LIBL/QC2LE) +               *
//                           DETAIL(*BASIC) +                    *
//                           ACTGRP(*NEW);                       *
//                                                               *
// >>END-PRE-COMPILER<<                                          *
//===============================================================*
ctl-opt debug option(*srcstmt: *nodebugio);
ctl-opt decedit('0,') datedit(*DMY.);
ctl-opt datfmt(*iso) timfmt(*iso);
ctl-opt expropts(*resdecpos);
ctl-opt extbinint(*yes);
//===============================================================*
//
// ------------------------------------
//  Type definitions
// ------------------------------------
//
// ------------------------------------
//  External Prototypes
// ------------------------------------
/copy QBASICS1,PBASICS1 SrvPgm: Basics 1
/copy QPRTLOG,PPRTLOG SrvPgm: Print log
/copy QPINGPORT,SOCKETLIB Socket Library

// ------------------------------------
//  Global Fields
// ------------------------------------

//  Logger
dcl-s g_hLogger like(prtLog_handle_t) inz;

// ------------------------------------
//  Globale Konstanten
// ------------------------------------
//
// ------------------------------------
//  Prototypes
// ------------------------------------

dcl-pr PGM_ENTRY_POINT extpgm('PINGPORTR');
  gi_host varchar(64) const;
  gi_port int(10) const;
end-pr;

dcl-pr main;
  i_host varchar(64) value;
  i_port int(10) value;
end-pr;

//  Test for errors and log them.
dcl-pr isErrorMsg ind;
  i_msg likeds(msg_t) const;
end-pr;

//  Open Logger
dcl-pr openLogger;
  i_layout char(1) value;
  i_splF   varchar(10) value;
  i_usrDta varchar(10) value;
end-pr;

//  Logs a given string.
dcl-pr log;
  i_msgText varchar(256) const;
end-pr;

//  Logs a given message.
dcl-pr logMsg;
  i_msg likeds(msg_t) const;
end-pr;

//  Logs a monitored message.
dcl-pr logMonitor likeds(msg_t);
  i_text varchar(128) const;
end-pr;

//  Close Logger
dcl-pr closeLogger;
end-pr;

//  Abrufen letzte Abbruch-Nachricht.
dcl-pr rcvEscMsg likeds(msg_t);
  i_stckCnt int(10) const;
end-pr;

//  Abrufen Nachrichtentext für Nachricht.
dcl-pr rtvMsgText varchar(1024);
  i_msg likeds(msg_t) const;
end-pr;

//  Sends a message to QCMD
dcl-pr sndMsg;
  i_text        varchar(128) value;
  i_doSendToExt ind options(*nopass) value;
end-pr;

//  Auflösen Hostname nach IP-Adresse
dcl-pr resolveHost uns(10);
  i_host pointer options(*string: *trim) const;
end-pr;

//===============================================================*
//  Program Entry Point
//===============================================================*
dcl-pi PGM_ENTRY_POINT;
  gi_host varchar(64) const;
  gi_port int(10) const;
end-pi;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//openLogger('L': sds.pgmName: '???????');

main(
      gi_host
      :gi_port
                     );

// Close logger
//closeLogger();

*inlr = *on;


//===============================================================*
//  Test for errors and log them.
//===============================================================*
dcl-proc isErrorMsg;
  dcl-pi *n ind;
    i_msg likeds(msg_t) const;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (i_msg.ID <> cMSG_ID_OK);
    logMsg(i_msg);
    return cTrue;
  else;
    return cFalse;
  endif;

end-proc;

//===============================================================*
//  *** Private ***
//  Open Logger
//===============================================================*
dcl-proc openLogger;
  dcl-pi *n;
    i_layout char(1) value;
    i_splF   varchar(10) value;
    i_usrDta varchar(10) value;
  end-pi;

  //  Helper fields
  dcl-s cmd varchar(256) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cmd = 'OVRPRTF ' +
           'FILE(PRTLOGP) '               +
           'LPI(6) '                      +
           'CPI(10) '                     +
           'OVRSCOPE(*ACTGRPDFN) '        +
           'SPLFNAME(' + i_splF + ') '    +
           'MAXRCDS(*NOMAX) '             +
           'USRDTA(''' + i_usrDta + ''') ';

  if (i_layout = 'P');
    cmd = cmd + 'PAGESIZE(70 80) ' +
                'OVRFLW(64) ';
  else;
    cmd = cmd + 'PAGESIZE(49 132) ' +
                'OVRFLW(42) ';
  endif;

  f_execute(cmd);

  // Open logger
  if (f_opnPrtLog('Examinee: '+ i_usrDta: cFalse: g_hLogger));   //no scndl
    log('######## Start of Test ########');
  endif;

end-proc;

//===============================================================*
//  *** Private ***
//  Logs a given string.
//===============================================================*
dcl-proc log;
  dcl-pi *n;
    i_msgText varchar(256) const;
  end-pi;

  //  Helper fields
  dcl-ds msg likeds(msg_t) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (i_msgText = '');
    msg = f_newMsg(cMSG_ID_NONE: x'41');
  else;
    msg = f_newMsg(cMSG_ID_NONE: i_msgText);
  endif;

  logMsg(msg);

end-proc;

//===============================================================*
//  *** Private ***
//  Logs a given message.
//===============================================================*
dcl-proc logMsg;
  dcl-pi *n;
    i_msg likeds(msg_t) const;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  f_wrtPrtLog(g_hLogger: i_msg);

end-proc;

//===============================================================*
//  *** Private ***
//  Logs a monitored message.
//===============================================================*
dcl-proc logMonitor;
  dcl-pi *n likeds(msg_t);
    i_text varchar(128) const;
  end-pi;

  //  Funktionswert
  dcl-ds msg likeds(msg_t) inz;

  //  Arbeitsfelder
  dcl-s msgText varchar(1024) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  msg = rcvEscMsg(2);

  msgText = 'MONITOR: ' + i_text + ' - ' + rtvMsgText(msg);

  log(msgText);

  return msg;

end-proc;

//===============================================================*
//  *** Private ***
//  Close Logger
//===============================================================*
dcl-proc closeLogger;
  dcl-pi *n;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  log('########  End of Test  ########');

  // Close logger
  f_cloPrtLog(g_hLogger);

  g_hLogger = *null;

end-proc;

//===============================================================*
//  *** Private ***
//  Abrufen letzte Abbruch-Nachricht.
//===============================================================*
dcl-proc rcvEscMsg;
  dcl-pi *n likeds(msg_t);
    i_stckCnt int(10) const;
  end-pi;

  //  Funktionswert
  dcl-ds msg likeds(msg_t) inz;

  //  Arbeitsfelder
  dcl-s msgKey char(4) inz;
  dcl-s msgData varchar(512) inz;

  dcl-ds rcvm0200 qualified inz;
    bytRet      int(10);
    bytAvl      int(10);
    msgSev      int(10);
    msgID       char(7);
    msgType     char(2);
    msgKey      char(4);
    msgF        char(10);
    msgLS       char(10);
    msgLU       char(10);
    sndJob      char(10);
    sndUsr      char(10);
    sndNbr      char(6);
    sndPgm      char(12);
    sndINb      char(4);
    sndDat      char(7);
    sndTim      char(6);
    rcvPgm      char(10);
    rcvINb      char(4);
    sndTyp      char(1);
    rcvTyp      char(1);
    reserved_01 char(1);
    cStIDTx     int(10);
    cStIDDt     int(10);
    alrOpt      char(9);
    ccsidMH     int(10);
    ccsidRD     int(10);
    lnRplDtR    int(10);
    lnRplDtA    int(10);
    lnMgR       int(10);
    lnMgA       int(10);
    lnMgHR      int(10);
    lnMgHA      int(10);
    value       char(4096);
  end-ds;

  dcl-ds errCode qualified inz;
    bytPrv int(10);
    bytAvl int(10);
  end-ds;

  //  Receive Program Message (QMHRCVPM) API
  dcl-pr QMHRCVPM extpgm('QMHRCVPM');
    o_rcvVar   char(32767) options(*varsize);
    i_length   int(10) const;
    i_format   char(8) const;
    i_callStkE char(10) const;
    i_callStkC int(10) const;
    i_msgType  char(10) const;
    i_msgKey   char(4) const;
    i_wait     int(10) const;
    i_action   char(10) const;
    io_ErrCode char(32767) options(*varsize);
  end-pr;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  QMHRCVPM(rcvm0200: %size(rcvm0200): 'RCVM0200': '*': i_stckCnt:
           '*ESCAPE': msgKey: 0: '*SAME': errCode);

  if (rcvm0200.lnMgR > 0);
    msgData = %subst(rcvm0200.value: 1: rcvm0200.lnMgR);
  else;
    msgData = '';
  endif;

  clear msg;
  msg.file = rcvm0200.msgF;
  msg.lib  = rcvm0200.msgLU;
  msg.type = '*INFO';
  msg.ID   = rcvm0200.msgID;
  msg.data = msgData;

  return msg;

end-proc;

//===============================================================*
//  *** Private ***
//  Abrufen Nachrichtentext für Nachricht.
//===============================================================*
dcl-proc rtvMsgText;
  dcl-pi *n varchar(1024);
    i_msg likeds(msg_t) const;
  end-pi;

  //  Funktionswert
  dcl-s msgText varchar(1024) inz;

  //  Arbeitsfelder
  dcl-ds rtvm0100 qualified inz;
    bytRet    bindec(9);
    bytAvl    bindec(9);
    lenMsgRet bindec(9);
    lenMsgAvl bindec(9);
    lenHlpRet bindec(9);
    lenHlpAvl bindec(9);
    data      char(4096);
  end-ds;

  dcl-ds qMsgF qualified inz;
    name char(10);
    lib  char(10);
  end-ds;

  dcl-ds errCode qualified inz;
    bytPrv int(10);
    bytAvl int(10);
  end-ds;

  //  Retrieve Message (QMHRTVM) API
  dcl-pr QMHRTVM extpgm('QMHRTVM');
    o_msgInf      char(32767) options(*varsize);
    i_length      int(10) const;
    i_format      char(8) const;
    i_msgID       char(7) const;
    i_qMsgF       char(20) const;
    i_rplData     char(32767) options(*varsize) const;
    i_rpldataLen  int(10) const;
    i_rplVars     char(10) const;
    i_rtnCtrlChrs char(10) const;
    io_ErrCode    char(32767) options(*varsize);
  end-pr;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  qMsgF.name = i_msg.file;
  qMsgF.lib  = i_msg.lib;

  QMHRTVM(rtvm0100: %size(rtvm0100): 'RTVM0100': i_msg.ID: qMsgF:
          i_msg.data: %len(i_msg.data): '*YES': '*NO': errCode);

  if (rtvm0100.lenMsgRet > 0);
    msgText = %subst(rtvm0100.data: 1: rtvm0100.lenMsgRet);
  else;
    msgText = '';
  endif;

  return msgText;

end-proc;

//==================================================================*
//  Sends a message to the caller.
//==================================================================*
dcl-proc sndMsg;
  dcl-pi *n;
    i_text        varchar(128) value;
    i_doSendToExt ind options(*nopass) value;
  end-pi;

  //  Local fields
  dcl-s msgKey char(4) inz;

  dcl-ds qMsgF qualified inz;
    name char(10);
    lib  char(10);
  end-ds;

  dcl-ds errCode qualified inz;
    bytPrv   int(10);
    bytAvl   int(10);
    excID    char(7);
    reserved char(1);
    excDta   char(256);
  end-ds;

  //  Send Program Message (QMHSNDPM) API
  dcl-pr QMHSNDPM extpgm('QMHSNDPM');
    i_msgID      char(7) const;
    i_qMsgF      char(20) const;
    i_msgData    char(32767) options(*varsize) const;
    i_length     int(10) const;
    i_msgType    char(10) const;
    i_callStkE   char(32767) options(*varsize) const;
    i_callStkC   int(10) const;
    o_msgKey     char(4);
    io_ErrCode   char(32767) options(*varsize);
    i_lenStkE    int(10) options(*nopass) const;
    i_callStkEQ  char(20) options(*nopass) const;
    i_wait       int(10) options(*nopass) const;
    i_callStkEDT char(10) options(*nopass) const;
    i_ccsid      int(10) options(*nopass) const;
  end-pr;
  // ---------------------------------------------------------


  clear qMsgF;
  qMsgF.name = 'QCPFMSG';
  qMsgF.lib  = '*LIBL';

  clear errCode;
  errCode.bytPrv = %size(errCode);

  if (%parms() >= 2 and i_doSendToExt);
    QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
             : '*CTLBDY': 1
             : msgKey: errCode);
  else;
    QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
             : '*CTLBDY': 0
             : msgKey: errCode);
  endif;

end-proc;

//===============================================================*
//  Auflösen Hostname nach IP-Adresse
//===============================================================*
dcl-proc resolveHost;
  dcl-pi *n uns(10);
    i_host pointer options(*string: *trim) const;
  end-pi;

  //  Deklarieren Funktionswert
  dcl-s ipAdrLong uns(10) inz;

  //  Funktionslokale Felder
  dcl-s tmpIpAdrLong like(ipAdrLong) inz;

  dcl-ds hostent likeds(hostent_t) based(pHostent);
  dcl-s p1HostAdr pointer based(hostent.h_addrlist);
  dcl-s hostAdr uns(10) based(p1HostAdr);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  // Initialisieren Rückgabewerte
  reset ipAdrLong;

  // SOLANGE BIS alles getan oder Fehler
  dou (1=1);

    // Umsetzen IP Adresse von xxx.xxx.xxx.xxx in 32-Bit Adresse (Long)
    tmpIpAdrLong = inet_addr(i_host);

    // Wenn dies fehlschlägt, dann annehmen, dass der Host name als
    // DNS Name übergeben wurde und versuchen, die IP Adresse
    // anhand des Host-Namens zu ermitteln.
    if (tmpIpAdrLong = INADDR_NONE);
      tmpIpAdrLong = 0;
      pHostent = gethostbyname(i_host);
      if (pHostent <> *null);
        tmpIpAdrLong = hostAdr;
      endif;
    endif;

    if (tmpIpAdrLong = 0);
      sndMsg('Unknown host: ' + %str(i_host): cTrue);
      leave;
    endif;

    // Setzen Funktionswert
    ipAdrLong = tmpIpAdrLong;
  enddo;

  return ipAdrLong;

end-proc;

//===============================================================*
//  Main procedure
//===============================================================*
dcl-proc main;
  dcl-pi *n;
    i_host varchar(64) value;
    i_port int(10) value;
  end-pi;

  //  Helper fields
  dcl-s sd int(10) inz(-1);

  dcl-ds sockAddr likeds(sockaddr_in_t);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  // Do until everything is done or an error occured
  dou (1=1);

    // Erstellen Socket
    sd = socket(AF_INET: SOCK_STREAM: IPPROTO_IP);
    if (sd < 0);
      sndMsg('Faild: socket()': cTrue);
      leave;
    endif;

    // Aufbauen Verbindung zum Server über gegebene Portnummer
    sockAddr.sin_Family = AF_INET;
    sockAddr.sin_Port   = i_port;
    sockAddr.sin_addr   = resolveHost(i_host);
    sockAddr.sin_zero   = *allx'00';

    if (sockAddr.sin_addr = 0);
      leave;
    endif;

    if (connect(sd: %addr(sockAddr): %size(sockAddr)) = -1);
      sndMsg('Failed to connect to host ' +
              i_host + ':' + %char(i_port): cTrue);
      logRootCause();
      leave;
    endif;

    // Prima, klappt.
    sndMsg('Connection to host ' + i_host + ':' + %char(i_port) +
           ' verified.': cTrue);
  enddo;

  // Schließen Socket
  if (sd <> -1);
    callp close(sd);
    reset sd;
  endif;

end-proc;

//===============================================================*
//  Log root cause.
//===============================================================*
dcl-proc logRootCause;
  dcl-pi *n;
  end-pi;

  dcl-s errorNbr int(10) based(pErrorNbr);
  dcl-s errorText char(128) based(pErrorText);
  dcl-s errorMessage char(128);

  pErrorNbr = errno();
  if (pErrorNbr <> *null);
    if (errorNbr <> 0);
      pErrorText = strerror(errorNbr);
      if (pErrorText <> *null);
        errorMessage = %str(pErrorText: 128);
        sndMsg('C-Error: ' + %trim(errorMessage));
      endif;
    endif;
  endif;

end-proc;

