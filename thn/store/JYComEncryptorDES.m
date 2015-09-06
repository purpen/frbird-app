//
// Copyright (c) 2011 Five-technology Co.,Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "JYComEncryptorDES.h"
#import "NSData+JYComBase64.h"

@implementation JYComEncryptorDES

#pragma mark -
#pragma mark Initialization and deallcation


#pragma mark -
#pragma mark Praivate


#pragma mark -
#pragma mark API

+ (NSData*)encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv {
    NSData* result = nil;

    // setup key
    unsigned char cKey[JYComENCRYPT_KEY_SIZE];
	bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:JYComENCRYPT_KEY_SIZE];
	
    // setup iv
    char cIv[JYComENCRYPT_BLOCK_SIZE];
    bzero(cIv, JYComENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:JYComENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
	size_t bufferSize = [data length] + JYComENCRYPT_BLOCK_SIZE;
	char *buffer = malloc(bufferSize);

    // do encrypt
	size_t encryptedSize = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          JYComENCRYPT_ALGORITHM,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          cKey,
                                          JYComENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
										  &encryptedSize);
	if (cryptStatus == kCCSuccess) {
		result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
	} else {
        free(buffer);
    }
	
	return result;
}

+ (NSData*)decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv {
    NSData* result = nil;

    // setup key
    //
    unsigned char cKey[JYComENCRYPT_KEY_SIZE];
    //extern void bzero（void *s, int n）;s为要置0的内存起始位置，n为置0的位数
	bzero(cKey, sizeof(cKey));
    //
    [key getBytes:cKey length:JYComENCRYPT_KEY_SIZE];

    // setup iv
    char cIv[JYComENCRYPT_BLOCK_SIZE];
    bzero(cIv, JYComENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:JYComENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
    // 32 16+16
	size_t bufferSize = [data length] + JYComENCRYPT_BLOCK_SIZE;
	void *buffer = malloc(bufferSize);
	
    // do decrypt
	size_t decryptedSize = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          JYComENCRYPT_ALGORITHM,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
										  cKey,
                                          JYComENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
	//decreyptedSize 16
	if (cryptStatus == kCCSuccess) {
		result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
	} else {
        free(buffer);
        NSLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }
	return result;
}


+ (NSString*)encryptBase64String:(NSString*)string keyString:(NSString*)keyString {
    NSData* data = [self encryptData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                 key:[keyString dataUsingEncoding:NSUTF8StringEncoding]
                                  iv:nil];

    return [data jyBase64Encoding];//[data base64EncodedStringWithSeparateLines:separateLines];
}

+ (NSString*)decryptBase64String:(NSString*)encryptedBase64String keyString:(NSString*)keyString {
    NSData* encryptedData = [NSData jyDataWithBase64EncodedString:encryptedBase64String];
    NSLog(@"%@",encryptedData);
    NSData* data = [self decryptData:encryptedData
                                 key:[keyString dataUsingEncoding:NSUTF8StringEncoding]
                                  iv:nil];
    if (data) {
        return [[[NSString alloc] initWithData:data
                                      encoding:NSUTF8StringEncoding] autorelease];
    } else {
        return nil;
    }
}


#define FBENCRYPT_IV_HEX_LEGNTH (JYComENCRYPT_BLOCK_SIZE*2)

+ (NSData*)generateIv {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand(time(NULL));
    });

    char cIv[JYComENCRYPT_BLOCK_SIZE];
    for (int i=0; i < JYComENCRYPT_BLOCK_SIZE; i++) {
        cIv[i] = rand() % 256;
    }
    return [NSData dataWithBytes:cIv length:JYComENCRYPT_BLOCK_SIZE];
}


+ (NSString*)hexStringForData:(NSData*)data {
    if (data == nil) {
        return nil;
    }

    NSMutableString* hexString = [NSMutableString string];

    const unsigned char *p = [data bytes];
    
    for (int i=0; i < [data length]; i++) {
        [hexString appendFormat:@"%02x", *p++];
    }
    return hexString;
}

+ (NSData*)dataForHexString:(NSString*)hexString {
    if (hexString == nil) {
        return nil;
    }
    
    const char* ch = [[hexString lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [NSMutableData data];
    while (*ch) {
        char byte = 0;
        if ('0' <= *ch && *ch <= '9') {
            byte = *ch - '0';
        } else if ('a' <= *ch && *ch <= 'f') {
            byte = *ch - 'a' + 10;
        }
        ch++;
        byte = byte << 4;
        if (*ch) {
            if ('0' <= *ch && *ch <= '9') {
                byte += *ch - '0';
            } else if ('a' <= *ch && *ch <= 'f') {
                byte += *ch - 'a' + 10;
            }
            ch++;
        }
        [data appendBytes:&byte length:1];
    }
    return data;
}

@end
