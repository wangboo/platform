#ifndef _RSA_H_
#define _RSA_H_

#define RE_CONTENT_ENCODING 0x0400
#define RE_DATA 0x0401
#define RE_DIGEST_ALGORITHM 0x0402
#define RE_ENCODING 0x0403
#define RE_KEY 0x0404
#define RE_KEY_ENCODING 0x0405
#define RE_LEN 0x0406
#define RE_MODULUS_LEN 0x0407
#define RE_NEED_RANDOM 0x0408
#define RE_PRIVATE_KEY 0x0409
#define RE_PUBLIC_KEY 0x040a
#define RE_SIGNATURE 0x040b
#define RE_SIGNATURE_ENCODING 0x040c
#define RE_ENCRYPTION_ALGORITHM 0x040d
#define RE_FILE 0x040e

#define ID_OK    0
#define ID_ERROR 1

#define MAX_RSA_MODULUS_BITS 1024
#define MAX_RSA_MODULUS_LEN ((MAX_RSA_MODULUS_BITS + 7) / 8)
#define MAX_RSA_PRIME_BITS ((MAX_RSA_MODULUS_BITS + 1) / 2)
#define MAX_RSA_PRIME_LEN ((MAX_RSA_PRIME_BITS + 7) / 8)

typedef struct {
  unsigned short int bits;                     /* length in bits of modulus */
  unsigned char modulus[MAX_RSA_MODULUS_LEN];  /* modulus */
  unsigned char exponent[MAX_RSA_MODULUS_LEN]; /* public exponent */
} R_RSA_PUBLIC_KEY;

/*******
rsa锟斤拷锟斤拷
锟斤拷锟�
input        锟斤拷要锟斤拷锟杰碉拷锟斤拷锟斤拷锟街凤拷指锟斤拷
inputLen     锟斤拷要锟斤拷锟杰碉拷锟斤拷锟侥筹拷锟斤拷
publicKey    锟斤拷锟斤拷锟斤拷钥
锟斤拷锟斤拷:
outputLen    锟斤拷锟杰猴拷锟斤拷锟斤拷某锟斤拷锟�
锟斤拷锟斤拷值:
锟斤拷锟斤拷锟斤拷锟侥伙拷锟斤拷锟街革拷耄拷锟揭拷锟斤拷锟斤拷头锟斤拷诖锟秸硷拷
********/
char * gEncRSA(int *outputLen, char *input, int inputLen, R_RSA_PUBLIC_KEY *publicKey);


/*******
rsa锟斤拷锟斤拷
锟斤拷锟�
input        锟斤拷要锟斤拷锟杰碉拷锟斤拷锟斤拷锟街凤拷指锟斤拷
inputLen     锟斤拷要锟斤拷锟杰碉拷锟斤拷锟侥筹拷锟斤拷
publicKey    锟斤拷锟斤拷锟斤拷钥
锟斤拷锟斤拷:
outputLen    锟斤拷锟杰猴拷锟斤拷锟斤拷某锟斤拷锟�
锟斤拷锟斤拷值:
锟斤拷锟斤拷锟斤拷锟侥伙拷锟斤拷锟街革拷耄拷锟揭拷锟斤拷锟斤拷头锟斤拷诖锟秸硷拷
********/
char *gDecRSA(int *outputLen, char *input, int inputLen, R_RSA_PUBLIC_KEY *publicKey);


char *gIAppDecRSA(int *outputLen, char *input, int inputLen, const char *szPrivatekey,const char *szModKey);

char *gIAppEncRSA(int *outputLen, char *input, int inputLen, const char *szPrivatekey,const char *szModKey);

void byte2hex(char *inBuf,int inLen,char *sOut);
#endif
