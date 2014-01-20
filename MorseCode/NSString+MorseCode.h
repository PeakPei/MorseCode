//
//  NSString+MorseCode.h
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MorseCode)

+(NSArray *)getArrayOfCapitalSpacelessOneLetteredStrings:(NSString*)theWord;

+(NSString*)returnAStringRepresentingTheMorseCodeNumberOfThisLetter:(NSString*)theCharacter;

+(NSArray*)returnAnArrayOfMorseCodeSymbolsFromAWord:(NSString*)theWord;

@end
