//
//  CKPGNDatabase.m
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPGNDatabase.h"

@interface CKPGNDatabase()
{
    NSData *_databaseData;
    NSString *_databaseString;
    NSMutableArray *_gameRanges;
}
@end

@implementation CKPGNDatabase

- (id)initWithContentsOfURL:(NSURL *)url
{
    self = [super initWithContentsOfURL:url];
    if (self)
    {
        //_databaseData = [NSData dataWithContentsOfMappedFile:[url path]];
        //_databaseString = [[NSString alloc] initWithBytesNoCopy:_databaseData.bytes length:[_databaseData length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
        _gameRanges = [[NSMutableArray alloc] init];
        [self parseDatabaseC];
        //_databaseData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:NULL];
        //_databaseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    }
    return self;
}

- (NSUInteger)count
{
    return _gameRanges.count;
}

- (CKGame *)gameAtIndex:(NSUInteger)index
{
    return 0;
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
