function tr_lut_conv, in, basefil, times, dir=dir, $
	ic=ic, oc=oc, qdebug=qdebug, qstop=qstop
;
;+
;NAME:
;	tr_lut_conv
;PURPOSE:
;	TRACE routine to allow lookup table (lut) conversions of
;	input values.
;SAMPLE CALLING SEQUENCE:
;	print, tr_lut_conv(in, basefil, times)
;	print, tr_lut_conv(4, 'wave_table')
;	prstr, tr_lut_conv(indgen(32), 'wave_table')
;INPUT:
;	in	- integer table entry numbers
;	basefil	- The base filename.  A valid start date/time is
;		  encoded in the filename to say when it started
;		  being active
;	times	- The times for each of the input values.  The
;		  input is assumed to be time sorted.
;OUTPUT:
;	out	- The lookup table value.  If the value is not
;		  in the table, then '????' is returned.  If it
;		  can't find a lookup table file for the proper
;		  time, then 'LUT_NFF' is returned.
;HISTORY:
;	Written 29-Jan-98 by M.Morrison
;	19-Feb-98 (MDM) - Modified to do the file listings once
;			  to speed things up
;        7-Apr-1998 S.L.Freeland - $SSW_TRACE environmental
;       13-May-19 (FZ)  - Changed loop variable to long
;       29-mar-2006 - S.L.Freeland - apply Windows tweak suggested by Y.P.Li
;       23-Apr-2026 - Zarro (Retired) - pre-parse table files for valid FIDs
;-
;
common tr_lut_conv_blk2, dir_save, ff_save, tim_save
;
n = n_elements(in)
out = strarr(n) + 'LUT_NFF'	;"no file found"
;
if (n_elements(ic) eq 0) then ic = 0	;input column
if (n_elements(oc) eq 0) then oc = 1	;output column
if n_elements(dir) eq 0 then $
   dir=concat_dir(concat_dir(concat_dir('SSW_TRACE','dbase'),'cal'),'lut')

if not file_exist(dir(0)) then  dir = '/tsw/dbase/cal/lut'	;backward compat
;
qread = n_elements(ff_save) eq 0	;nothing done yet
if (keyword_set(dir_save)) then if (dir_save ne dir) then qread = 1	;new directory
if qread then begin
    print, 'TR_LUT_CONV: Looking for lookup table files in ' + dir + ' ...'
    ff_save = file_list(dir, '*')
	valid=parse_time(ff_save,count=count,ss=ss)
	if count gt 0 then ff_save=ff_save[ss]
    dir_save = dir
    tim_save = file2time(ff_save)
end
;
ss = wc_where(ff_save, '*' + get_delim() + basefil + '*', nss)
if (nss eq 0) then begin
    print, 'TR_LUT_CONV: Cannot find any files: ' + basefil + ' in dir='+dir
    return, out
end
ff = ff_save(ss)
tim = tim_save(ss)
;
if (keyword_set(times)) then stimes = anytim(times, /ccsds) $
			else stimes = anytim(ut_time(), /ccsds)
if (n_elements(stimes) ne n) then stimes = replicate(stimes(0), n)
if (keyword_set(qdebug)) then print, 'TR_LUT_CONV: Input time ' + stimes(0)
if (keyword_set(qdebug)) then fmt_timer, tim
;
for ifil=n_elements(ff)-1,0L do begin	;work backwards through the list of files
    if (keyword_set(qdebug)) then print, 'Checking file: ' + ff(ifil)
    ss = where((stimes ge tim(ifil)) and (out eq 'LUT_NFF'), nss)
    if (nss ne 0) then begin
	if (keyword_set(qdebug)) then print, 'TR_LUT_CONV: Reading ' + ff(ifil)
	mat = rd_ulin_col(ff(ifil), nocomment='#', /nohead)
	inarr = long( mat(ic,*) )
	outarr= mat(oc,*)
	ss2 = where_arr( in(ss), inarr, nss2, /map_ss)
	out(ss) = '????'	;value is not in the lookup table
	ss3 = where(ss2 ne -1, nss3)
	if (nss3 ne 0) then out(ss(ss3)) = outarr(ss2(ss3))
    end
end
;
if (n_elements(out) eq 1) then out = out(0)	;make it scalar
if (keyword_set(stop)) then stop
return, out
end
;-------------------------------------------------------------
;0.052 sec for FILE2TIME
;0.013 sec for ANYTIM
;0.043 sec for UT_TIME()
;0.014 sec for RD_ULIN_COL
;-------
;0.14 sec per TR_LUT_CONV call (for a single file) with no input time
;0.095 sec per TR_LUT_CONV with an input time
;
;New
;0.04 sec per TR_LUT_CONV with an input time
