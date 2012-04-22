//
//  CKDatabase.h
//  ChessKit
//
//  Created by Austen Green on 3/10/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKGame;

@interface CKDatabase : NSObject
@property (nonatomic, readonly) NSURL *url;

+ (id)databaseWithContentsOfFile:(NSString *)file;
+ (id)databaseWithContentsOfURL:(NSURL *)url;

- (id)initWithContentsOfFile:(NSString *)file;
- (id)initWithContentsOfURL:(NSURL *)url;

- (NSUInteger)count;
- (CKGame *)gameAtIndex:(NSUInteger)index;

@end
