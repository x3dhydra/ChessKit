//
//  CCGameTypes.h
//  CoreChess
//
//  Created by Austen Green on 6/25/11.
//  Copyright 2011 Austen Green Consulting. All rights reserved.
//

#ifndef CCGAMETYPES_H
#define CCGAMETYPES_H

#import <Foundation/Foundation.h>

enum CKGameResult
{
    CKGameResultWhite,   // 1-0
    CKGameResultBlack,   // 0-1
    CKGameResultDraw,    // 1/2-1/2
    CKGameResultUnknown, // *
    
    CKGameResultUndefined = NSIntegerMax
};

typedef enum CKGameResult CKGameResult;

#endif