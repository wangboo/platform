
#include"stdlib.h"
#include"stdio.h"
#include <string.h>
#include "base64.h"
#include "bigint.h"
//以下�?Base64.h 的内�?

size_t Base64_Decode(char *pDest, const char *pSrc, size_t srclen);
size_t Base64_Encode(char *pDest, const char *pSrc, size_t srclen);

//以下�?Base64.cpp 的内�?

BYTE Decode_GetByte(char c);
char Encode_GetChar(BYTE num);

//===================================
//    Base64 解码
//===================================
BYTE Decode_GetByte(char c)
{
    if(c == '+')
        return 62;
    else if(c == '/')
        return 63;
    else if(c <= '9')
        return (BYTE)(c - '0' + 52);
    else if(c == '=')
        return 64;
    else if(c <= 'Z')
        return (BYTE)(c - 'A');
    else if(c <= 'z')
        return (BYTE)(c - 'a' + 26);
    return 64;
}

//解码
size_t Base64_Decode(char *pDest, const char *pSrc, size_t srclen)
{
    BYTE input[4];
    size_t i, index = 0;
    for(i = 0; i < srclen; i += 4)
    {
        //byte[0]
        input[0] = Decode_GetByte(pSrc[i]);
        input[1] = Decode_GetByte(pSrc[i + 1]);
        pDest[index++] = (input[0] << 2) + (input[1] >> 4);

        //byte[1]
        if(pSrc[i + 2] != '=')
        {
            input[2] = Decode_GetByte(pSrc[i + 2]);
            pDest[index++] = ((input[1] & 0x0f) << 4) + (input[2] >> 2);
        }

        //byte[2]
        if(pSrc[i + 3] != '=')
        {
            input[3] = Decode_GetByte(pSrc[i + 3]);
            pDest[index++] = ((input[2] & 0x03) << 6) + (input[3]);
        }
    }

    //null-terminator
    pDest[index] = 0;
    return index;
}

//===================================
//    Base64 编码
//===================================
char Encode_GetChar(BYTE num)
{
    return
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789"
        "+/="[num];
}

//编码
size_t Base64_Encode(char *pDest, const char *pSrc, size_t srclen)
{
    BYTE input[3], output[4];
    size_t i, index_src = 0, index_dest = 0;
    for(i = 0; i < srclen; i += 3)
    {
        //char [0]
        input[0] = pSrc[index_src++];
        output[0] = (BYTE)(input[0] >> 2);
        pDest[index_dest++] = Encode_GetChar(output[0]);

        //char [1]
        if(index_src < srclen)
        {
            input[1] = pSrc[index_src++];
            output[1] = (BYTE)(((input[0] & 0x03) << 4) + (input[1] >> 4));
            pDest[index_dest++] = Encode_GetChar(output[1]);
        }
        else
        {
            output[1] = (BYTE)((input[0] & 0x03) << 4);
            pDest[index_dest++] = Encode_GetChar(output[1]);
            pDest[index_dest++] = '=';
            pDest[index_dest++] = '=';
            break;
        }

        //char [2]
        if(index_src < srclen)
        {
            input[2] = pSrc[index_src++];
            output[2] = (BYTE)(((input[1] & 0x0f) << 2) + (input[2] >> 6));
            pDest[index_dest++] = Encode_GetChar(output[2]);
        }
        else
        {
            output[2] = (BYTE)((input[1] & 0x0f) << 2);
            pDest[index_dest++] = Encode_GetChar(output[2]);
            pDest[index_dest++] = '=';
            break;
        }

        //char [3]
        output[3] = (BYTE)(input[2] & 0x3f);
        pDest[index_dest++] = Encode_GetChar(output[3]);
    }
    //null-terminator
    pDest[index_dest] = 0;
    return index_dest;
}

size_t gIAppBase64Decode(const char *szInput,char *szOutput)
{
	char szTmp[128];
	char szTmp2[128];
	szTmp[0]='\0';

	Base64_Decode(szTmp,szInput,strlen(szInput));
	szTmp2[0]='\0';

	return Base64_Decode(szOutput,szTmp+40,strlen(szTmp)-40);
}
