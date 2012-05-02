//
//  CKPGNDatabase.m
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPGNDatabase.h"
#import "CKPGNGameBuilder.h"

static NSString * const CKPGNLastModifiedDateKey = @"kPGNLastModifiedDateKey";
static NSString * const CKPGNGameRangesKey = @"kPGNGameRangesKey";

@interface CKPGNDatabase()
{
    NSString *_databaseString;
    NSMutableArray *_gameRanges;
    NSData *_gameData;
    NSCache *_metadataCache;
}
@end

@implementation CKPGNDatabase

- (id)initWithContentsOfURL:(NSURL *)url
{
    self = [super initWithContentsOfURL:url];
    if (self)
    {
        _gameData = [NSData dataWithContentsOfMappedFile:[url path]];
        _databaseString = [[NSString alloc] initWithBytesNoCopy:_gameData.bytes length:[_gameData length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
        _gameRanges = [[NSMutableArray alloc] init];
        _metadataCache = [[NSCache alloc] init];
        [self loadDatabase];
    }
    return self;
}

- (NSUInteger)count
{
    return _gameRanges.count;
}

- (CKGame *)gameAtIndex:(NSUInteger)index
{
    NSString *gameText = [self gameStringAtIndex:index];
    CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:gameText];
    NSLog(@"%@", gameText);
    return builder.game;
}

- (NSDictionary *)metadataAtIndex:(NSUInteger)index
{
    id key = [NSNumber numberWithUnsignedInteger:index];
    
    NSDictionary *metadata = [_metadataCache objectForKey:key];
    if (!metadata)
    {
        CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:[self gameStringAtIndex:index] options:CKPGNMetadataOnly];
        metadata = builder.metadata;
        if (metadata)
            [_metadataCache setObject:metadata forKey:key];
    }
    
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
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        NSDictionary *index = [NSDictionary dictionaryWithContentsOfURL:url];
        NSDate *date = [index objectForKey:CKPGNLastModifiedDateKey];
        
        // If the database hasn't been modified since we last parsed it, then the index is good.  Load and return early
        if ([date compare:lastModified] != NSOrderedAscending)
        {
            _gameRanges = [metadata objectForKey:CKPGNGameRangesKey];
            return;
        }
        else 
        {
            // Otherwise discard it
            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
        }
    }
    
    [self parseDatabaseC];
    
    // Save the metadata so that we can use it in the future.
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                lastModified, CKPGNLastModifiedDateKey,
                                _gameRanges, CKPGNGameRangesKey,
                                nil];
    [dictionary writeToURL:url atomically:YES];
}

// Parses the database using C functions
- (void)parseDatabaseC
{
    FILE *file = fopen([self.url.path cStringUsingEncoding:NSUTF8StringEncoding], "rt");
    
    if (file == NULL)
    {
        NSLog(@"File couldn't be opened in %@", NSStringFromSelector(_cmd));
        return;
    }
    
    BOOL logNextBracket = NO;
    BOOL countNextLinebreak = NO;
    NSRange gameRange; gameRange.location = 0; gameRange.length = 0;
    NSRange lineRange; lineRange.location = 0; lineRange.length = 0;
    NSRange lastLinebreakRange; lastLinebreakRange.location = 0; lastLinebreakRange.length = 0;
    
    fpos_t pos = 0;
    char buffer[256];
    char *result = NULL;
    char c = 0;
    while (!feof(file)) {
        
        // Get the line range
        lineRange.location = pos;
        result = fgets(buffer, 256, file);
        fgetpos(file, &pos);
        lineRange.length = pos - lineRange.location;
        
        if (result == NULL)
        {
            // TODO: Handle error
            break;
        }
        
        c = buffer[0];    
        
        if (logNextBracket && (c == '['))
        {
            // The first '[' marks the start of the game
            // Assumption: Every game starts with at least one tag pair
            
            logNextBracket = NO;
            if (lastLinebreakRange.location > gameRange.location)
            {
                gameRange.length = lastLinebreakRange.location - gameRange.location;
                [_gameRanges addObject:[NSValue valueWithRange:gameRange]];
                
                gameRange.location = lineRange.location;
            }
            countNextLinebreak = YES;
        }
        
        // Process as a linebreak
        else if (c == '\r' || c == '\n' || c == 0) 
        {
            lastLinebreakRange = lineRange;
            if (countNextLinebreak == YES)
            {
                countNextLinebreak = NO;
            }
            else
            {
                logNextBracket = YES;
            }
        }
        
        // Technically the PGN standard calls for no spaces at the beginning or end of a line
        // However, some PGN games might have a space in front of an empty line, which throws off our parsing
        // so make sure we take care of it
        else if (c == ' ')
        {
            BOOL lineIsEmpty = YES;
            
            for (int i = 0; i < strlen(buffer); i++)
            {
                if (isgraph(c))
                {
                    lineIsEmpty = NO;
                    break;
                }
            }
            if (lineIsEmpty)
            {
                lastLinebreakRange = lineRange;
                if (countNextLinebreak == YES)
                {
                    countNextLinebreak = NO;
                }
                else
                {
                    logNextBracket = YES;
                }
            }
        }
        
        // Process non-empty lines
        else if (logNextBracket == NO && (c != '[')) {
            //countNextLinebreak = YES;
        }
    }
    
    gameRange.length = lineRange.location + lineRange.length - gameRange.location;
    [_gameRanges addObject:[NSValue valueWithRange:gameRange]];
    
    
    fclose(file);
}


@end
