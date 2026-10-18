/*===================================================================*/
/*                                                                   */
/* Kurzdokumentation :                                               */
/*                                                                   */
/* Bereich . . . : Ping Port                                         */
/* Objekt  . . . : PINGPORT                                          */
/* Beschreibung  : Tool: Ping with Port                              */
/* Author  . . . : Thomas Raddatz   <thomas.raddatz@tools400.de>     */
/* Datum . . . . : 09.11.2007                                        */
/*                                                                   */
/*===================================================================*/
/*                                                                   */
/* This software is free software, you can redistribute it and/or    */
/* modify it under the terms of the GNU General Public License (GPL) */
/* as published by the Free Software Foundation.                     */
/*                                                                   */
/* See GNU General Public License for details.                       */
/*         http://www.opensource.org                                 */
/*         http://www.opensource.org/licenses/gpl-license.html       */
/*                                                                   */
/*===================================================================*/
/* History:                                                          */
/*                                                                   */
/* Datum       Name          Änderung                                */
/* ----------  ------------  --------------------------------------- */
/*                                                                   */
/*===================================================================*/
/*>>PRE-COMPILER<<                                                   */
/*                                                                   */
/*  >>CRTCMD<< CRTCMD       CMD(&LI/&OB) +                           */
/*                          SRCFILE(&SL/&SF) +                       */
/*                          SRCMBR(&SM);                             */
/*                                                                   */
/*  >>COMPILE<<                                                      */
/*    >>PARM<< PGM(*LIBL/PINGPORTR);                                 */
/*    >>PARM<< HLPPNLGRP(*LIBL/PINGPORTP);                           */             /*RADD*/
/*    >>PARM<< HLPID(PINGPORT);                                      */             /*RADD*/
/*    >>PARM<< PRDLIB(&LI);                                          */
/*  >>END-COMPILE<<                                                  */
/*                                                                   */
/*  >>EXECUTE<<                                                      */
/*                                                                   */
/*>>END-PRE-COMPILER<<                                               */
/*===================================================================*/

             CMD        PROMPT('Ping with Port')

             PARM       KWD(HOST)              +
                        MIN(1)                 +
                        TYPE(*CHAR)            +
                        VARY(*YES *INT2)       +
                        LEN(256)               +
                        PROMPT('Host name or IP address')

             PARM       KWD(PORT)              +
                        TYPE(*INT4)            +
                        MIN(1)                 +
                        PROMPT('Port number')

