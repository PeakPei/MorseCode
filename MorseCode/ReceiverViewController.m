//
//  CAMViewController.m
//  FlashDetector
//
//  Created by Chris Meehan on 1/23/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//

#import "ReceiverViewController.h"
#import "CFMagicEvents.h" // We import this camera input analyzer class we got off github to measure light intensities.
#import "NSString+MorseArrayToLetter.h" // We use this NSString extension for converting morse symbols to english letters.

@interface ReceiverViewController (){
    float timeMagnitude;
}
- (IBAction)sliderMoved:(id)sender;
- (IBAction)valueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *sensativiyLabel;
@property (weak, nonatomic) IBOutlet UILabel *flashIndicator;
@property (strong,nonatomic) NSOperationQueue* nSOQ; // This will run all of our 2nd queue, camera processing operations.
@property (weak, nonatomic) IBOutlet UILabel *theLabel; // This label will display to the user, the message being decoded.
@property (strong,nonatomic) NSMutableArray* morseLetter; // This will hold the contents of the current morse letter being sent to us.
@end

@implementation ReceiverViewController

// We initiallize in here, because we want everything to stop if we back out of the screen, and re-init when we come back in. Like a reset.
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    timeMagnitude = 1.5; //Magnituding the time difference of symbols by 1.5 helps the accuracy.
    sensativiy = 100000; // 100,000 sensativity to start is average.
    weAreRunning = YES; // Our 2nd queue keeps checking this value to see if it should stop.
    self.morseLetter = [[NSMutableArray alloc]init]; // Get this array ready, that is going to hold an entire letter in morse symbols.
    self.theLabel.text = @""; // Display nothing to the user right now.
    self.nSOQ = [[NSOperationQueue alloc]init]; // Get our 2nd queue ready to read camera input.
    firstWordSpaceHasFired = NO; // This will get set to "yes" once the firstWordSpace gets fired right at the beginning, so we can then ignore the 1st one.
    // Beginning of block.    Each block will grab the current picture's light level, compare it to the last one it had, and make a decision ask quick as it can. And these blocks do this back to back as fast as the processor will let them.
    NSBlockOperation* nSBO = [NSBlockOperation blockOperationWithBlock:^{
        CFMagicEvents* cFME = [[CFMagicEvents alloc]init]; // Setup that class that gets camera input and offers us brightness data.
        [cFME startCapture]; // And tell that class to start analyzing camera input data. It keeps getting recalled with every block though, possible I should be calling it once somehow within this 2nd queue and always have a pointer to it. But for now, we just keep recalling it for every block.
        lightIsOn = NO; // We will start with the knowledge that the light is off right now.
        onDate = [NSDate date];    // So it has something to compare to the very first time.
        offDate = [NSDate date];    // So it has something to compare to the very first time.
        while(weAreRunning){
            
            // When we back out of the screen, this gets set to "NO" and this infinit camera loop stops, and then so will the operationQueue.
            int theBrightness = [cFME getLastBrightness]; // This is our most valueable method call, it's how we get the current level of brightness.
            if(theBrightness-lastBrightness > sensativiy && !lightIsOn){ // Just turned on. It got really bright, and we weren'n on before?
                // Now ask the offDate how long it was activated until now (basically, how long has the light been off for.)
                NSTimeInterval timeInterval = [offDate timeIntervalSinceNow] * -1.0; // It comes out negative, so we invert it.
                onDate = [NSDate date];
                lightIsOn = YES;
                if(timeInterval < 0.2 * timeMagnitude){  // should be 0.1 for a symbol space, but we split the differece from a letter spacing 0.3 pause
                    // if it was dark for that short amount of time, then this was a seperation of symbols. Which is a default, expected pause, so we do nothing.
                }
                // But if the pause was around 0.3 seconds, then this is the beggining of a new letter. Let's log in the last letter.
                else if(timeInterval < 0.4 * timeMagnitude){ // We use 0.4 as our barier, to split the difference between a 0.3 letter splitter and a 0.5 word splitter.
                    // Now let's send the MAIN UI the letter weve aquired, then clear the letter array.
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSString* str = [NSString englishLetterFromAMorseLetter:self.morseLetter];
                        [self addThisLetter:str]; // Add this letter to the end of the word being displayed to the user.
                        [self.theLabel setNeedsDisplay];
                        [self.morseLetter removeAllObjects]; // Clear the array for the next letter.
                    }];
                }
                // If we're here, then the darkness before this light was longer than 0.4 seconds, and 0.5 seconds of darkness means a word split.
                else{
                    if(firstWordSpaceHasFired){ // As long as that errorneous firstWordSpace has been fired, we can behave like normal.
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSString* str = [NSString englishLetterFromAMorseLetter:self.morseLetter];
                            [self addThisLetter:str];
                            [self addThisLetter:@" "]; // This is us adding a space to the end of the string being presented to the user.
                            [self.theLabel setNeedsDisplay];
                            [self.morseLetter removeAllObjects]; // Clear the array for the next letter.
                        }];
                    }
                    // Otherwise, this is the 1st time it fired, it is like the engine startup, we will ignore it.
                    else{
                        firstWordSpaceHasFired = YES;
                    }
                }
                // Tell our MAIN's UI to change that square box to green, for "light on".
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.flashIndicator setBackgroundColor:[UIColor greenColor]];
                }];
            }
            // Just turned off. It got really dim, and we weren'n off before.
            else if((lastBrightness-theBrightness > sensativiy) && lightIsOn){ // As long as it just got reeeallllly dim, and the light was on.
                offDate = [NSDate date]; // Then lets log in what time it turned off, so we can compare to the next turn on.
                // Now ask the onDate how long it was activated until now (basically, how long was the last light on for.)
                NSTimeInterval timeInterval = [onDate timeIntervalSinceNow]* -1.0; // It comes out negative, so we invert it.
                lightIsOn =NO;
                // A dot is 0.1 seconds long, and dash is 0.3 seconds. Lets split the difference at 0.2.  
                if(timeInterval < 0.2 * timeMagnitude){
                    [self.morseLetter addObject:@"."];
                }
                else{
                    [self.morseLetter addObject:@"-"];
                }
                // Tell our MAIN's UI to change that square box to black, for "light off".
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.flashIndicator setBackgroundColor:[UIColor blackColor]];
                }];
            }
            lastBrightness = theBrightness; // Cant compare the next pictures brightness to our own unless we save this one.
            
        }
    }];
    // End of block.    We're back in MAIN now.
    [self.nSOQ addOperation:nSBO]; // Lets add that 1 block of infinitly looping through pictures, to our 2nd queue now to start it running.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    weAreRunning = NO; // This is what shuts down the 2nd queue.
}

// This gets called from within the 2nd queue once it confirms it found a letter. And this adds that letter to the end or the string the user sees.
-(void)addThisLetter:(NSString*)theLetter{
    self.theLabel.text = [self.theLabel.text stringByAppendingString:theLetter];
}


- (IBAction)sliderMoved:(id)sender {
    UISlider* uIS  = (UISlider*) sender;
    sensativiy = uIS.value;
    self.sensativiyLabel.text = [NSString stringWithFormat:@"%d",(int) sensativiy];
}

- (IBAction)valueChanged:(id)sender {
    UISwitch* theSwitch = (UISwitch*) sender;
    if(theSwitch.isOn){
        timeMagnitude = 1.5;
    }
    else{
        timeMagnitude = 1;
    }
}
@end
