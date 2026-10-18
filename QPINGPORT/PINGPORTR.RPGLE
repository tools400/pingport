      *===============================================================*
      *                                                               *
      *  erstellt :  9.11.2007                                        *
      *                                                               *
      *===============================================================*
      *                                                               *
      *  Kurzdokumentation :                                          *
      *                                                               *
      *  Rahmentestprogramm mit Protokollausgabe                      *
      *  Thema:                                                       *
      *     Tool: Ping Port                                           *
      *                                                               *
      *===============================================================*
      * >>PRE-COMPILER<<                                              *
      *                                                               *
      *   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                   *
      *                           SRCFILE(&SL/&SF) +                  *
      *                           SRCMBR(&SM);                        *
      *                                                               *
      *   >>COMPILE<<                                                 *
      *     >>PARM<< TRUNCNBR(*NO);                                   *
      *     >>PARM<< DBGVIEW(*LIST);                                  *
      *   >>END-COMPILE<<                                             *
      *                                                               *
      *   >>EXECUTE<<                                                 *
      *                                                               *
      *   >>CMD<<    CRTPGM       PGM(&LI/&OB) +                      *
      *                           MODULE(&LI/&OB          +           *
      *                                          ) +                  *
      *                           BNDSRVPGM(*LIBL/BASICS1      +      *
      *                                     *LIBL/PRTLOG       +      *
      *                                          ) +                  *
      *                           BNDDIR(*LIBL/QC2LE) +               *
      *                           DETAIL(*BASIC) +                    *
      *                           ACTGRP(*NEW);                       *
      *                                                               *
      * >>END-PRE-COMPILER<<                                          *
      *===============================================================*
     H DEBUG
     H OPTION(*SRCSTMT : *NODEBUGIO)
     H DECEDIT('0,') DATEDIT(*DMY.)
     H DATFMT(*ISO )  TIMFMT(*ISO )
     H EXPROPTS(*RESDECPOS)
     H EXTBININT(*YES)
      *===============================================================*
      *
      * ------------------------------------
      *  Type definitions
      * ------------------------------------
      *
      * ------------------------------------
      *  External Prototypes
      * ------------------------------------
      /COPY QBASICS1,PBASICS1                      SrvPgm: Basics 1
      /COPY QPRTLOG,PPRTLOG                        SrvPgm: Print log
      /COPY QPINGPORT,SOCKETLIB                    Socket Library
      *
      * ------------------------------------
      *  Global Fields
      * ------------------------------------
      *
      *  Logger
     D g_hLogger       S                   like(prtLog_handle_t) inz
      *
      * ------------------------------------
      *  Globale Konstanten
      * ------------------------------------
      *
      * ------------------------------------
      *  Prototypes
      * ------------------------------------
      *
     D PGM_ENTRY_POINT...
     D                 PR                  extpgm('PINGPORTR')
     D gi_host                       64A   const  varying
     D gi_port                       10I 0 const
      *
     D main...
     D                 PR
     D i_host                        64A   value  varying
     D i_port                        10I 0 value
      *
      *  Test for errors and log them.
     D isErrorMsg...
     D                 PR              N
     D  i_msg                              const  likeds(msg_t    )
      *
      *  Open Logger
     D openLogger...
     D                 PR
     D  i_layout                      1A   value
     D  i_splF                       10A   value  varying
     D  i_usrDta                     10A   value  varying
      *
      *  Logs a given string.
     D log...
     D                 PR
     D  i_msgText                   256A   const  varying
      *
      *  Logs a given message.
     D logMsg...
     D                 PR
     D  i_msg                              const  likeds(msg_t        )
      *
      *  Logs a monitored message.
     D logMonitor...
     D                 PR                         likeds(msg_t   )
     D  i_text                      128A   const  varying
      *
      *  Close Logger
     D closeLogger...
     D                 PR
      *
      *  Abrufen letzte Abbruch-Nachricht.
     D rcvEscMsg...
     D                 PR                         likeds(msg_t    )
     D  i_stckCnt                    10I 0 const
      *
      *  Abrufen Nachrichtentext für Nachricht.
     D rtvMsgText...
     D                 PR          1024A          varying
     D  i_msg                                     const  likeds(msg_t   )
      *
      *  Sends a message to QCMD
     D sndMsg...
     D                 PR
     D  i_text                      128A   value  varying
     D  i_doSendToExt                  N   VALUE  options(*nopass)
      *
      *  Auflösen Hostname nach IP-Adresse
     D resolveHost...
     D                 PR            10U 0
     D  i_host                         *   const  options(*string: *trim)
      *
      *===============================================================*
      *  Program Entry Point
      *===============================================================*
     D PGM_ENTRY_POINT...
     D                 PI
     D gi_host                       64A   const  varying
     D gi_port                       10I 0 const
      *
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         //openLogger('L': sds.pgmName: '???????');

         main(
               gi_host
               :gi_port
                              );

         // Close logger
         //closeLogger();

         *inlr = *on;

      /END-FREE
      *
      *===============================================================*
      *  Test for errors and log them.
      *===============================================================*
     P isErrorMsg...
     P                 B
     D                 PI              N
     D  i_msg                              const  likeds(msg_t    )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if i_msg.ID <> cMSG_ID_OK;
            logMsg(i_msg);
            return cTrue;
         else;
            return cFalse;
         endif;

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Open Logger
      *===============================================================*
     P openLogger...
     P                 B
     D                 PI
     D  i_layout                      1A   value
     D  i_splF                       10A   value  varying
     D  i_usrDta                     10A   value  varying
      *
      *  Helper fields
     D cmd             S            256A   inz   varying
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         cmd = 'OVRPRTF ' +
                  'FILE(PRTLOGP) '               +
                  'LPI(6) '                      +
                  'CPI(10) '                     +
                  'OVRSCOPE(*ACTGRPDFN) '        +
                  'SPLFNAME(' + i_splF + ') '    +
                  'MAXRCDS(*NOMAX) '             +
                  'USRDTA(''' + i_usrDta + ''') ';

         if i_layout = 'P';
            cmd = cmd + 'PAGESIZE(70 80) ' +
                        'OVRFLW(64) ';
         else;
            cmd = cmd + 'PAGESIZE(49 132) ' +
                        'OVRFLW(42) ';
         endif;

         f_execute(cmd);

         // Open logger
         if f_opnPrtLog('Examinee: '+ i_usrDta: cFalse: g_hLogger);   //no scndl
            log('######## Start of Test ########');
         endif;

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Logs a given string.
      *===============================================================*
     P log...
     P                 B
     D                 PI
     D  i_msgText                   256A   const  varying
      *
      *  Helper fields
     D msg             DS                  likeds(msg_t   ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if i_msgText = '';
            msg = f_newMsg(cMSG_ID_NONE: x'41');
         else;
            msg = f_newMsg(cMSG_ID_NONE: i_msgText);
         endif;

         logMsg(msg);

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Logs a given message.
      *===============================================================*
     P logMsg...
     P                 B
     D                 PI
     D  i_msg                              const  likeds(msg_t        )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         f_wrtPrtLog(g_hLogger: i_msg);

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Logs a monitored message.
      *===============================================================*
     P logMonitor...
     P                 B
     D                 PI                         likeds(msg_t   )
     D  i_text                      128A   const  varying
      *
      *  Funktionswert
     D msg             DS                  likeds(msg_t        ) inz
      *
      *  Arbeitsfelder
     D msgText         S           1024A   varying inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         msg = rcvEscMsg(2);

         msgText = 'MONITOR: ' + i_text + ' - ' + rtvMsgText(msg);

         log(msgText);

         return msg;

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Close Logger
      *===============================================================*
     P closeLogger...
     P                 B
     D                 PI
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         log('########  End of Test  ########');

         // Close logger
         f_cloPrtLog(g_hLogger);

         g_hLogger = *NULL;

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Abrufen letzte Abbruch-Nachricht.
      *===============================================================*
     P rcvEscMsg...
     P                 B
     D                 PI                         likeds(msg_t    )
     D  i_stckCnt                    10I 0 const
      *
      *  Funktionswert
     D msg             DS                  likeds(msg_t    ) inz
      *
      *  Arbeitsfelder
     D msgKey          S              4A   inz
     D msgData         S            512A   inz varying
      *
     D rcvm0200        DS                  qualified inz
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  msgSev                       10I 0
     D  msgID                         7A
     D  msgType                       2A
     D  msgKey                        4A
     D  msgF                         10A
     D  msgLS                        10A
     D  msgLU                        10A
     D  sndJob                       10A
     D  sndUsr                       10A
     D  sndNbr                        6A
     D  sndPgm                       12A
     D  sndINb                        4A
     D  sndDat                        7A
     D  sndTim                        6A
     D  rcvPgm                       10A
     D  rcvINb                        4A
     D  sndTyp                        1A
     D  rcvTyp                        1A
     D  reserved_01                   1A
     D  cStIDTx                      10I 0
     D  cStIDDt                      10I 0
     D  alrOpt                        9A
     D  ccsidMH                      10I 0
     D  ccsidRD                      10I 0
     D  lnRplDtR                     10I 0
     D  lnRplDtA                     10I 0
     D  lnMgR                        10I 0
     D  lnMgA                        10I 0
     D  lnMgHR                       10I 0
     D  lnMgHA                       10I 0
     D  value                      4096A
      *
     D errCode         DS                  qualified inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
      *
      *  Receive Program Message (QMHRCVPM) API
     D QMHRCVPM        PR                         extpgm('QMHRCVPM')
     D  o_rcvVar                  32767A          options(*varsize )
     D  i_length                     10I 0 const
     D  i_format                      8A   const
     D  i_callStkE                   10A   const
     D  i_callStkC                   10I 0 const
     D  i_msgType                    10A   const
     D  i_msgKey                      4A   const
     D  i_wait                       10I 0 const
     D  i_action                     10A   const
     D  io_ErrCode                32767A          options(*varsize )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         QMHRCVPM(rcvm0200: %size(rcvm0200): 'RCVM0200': '*': i_stckCnt:
                  '*ESCAPE': msgKey: 0: '*SAME': errCode);

         if rcvm0200.lnMgR > 0;
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

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  *** Private ***
      *  Abrufen Nachrichtentext für Nachricht.
      *===============================================================*
     P rtvMsgText...
     P                 B
     D                 PI          1024A          varying
     D  i_msg                                     const  likeds(msg_t   )
      *
      *  Funktionswert
     D msgText         S           1024A   varying inz
      *
      *  Arbeitsfelder
     D rtvm0100        DS                  qualified inz
     D  bytRet                        9B 0
     D  bytAvl                        9B 0
     D  lenMsgRet                     9B 0
     D  lenMsgAvl                     9B 0
     D  lenHlpRet                     9B 0
     D  lenHlpAvl                     9B 0
     D  data                       4096A
      *
     D qMsgF           DS                  qualified inz
     D  name                         10A
     D  lib                          10A
      *
     D errCode         DS                  qualified inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
      *
      *  Retrieve Message (QMHRTVM) API
     D QMHRTVM         PR                         extpgm('QMHRTVM')
     D  o_msgInf                  32767A          options(*varsize )
     D  i_length                     10I 0 const
     D  i_format                      8A   const
     D  i_msgID                       7A   const
     D  i_qMsgF                      20A   const
     D  i_rplData                 32767A   const  options(*varsize )
     D  i_rpldataLen                 10I 0 const
     D  i_rplVars                    10A   const
     D  i_rtnCtrlChrs                10A   const
     D  io_ErrCode                32767A          options(*varsize )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         qMsgF.name = i_msg.file;
         qMsgF.lib  = i_msg.lib;

         QMHRTVM(rtvm0100: %size(rtvm0100): 'RTVM0100': i_msg.ID: qMsgF:
                 i_msg.data: %len(i_msg.data): '*YES': '*NO': errCode);

         if rtvm0100.lenMsgRet > 0;
            msgText = %subst(rtvm0100.data: 1: rtvm0100.lenMsgRet);
         else;
            msgText = '';
         endif;

         return msgText;

      /END-FREE
     P                 E
      *
      *==================================================================*
      *  Sends a message to the caller.
      *==================================================================*
     P sndMsg...
     P                 B
     D                 PI
     D  i_text                      128A   value  varying
     D  i_doSendToExt                  N   VALUE  options(*nopass)
      *
      *  Local fields
     D msgKey          S              4A                        inz
      *
     D qMsgF           DS                  qualified            inz
     D  name                         10A
     D  lib                          10A
      *
     D errCode         DS                  qualified            inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
     D  excID                         7A
     D  reserved                      1A
     D  excDta                      256A
      *
      *  Send Program Message (QMHSNDPM) API
     D QMHSNDPM        PR                         extpgm('QMHSNDPM')
     D   i_msgID                      7A   const
     D   i_qMsgF                     20A   const
     D   i_msgData                32767A   const  options(*varsize )
     D   i_length                    10I 0 const
     D   i_msgType                   10A   const
     D   i_callStkE               32767A   const  options(*varsize )
     D   i_callStkC                  10I 0 const
     D   o_msgKey                     4A
     D   io_ErrCode               32767A          options(*varsize )
     D   i_lenStkE                   10I 0 const  options(*nopass  )
     D   i_callStkEQ                 20A   const  options(*nopass  )
     D   i_wait                      10I 0 const  options(*nopass  )
     D   i_callStkEDT                10A   const  options(*nopass  )
     D   i_ccsid                     10I 0 const  options(*nopass  )
      * ---------------------------------------------------------
      *
      /FREE

         clear qMsgF;
         qMsgF.name = 'QCPFMSG';
         qMsgF.lib  = '*LIBL';

         clear errCode;
         errCode.bytPrv = %size(errCode);

         if %parms() >= 2 and i_doSendToExt;
            QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
                     : '*CTLBDY': 1
                     : msgKey: errCode);
         else;
            QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
                     : '*CTLBDY': 0
                     : msgKey: errCode);
         endif;

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  Auflösen Hostname nach IP-Adresse
      *===============================================================*
     P resolveHost...
     P                 B
     D                 PI            10U 0
     D  i_host                         *   const  options(*string: *trim)
      *
      *  Deklarieren Funktionswert
     D ipAdrLong       S             10U 0 inz
      *
      *  Funktionslokale Felder
     D tmpIpAdrLong    S                   like(ipAdrLong ) inz
      *
     D hostent         DS                  likeds(hostent_t) based(pHostent)
     D p1HostAdr       S               *   based(hostent.h_addrlist)
     D hostAdr         S             10U 0 based(p1HostAdr)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // Initialisieren Rückgabewerte
         reset ipAdrLong;

         // SOLANGE BIS alles getan oder Fehler
         dou 1=1;

            // Umsetzen IP Adresse von xxx.xxx.xxx.xxx in 32-Bit Adresse (Long)
            tmpIpAdrLong = inet_addr(i_host);

            // Wenn dies fehlschlägt, dann annehmen, dass der Host name als
            // DNS Name übergeben wurde und versuchen, die IP Adresse
            // anhand des Host-Namens zu ermitteln.
            if tmpIpAdrLong = INADDR_NONE;
               tmpIpAdrLong = 0;
               pHostent = gethostbyname(i_host);
               if pHostent <> *NULL;
                  tmpIpAdrLong = hostAdr;
               endif;
            endif;

            if tmpIpAdrLong = 0;
               sndMsg('Unknown host: ' + %str(i_host): cTrue);
               leave;
            endif;

            // Setzen Funktionswert
            ipAdrLong = tmpIpAdrLong;
         enddo;

         return ipAdrLong;

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  Main procedure
      *===============================================================*
     P main...
     P                 B
     D                 PI
     D i_host                        64A   value  varying
     D i_port                        10I 0 value
      *
      *  Helper fields
     D sd              S             10I 0 inz(-1)
      *
     D sockAddr        DS                  likeds(sockaddr_in_t)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // Do until everything is done or an error occured
         dou 1=1;

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
            sockAddr.sin_zero   = *ALLx'00';

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

      /END-FREE
     P                 E
      *
      *===============================================================*
      *  Log root cause.
      *===============================================================*
     P logRootCause...
     P                 B
     D                 PI
      *
     D errorNbr        s             10i 0 based(pErrorNbr)
     D errorText       s            128a   based(pErrorText)
     D errorMessage    s            128a
      /free

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

      /end-free
     P                 E
      *
