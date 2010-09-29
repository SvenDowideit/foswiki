<?php
global $BEAUT_PATH;
if (!isset ($BEAUT_PATH)) return;
require_once("$BEAUT_PATH/Beautifier/HFile.php");
  class HFile_asm2106 extends HFile{
   function HFile_asm2106(){
     $this->HFile();	
/*************************************/
// Beautifier Highlighting Configuration File 
// 2106x Assembly
/*************************************/
// Flags

$this->nocase            	= "1";
$this->notrim            	= "0";
$this->perl              	= "0";

// Colours

$this->colours        	= array("blue", "purple", "gray", "brown");
$this->quotecolour       	= "blue";
$this->blockcommentcolour	= "green";
$this->linecommentcolour 	= "green";

// Indent Strings

$this->indent            	= array();
$this->unindent          	= array();

// String characters and delimiters

$this->stringchars       	= array("\"", "'");
$this->delimiters        	= array("~", "!", "@", "%", "^", "&", "*", "(", ")", "-", "+", "=", "|", "\\", "/", "[", "]", ":", ";", "\"", "'", "<", ">", " ", ",", "	", ".", "?");
$this->escchar           	= "";

// Comment settings

$this->linecommenton     	= array("{");
$this->blockcommenton    	= array("/*");
$this->blockcommentoff   	= array("*/");

// Keywords (keyword mapping to colour number)

$this->keywords          	= array(
			"#define" => "1", 
			"#error" => "1", 
			"#include" => "1", 
			"#elif" => "1", 
			"#if" => "1", 
			"#line" => "1", 
			"#else" => "1", 
			"#ifdef" => "1", 
			"#pragma" => "1", 
			"#endif" => "1", 
			"#ifndef" => "1", 
			"#undef" => "1", 
			"abs" => "1", 
			"AC" => "1", 
			"AF" => "1", 
			"AI" => "1", 
			"AIS" => "1", 
			"ALUSAT" => "1", 
			"AN" => "1", 
			"and" => "1", 
			"AOS" => "1", 
			"AS" => "1", 
			"ashift" => "1", 
			"astat" => "1", 
			"AUS" => "1", 
			"AV" => "1", 
			"AVS" => "1", 
			"AZ" => "1", 
			"bclr" => "1", 
			"BCNT" => "1", 
			"bit" => "1", 
			"bitrev" => "1", 
			"BMAX" => "1", 
			"BR0" => "1", 
			"BR8" => "1", 
			"bset" => "1", 
			"BTF" => "1", 
			"btgl" => "1", 
			"btst" => "1", 
			"BUSLK" => "1", 
			"by" => "1", 
			"C0" => "1", 
			"C1" => "1", 
			"C4" => "1", 
			"C5" => "1", 
			"C6" => "1", 
			"C7" => "1", 
			"C8" => "1", 
			"C9" => "1", 
			"CACC0" => "1", 
			"CACC1" => "1", 
			"CACC2" => "1", 
			"CACC3" => "1", 
			"CACC4" => "1", 
			"CACC5" => "1", 
			"CACC6" => "1", 
			"CACC7" => "1", 
			"CADIS" => "1", 
			"CAFRZ" => "1", 
			"call" => "1", 
			"CB15I" => "1", 
			"CB15S" => "1", 
			"CB7I" => "1", 
			"CB7S" => "1", 
			"cjump" => "1", 
			"clip" => "1", 
			"clr" => "1", 
			"comp" => "1", 
			"copysign" => "1", 
			"CP0" => "1", 
			"CP1" => "1", 
			"CP4" => "1", 
			"CP5" => "1", 
			"CP6" => "1", 
			"CP7" => "1", 
			"CP8" => "1", 
			"CP9" => "1", 
			"CSEL" => "1", 
			"DA0" => "1", 
			"DA1" => "1", 
			"DA4" => "1", 
			"DA5" => "1", 
			"DB0" => "1", 
			"DB1" => "1", 
			"DB4" => "1", 
			"DB5" => "1", 
			"dm" => "1", 
			"DMAC6" => "1", 
			"DMAC7" => "1", 
			"DMAC8" => "1", 
			"DMAC9" => "1", 
			"DMASTAT" => "1", 
			"do" => "1", 
			"EC6" => "1", 
			"EC7" => "1", 
			"EC8" => "1", 
			"EC9" => "1", 
			"EI6" => "1", 
			"EI7" => "1", 
			"EI8" => "1", 
			"EI9" => "1", 
			"ELAST" => "1", 
			"EM6" => "1", 
			"EM7" => "1", 
			"EM8" => "1", 
			"EM9" => "1", 
			"endseg" => "1", 
			"EP0I" => "1", 
			"EP1I" => "1", 
			"EP2I" => "1", 
			"EP3I" => "1", 
			"EPB0" => "1", 
			"EPB1" => "1", 
			"EPB2" => "1", 
			"EPB3" => "1", 
			"extern" => "1", 
			"fdep" => "1", 
			"fext" => "1", 
			"fix" => "1", 
			"FIXI" => "1", 
			"FLG0" => "1", 
			"FLG0O" => "1", 
			"FLG1" => "1", 
			"FLG1O" => "1", 
			"FLG2" => "1", 
			"FLG2O" => "1", 
			"FLG3" => "1", 
			"FLG3O" => "1", 
			"float" => "1", 
			"FLTII" => "1", 
			"FLTOI" => "1", 
			"FLTUI" => "1", 
			"fpack" => "1", 
			"funpack" => "1", 
			"global" => "1", 
			"GP0" => "1", 
			"GP1" => "1", 
			"GP4" => "1", 
			"GP5" => "1", 
			"GP6" => "1", 
			"GP7" => "1", 
			"GP8" => "1", 
			"GP9" => "1", 
			"idle" => "1", 
			"idle16" => "1", 
			"if" => "1", 
			"II0" => "1", 
			"II1" => "1", 
			"II2" => "1", 
			"II4" => "1", 
			"II5" => "1", 
			"II6" => "1", 
			"II7" => "1", 
			"II8" => "1", 
			"II9" => "1", 
			"IM0" => "1", 
			"IM1" => "1", 
			"IM2" => "1", 
			"IM4" => "1", 
			"IM5" => "1", 
			"IM6" => "1", 
			"IM7" => "1", 
			"IM8" => "1", 
			"IM9" => "1", 
			"imask" => "1", 
			"imaskp" => "1", 
			"IRPTEN" => "1", 
			"irptl" => "1", 
			"IRQ0E" => "1", 
			"IRQ0I" => "1", 
			"IRQ1E" => "1", 
			"IRQ1I" => "1", 
			"IRQ2E" => "1", 
			"IRQ2I" => "1", 
			"je" => "1", 
			"jne" => "1", 
			"jump" => "1", 
			"lce" => "1", 
			"lcntr" => "1", 
			"lefto" => "1", 
			"leftz" => "1", 
			"logb" => "1", 
			"LSEM" => "1", 
			"lshift" => "1", 
			"LSOV" => "1", 
			"mant" => "1", 
			"max" => "1", 
			"MI" => "1", 
			"min" => "1", 
			"MIS" => "1", 
			"MN" => "1", 
			"mode1" => "1", 
			"mode2" => "1", 
			"modify" => "1", 
			"MOS" => "1", 
			"MSGR0" => "1", 
			"MSGR1" => "1", 
			"MSGR2" => "1", 
			"MSGR3" => "1", 
			"MSGR4" => "1", 
			"MSGR5" => "1", 
			"MSGR6" => "1", 
			"MSGR7" => "1", 
			"MU" => "1", 
			"MUS" => "1", 
			"MV" => "1", 
			"MVS" => "1", 
			"NESTM" => "1", 
			"nop" => "1", 
			"not" => "1", 
			"or" => "1", 
			"pass" => "1", 
			"PCEM" => "1", 
			"PCFL" => "1", 
			"pm" => "1", 
			"pop" => "1", 
			"push" => "1", 
			"px" => "1", 
			"px1" => "1", 
			"px2" => "1", 
			"recips" => "1", 
			"rframe" => "1", 
			"rnd" => "1", 
			"RND32" => "1", 
			"rot" => "1", 
			"rsqrts" => "1", 
			"RSTI" => "1", 
			"rti" => "1", 
			"rts" => "1", 
			"sat" => "1", 
			"scalb" => "1", 
			"segment" => "1", 
			"set" => "1", 
			"SFT0I" => "1", 
			"SFT1I" => "1", 
			"SFT2I" => "1", 
			"SFT3I" => "1", 
			"SOVFI" => "1", 
			"SPR0I" => "1", 
			"SPR1I" => "1", 
			"SPT0I" => "1", 
			"SPT1I" => "1", 
			"SRCU" => "1", 
			"SRD1H" => "1", 
			"SRD1L" => "1", 
			"SRD2H" => "1", 
			"SRD2L" => "1", 
			"SRRFH" => "1", 
			"SRRFL" => "1", 
			"SS" => "1", 
			"SSE" => "1", 
			"SSEM" => "1", 
			"SSOV" => "1", 
			"stky" => "1", 
			"SV" => "1", 
			"SYSCON" => "1", 
			"SYSTAT" => "1", 
			"SZ" => "1", 
			"TCOUNT" => "1", 
			"tgl" => "1", 
			"TIMEN" => "1", 
			"TMZHI" => "1", 
			"TMZLI" => "1", 
			"TPERIOD" => "1", 
			"trunc" => "1", 
			"TRUNCATE" => "1", 
			"tst" => "1", 
			"until" => "1", 
			"ustat1" => "1", 
			"ustat2" => "1", 
			"var" => "1", 
			"VIRPT" => "1", 
			"VIRPTI" => "1", 
			"WAIT" => "1", 
			"xor" => "1", 
			"CP2" => "2", 
			"DA2" => "2", 
			"DB2" => "2", 
			"GP2" => "2", 
			"II3" => "2", 
			"IM3" => "2", 
			"BSO" => "3", 
			"BSYN" => "3", 
			"CP3" => "3", 
			"CRBM" => "3", 
			"DA3" => "3", 
			"DB3" => "3", 
			"DCPR" => "3", 
			"DWPD" => "3", 
			"EBPR00" => "3", 
			"EBPR01" => "3", 
			"EBPR10" => "3", 
			"GP3" => "3", 
			"HMSWF" => "3", 
			"HPFLSH" => "3", 
			"HPM00" => "3", 
			"HPM01" => "3", 
			"HPM10" => "3", 
			"HPM11" => "3", 
			"HPS" => "3", 
			"HSTM" => "3", 
			"IDC" => "3", 
			"IIVT" => "3", 
			"IMDW0X" => "3", 
			"IMDW1X" => "3", 
			"IMGR" => "3", 
			"IWT" => "3", 
			"KEYMASK0" => "3", 
			"KEYMASK1" => "3", 
			"KEYWD0" => "3", 
			"KEYWD1" => "3", 
			"MRCCS0" => "3", 
			"MRCCS1" => "3", 
			"MRCS0" => "3", 
			"MRCS1" => "3", 
			"MTCCS0" => "3", 
			"MTCCS1" => "3", 
			"MTCS0" => "3", 
			"MTCS1" => "3", 
			"RCNT0" => "3", 
			"RCNT1" => "3", 
			"RDIV0" => "3", 
			"RDIV1" => "3", 
			"RX0" => "3", 
			"RX1" => "3", 
			"SPATH0" => "3", 
			"SPATH1" => "3", 
			"SPCNT0" => "3", 
			"SPCNT1" => "3", 
			"SRCTL0" => "3", 
			"SRCTL1" => "3", 
			"SRST" => "3", 
			"STCTL0" => "3", 
			"STCTL1" => "3", 
			"TCNT0" => "3", 
			"TCNT1" => "3", 
			"TDIV0" => "3", 
			"TDIV1" => "3", 
			"TX0" => "3", 
			"TX1" => "3", 
			"VIPD" => "3", 
			"b0" => "4", 
			"b1" => "4", 
			"b10" => "4", 
			"b11" => "4", 
			"b12" => "4", 
			"b13" => "4", 
			"b14" => "4", 
			"b15" => "4", 
			"b2" => "4", 
			"b3" => "4", 
			"b4" => "4", 
			"b5" => "4", 
			"b6" => "4", 
			"b7" => "4", 
			"b8" => "4", 
			"b9" => "4", 
			"f0" => "4", 
			"f1" => "4", 
			"f10" => "4", 
			"f11" => "4", 
			"f12" => "4", 
			"f13" => "4", 
			"f14" => "4", 
			"f15" => "4", 
			"f2" => "4", 
			"f3" => "4", 
			"f4" => "4", 
			"f5" => "4", 
			"f6" => "4", 
			"f7" => "4", 
			"f8" => "4", 
			"f9" => "4", 
			"i0" => "4", 
			"i1" => "4", 
			"i10" => "4", 
			"i11" => "4", 
			"i12" => "4", 
			"i13" => "4", 
			"i14" => "4", 
			"i15" => "4", 
			"i2" => "4", 
			"i3" => "4", 
			"i4" => "4", 
			"i5" => "4", 
			"i6" => "4", 
			"i7" => "4", 
			"i8" => "4", 
			"i9" => "4", 
			"l0" => "4", 
			"l1" => "4", 
			"l10" => "4", 
			"l11" => "4", 
			"l12" => "4", 
			"l13" => "4", 
			"l14" => "4", 
			"l15" => "4", 
			"l2" => "4", 
			"l3" => "4", 
			"l4" => "4", 
			"l5" => "4", 
			"l6" => "4", 
			"l7" => "4", 
			"l8" => "4", 
			"l9" => "4", 
			"m0" => "4", 
			"m1" => "4", 
			"m10" => "4", 
			"m11" => "4", 
			"m12" => "4", 
			"m13" => "4", 
			"m14" => "4", 
			"m15" => "4", 
			"m2" => "4", 
			"m3" => "4", 
			"m4" => "4", 
			"m5" => "4", 
			"m6" => "4", 
			"m7" => "4", 
			"m8" => "4", 
			"m9" => "4", 
			"r0" => "4", 
			"r1" => "4", 
			"r10" => "4", 
			"r11" => "4", 
			"r12" => "4", 
			"r13" => "4", 
			"r14" => "4", 
			"r15" => "4", 
			"r2" => "4", 
			"r3" => "4", 
			"r4" => "4", 
			"r5" => "4", 
			"r6" => "4", 
			"r7" => "4", 
			"r8" => "4", 
			"r9" => "4");

// Special extensions

// Each category can specify a PHP function that returns an altered
// version of the keyword.
        
        

$this->linkscripts    	= array(
			"1" => "donothing", 
			"2" => "donothing", 
			"3" => "donothing", 
			"4" => "donothing");
}


function donothing($keywordin)
{
	return $keywordin;
}

}?>