//
//  NSString+MorseArrayToLetter.m
//  MorseCode
//
//  Created by Chris Meehan on 1/22/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//

#import "NSString+MorseArrayToLetter.h"

@implementation NSString (MorseArrayToLetter)


+(NSString*)englishLetterFromAMorseLetter:(NSArray*)arrayContainingAMorseLetter{
    if(arrayContainingAMorseLetter.count > 0){ // As long as this array has at least 1 item in it.
        if([[arrayContainingAMorseLetter objectAtIndex:0] isEqualToString:@"wordspace"]){
            NSString* spaceString = @" ";
            return spaceString;
        }
        // Then this is surely a morse code letter array, not a space. Let's convert it.
        else{
            NSString* morseLetterString = @""; // Get this string ready for concatenating.
            // This loops through the morse array to convert it to 1 morse string of those same symbols.
            for (NSString* eachBit in arrayContainingAMorseLetter) {
                morseLetterString = [morseLetterString stringByAppendingString:eachBit];
            }
            // There, morseLetterString is now ready to be compared to a morse dictionary from below
            NSDictionary* dictOfMorseCodes = [[NSDictionary alloc]initWithObjectsAndKeys:@"A",@".-",@"B",@"-...",@"C",@"-.-.",@"D",@"-..",@"E",@".",@"F",@"..-.",@"G",@"--.",@"H",@"....",@"I",@"..",@"J",@".---",@"K",@"-.-",@"L",@".-..",@"M",@"--",@"N",@"-.",@"O",@"---",@"P",@".--.",@"Q",@"--.-",@"R",@".-.",@"S",@"...",@"T",@"-",@"U",@"..-",@"V",@"...-",@"W",@".--",@"X",@"-..-",@"Y",@"-.--",@"Z",@"--..",@"0",@"-----",@"1",@".---",@"2",@"..---",@"3",@"...--",@"4",@"....-",@"5",@".....",@"6",@"-....",@"7",@"--...",@"8",@"---..",@"9",@"----.",nil];
            NSString* theEnglishLetter =[dictOfMorseCodes objectForKey:morseLetterString];
            if(theEnglishLetter){ // As long as an english letter or number was returned, then let's return it.
                return theEnglishLetter;
            }
            else{
                return @""; // Otherwise send back an empty string.
            }
        }
    }
    // Otherwise, if the array had nothing in it send back an empty string.
    else{
        return @"";
    }
}


@end
