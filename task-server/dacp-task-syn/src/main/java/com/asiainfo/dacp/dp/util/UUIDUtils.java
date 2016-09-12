package com.asiainfo.dacp.dp.util;

import java.text.SimpleDateFormat;
import java.util.Date;
public class UUIDUtils {
	public static long seqno=0;
	public static synchronized String getUUID(){
		 Date  date=new Date();
		 SimpleDateFormat simpl=new SimpleDateFormat("yyMMddHHmmss");
		 String TimeSeq= simpl.format(date);		 
		 seqno=seqno+1;
		 if(seqno>=9999)seqno=0;	 
		 TimeSeq=TimeSeq+String.format("1%1$04d", seqno);
		 return Long.parseLong(TimeSeq)+"";
	}
	/**
	 * @return the _jobseqno
	 */
	public static synchronized long getSeqno() {
		 Date  date=new Date();
		 SimpleDateFormat simpl=new SimpleDateFormat("yyMMddHHmm");
		 String TimeSeq= simpl.format(date);		 
		 seqno=seqno+1;
		 if(seqno>=9999)seqno=0;	 
//		 if(Long.toString(seqno).length()>=4)
//			 TimeSeq=TimeSeq+Long.toString(seqno).substring(0, 4);
//		 else
//			 TimeSeq=TimeSeq;
//			 TimeSeq=TimeSeq+seqno;	 
		 TimeSeq=TimeSeq+String.format("1%1$04d", seqno);
		 return Long.parseLong(TimeSeq);
	}
}
