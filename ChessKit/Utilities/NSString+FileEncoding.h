//
//  NSString+FileEncoding.h
//  ChessKit
//
//  Created by Austen Green on 7/21/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileEncoding)

+ (NSStringEncoding)encodingForFileAtURL:(NSURL *)fileURL error:(NSError **)error;
+ (NSStringEncoding)encodingForData:(NSData *)data error:(NSError **)error;
+ (NSIndexSet *)allStringEncodings;

@end
