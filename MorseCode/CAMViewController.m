//
//  CAMViewController.m
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//


#import "CAMViewController.h"
#import "NSString+MorseCode.h"

@interface CAMViewController ()

@end

@implementation CAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}


-(void)analyzeAndPrintTheTextField{
    // Get the word
    NSString* stringToBreakApart = self.myTextField.text;

    // Convert each letter in the array into its morse code equivilant, and return that new array.
    arrayOfStringsRepresentingAMorseCodeLetters = [NSString returnAnArrayOfMorseCodeSymbolsFromAWord:stringToBreakApart];
    
    NSString* allMorseCodesTogether = @"";
    for(NSString* aString in arrayOfStringsRepresentingAMorseCodeLetters){
        allMorseCodesTogether = [allMorseCodesTogether stringByAppendingString:[NSString stringWithFormat:@"%@    ",aString]];
    }
    
    self.myLabel.text = allMorseCodesTogether;
    
    
    
    NSLog(@"%@" , arrayOfStringsRepresentingAMorseCodeLetters);
}


-(NSArray*)returnArrayOfMorseCodeLettersFromAnArrayOfLetters:(NSArray*)arrayOfLetters{
    NSMutableArray* arrayOfMorseCodes =  [[NSMutableArray alloc]init];
    
    for(NSString* oneLetter in arrayOfLetters){
        [arrayOfMorseCodes addObject:[NSString returnAStringRepresentingTheMorseCodeNumberOfThisLetter:oneLetter]];
    }
    return arrayOfMorseCodes;
}


- (IBAction)goWasHit:(id)sender {
    [self analyzeAndPrintTheTextField];
}
@end
