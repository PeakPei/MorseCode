//
//  MCViewController.m
//  MorseCodeDemo
//
//  Created by Brad on 1/20/14.
//  Copyright (c) 2014 Brad. All rights reserved.
//

#import "MCViewController.h"
#import "NSString+MorseCode.h"

@interface MCViewController ()

@end

@implementation MCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *stringToBreakApart = @"Yo Joe";
    
    NSArray *arrayForOneLetteredStrings;
    // If there is a string in this object.
    if(stringToBreakApart){
        // We changed the NSString class by adding a "category" that gives it a method that returns an array of letters (which are actually just one lettered strings) from the overall string.
        arrayForOneLetteredStrings = [stringToBreakApart getArrayOfOneLetteredStrings];
    }
    // Otherwise, the object is nill.
    else{
       arrayForOneLetteredStrings =  @[@"String Was Nil"];
    }
    
    NSLog(@"%@", arrayForOneLetteredStrings);
}


@end
