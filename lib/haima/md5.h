/*
 *  absc_md5.h
 *  testC
 *
 *  Created by  lyong on 11-7-4.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MD5_H
#define _MD5_H

typedef unsigned int uint32;

typedef struct MD5Context {
	uint32 buf[4];
	uint32 bits[2];
	unsigned char in[64];
}MD5_CTX;



/*
 MD5鈥欌劉鈥溾劉脌鈥炩垜庐惟鈥澝糕亜拢鈭犫�禄脦拢鈭慌掆�鈥氣棅梅惟鈦劼Ｂ�鈩⑩�鈩⒙ｂ埆16鈼娒肺┾亜
 */
void absc_MD5_Hash
(
 unsigned char *pucData,	/* 聽鈥奥幻幝ｂ埆聽藵忙鈥�*/
 unsigned long iDataLen,	/* 聽鈥奥幻幝ｂ埆聽藵忙鈥衡棅梅惟鈦勨墺搂鈭偮�*/
 unsigned char *pDigest	/* 聽鈥扳墺藛拢鈭�6鈼娒肺┾亜鈥β⒙♀�梅碌拢庐鈥溾墹鈮モ垎艙藲艙垄鈥欌劉鈥溾劉拢漏*/
 );

void absc_MD5Init(MD5_CTX *);
void absc_MD5Update(MD5_CTX *, unsigned char *, unsigned int);
void absc_MD5Final(unsigned char *, MD5_CTX *);
void gIAppMD5(char *pInput,int len,char *szOutput);
#endif




