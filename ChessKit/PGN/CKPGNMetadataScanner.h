//
//  CKPGNMetadataScanner.h
//  ChessKit
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKPGNMetadataScanner : NSObject
@property (nonatomic, readonly) NSString *gameText;

- (id)initWithGameText:(NSString *)gameText;
- (NSDictionary *)metadata;

@end
