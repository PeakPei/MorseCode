//
//  NSString+MorseCode.m
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//


#import "NSString+MorseCode.h"

@implementation NSString (MorseCode)

+(NSString*)returnAStringRepresentingTheMorseCodeNumberOfThisLetter:(NSString*)theCharacter{
    NSDictionary* dictOfMorseCodes = [[NSDictionary alloc]initWithObjectsAndKeys:@".-",@"A",@"-...",@"B",@"-.-.",@"C",@"-..",@"D",@".",@"E",@"..-.",@"F",@"--.",@"G",@"....",@"H",@"..",@"I",@".---",@"J",@"-.-",@"K",@".-..",@"L",@"--",@"M",@"-.",@"N",@"---",@"O",@".--.",@"P",@"--.-",@"Q",@".-.",@"R",@"...",@"S",@"-",@"T",@"..-",@"U",@"...-",@"V",@".--",@"W",@"-..-",@"X",@"-.--",@"Y",@"--..",@"Z",@"-----",@"0",@".---",@"1",@"..---",@"2",@"...--",@"3",@"....-",@"4",@".....",@"5",@"-....",@"6",@"--...",@"7",@"---..",@"8",@"----.",@"9",nil];
    NSString* tempString =[dictOfMorseCodes objectForKey:theCharacter];
    return tempString;
    
}

+(NSArray*)returnAnArrayOfMorseCodeSymbolsFromAWord:(NSString*)theWord{
    NSArray* englishLetterArray = [self getArrayOfCapitalSpacelessOneLetteredStrings:theWord];
    NSMutableArray* arrayOfMorseChars = [[NSMutableArray alloc]init];
    
    for(NSString* aLetter in englishLetterArray){
        NSString* someString = [self returnAStringRepresentingTheMorseCodeNumberOfThisLetter:aLetter];
        if(someString){
            [arrayOfMorseChars addObject:someString];
        }
    }
    
    return arrayOfMorseChars;
}


+(NSArray *)getArrayOfCapitalSpacelessOneLetteredStrings:(NSString*)theWord{
    NSMutableArray *tempArray = [NSMutableArray new];
    NSString *noSpaces = [theWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // This "for loop" will iterate through each letter of your string, and add it to the array to send back.
    for (int i = 0; i <noSpaces.length; i++) {
        NSString* thisChar = [noSpaces substringWithRange:NSMakeRange(i, 1)];
        if(thisChar){
            [tempArray addObject:[NSString changeTheCharToCap:thisChar]];
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