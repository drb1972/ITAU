//ITAU9CMP JOB (40600000),CLASS=A,MSGCLASS=X
//*
//* ITAU9002
//*
//COMPILE  EXEC  PGM=IGYCRCTL
//STEPLIB  DD  DSN=IGY.SIGYCOMP,DISP=SHR
//*
//SYSPRINT DD  SYSOUT=(*)
//SYSIN    DD  DSN=ITAU9.COBOL(ITAU9002),
//   DISP=SHR
//SYSPUNCH DD  DUMMY
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT2   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT3   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT4   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT5   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT6   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT7   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT8   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT9   DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT10  DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT11  DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT12  DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT13  DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT14  DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT15  DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSMDECK DD  UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//         DD  DSN=ITAU9.COBOL(ITAU9002),DISP=SHR
//SYSLIN   DD  DSN=ITAU9.OBJECT(ITAU9002),DISP=SHR
//*
//LKED   EXEC PGM=HEWL,COND=(8,LT,COMPILE),REGION=1024K
//SYSLIB   DD DSNAME=CEE.SCEELKED,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSNAME=ITAU9.OBJECT(ITAU9002),DISP=SHR
//         DD DDNAME=SYSIN
//SYSLMOD  DD DSNAME=ITAU9.LOAD(ITAU9002),DISP=SHR
//SYSUT1   DD UNIT=VIO,SPACE=(TRK,(10,10))
//GO     EXEC PGM=*.LKED.SYSLMOD,COND=((8,LT,COMPILE),(4,LT,LKED)),
//            REGION=2048K
//STEPLIB  DD DSNAME=CEE.SCEERUN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//LKED   EXEC PGM=HEWL,COND=(8,LT,COMPILE),REGION=1024K
//SYSLIB   DD DSNAME=CEE.SCEELKED,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSNAME=ITAU9.OBJECT(ITAU9002),DISP=SHR
//         DD DDNAME=SYSIN
//SYSLMOD  DD DSNAME=ITAU9.IMS.LOAD(ITAU9002),DISP=SHR
//SYSUT1   DD UNIT=VIO,SPACE=(TRK,(10,10))
//GO     EXEC PGM=*.LKED.SYSLMOD,COND=((8,LT,COMPILE),(4,LT,LKED)),
//            REGION=2048K
//STEPLIB  DD DSNAME=CEE.SCEERUN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//LKED   EXEC PGM=HEWL,COND=(8,LT,COMPILE),REGION=1024K
//SYSLIB   DD DSNAME=CEE.SCEELKED,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSNAME=ITAU9.OBJECT(ITAU9002),DISP=SHR
//         DD DDNAME=SYSIN
//SYSLMOD  DD DSNAME=ITAU9.CICS.LOAD(ITAU9002),DISP=SHR
//SYSUT1   DD UNIT=VIO,SPACE=(TRK,(10,10))
//GO     EXEC PGM=*.LKED.SYSLMOD,COND=((8,LT,COMPILE),(4,LT,LKED)),
//            REGION=2048K
//STEPLIB  DD DSNAME=CEE.SCEERUN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//LKED   EXEC PGM=HEWL,COND=(8,LT,COMPILE),REGION=1024K
//SYSLIB   DD DSNAME=CEE.SCEELKED,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSNAME=ITAU9.OBJECT(ITAU9002),DISP=SHR
//         DD DDNAME=SYSIN
//SYSLMOD  DD DSNAME=ITAU9.DBRM(ITAU9002),DISP=SHR
//SYSUT1   DD UNIT=VIO,SPACE=(TRK,(10,10))
//GO     EXEC PGM=*.LKED.SYSLMOD,COND=((8,LT,COMPILE),(4,LT,LKED)),
//            REGION=2048K
//STEPLIB  DD DSNAME=CEE.SCEERUN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//CEEDUMP  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
