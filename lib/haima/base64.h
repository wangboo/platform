#ifndef _BASE64_H_
#define _BASE64_H_

size_t Base64_Decode(char *pDest, const char *pSrc, size_t srclen);
size_t Base64_Encode(char *pDest, const char *pSrc, size_t srclen);
size_t gIAppBase64Decode(const char *szInput,char *szOutput);

#endif
