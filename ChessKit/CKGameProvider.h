//
//  CKGameProvider.h
//  ChessKit
//
//  Created by Austen Green on 5/27/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKGame;

@protocol CKGameProvider <NSObject>
@required
- (NSUInteger)count;
- (CKGame *)gameAtIndex:(NSUInteger)index;
- (NSDictionary *)metadataAtIndex:(NSUInteger)index;

@end
