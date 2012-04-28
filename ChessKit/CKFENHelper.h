//
//  CKFENHelper.h
//  ChessKit
//
//  Created by Austen Green on 4/23/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKPosition;

@interface CKFENHelper : NSObject

+ (CKPosition *)positionWithFEN:(NSString *)FENString;

- (CKPosition *)positionWithFEN:(NSString *)FENString;

@end
