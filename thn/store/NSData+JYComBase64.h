//
//  NSData+Base64.h
//  MClient
//
//  Created by  史正烨 on 09-11-10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JYComBase64)

/*!	@function	+dataWithBase64EncodedString:
 @discussion	This method returns an autoreleased NSData object. The NSData object is initialized with the
 contents of the Base 64 encoded string. This is a convenience method.
 @param	inBase64String	An NSString object that contains only Base 64 encoded data.
 @result	The NSData object. */
+ (NSData *) jyDataWithBase64EncodedString:(NSString *) string;
- (NSString *)jyBase64Encoding;
/*!	@function	-initWithBase64EncodedString:
 @discussion	The NSData object is initialized with the contents of the Base 64 encoded string.
 This method returns self as a convenience.
 @param	inBase64String	An NSString object that contains only Base 64 encoded data.
 @result	This method returns self. */
//- (id) initWithBase64EncodedString:(NSString *) string;

/*!	@function	-base64EncodingWithLineLength:
 @discussion	This method returns a Base 64 encoded string representation of the data object.
 @param	inLineLength A value of zero means no line breaks.  This is crunched to a multiple of 4 (the next
 one greater than inLineLength).
 @result	The base 64 encoded data. */
//- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end

