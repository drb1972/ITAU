/* rexx - clone ITAUM Application */
parse upper arg action
call init

exit
say '['||time()||']'
all:
   call get_lib_info
   call load_info
   call allocate_files
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
say '' 
say '['||time()||']'
return

init:
   "clear"
   say '['||time()||']'
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
   com ='zowe zos-files list data-set "itaum*" -a --rfj > libraries.json'; interpret "'"com"'"
return

load_info:
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
            dsname.i.clon = TRANSLATE(line,clon,'ITAUM')  
         end
         when pos('blksz',line) > 0 then parse var line '"blksz": "' dsname.i.blksz '",'
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
      call init
      call load_info
   end

   com ="zowe zos-files create classic "clon||".TEMP --bs 6160 --dst LIBRARY --rf FB --rl 80 --sz 1 --ss 1"; interpret '"'com'"'
   com ="zowe zos-files upload file-to-dataset rexxvsam.rex "clon||".TEMP(REXXVSAM)"; interpret '"'com'"'

   do i = 1 to dsname.0
      say 'Creating 'dsname.i.clon
      select 
         /* LOAD Libraries */
         when dsname.i.????? = '???' then do ??? /* dxr */
            com ="zowe zos-files create data-set-binary" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* PDS Libraries */
         when dsname.i.????? = '???' then do ??? /* dxr mirar data-set type */
            com ="zowe zos-files create data-set-classic" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* PS Files */
         when dsname.i.????? = '???' then do ??? /* dxr */
            com ="zowe zos-files create data-set-classic" dsname.i.clon ,
               " --bs " dsname.i.blksz ,
               " --rf " dsname.i.recfm ,
               " --rl " dsname.i.lrecl ,
               " --sz " dsname.i.sizex ,
               " --ss 15"
            interpret '"'com'"'
         end
         /* VSAM Files */
         when dsname.i.????? = '???' then do ??? /* dxr */
            if pos('.INDEX',dsname.i) > 0 then iterate
            if pos('.DATA' ,dsname.i) > 0 then iterate
            vsam = "'"dsname.i"'"
            com1 = "'"clon||".TEMP(REXXSAM)'"
            com = 'zowe tso issue cmd --ssm "ex 'com1' 'vsam'"'
            interpret "'"com"  | RxQueue'"
            drop jcl.
            jcl = 0
            jcl=jcl+1 ; jcl.jcl = '//ITAUVSAM JOB (40600000),CLASS=A,MSGCLASS=X'
            jcl=jcl+1 ; jcl.jcl = '//DEFVSAM  EXEC PGM=IDCAMS'
            jcl=jcl+1 ; jcl.jcl = '//SYSPRINT DD SYSOUT=*'
            jcl=jcl+1 ; jcl.jcl = '//SYSIN    DD *'
            do queued()
               pull sysin
               if pos(dsname.i,sysin) > 0 then do
                  parse var sysin head dsname.i tail
                  sysin = head dsname.i.clon tail
               end
               jcl=jcl+1 ; jcl.jcl = ' 'sysin
            end

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
         otherwise say 'File 'dsname.i 'not cloned'

      end /* select */      
   end /* do i */
   com ="zowe zos-files delete "clon||".TEMP -f"; interpret '"'com'"'

return