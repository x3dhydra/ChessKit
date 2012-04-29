//
//  Tokens.h
//  ChessParser
//
//  Created by Austen Green on 5/22/11.
//  Copyright 2011 Austen Green Consulting. All rights reserved.
//

// Core chess token types
typedef enum
{
    CCTokenNull = 0,
    CCTokenBeginAnnotation = 1,
    CCTokenBeginRAV = 2,
    CCTokenBeginTag = 3,
    
    CCTokenEndAnnotation,
    CCTokenEndRAV,
    CCTokenEndTag,
    
    CCTokenSymbol,
    CCTokenTagSymbol,
    CCTokenString,
    CCTokenAnnotation,
    
    CCTokenPeriod,
    
    CCTokenGameTermination,
    
    CCTokenUnrecognized
}  CCTokenType;
