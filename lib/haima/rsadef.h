#ifndef RSADEF_H_201305071651
#define RSADEF_H_201305071651

#include <stdint.h>

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

#define MAC_TEMPKEY        128
#define MAC_KEYLEN         64
#define ABSC_KEY_LEN  (24)  // 工作密钥的长度


struct R_RSA_PUBLIC_KEY
{
	uint16_t bits;                     /* length in bits of modulus */
	uint8_t modulus[MAX_RSA_MODULUS_LEN];  /* modulus */
	uint8_t exponent[MAX_RSA_MODULUS_LEN]; /* public exponent */
};

#define RANDOM_BYTES_RQ 1
#define MIN_RSA_MODULUS_BITS 128
#define MAX_RSA_MODULUS_BITS 1024


typedef struct {
	uint32_t bytesNeeded;                    /* seed bytes required */
	uint8_t state[16];                     /* state of object */
	uint32_t outputAvailable;                /* number byte available */
	uint8_t output[16];                    /* output bytes */
} R_RANDOM_STRUCT;

typedef struct {
	uint16_t bits;                     /* length in bits of modulus */
	uint8_t modulus[MAX_RSA_MODULUS_LEN];  /* modulus */
	uint8_t publicExponent[MAX_RSA_MODULUS_LEN];     /* public exponent */
	uint8_t exponent[MAX_RSA_MODULUS_LEN]; /* private exponent */
	uint8_t prime[2][MAX_RSA_PRIME_LEN];   /* prime factors */
	uint8_t primeExponent[2][MAX_RSA_PRIME_LEN];     /* exponents for CRT */
	uint8_t coefficient[MAX_RSA_PRIME_LEN];          /* CRT coefficient */
} R_RSA_PRIVATE_KEY;

typedef struct {
	uint32_t bits;                           /* length in bits of modulus */
	int32_t useFermat4;                              /* public exponent (1 = F4, 0 = 3) */
} R_RSA_PROTO_KEY;

#endif


