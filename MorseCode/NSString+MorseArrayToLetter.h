//
//  NSString+MorseArrayToLetter.h
//  MorseCode
//
//  Created by Chris Meehan on 1/22/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//
// This extension to NSString just take an array that represents 1 morse letter, and returns and english letter in an NSString.

#import <Foundation/Foundation.h>

@interface NSString (MorseArrayToLetter)

+(NSString*)englishLetterFromAMorseLetter:(NSArray*)arrayContainingAMorseLetter;

@end
