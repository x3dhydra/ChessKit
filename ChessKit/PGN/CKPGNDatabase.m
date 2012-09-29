//
//  CKPGNDatabase.m
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPGNDatabase.h"
#import "CKPGNGameBuilder.h"
#import "CKPGNTokenizer.h"
#import "NSString+FileEncoding.h"

static NSString * const CKPGNLastModifiedDateKey = @"kPGNLastModifiedDateKey";
static NSString * const CKPGNGameRangesKey = @"kPGNGameRangesKey";

@interface CKPGNDatabase()
{
    NSString *_databaseString;
    NSMutableArray *_gameRanges;
    NSData *_gameData;
    NSCache *_metadataCache;
    NSFileHandle *_fileHandle;
    dispatch_queue_t _syncQueue;
}
@end

@implementation CKPGNDatabase

- (id)initWithContentsOfURL:(NSURL *)url
{
    self = [super initWithContentsOfURL:url];
    if (self)
    {    
        NSError *error = nil;
        _fileHandle = [NSFileHandle fileHandleForReadingFromURL:url error:&error];
        
        // Technicaly PGN is supposed to be ASCII, but we try to start with UTF8.
        _gameData = [NSData dataWithContentsOfMappedFile:[url path]];
         _databaseString = [[NSString alloc] initWithBytesNoCopy:_gameData.bytes length:[_gameData length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
        
        // This is probably super-inefficient, but if we can't get the database string with UTF8, then enumerate over the available string encodings
        if (!_databaseString)
        {
            [[NSString allStringEncodings] enumerateIndexesUsingBlock:^(NSStringEncoding encoding, BOOL *stop) {
                _databaseString = [[NSString alloc] initWithBytesNoCopy:_gameData.bytes length:[_gameData length] encoding:encoding freeWhenDone:NO];
                if (_databaseString)
                    *stop = YES;
            }];
        }
                
        _gameRanges = [[NSMutableArray alloc] init];
        _metadataCache = [[NSCache alloc] init];
        _syncQueue = dispatch_queue_create("com.ChessKit.CKPGNDatabase.syncQueue", DISPATCH_QUEUE_SERIAL);
        [self loadDatabase];
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_syncQueue);
}

- (NSUInteger)count
{
    return _gameRanges.count;
}

- (CKGame *)gameAtIndex:(NSUInteger)index
{
    NSString *gameText = [self gameStringAtIndex:index];
    CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:gameText];
    return builder.game;
}

- (NSDictionary *)metadataAtIndex:(NSUInteger)index
{
    __block NSDictionary *metadata;
    id key = [NSNumber numberWithUnsignedInteger:index];
    
    dispatch_sync(_syncQueue, ^{
        metadata = [_metadataCache objectForKey:key];
        if (!metadata)
        {
            CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:[self gameStringAtIndex:index] options:CKPGNMetadataOnly];
            metadata = builder.metadata;
            if (metadata)
                [_metadataCache setObject:metadata forKey:key];
        }
    });

    return metadata;
}

- (NSString *)gameStringAtIndex:(NSUInteger)index
{
    NSRange range = [[_gameRanges objectAtIndex:index] rangeValue];
    NSString *gameText = [_databaseString substringWithRange:range];
    return gameText;
}

- (NSURL *)pathForIndexFile
{
    return [[self.url URLByDeletingPathExtension] URLByAppendingPathExtension:@"pgi"];
}

- (void)loadDatabase
{
    NSURL *url = [self pathForIndexFile];
    
    NSDictionary *metadata = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.url path] error:NULL];
    NSDate *lastModified = [metadata objectForKey:NSFileModificationDate];
    
    // Attempt to load the index file, which will keep us from having to re-parse the PGN every time it's loaded
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
//    {
//        NSDictionary *index = [NSDictionary dictionaryWithContentsOfURL:url];
//        NSDate *date = [index objectForKey:CKPGNLastModifiedDateKey];
//        
//        // If the database hasn't been modified since we last parsed it, then the index is good.  Load and return early
//        if ([date compare:lastModified] != NSOrderedAscending)
//        {
//            _gameRanges = [metadata objectForKey:CKPGNGameRangesKey];
//            return;
//        }
//        else 
//        {
//            // Otherwise discard it
//            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
//        }
//    }
    
    //[self parseDatabaseC];
    //[self parseDatabase];
    //[self parseDatabaseUpdate];
	[self parseDatabaseObjC];
    //NSLog(@"%@", _gameRanges);
    
    // Save the metadata so that we can use it in the future.
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                lastModified, CKPGNLastModifiedDateKey,
                                _gameRanges, CKPGNGameRangesKey,
                                nil];
    [dictionary writeToURL:url atomically:YES];
}

- (void)parseDatabaseObjC
{
	__block NSRange gameRange = NSMakeRange(0, 0);
	
	__block NSUInteger lineGroupsSkippedCount = 0;
	__block BOOL nextBracketIndicatesNewGame = YES;
	__block BOOL isInLinebreakGroup = NO;
	
	[_databaseString enumerateSubstringsInRange:NSMakeRange(0, _databaseString.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange lineRange, NSRange enclosingRange, BOOL *stop) {
		
		// Keep track of linebreak groups in case there are multiple newlines in between the metadata and movetext sections
		
		if (isInLinebreakGroup && lineRange.length)
		{
			// We were in a linebreak group and now we have non-linebreak text
			isInLinebreakGroup = NO;
			lineGroupsSkippedCount++;
			
			if (lineGroupsSkippedCount % 2 == 0)
			{
				lineGroupsSkippedCount = 0;
				nextBracketIndicatesNewGame = YES;
			}
		}
		
		if (lineRange.length && nextBracketIndicatesNewGame && [substring characterAtIndex:0] == '[')
		{
			nextBracketIndicatesNewGame = NO;
			
			// This way we don't include the first game range
			if (gameRange.length > 0)
			{
				[_gameRanges addObject:[NSValue valueWithRange:gameRange]];
				gameRange = NSMakeRange(lineRange.location, 0);
			}
		}
		else if (!lineRange.length && !isInLinebreakGroup)
		{
			isInLinebreakGroup = YES;
		}
		
		gameRange = NSUnionRange(gameRange, lineRange);
	}];
	
	// Make sure we include the last game
	if (gameRange.length)
	{
		[_gameRanges addObject:[NSValue valueWithRange:gameRange]];
	}
}

@end
