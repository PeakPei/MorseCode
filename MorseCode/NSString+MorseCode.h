//
//  NSString+MorseCode.h
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//
// My SenderViewController will use this NSString extension class for getting an array of morse code letters.

#import <Foundation/Foundation.h>

@interface NSString (MorseCode)
+(NSArray*)returnAnArrayOfArraysWithMorseSymbolsFromSentence:(NSString*)theWords;
@end
