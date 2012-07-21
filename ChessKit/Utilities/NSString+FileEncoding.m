//
//  NSString+FileEncoding.m
//  ChessKit
//
//  Created by Austen Green on 7/21/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "NSString+FileEncoding.h"

static const NSUInteger kSampleDataLength = 250;

@implementation NSString (FileEncoding)

+ (NSStringEncoding)encodingForFileAtURL:(NSURL *)fileURL error:(NSError *__autoreleasing *)outError;
{
    NSError *error = nil;
    NSStringEncoding usedEncoding = NSUTF8StringEncoding;
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
    if (!error)
    {
        NSData *data = [fileHandle readDataOfLength:kSampleDataLength];
        return [self encodingForData:data error:outError];
    }
    
    if (error)
    {
        if (outError)
            *outError = error;
    }
    
    return usedEncoding;
}

+ (NSStringEncoding)encodingForData:(NSData *)data error:(NSError **)outError
{        
    NSError *error = nil;
    NSStringEncoding usedEncoding = NSUTF8StringEncoding;
    
    NSString *tempLocation = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    if ([data writeToFile:tempLocation options:NSDataWritingAtomic error:&error])
    {
        NSString *temp = [NSString stringWithContentsOfFile:tempLocation usedEncoding:&usedEncoding error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:tempLocation error:NULL];
    }
    
    if (error)
    {
        if (outError)
            *outError = error;
    }
    
    return usedEncoding;

}

+ (NSIndexSet *)allStringEncodings
{
    static NSIndexSet *encodings = nil;
    if (!encodings)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            NSASCIIStringEncoding = 1,		/* 0..127 only */
//            NSNEXTSTEPStringEncoding = 2,
//            NSJapaneseEUCStringEncoding = 3,
//            NSUTF8StringEncoding = 4,
//            NSISOLatin1StringEncoding = 5,
//            NSSymbolStringEncoding = 6,
//            NSNonLossyASCIIStringEncoding = 7,
//            NSShiftJISStringEncoding = 8,          /* kCFStringEncodingDOSJapanese */
//            NSISOLatin2StringEncoding = 9,
//            NSUnicodeStringEncoding = 10,
//            NSWindowsCP1251StringEncoding = 11,    /* Cyrillic; same as AdobeStandardCyrillic */
//            NSWindowsCP1252StringEncoding = 12,    /* WinLatin1 */
//            NSWindowsCP1253StringEncoding = 13,    /* Greek */
//            NSWindowsCP1254StringEncoding = 14,    /* Turkish */
//            NSWindowsCP1250StringEncoding = 15,    /* WinLatin2 */
//            NSISO2022JPStringEncoding = 21,        /* ISO 2022 Japanese encoding for e-mail */
//            NSMacOSRomanStringEncoding = 30,
//
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            [indexSet addIndexesInRange:NSMakeRange(NSASCIIStringEncoding, 14)];
            [indexSet addIndex:NSISO2022JPStringEncoding];
            [indexSet addIndex:NSMacOSRomanStringEncoding];
            encodings = indexSet;
        });
    }
    
    return encodings;
}

@end
