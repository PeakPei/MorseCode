//
//  CAMViewController.h
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//

// This class sends the morse code message using camera flashes.

#import <UIKit/UIKit.h>

@interface SenderViewController : UIViewController<UITextFieldDelegate>{
    NSArray* arrayOfStringsRepresentingMorseCodeLetters; // The letters to be flashed.
    BOOL goIsNowTheCancellButton; // The send and cancel button are shared by one button, this is how it changes.
    int letterOrSpaceIterater; // This is just a counter, keeping track of each letter we're currently showing from our messsage.
}

@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UILabel *myLabel2;

- (IBAction)goWasHit:(id)sender; 

@end
