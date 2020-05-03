/*------------------- REXX -----------------------------------*
 *                                                            *
 * This code either displays a VSAM entry or writes the       *
 * IDCAMS control statement needed to define a VSAM file.     *
 * (MUST run under ISPF)                                      *
 *                                                            *
 * From ISPF 3.4, type VC next to a VSAM data set             *
 *                                                            *
 * Originally Written by Jim Connelley.  No copyright.        *
 * Ifyawanna, (If you want to) send your enhancements to      *
 *                                                            *
 * Updated: 2005 -- Ted MacNEIL. Same disclaimer.             *
 *               -- I needed a method to clean up our old     *
 *                  VSAM with the keywords: REPLICATE, IMBED  *
 *                  and KEYRANGE. This was the fastest way.   *
 *                  Those parameters are caught but not       *
 *                  written to control cards.                 *
 *                  I also added a few lines to do a:         *
 *                  DELETE ------ PURGE at the front          *
 *                                                            *
 * There are bugs, such as handling multi-volume files, but   *
 * that's where YOU come in.                                  *
 * (-- Ted MacNEIL -- I believe I fixed this bug, but I did   *
 *  --             -- not have any multi-volumes to test with)*
 *                                                            *
 * (-- The dependency on STEMVIEW was removed to either write *
 *  -- out to a file or say inside a loop)                    *
 *                                                            *
 * CBTTAPE FILE 493                                           *
 *                                                            *
 *------------------------------------------------------------*
 * %VC3 VSAMDSN pds member                                    *
 *                                                            *
 *   VSAMDSN -- the VSAM FILE you wish to CLONE               *
 *              (if you specify quotes, they are removed)     *
 *                                                            *
 *   pds     -- where to output the control cards             *
 *            - default: <userid>.VSAM.CONTROL.CARDS          *
 *                                                            *
 *   member  -- the member name used to output the statements *
 *                                                            *
 *                                                            *
 *   NOTE: if PDS does not exist, this outputs to the screen  *
 *                                                            *
 *------------------------------------------------------------*
 */
trace
parse arg data_set_name dsname member
  indent = copies(' ',5)
  address "TSO"
  call init_variables
  call execute_listcat
  call process_listcat
  call addkey ")"        /* add closing paren */
  out_line.0 = x         /* set total linecount */
  call output_results
exit 0

/*------------------------------------------------------------*
 *                                                            *
 * process_listcat drives the processing of the LISTCAT       *
 * output.                                                    *
 *                                                            *
 *------------------------------------------------------------*
 */
process_listcat:
do i = 1 to trap_line.0
  parse var trap_line.i field1 the_rest
  select
    When field1 = 'NONVSAM' Then Do
        say
        say member || ":" data_set_name "NONVSAM (Possibly Migrated)"
        say
        Exit 4
        end
    When field1 = 'CLUSTER' Then Do
      big_state = 'CLUSTER'
      Parse Var the_rest . object_name
      x = 1
      out_line.x = indent "DEFINE CLUSTER ("
      indent = copies(' ',5)
      Call addkey "NAME(" || object_name || ")"
      indent = copies(' ',10)
      Call addkey "INDEXED"          /* KLUDGE default LINE 7 */
      Call addkey "SHAREOPTION(2 1)" /* KLUDGE default LINE 8 */
      End
    When field1 = 'DATA' Then Do
      big_state = 'DATA'
      Parse Var the_rest . data_name
      indent = copies(' ',5)
      Call addkey ")"
      indent = copies(' ',1)
      Call addkey "DATA("
      indent = copies(' ',5)
      Call addkey "NAME(" || data_name || ")"
      volstate = "VOLUMENOTDONE"
      indent = copies(' ',10)
      End
    When field1 = 'INDEX' Then Do
      big_state = 'INDEX'
      Parse Var the_rest . index_name
      indent = copies(' ',5)
      Call addkey ")"
      indent = copies(' ',1)
      Call addkey "INDEX("
      indent = copies(' ',5)
      Call addkey "NAME(" || index_name || ")"
      volstate = "VOLUMENOTDONE"
      indent = copies(' ',10)
      End
    When field1 = 'HISTORY' Then Do
      state = 'HISTORY'
      End
    When field1 = 'SMSDATA' Then Do
      state = 'SMSDATA'
      End
    When field1 = 'RLSDATA' Then Do
      state = 'RLSDATA'
      End
    When field1 = 'ASSOCIATIONS' Then Do
      state = 'ASSOCIATIONS'
      End
    When field1 = 'ATTRIBUTES' Then Do
      state = 'ATTRIBUTES'
      End
    When field1 = 'STATISTICS' Then Do
      state = 'STATISTICS'
      End
    When field1 = 'ALLOCATION' Then Do
      state = 'ALLOCATION'
      End
    When field1 = 'VOLUME' Then Do
      state = 'VOLUME'
      End
    Otherwise
      Select
        When state = 'SMSDATA' Then Do
          Call do_smsdata
          End
        When state = 'ATTRIBUTES' Then Do
          Call do_attributes
          End
        When state = 'ALLOCATION' Then Do
          Call do_allocation
          End
        When state = 'VOLUME' Then Do
          Call do_volume
          End
        Otherwise
          Nop
      End /* Select state */
  End /* Select field1 */
End

Return

/*------------------------------------------------------------*
 *                                                            *
 * do_smsdata processes the keywords found under the SMSDATA  *
 * section of output from listcat command.                    *
 *                                                            *
 *------------------------------------------------------------*
 */
do_smsdata:

  keyval = getkey('STORAGECLASS' trap_line.i)
  If keyval /= '' Then
    Call addkey "STORAGECLASS(" || keyval || ")"

  keyval = getkey('MANAGEMENTCLASS' trap_line.i)
  If keyval /= '' Then
    Call addkey "MANAGEMENTCLASS(" || keyval || ")"

  keyval = getkey('DATACLASS' trap_line.i)
  If keyval /= '' Then
    Call addkey "DATACLASS(" || keyval || ")"

  keyval = getkey('BWO----' trap_line.i)
  If keyval /= '' Then
    Call addkey "BWO(" || keyval || ")"

  Return

/*------------------------------------------------------------*
 *                                                            *
 * do_volume processes the keywords and values found under    *
 * under the volume section of the LISTCAT command.           *
 * Currently, we are only interested in the VOLUME keyword.   *
 *                                                            *
 *------------------------------------------------------------*
 */
do_volume:

  keyval = getkey('VOLSER' trap_line.i)
  If keyval /= '' & volstate /= "VOLUMEDONE" then do
    Call addkey "VOLUMES(" || keyval || ")"
    volstate = "VOLUMEDONE"
    end

  Return

/*------------------------------------------------------------*
 *                                                            *
 * do_allocation processes the keywords and values found      *
 * under the allocation section of the LISTCAT command.       *
 *                                                            *
 *------------------------------------------------------------*
 */
do_allocation:

  keyval = getkey('SPACE-TYPE' trap_line.i)
  If keyval /= '' Then
    space_type = keyval

  keyval = getkey('SPACE-PRI' trap_line.i)
  If keyval /= '' Then
    space_pri = keyval

  keyval = getkey('SPACE-SEC' trap_line.i)
  If keyval /= '' Then
    Call addkey space_type || "(" || space_pri keyval || ")"

  Return

/*------------------------------------------------------------*
 *                                                            *
 * do_attributes process the non-default data under the       *
 * ATTRIBUTES section of output from the LISTCAT command.     *
 *                                                            *
 *------------------------------------------------------------*
 */
do_attributes:

  If big_state = 'DATA' Then
    Call do_attributes_data

  If big_state = 'INDEX' Then
    Call do_attributes_index

  keyval = getkey('BUFSPACE' trap_line.i)
  If keyval /= '' Then
    Call addkey "BUFFERSPACE(" || keyval || ")"

  keyval = getkey('EXCPEXIT' trap_line.i)
  If keyval /= '' Then
    Call addkey "EXCEPTIONEXIT(" || keyval || ")"

  keyval = getkey('CISIZE' trap_line.i)
  If keyval /= '' Then
    Call addkey "CONTROLINTERVALSIZE(" || keyval || ")"

  position = pos('SHROPTNS',trap_line.i)
  /*
   *********************************************************
   * This kludge took a while to understand, but since the *
   * outputted values from LISTCAT puts this in a different*
   * place than required for IDCAMS, that is what this code*
   * handles  -- 2005: --tm                                *
   *********************************************************
   */
  If position /= 0 Then Do
    position = position + length('SHROPTNS(')
    keyval = substr(trap_line.i,position,3)
    out_line.8 = indent "SHAREOPTIONS(" || keyval || ") -"
    End

  Call findkey "WRITECHECK"
  Call findkey "REUSE"

  /*
   *********************************************************
   * This kludge took a while to understand, but since the *
   * outputted values from LISTCAT puts this in a different*
   * place than required for IDCAMS, that is what this code*
   * handles  -- 2005: --tm                                *
   *********************************************************
   */
  If wordpos("NONINDEXED",trap_line.i) /= 0 then do
       out_line.7 = indent "NONINDEXED"
       end
  If wordpos("NUMBERED",trap_line.i) /= 0 then do
       out_line.7 = indent "NUMBERED"
       end
  If wordpos("LINEAR",trap_line.i) /= 0 then do
       out_line.7 = indent "LINEAR"
       end

  Return

/*------------------------------------------------------------*
 *                                                            *
 * do_attributes_data processes those keywords that are       *
 * only valid for the data portion of a cluster.        .     *
 * Currently these are KEYS(), RECORDSIZE(), erase and speed. *
 *                                                            *
 *------------------------------------------------------------*
 */
do_attributes_data:

  keyval = getkey('KEYLEN' trap_line.i)
  If keyval /= '' Then
    keylen = keyval

  keyval = getkey('RKP' trap_line.i)
  If keyval /= '' Then
    Call addkey "KEYS(" || keylen keyval || ")"

  keyval = getkey('AVGLRECL' trap_line.i)
  If keyval /= '' Then
    avglrecl = keyval

  keyval = getkey('MAXLRECL' trap_line.i)
  If keyval /= '' Then
    Call addkey "RECORDSIZE(" || avglrecl keyval || ")"

  Call findkey "ERASE"
 /*
  Call findkey "SPEED"
  */

  Return

/*------------------------------------------------------------*
 *                                                            *
 * do_attributes_index processes those keywords that are      *
 * only valid for the index portion of a cluster.             *
 * Currently these are REPLICATE and INBED.                   *
 *                                                            *
 *------------------------------------------------------------*
 */
do_attributes_index:
  Return
  Call findkey "REPLICATE"
  Call findkey "IMBED"
  Return

/*------------------------------------------------------------*
 *                                                            *
 * getkey function scans a passed string for a                *
 * specific keyword.  If the keyword is found, getkey         *
 * returns a value associated with the keyword.               *
 *                                                            *
 * getkey is oriented to that ugly listcat output such as:    *
 *     STORAGECLASS -----SCPRIM                               *
 * example:                                                   *
 *  getkey('STORAGECLASS','STORAGECLASS -----SCPRIM')         *
 *                                                            *
 * getkey will return SCPRIM                                  *
 *                                                            *
 *------------------------------------------------------------*
 */
getkey: procedure
  Parse Arg keyword  str
  ret_str = ''
  position = pos(keyword,str)
  If position /= 0 Then Do
    len = length(keyword)
    position = position + len
    len = 24  - len
    ret_str = strip(strip(substr(str,position,len)),,'-')
    If ret_str = '(NULL)' Then ret_str = ''
    End
  Return ret_str

/*------------------------------------------------------------*
 *                                                            *
 * findkey scans for a passed string and if it is found,      *
 * adds the same string to the DEFINE statement.              *
 *                                                            *
 *------------------------------------------------------------*
 */
findkey:
  Parse Arg keyword
  If wordpos(keyword,trap_line.i) /= 0 Then
    Call addkey keyword
  Return

/*------------------------------------------------------------*
 *                                                            *
 * addkey procedure simply adds a passed value to the         *
 * DEFINE statement that we are building.                     *
 *                                                            *
 * Put a check here for keywords such as recordsize(0 0)      *
 *   Return if found, because IDCAMS rejects such values      *
 *     as being 'out of range'.                               *
 *                                                            *
 *------------------------------------------------------------*
 */
addkey: procedure expose out_line. x indent
  Parse Arg keyword
  length_keyword = length(keyword)
  If length_keyword > 3 Then
    If substr(keyword,length_keyword-2,3) = '(0)' Then
      Return
  If length_keyword > 5 Then
    If substr(keyword,length_keyword-4,5) = '(0 0)' Then
      Return
  out_line.x = out_line.x "-"
  x = x + 1
  out_line.x = indent keyword
  Return

/*------------------------------------------------------------*
 *                                                            *
 * execute_listcat calls listcat command and handles return.  *
 *                                                            *
 *------------------------------------------------------------*
 */
execute_listcat:
data_set_name = strip(data_set_name,,"'")

y = outtrap('trap_line.') 
"listcat entry('" || data_set_name || "') all" 

If RC /= 0 Then Do
  say
  say member || ": '" || data_set_name || "' Not found"
  say
  Exit 4
  End
y = outtrap('off') 

If DATATYPE(trap_line.0)  /= 'NUM' Then Do
  say
  say member || ": No specification for" data_set_name
  say
  Exit 4
  End
Return

/*------------------------------------------------------------*
 *                                                            *
 * init_variables is coded promarily so we can add comments   *
 * about the variables used in this REXX.                     *
 *                                                            *
 *------------------------------------------------------------*
 */
init_variables:
if sysvar("SYSISPF")�="ACTIVE" then do
   say "Usage: %VC3 <ENTRY> pds member"
   say "-pds- & -member- are optional."
   say "MUST run under ISPF!"
   exit 8
   end

drop trap_line.                        /* trapped from listcat */
drop out_line.                         /* output array */
drop state                             /* currently parsing this */
drop object_name                       /* cluster name */
drop data_name                         /* data name */
drop index_name                        /* index name */
x = 0                                  /* current output line */
indent = copies(' ',1)
return

/*------------------------------------------------------------*
 *                                                            *
 * Generate the next member -- VSAM####                       *
 *                                                            *
 *------------------------------------------------------------*
 */

gencount:
  dummy = msg("OFF")
  address "TSO" "DELETE VSAM.MEMBERS"
  dummy = msg("ON")

  address "ISPEXEC"
    "LMINIT   DATAID(ID) DATASET(" || dsname || ") ENQ(SHR)"
    "LMOPEN DATAID(" || id || ")"
    "LMMLIST DATAID(" || id || ") OPTION(SAVE) GROUP(VSAM)",
            "STATS(NO) PATTERN(VSAM*)"
    "LMCLOSE  DATAID(" || id || ")"
    "LMFREE   DATAID(" || id || ")"

    /* Special Case: Empty CONTROL CARDS dataset */
    dummy = msg("OFF")
    if sysdsn('VSAM.MEMBERS') �= "OK" then do
       return VSAM0001
       end
    dummy = msg("ON")

    address "TSO"
      drop control.
       "ALLOC F(INMEM) DA(VSAM.MEMBERS) SHR"
       "EXECIO * DISKR INMEM (FINIS STEM CONTROL."
       "FREE F(INMEM)"
       dummy = msg("OFF")
       "DELETE VSAM.MEMBERS"
       dummy = msg("ON")
       i = control.0
       lastmem = control.i
       lastmem = strip(lastmem,," ")
       lastmem = substr(lastmem,5)
       if �datatype(lastmem,"NUM") then num = "0001"
       else                             num = lastmem+1
       if length(num) = 1 then num = "000" || num
       if length(num) = 2 then num =  "00" || num
       if length(num) = 3 then num =   "0" || num
   return "VSAM" || num
/*------------------------------------------------------------*
 *                                                            *
 * Output any results and then exit this exec.                *
 *                                                            *
 *------------------------------------------------------------*
 */
output_results:

if length(dsname) < 1 then dsname = "VSAM.CONTROL.CARDS"
if sysdsn(dsname) = "OK" then do
   if length(member) < 1 then member = gencount()
   address "TSO"
   dummy = msg("OFF")
   "FREE FI(VSAMCNTL)"
   dummy = msg("ON")
   "ALLOC FI(VSAMCNTL) REUSE OLD DA(" || dsname || "(" || member || ")"
   "EXECIO * DISKW VSAMCNTL (FINIS STEM OUT_LINE."
   "FREE F(VSAMCNTL)"
   end
else do
    do i=1 to out_line.0
        say out_line.i
        end
    end
return
