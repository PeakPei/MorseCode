//
//  NSString+MorseCode.m
//  MorseCodeDemo
//
//  Created by Brad on 1/20/14.
//  Copyright (c) 2014 Brad. All rights reserved.
//

#import "NSString+MorseCode.h"

@implementation NSString (MorseCode)

-(NSArray *)getArrayOfOneLetteredStrings
{
    NSMutableArray *tempArray = [NSMutableArray new];
    NSString *noSpaces = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // This "for loop" will iterate through each letter of your string, and add it to the array to send back.
    for (int i = 0; i <noSpaces.length; i++) {
        [tempArray addObject:[self changeTheCharToCap:[noSpaces substringWithRange:NSMakeRange(i, 1)]]];
    }
    
    return [NSArray arrayWithArray:tempArray];
    
}

// This method takes a string (which should only be 1 character) and returns the same string, but ALL CAPS
-(NSString *)changeTheCharToCap:(NSString *)oneLetteredString{
    oneLetteredString = [oneLetteredString uppercaseString];
    return oneLetteredString;
}

@end
