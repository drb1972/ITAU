/* rexx - clone ITAUM Application */
/* If no */
parse upper arg action
call init

exit

all:
   call get_lib_info
   call allocate
exit
return

init:
   if action = '' then do /* read config.rex */
      say '['||time()||'] Start Clonning Process'
      /* Load variables from config file */
      call config.rex
      do queued()
         parse caseless pull var
         interpret var
      end
   end
   if action = '' then call all
   else interpret call action
return

get_lib_info:
   com ='zowe  zos-files list data-set "itaum*" -a --rfj > libraries.json'; interpret "'"com"'"
   input_file  = 'libraries.json'
   drop dsname.
   i = 0
   /* Read lines in loop and process them */
   do while lines(input_file) \= 0
      line = linein(input_file)
      if pos('ITAUM',line) > 0 then TRANSLATE(line,clon,'ITAUM')  
      select 
         when pos('stdout',line) > 0 then iterate 
         when pos('dsname',line) > 0 then do 
            i = i+1
            parse var line '"dsname": "' dsname.i '",'
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

allocate:
   do i = 1 to dsname.0
   say dsname.i
   end


return