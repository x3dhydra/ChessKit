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
    [self parseDatabaseUpdate];
    //NSLog(@"%@", _gameRanges);
    
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

- (void)parseDatabase
{
    NSUInteger index = 0;
    
    @autoreleasepool 
    {
        do 
        {
            NSString *scanString = [_databaseString substringWithRange:NSMakeRange(index, _databaseString.length - index)];
            
            CKPGNTokenizer *tokenizer = [[CKPGNTokenizer alloc] initWithString:scanString];
            CCTokenType tokenType = CCTokenUnrecognized;
            NSString *token = nil;
            
            do {
                token = [tokenizer getNextToken:&tokenType];
            } while (tokenType != CCTokenGameTermination && token != nil);
            
            NSInteger length = [tokenizer scanLocation];
            NSRange gameRange = NSMakeRange(index, length);
            index += length;
                        
            if (token)
            {
                [_gameRanges addObject:[NSValue valueWithRange:gameRange]];
            }
        } while (index < _databaseString.length);
    }
}

- (void)parseDatabaseUpdate
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
    
        // Buffer size - buffer theoretically should not exceed 80 chars
//        int bufferSize = 121;
//        char* buffer = new char[bufferSize];
//        bool logNextBracket = true;
//        long offset = 0;
        
    short linesSkipped = 0;
    
    while(!feof(file))
    {
        //database->getline(buffer, bufferSize);
        
        // Get the line range
        lineRange.location = pos;
        result = fgets(buffer, 256, file);
        fgetpos(file, &pos);
        lineRange.length = pos - lineRange.location;

        
        if (logNextBracket && (buffer[0] == '[')) {
            logNextBracket = NO;
            
            if (lastLinebreakRange.location > gameRange.location)
            {
                gameRange.length = lastLinebreakRange.location - gameRange.location;
                [_gameRanges addObject:[NSValue valueWithRange:gameRange]];
                
                gameRange.location = lineRange.location;
            }

            
            //offset = (long)database->tellg() - (strlen(buffer) + 1);
            //gameIndexes->push_back(offset);
        } 
        /* New Method: 
         * Assumptions: 
         * 1. '\r' is present for all new lines
         * 2. There always exists one and only one
         *    blank line in between the header and gametext
         *    and the gametext and next game.
         */
        else if (buffer[0] == '\r' || buffer[0] == '\n') {
            linesSkipped++;
            lastLinebreakRange = lineRange;
            
            if (linesSkipped % 2 == 0) {
                linesSkipped = 0;
                logNextBracket = YES;
            }
        }
        
        /* Old Method: failed if a '[' appeared as the first character
         * of a non-header line.
         
         else if (logNextBracket == false && (buffer[0] != '[')) {
         logNextBracket = true;
         }
         */
    }
    
    gameRange.length = lineRange.location + lineRange.length - gameRange.location;
    [_gameRanges addObject:[NSValue valueWithRange:gameRange]];

    
    fclose(file);
}

@end
