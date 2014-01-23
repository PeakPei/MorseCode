//
//  NSString+MorseCode.m
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//


#import "NSString+MorseCode.h"

@implementation NSString (MorseCode)

+(NSString*)returnAStringRepresentingAnEntireMorseCodeLetter:(NSString*)theCharacter{
    NSDictionary* dictOfMorseCodes = [[NSDictionary alloc]initWithObjectsAndKeys:@".-",@"A",@"-...",@"B",@"-.-.",@"C",@"-..",@"D",@".",@"E",@"..-.",@"F",@"--.",@"G",@"....",@"H",@"..",@"I",@".---",@"J",@"-.-",@"K",@".-..",@"L",@"--",@"M",@"-.",@"N",@"---",@"O",@".--.",@"P",@"--.-",@"Q",@".-.",@"R",@"...",@"S",@"-",@"T",@"..-",@"U",@"...-",@"V",@".--",@"W",@"-..-",@"X",@"-.--",@"Y",@"--..",@"Z",@"-----",@"0",@".---",@"1",@"..---",@"2",@"...--",@"3",@"....-",@"4",@".....",@"5",@"-....",@"6",@"--...",@"7",@"---..",@"8",@"----.",@"9",nil];
    NSString* tempString =[dictOfMorseCodes objectForKey:theCharacter];
    return tempString;
    
}

// 2 - Method that takes a sentence and returns [ [@"-",@"."] [@".",@"."][@"wordspace"][@"-"] ]
// theWords has spaces between each word. Lets keep it that way.
+(NSArray*)returnAnArrayOfArraysWithMorseSymbolsFromSentence:(NSString*)theWords{
    NSArray* englishLetterArray = [self getArrayOfCapitalOneLetteredStrings:theWords];
    NSMutableArray* arrayOfMorseChars = [[NSMutableArray alloc]init];
    
    for(NSString* aLetter in englishLetterArray){
        if([aLetter isEqualToString:@"wordspace"]){
            NSArray* arrayHoldingJustOneWordspaceString = [[NSArray alloc]initWithObjects:@"wordspace", nil];
            [arrayOfMorseChars addObject:arrayHoldingJustOneWordspaceString];
        }
        else{
            NSArray* someArray = [self returnAnArrayOfSymbolsForALetter:aLetter];
            if(someArray){
                [arrayOfMorseChars addObject:someArray];
            }
        }
    }
    
    return arrayOfMorseChars;
}

// 1 - method returns array of symbols for a letter.
+(NSArray*)returnAnArrayOfSymbolsForALetter:(NSString*)theEnglishLetter{
    NSString* theStringOfMorseChars = [self returnAStringRepresentingAnEntireMorseCodeLetter:theEnglishLetter];
    
    NSMutableArray* anArray = [NSMutableArray new];
    
    for (int i = 0; i <theStringOfMorseChars.length; i++) {
       [ anArray addObject: [theStringOfMorseChars substringWithRange:NSMakeRange(i, 1)]];
    }
    return  anArray;
}


+(NSArray *)getArrayOfCapitalOneLetteredStrings:(NSString*)theWords{
    NSMutableArray *tempArray = [NSMutableArray new];
    
    // This "for loop" will iterate through each letter of your string, and add it to the array to send back.
    for (int i = 0; i <theWords.length; i++) {
        NSString* thisChar = [theWords substringWithRange:NSMakeRange(i, 1)];
        if(thisChar){
            if([thisChar isEqualToString:@" "]){   // Then this is a word break. Dont capitalize, but do add to array.
                [tempArray addObject:@"wordspace"];
            }
            else{
                [tempArray addObject:[NSString changeTheCharToCap:thisChar]];
            }
        }
    }
    return [NSArray arrayWithArray:tempArray];
}

// This method takes a string (which should only be 1 character) and returns the same string, but ALL CAPS
+(NSString *)changeTheCharToCap:(NSString *)oneLetteredString{
    NSString* aNewString =[oneLetteredString uppercaseString];
    return aNewString;
}

@end