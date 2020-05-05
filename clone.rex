/* rexx - clone ITAUM Application */
parse upper arg action
call init
exit

all:
   call get_lib_info
   call load_info
   call allocate_files
   call load_files
   say '['||time()||']'
exit
return

help:
say ''
say 'STEPS '
say '=================='
say '<blank> to execute all'
say 'get_lib_info'
say 'load_info'
say 'allocate_files'
say 'load_files'
say '' 
say '['||time()||']'
return

init:
   "clear"
   say '['||time()||']'
   say 'Reading Config'
   /* Load variables from config file */
   call config.rex
   do queued()
      parse caseless pull var
      interpret var
   end
   if action = '' then call all
   else interpret call action
return

get_lib_info:

      'bright profiles create zosmf-profile zosmf-sr01brs --host sr01brs.lvn.broadcom.net --port 443 --user roddi01 --pass Praga345 --reject-unauthorized false --ow'
   
      'bright profiles create tso-profile tso-sr01brs --account ACCT# --region-size 250000 --logon-procedure CATSO --ow'

   say ''
   say '['||time()||']'
   say 'Retrieving linfo from ITAUM Application'
   com ='zowe zos-files list data-set "itaum*" -a --rfj > libraries.json'
   say com
   interpret "'"com"'"
return

load_info:
   say ''
   say '['||time()||']'
   say 'Loading Data Set information'
   input_file  = 'libraries.json'
   drop dsname.
   i = 0
   /* Read lines in loop and process them */
   do while lines(input_file) \= 0
      line = linein(input_file)
      select 
         when pos('stdout',line) > 0 then iterate 
         when pos('dsname',line) > 0 then do 
            i = i+1
            parse var line '"dsname": "' dsname.i '",'
            dsname.i.clon = replace_string(dsname.i,'ITAUM',clon)                                       
         end
         when pos('blksz',line) > 0 then parse var line '"blksz": "' dsname.i.blksz '",'
         when pos('dsntp',line) > 0 then parse var line '"dsntp": "' dsname.i.dsntp '",'
         when pos('dsorg',line) > 0 then parse var line '"dsorg": "' dsname.i.dsorg '",'
         when pos('lrecl',line) > 0 then parse var line '"lrecl": "' dsname.i.lrecl '",'
         when pos('recfm',line) > 0 then parse var line '"recfm": "' dsname.i.recfm '",'
         when pos('sizex',line) > 0 then parse var line '"sizex": "' dsname.i.sizex '",'
         otherwise iterate
      end 
      /* close input file */
   end
   call lineout input_file
   dsname.0 = i
return

allocate_files:
   if action <> '' then do 
      call load_info
   end
   say ''
   say '['||time()||']'
   say 'Allocating Files for 'clon 
   say 'Creating 'clon ||'.TEMP File'
   com ="zowe zos-files create classic "clon||".TEMP --bs 6160 --dst LIBRARY --rf FB --rl 80 --sz 1 --ss 1"; interpret '"'com'"'
   com ='zowe zos-files upload file-to-data-set rexxvsam.rex "'|| clon ||'.TEMP(REXXVSAM)"'; interpret "'"com"'"
/*dxr*/
   do i = 1 to dsname.0
      say 'Creating 'dsname.i.clon
      select 
         /* LOAD Libraries */
         when dsname.i.recfm = 'U' then do 
            com ="zowe zos-files create data-set-binary" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --dst" dsname.i.dsntp ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* PDS Libraries */
         when dsname.i.dsntp = 'PDS' then do 
            com ="zowe zos-files create data-set-classic" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --dst" dsname.i.dsntp ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* PDS-E Libraries */
         when dsname.i.dsntp = 'LIBRARY' then do 
            com ="zowe zos-files create data-set-classic" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --dst" dsname.i.dsntp ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* PS Files */
         when dsname.i.DSORG = 'PS' then do 
            com ="zowe zos-files create data-set-sequential" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* VSAM Files */
         when dsname.i.dsorg = 'VS' then do
            if pos('.INDEX',dsname.i) > 0 then iterate
            if pos('.DATA' ,dsname.i) > 0 then iterate

            exec = clon||'.TEMP(REXXVSAM)' 
            say 'zowe tso issue command --ssm "'||ex "'"|| exec ||"'" "'"dsname.i"'" '" | RxQueue'
            
            'zowe tso issue command --ssm "'||ex "'"|| exec ||"'" "'"dsname.i"'" '" | RxQueue'
            drop jcl.
            jcl = 0
            jcl=jcl+1 ; jcl.jcl = '//ITAUVSAM JOB (40600000),CLASS=A,MSGCLASS=X'
            jcl=jcl+1 ; jcl.jcl = '//DEFVSAM  EXEC PGM=IDCAMS'
            jcl=jcl+1 ; jcl.jcl = '//SYSPRINT DD SYSOUT=*'
            jcl=jcl+1 ; jcl.jcl = '//SYSIN    DD *'
            do queued()
               pull sysin
               if pos('SHAREOPTION(',sysin) > 0 then iterate 
               if pos('READY',sysin) > 0 then iterate
               if pos('ENCRYPTION',sysin) > 0 then iterate 
               sysin = replace_string(sysin,'ITAUM',clon)
               if pos('SHAREOPTIONS(',sysin) > 0 then jcl.jcl = ' 'sysin
               else do                                    
                  jcl=jcl+1 ; jcl.jcl = ' 'sysin
               end
               say jcl '> 'sysin
            end
            jcl.0 = jcl
            say 'jcl.0' jcl.0
            "rm temp.jcl"
            output_file = 'temp.jcl' 
            call lineout output_file, , 1
            do j = 1 to jcl.0
               call lineout output_file, jcl.j
            end
            call lineout output_file

            com ="zowe zos-jobs submit local-file temp.jcl --vasc"; interpret '"'com'"'

         end
         otherwise say 'File 'dsname.i 'not cloned'

      end /* select */      
   end /* do i */
   say 'Deleting 'clon ||'.TEMP File'
   com ="zowe zos-files delete data-set "clon||".TEMP -f"; interpret '"'com'"'

return

load_files:
   if action <> '' then do 
      call load_info
   end
   say ''
   say '['||time()||']'
   say 'Populating Fields'
   do i = 1 to dsname.0
      say dsname.i
      select 
         when pos('.INDEX' ,dsname.i) > 0 then iterate
         when pos('.DATA'  ,dsname.i) > 0 then iterate
         when pos('.LOAD'  ,dsname.i) > 0 then iterate
         when pos('.OBJECT',dsname.i) > 0 then iterate
         when pos('.IMS'   ,dsname.i) > 0 then iterate
         when pos('.COPY'  ,dsname.i) > 0 then call copy_and_replace
         when pos('.JCL'   ,dsname.i) > 0 then call copy_and_replace
         when pos('.COBOL' ,dsname.i) > 0 then do 
            call copy_and_replace
            call compile
         end
         when dsname.i.dsorg = 'PS' then 'zowe zos-files copy data-set "'||dsname.i||'" "'||dsname.i.clon||'"'
         when dsname.i.dsorg = 'PDS' then call iebcopy
         when dsname.i.dsntp = 'LIBRARY' then call iebcopy

         when dsname.i.dsorg = 'VS' then call repro
         otherwise nop
      end
   end
return

copy_and_replace:
   com = 'zowe zos-files list all-members "'||dsname.i||'"'
   interpret "'"com"  | RxQueue'"
   do queued()
      pull member
      newmember = replace_string(member,'ITAUM',clon)                                       

      drop jcl.
      jcl = 0
      jcl=jcl+1 ; jcl.jcl = '//ITAUSORT JOB (40600000),CLASS=A,MSGCLASS=X'
      jcl=jcl+1 ; jcl.jcl = '//SORT     EXEC PGM=SORT'
      jcl=jcl+1 ; jcl.jcl = '//SYSOUT   DD SYSOUT=*'
      jcl=jcl+1 ; jcl.jcl = '//SORTIN   DD DSN='|| dsname.i ||   '('|| member    ||'),DISP=SHR'
      jcl=jcl+1 ; jcl.jcl = '//SORTOUT  DD DSN='|| dsname.i.clon ||'('|| newmember ||'),DISP=SHR'
      jcl=jcl+1 ; jcl.jcl = '//SYSOUT   DD SYSOUT=*'
      jcl=jcl+1 ; jcl.jcl = '//SYSPRINT DD SYSOUT=*'
      jcl=jcl+1 ; jcl.jcl = '//SYSIN DD *'
      jcl=jcl+1 ; jcl.jcl = ' OPTION COPY'
      jcl=jcl+1 ; jcl.jcl = " OUTREC FINDREP=(IN=C'ITAUM',OUT=C'"|| clon ||"')"
      jcl.0 = jcl
      "rm temp.jcl"
      output_file = 'temp.jcl' 
      call lineout output_file, , 1
      do j = 1 to jcl.0
         call lineout output_file, jcl.j
      end
      call lineout output_file

      com ="zowe zos-jobs submit local-file temp.jcl --vasc"; interpret '"'com'"'
   end
return

repro:
   drop jcl.
   jcl = 0
   jcl=jcl+1 ; jcl.jcl = '//ITAUREPR JOB (40600000),CLASS=A,MSGCLASS=X'
   jcl=jcl+1 ; jcl.jcl = '//STEP1  EXEC PGM=IDCAMS '
   jcl=jcl+1 ; jcl.jcl = '//IN  DD DSN='|| dsname.i ||',DISP=SHR'
   jcl=jcl+1 ; jcl.jcl = '//OUT DD DSN='|| dsname.i.clon ||',DISP=SHR'
   jcl=jcl+1 ; jcl.jcl = '//SYSPRINT DD SYSOUT=*'
   jcl=jcl+1 ; jcl.jcl = '//SYSIN DD *'
   jcl=jcl+1 ; jcl.jcl = ' REPRO INFILE(IN) -'
   jcl=jcl+1 ; jcl.jcl = ' OUTFILE(OUT)'
   jcl.0 = jcl
   "rm temp.jcl"
   output_file = 'temp.jcl' 
   call lineout output_file, , 1
   do j = 1 to jcl.0
      call lineout output_file, jcl.j
   end
   call lineout output_file

   com ="zowe zos-jobs submit local-file temp.jcl --vasc"; interpret '"'com'"'
return

iebcopy:
   drop jcl.
   jcl = 0
   jcl=jcl+1 ; jcl.jcl = '//ITAUIEBC JOB (40600000),CLASS=A,MSGCLASS=X'
   jcl=jcl+1 ; jcl.jcl = '//JOBSTEP  EXEC  PGM=IEBCOPY'
   jcl=jcl+1 ; jcl.jcl = '//SYSPRINT DD  SYSOUT=A'
   jcl=jcl+1 ; jcl.jcl = '//SYSUT1   DD  DSNAME='|| dsname.i ||','
   jcl=jcl+1 ; jcl.jcl = '//             DISP=SHR'
   jcl=jcl+1 ; jcl.jcl = '//SYSUT2   DD  DSNAME='|| dsname.i.clon ||','
   jcl=jcl+1 ; jcl.jcl = '//             DISP=SHR'
   jcl.0 = jcl
   "rm temp.jcl"
   output_file = 'temp.jcl' 
   call lineout output_file, , 1
   do j = 1 to jcl.0
      call lineout output_file, jcl.j
   end
   call lineout output_file

   com ="zowe zos-jobs submit local-file temp.jcl --vasc"; interpret '"'com'"'
return

compile:
   com ='zowe zos-files list all-members "'dsname.i.clon'"'
   interpret "'"com"  | RxQueue'"

   member.0 = queued()
   input_file  = 'comp.jcl'
   output_file = 'temp.jcl' 
   do i=1 to member.0
      member.i = linein("QUEUE:")
      /* Open output for writing */
      call lineout output_file, , 1
      /* Read lines in loop and process them */
      do while lines(input_file) \= 0
         line = linein(input_file)
         if pos("&env",line) > 0 then do
            parse var line head '&env' tail
            line = head || clon || tail
         end 
         if pos("&member",line) > 0 then do
            parse var line head '&member' tail
            line = head || member.i || tail
         end 
         /* write line to the output file */
         call lineout output_file, line
         say line
      end
      /* close all files */
      call lineout output_file
      call lineout input_file
      com ="zowe zos-jobs submit local-file temp.jcl"; interpret '"'com'"'
   end
return

replace_string:
   retstring  = arg(1)                                               
   arg2length = length(arg(2))                                       
   do forever                                                        
   look4_pos = pos(arg(2),retstring)                                 
   if substr(retstring,look4_pos+arg2length,1) ?= ' ' then leave     
   if look4_pos = 0 then leave                                       
      retstring  = substr(retstring,1,look4_pos-1)||,                   
      arg(3)||,                                                         
      substr(retstring,look4_pos+arg2length)                            
   end                                                               
return retstring