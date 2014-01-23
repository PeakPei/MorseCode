//
//  CAMViewController.m
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//

#import "CAMViewController.h"
#import "NSString+MorseCode.h"
#import <AVFoundation/AVFoundation.h>

@interface CAMViewController ()
@property (weak, nonatomic) IBOutlet UIButton *myUIActivateButton;
@property (weak, nonatomic) IBOutlet UILabel *theLetterBeingDisplayedLabel; //Show the letter being displayed in the text view.
@property (strong,nonatomic) NSString* theWordBeingSent; // We use this string as a copy of the textview for letter displaying.
@property (strong,nonatomic) NSOperationQueue *myNSOpQueue; // This will basically hold an array of operations to perform on another thread.

@end

@implementation CAMViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    letterOrSpaceIterater = 0; //What letter are we displaying.
    goIsNowTheCancellButton = NO;
    [self.myUIActivateButton setEnabled:NO]; // We dont want to be able to send until text is entered in the text view.
    //This will keep the textField consantly busy, checking for text, but whatevs.
    [self.myTextField addTarget:self action:@selector(textFieldPopulated:) forControlEvents:UIControlEventAllEditingEvents];
}


- (IBAction)goWasHit:(id)sender {

    // Then we just hit the "cancel" button. The 2nd thread will keep checking back to see if the button was clicked.
    if(goIsNowTheCancellButton){
        goIsNowTheCancellButton = NO;
        //This should probably be set after the op has actually cancelled.
        [self.myUIActivateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.myUIActivateButton setTitle:@"send" forState:UIControlStateNormal];
        [self.myNSOpQueue setSuspended:YES];
        [self.myNSOpQueue cancelAllOperations];
        
    }
    // Then we just hit the "Send" button, it's go time.
    else{
        self.myNSOpQueue = [[NSOperationQueue alloc]init]; // He hit go, lets get the NSOperationQueue ready to take operations.
        [self.myNSOpQueue setMaxConcurrentOperationCount:1]; // This NSOperationQueue (aka: holder of NSOperations), shall only allow 1 thread.
        self.theWordBeingSent = self.myTextField.text;// Copy the string in the text view in case the user keeps typing.
        goIsNowTheCancellButton=YES; // Get the button ready to cancel.
        [self.myUIActivateButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.myUIActivateButton setTitle:@"cancel" forState:UIControlStateNormal];
        NSArray* arrayOfArrays = [NSString returnAnArrayOfArraysWithMorseSymbolsFromSentence:self.myTextField.text];
        [self flashUsingArrayOfArraysWithMorseSymbols:arrayOfArrays];  // Flash it out.
        NSLog(@"cal");
    }
}

- (void)turnTorchOn:(AVCaptureDevice *)device {
    [device lockForConfiguration:nil]; // This gets exclusive access to the camera's torch.
    [device setTorchMode:AVCaptureTorchModeOn]; //These two lines turn the light on.
    [device setFlashMode:AVCaptureFlashModeOn];
    [device unlockForConfiguration];
}

-(void)flashUsingArrayOfArraysWithMorseSymbols:(NSArray *)arrayOfArraysWithMorseSymbols{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice"); // Get the class of whatever av hardware this device has.
    if (captureDeviceClass != nil) { // As long as this device has some av device.
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; // Grab the camera device.
        if ([device hasTorch] && [device hasFlash]){
            for (NSArray* arrayRepresentingALetter in arrayOfArraysWithMorseSymbols) {
                NSBlockOperation* symbolOperation = [NSBlockOperation new];
                [symbolOperation addExecutionBlock:^{
                    // Lets tell our main thread to display the next iterating english letter (or space) of the sentence.
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{ [self letsDisplayTheNextLetter]; }];
                    
                    
                    for (NSString *aMorseCodeGranulatedSymbol in arrayRepresentingALetter) {
                        //Back to the 2nd thread again.
                        if ([aMorseCodeGranulatedSymbol isEqualToString:@"."]) {
                            NSLog(@"dot");
                            usleep( 100000 );  // Let's have this long of a gap in between each symbol.
                            [self turnTorchOn:device];
                            usleep( 100000 ); // Now FREEZE this thread for this long, while the light stays on.
                            [self turnOffTheTorch]; // Symbol is done.
                        } else if ([aMorseCodeGranulatedSymbol isEqualToString:@"-"]) {
                            NSLog(@"dash");
                            usleep( 100000 );  // Let's have this long of a gap in between each symbol.
                            [self turnTorchOn:device];
                            usleep( 300000 ); // Now FREEZE this thread for this long, while the light stays on.
                            [self turnOffTheTorch]; // Symbol is done.
                        }
                        else if([aMorseCodeGranulatedSymbol isEqualToString:@"wordspace"]){
                            NSLog(@"wordspace");
                            //We want 0.5, but every letter does for 0.1 anyways. Plus the end of each array for 0.2. And there are 2 of those. So we dont sleep at all.
                        }
                    }
                    //This gets once called for every array.
                    NSLog(@"new letter");
                    usleep(200000); // I want 300,000 after each array (letter), but each symbol automatically sleeps for 100,000 anyways.
                }];
                [self.myNSOpQueue addOperation:symbolOperation];
                
                
            }
        }
    }
}

// We set the textField up to constantly call here checking if it should keep the button enabled or not.
-(void)textFieldPopulated:(UITextField *)sender {
    [self.myUIActivateButton setEnabled:![sender.text isEqualToString:@""]]; // Tell the button to enable, we have text.
}


-(void)letsDisplayTheNextLetter{   // THis method uses the copy of the text field that we took.
    if(letterOrSpaceIterater<self.theWordBeingSent.length){
        NSString* thisChar = [self.theWordBeingSent substringWithRange:NSMakeRange(letterOrSpaceIterater, 1)];
        self.theLetterBeingDisplayedLabel.text = thisChar;
        [self.theLetterBeingDisplayedLabel setNeedsDisplay];
        letterOrSpaceIterater++;
    }
}

//This gets called from the main thread , and returns the result to another main thread call..
-(BOOL)checkIfCancelled{
    //  If the cancel button is visible, then it hasnt been hit yet
    if(goIsNowTheCancellButton){
        return NO;
    }
    // THe cancel button is not visible. Then we must stop because there should be no op running.
    else{
        return YES;
    }
}

-(void)turnOffTheTorch{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil]; // This gets exclusive access to the camera's torch.
    [device setTorchMode:AVCaptureTorchModeOff];
    [device setFlashMode:AVCaptureFlashModeOff];
    [device unlockForConfiguration];
}

@end
