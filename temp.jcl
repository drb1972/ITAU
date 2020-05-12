//ITAUVSAM JOB (40600000),CLASS=A,MSGCLASS=X
//DEFVSAM  EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
   DEFINE CLUSTER ( -
       NAME(ITAU8.VSAM1) -
            INDEXED -
            STORAGECLASS(USER) -
            DATACLASS(USER) -
            SHAREOPTIONS(1,3) -
       ) -
   DATA( -
       NAME(ITAU8.VSAM1.DATA) -
            BUFFERSPACE(12288) -
            CONTROLINTERVALSIZE(4096) -
            KEYS(6 1) -
            RECORDSIZE(80 80) -
            TRACK(1 1) -
            VOLUMES(USER03) -
       ) -
   INDEX( -
       NAME(ITAU8.VSAM1.INDEX) -
            CONTROLINTERVALSIZE(4096) -
            TRACK(1 1) -
            VOLUMES(USER03) -
            )
 
