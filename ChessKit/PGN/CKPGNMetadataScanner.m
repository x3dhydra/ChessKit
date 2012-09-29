//
//  CKPGNMetadataScanner.m
//  ChessKit
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPGNMetadataScanner.h"

@interface CKPGNMetadataScanner()
{
    NSMutableDictionary *_metadata;
}
@end

@implementation CKPGNMetadataScanner
@synthesize gameText = _gameText;

- (id)initWithGameText:(NSString *)gameText
{
    self = [super init];
    if (self)
    {
        _gameText = gameText;
    }
    return self;
}

- (NSDictionary *)metadata
{
    if (!_metadata)
    {
        _metadata = [[NSMutableDictionary alloc] init];
        [self scanMetadata];
    }
    return _metadata;
}

/*
- (void)scanMetadata
{
    CFStringRef gameText = (__bridge CFStringRef)_gameText;
    
    const char * cString = [_gameText cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *line = _gameText;
    
    size_t stringLength = line.length;
    
    NSRange keyRange;
    NSRange valueRange;
    const char * currentString = NULL;
    
    size_t location = 0;
    
    do {
        currentString = cString;
        
        if (currentString[location] != '[')
            break;
        
        // Locate the key, skip the initial bracket and whitespace
        size_t skippedCharacters = strspn(currentString, "[ ");        
        location += skippedCharacters;
        
        if (location > stringLength)
            return;
        
        currentString = &cString[location];
        
        // Scan all characters until the first space
        size_t length = strcspn(currentString, " ");
        keyRange.location = location;
        keyRange.length = length;
        
        location += length;
        if (location > stringLength)
            return;
        
        // Locate the value - skip all characters up to a starting quote
        currentString = &cString[location];
        skippedCharacters = strspn(currentString, " \"");
        location += skippedCharacters;
        
        if (location > stringLength)
            return;
        
        // Value lasts until the ending quote
        currentString = &cString[location];
        length = strcspn(currentString, "\"");
        valueRange.location = location;
        valueRange.length = length;
        
        location += length;
        
        if (location > stringLength)
            return;
                
        CFStringRef key = CFStringCreateWithSubstring(NULL, gameText, CFRangeMake(keyRange.location, keyRange.length));
        CFStringRef value = CFStringCreateWithSubstring(NULL, gameText, CFRangeMake(valueRange.location, valueRange.length));
        
        [_metadata setObject:(__bridge NSString *)value forKey:(__bridge NSString *)key];
        
        CFRelease(key);
        CFRelease(value);

        // Scan up to the new line
        currentString = &cString[location];
        length = strspn(currentString, "\" ]\r\n");
        location += length;
        
    } while (location < stringLength);
}
 */

- (void)scanMetadata
{
	NSScanner *scanner = [[NSScanner alloc] initWithString:_gameText];
	[scanner setCharactersToBeSkipped:[NSCharacterSet newlineCharacterSet]];
	
	NSUInteger scanLocation = scanner.scanLocation;
	NSUInteger length = _gameText.length;
	
	while (scanLocation < length && [_gameText characterAtIndex:scanLocation] == '[')
	{
		[scanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:nil];

		NSString *key = nil;
		[scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&key];
		
		[scanner scanUpToString:@"\"" intoString:nil];
		[scanner setScanLocation:scanner.scanLocation + 1];
		NSString *value = nil;
		[scanner scanUpToString:@"\"" intoString:&value];
		
		if (value && key)
			[_metadata setObject:value forKey:key];
		
		[scanner scanUpToString:@"[" intoString:nil];
		scanLocation = scanner.scanLocation;
	}
}

@end
