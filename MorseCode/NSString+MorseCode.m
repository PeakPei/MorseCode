//
//  NSString+MorseCode.m
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//


#import "NSString+MorseCode.h"

@implementation NSString (MorseCode)

//This method is what gets called by the Controller class. It takes an NSString sentence and returns an array of arrays, [ [@"-",@"."] [@".",@"."][@"wordspace"][@"-"] ].
+(NSArray*)returnAnArrayOfArraysWithMorseSymbolsFromSentence:(NSString*)theWords{
    //First, lets turn the string into an organized, filtered array of english letters, to manage them easier.
    NSArray* englishLetterArray = [self getArrayOfCapitalOneLetteredStrings:theWords];
    // Now let's get the array of morse arrays ready to send back.
    NSMutableArray* arrayOfMorseChars = [[NSMutableArray alloc]init];
    // Convert each letter from our letter array, into an array holding morse symbols, e.g. [@"-",@".",@"."].
    for(NSString* aLetter in englishLetterArray){
        if([aLetter isEqualToString:@"wordspace"]){// If our letter says "wordspace", then we just make an array with object[0] being a string "wordspace".
            NSArray* arrayHoldingJustOneWordspaceString = [[NSArray alloc]initWithObjects:@"wordspace", nil];
            [arrayOfMorseChars addObject:arrayHoldingJustOneWordspaceString];// and give it to our array of morse letters.
        }
        else{ // Otherwise, this is alpha-numeric. Which is more likely.
            // Lets add an array of symbols (which only makes up one morse letter) to the array of morse letters to be sent to the controller.
            NSArray* someArray = [self returnAnArrayOfSymbolsForALetter:aLetter];
            if(someArray){ // As long as a legitemit morse letter got send back.
                [arrayOfMorseChars addObject:someArray];
            }
        }
    }
    return arrayOfMorseChars; // Give it to the Controller.
}

// This is the first method to get called that checks the string. It converts it to an all caps, alpha-numeric only, array of english letters.
+(NSArray *)getArrayOfCapitalOneLetteredStrings:(NSString*)theWords{
    NSMutableArray *tempArray = [NSMutableArray new]; // Get the array ready.
    // This "for loop" will iterate through each letter of your string, and add it to the array to send back.
    for (int i = 0; i <theWords.length; i++) {
        NSString* thisChar = [theWords substringWithRange:NSMakeRange(i, 1)];// Lets grab this particular letter from the string.
        if(thisChar){ // As long as there is one.
            if([thisChar isEqualToString:@" "]){   // Then this is a word break. Dont capitalize, but do add @"wordspace" the array.
                [tempArray addObject:@"wordspace"];
            }
            else{
                // Otherwise, ensure that it becomes capital and add it to the array.
                [tempArray addObject:[NSString changeTheCharToCap:thisChar]];
            }
        }
    }
    return [NSArray arrayWithArray:tempArray]; // And return a copy of that array, I think I was having problems when I didn't make a copy.
}

// This method takes a string (which should only be 1 character) and returns the same string, but ALL CAPS
+(NSString *)changeTheCharToCap:(NSString *)oneLetteredString{
    NSString* aNewString =[oneLetteredString uppercaseString];
    return aNewString;
}

// We use this to turn an english letter into morse code symbols as a string.
+(NSString*)returnAStringRepresentingAnEntireMorseCodeLetter:(NSString*)theCharacter{
    NSDictionary* dictOfMorseCodes = [[NSDictionary alloc]initWithObjectsAndKeys:@".-",@"A",@"-...",@"B",@"-.-.",@"C",@"-..",@"D",@".",@"E",@"..-.",@"F",@"--.",@"G",@"....",@"H",@"..",@"I",@".---",@"J",@"-.-",@"K",@".-..",@"L",@"--",@"M",@"-.",@"N",@"---",@"O",@".--.",@"P",@"--.-",@"Q",@".-.",@"R",@"...",@"S",@"-",@"T",@"..-",@"U",@"...-",@"V",@".--",@"W",@"-..-",@"X",@"-.--",@"Y",@"--..",@"Z",@"-----",@"0",@".---",@"1",@"..---",@"2",@"...--",@"3",@"....-",@"4",@".....",@"5",@"-....",@"6",@"--...",@"7",@"---..",@"8",@"----.",@"9",nil];
    NSString* tempString =[dictOfMorseCodes objectForKey:theCharacter];
    return tempString;
}

// This takes 1 english letter, and converts it into an array holding morse symbols (a morse array representing 1 letter).
+(NSArray*)returnAnArrayOfSymbolsForALetter:(NSString*)theEnglishLetter{
    NSString* theStringOfMorseChars = [self returnAStringRepresentingAnEntireMorseCodeLetter:theEnglishLetter]; // Get a morse string.
    NSMutableArray* anArray = [NSMutableArray new]; // Get the array ready to send out.
    for (int i = 0; i <theStringOfMorseChars.length; i++) { // Take each symbol from that morse string, and add it to the array.
       [ anArray addObject: [theStringOfMorseChars substringWithRange:NSMakeRange(i, 1)]];
    }
    return  anArray;
}
@end