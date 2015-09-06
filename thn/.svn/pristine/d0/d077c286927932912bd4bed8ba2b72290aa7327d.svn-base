//
// NSString+MD5.m
// Originally created for MyFile
//
// Created by Árpád Goretity, 2011. Some infos were grabbed from StackOverflow.
// Released into the public domain. You can do whatever you want with this within the limits of applicable law (so nothing nasty!).
// I'm not responsible for any damage related to the use of this software. There's NO WARRANTY AT ALL.
//

#import "NSString+JYComMD5.h"

@implementation NSString (JYComMD5)


- (NSString *) JYComMD5Hash32 {
    const char *cStr = [self UTF8String];
    
    unsigned char result[16];
    
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    
    NSString *s =[NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    return [s lowercaseString];
}
- (NSString *) JYComMD5Hash8 {
	
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [self UTF8String], [self length]);
	
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x",
                   digest[0],  digest[1],
                   digest[2],  digest[3]];
	
	return s;
	
}

@end

