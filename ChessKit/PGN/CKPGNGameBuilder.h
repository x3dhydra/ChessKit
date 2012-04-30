//
//  CKPGNGameBuilder.h
//  ChessKit
//
//  Created by Austen Green on 4/28/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    CKPGNFullFormat = 0,
    CKPGNReducedFormat = 1,  // Ignores variations
    CKPGNMetadataOnly = 2,
};
typedef NSUInteger CKGameBuilderOptions;

@class CKGame;

@interface CKPGNGameBuilder : NSObject
@property (strong, nonatomic, readonly) NSString *gameText;
@property (nonatomic, readonly) CKGameBuilderOptions options;

- (id)initWithString:(NSString *)gameText;
- (id)initWithString:(NSString *)gameText options:(CKGameBuilderOptions)options;

- (CKGame *)game;
- (NSDictionary *)metadata;

@end

@interface CKPGNGameBuilder (Subclasses)
- (void)buildGame;
@end
