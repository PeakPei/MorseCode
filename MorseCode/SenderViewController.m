//
//  CAMViewController.m
//  MorseCode
//
//  Created by Chris Meehan on 1/20/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//

#import "SenderViewController.h"
#import "NSString+MorseCode.h"  // We extended the NSString class to handle and convert morse signals to english and vice versa.
#import <AVFoundation/AVFoundation.h> // Foundation for our camera flasher.
#import <M13ProgressSuite/M13ProgressViewPie.h> // For a HUD showing sending progress.
#import <BDKNotifyHUD/BDKNotifyHUD.h> // For a HUD showing the current letter being sent.

@interface SenderViewController ()
@property (weak, nonatomic) IBOutlet UIButton *myUIActivateButton; // This is the only button.
@property (strong,nonatomic) NSString* theWordBeingSent; // We use this string as a copy of the textview for letter displaying.
@property (strong,nonatomic) NSOperationQueue *myNSOpQueue; // This will basically hold an array of operations to perform on another queue.
@property (strong,nonatomic) M13ProgressViewPie* m13PV; // A HUD showing sending progress.
@property (strong,nonatomic) BDKNotifyHUD* bDKNHUD; // A HUD showing the current letter being sent.
@end

@implementation SenderViewController

-(void)viewWillDisappear:(BOOL)animated{ // When we leave this screen in any way, we stop any currently running queue.
    [self.myNSOpQueue cancelAllOperations];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    letterOrSpaceIterater = 0; //What letter we would be currently displaying (we're not yet though).
    goIsNowTheCancellButton = NO; // We start off with a button saying go, until we're sending flashes.
    [self.myUIActivateButton setEnabled:NO]; // We dont want to be able to send until text is entered in the text view.
    //This will keep the textField constantly busy, checking for a string at least one character long, but whatevs.
    [self.myTextField addTarget:self action:@selector(textFieldPopulated:) forControlEvents:UIControlEventAllEditingEvents];
}

- (IBAction)goWasHit:(id)sender {
    [self hideKeyboard];
    [self.myLabel setHidden:YES];    // Might as well get rid of that turorial message for good.
    [self.myLabel2 setHidden:YES];
    // Then we just hit the "cancel" button. The 2nd queue keeps checking back to see if this button was clicked. And will soon see it is.
    if(goIsNowTheCancellButton){
        letterOrSpaceIterater = 0; // Start this over for next time.
        [self.m13PV setHidden:YES];// kill the hud
        [self.bDKNHUD setHidden:YES];// kill the hud
        goIsNowTheCancellButton = NO; // Go is now the "go" button again.
        [self.myUIActivateButton setTitle:@"send" forState:UIControlStateNormal];
        [self.myUIActivateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.myNSOpQueue setSuspended:YES]; // Tell the queue to stop its execution.
        [self.myNSOpQueue cancelAllOperations]; // And cancel it for good.
    }
    // Then we just hit the "Send" button, it's go time.
    else{
        //Lets set up the HUD to display these letters and progress.
        float hUDWidth = 100.0;
        float progressX = (self.view.frame.size.width/2.0)-(hUDWidth/2.0)-98; // Set the progress HUD a bit to the left from center.
        float originY = 155.0; // And 155 from top of screen
        self.m13PV = [[M13ProgressViewPie alloc]initWithFrame:CGRectMake(progressX,originY,hUDWidth,hUDWidth)];
        [self.m13PV setProgress:0 animated:YES];
        [self.view addSubview:self.m13PV];
        UIView* someCustomView = [[UIView alloc]init]; // The letter displaying HUD wants a UIView upon initialization.
        self.bDKNHUD = [BDKNotifyHUD notifyHUDWithView:someCustomView text:@""];
        self.bDKNHUD.center = CGPointMake(self.view.center.x + 80, 240);
        [self.view addSubview:self.bDKNHUD];
        self.myNSOpQueue = [[NSOperationQueue alloc]init]; // He hit go, lets get the NSOperationQueue ready to take operations.
        [self.myNSOpQueue setMaxConcurrentOperationCount:1]; // This NSOperationQueue (aka: holder of NSOperations), shall only allow 1 thread.
        self.theWordBeingSent = self.myTextField.text;// Copy the string in the text view in case the user keeps typing.
        goIsNowTheCancellButton=YES; // Get the button ready to cancel.
        [self.myUIActivateButton setTitle:@"cancel" forState:UIControlStateNormal];
        [self.myUIActivateButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        NSArray* arrayOfArrays = [NSString returnAnArrayOfArraysWithMorseSymbolsFromSentence:self.myTextField.text]; // Get an array of symbols to flash.
        [self flashUsingArrayOfArraysWithMorseSymbols:arrayOfArrays];  // Flash it out.
    }
}

- (void)turnTorchOn:(AVCaptureDevice *)device {
    [device lockForConfiguration:nil]; // This gets exclusive access to the camera's torch.
    [device setTorchMode:AVCaptureTorchModeOn]; //These two lines turn the light on.
    [device setFlashMode:AVCaptureFlashModeOn];
    [device unlockForConfiguration];
}

// This method is what does the flashing.
-(void)flashUsingArrayOfArraysWithMorseSymbols:(NSArray *)arrayOfArraysWithMorseSymbols{
    int numOfLetters = 0; // Get ready to count how many letters this array is holding.
    for(NSArray* anArray in arrayOfArraysWithMorseSymbols){
        numOfLetters++; // So we know how many letters we have, for the progress bar to use as a division of progress.
    }
    int currentLetterCount = 0;  // This will keep track of how many letters we've shown, for the progress meter.
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice"); // Get the class of whatever av hardware this device has.
    if (captureDeviceClass != nil) { // As long as this device has some av device.
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; // Grab the camera device.
        if ([device hasTorch] && [device hasFlash]){ // If it can support flash.
            // Then we will step through each letter. And each letter's flash sequence will be put into a block, and that block added to the queue.
            for (NSArray* arrayRepresentingALetter in arrayOfArraysWithMorseSymbols) {
                NSBlockOperation* symbolOperation = [NSBlockOperation new]; // Create a new operation just for this letter.
                // Beginning of block.
                [symbolOperation addExecutionBlock:^{
                    // Lets really quickly tell our MAIN queue to display the next iterating english letter (or space) of the sentence.
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self letsDisplayTheNextLetter];
                        [self.m13PV setProgress:(float)currentLetterCount/(float)numOfLetters animated:YES]; // And adjust our progress.
                    }]; // End of message to MAIN.
                    // Now lets take this morse letter, and "for" loop through each symbol it contains. (e.g.  dot, dot, dash, dot   )
                    for (NSString *aMorseCodeIndividualSymbol in arrayRepresentingALetter) {
                        if ([aMorseCodeIndividualSymbol isEqualToString:@"."]) {
                            usleep( 100000 );  // Let's sleep for 0.1 second before shining each symbol, to seperate it from whatever happened before it.
                            [self turnTorchOn:device]; // Now shine the light for the dot.
                            usleep( 100000 ); // Now FREEZE this queue for this 0.1 second while the light stays on. Becaue that's the length of a dot.
                            [self turnOffTheTorch]; // Symbol is done.
                        } else if ([aMorseCodeIndividualSymbol isEqualToString:@"-"]) {
                            usleep( 100000 );  // Let's sleep for 0.1 second before shining each symbol, to seperate it from whatever happened before it.
                            [self turnTorchOn:device]; // Now shine the light for the dash.
                            usleep( 300000 ); // Now FREEZE this queue for this 0.3 seconds while the light stays on. Becaue that's the length of a dash.
                            [self turnOffTheTorch]; // Symbol is done.
                        }
                        else if([aMorseCodeIndividualSymbol isEqualToString:@"wordspace"]){
                            //We want a 0.5 second pause between the last letter of wordA and the first letter of wordB, but every letter does for 0.1 not matter what. Plus the end of each english letter (or space) does for 0.2 seconds. And there are 2 of those (the letter before this had one, and this space itself has one). So we dont sleep at all. That worked out too well.
                        }
                    }
                    //This gets called once after every letter (or space). It's pause is what seperates one letter to the next.
                    usleep(200000); // I want a total of a 0.3 second gap between the end of letterA and the beginning of letterB, but every letter gives a 0.1 second pause after it's over no matter what. So I only need to add 0.2 seconds pause to the end of that. And that's what we're doing.
                }];
                // End of this letter's operation block. Add it to the queue to run the flash sequences.
                [self.myNSOpQueue addOperation:symbolOperation];
                // Now that we're back to our MAIN queue, let's add 1 to the currentLetterCount for when we call our progress meter HUD.
                currentLetterCount++;
                // Now go back to the top of this loop to create another operation block.
            }
            // There, the flashing of all letters have now been created and handed off to the second queue.
            
            // Now, if I wanted to tell MIAN to do something UI at the end of all those flash sequences (let's say turn off the progress HUD), I wouldn't just type it here (in my MAIN), because by the time that this line is being called, the first letter of the first word has probably only just begun its flashing. So this code would be getting called at that exact same time, not at the end. Instead, we need to add to the end of the NSOperationQueue, an operation that calls back to MAIN.
            
            // Hey, let's do that right now.
            NSBlockOperation* finalUICleanupOperation = [NSBlockOperation new];
            [finalUICleanupOperation addExecutionBlock:^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    letterOrSpaceIterater = 0; // Starts this over for the progress meter HUD
                    [self.m13PV setHidden:YES]; // Bye bye HUD
                    [self goWasHit:nil]; // Let's call the method that gets called when we hit cancel, (which resets our button back and such).
                }];
            }];
            // Now add that cleanup operation to the end of our sequence in our 2nd queue.
            [self.myNSOpQueue addOperation:finalUICleanupOperation];
        }
    }
}
// Now that's how you create a large operation queue and get it running in one method. Wow.


// We set the textField up to constantly call here checking if it should keep the button enabled or not. Because the second it's empty, we dont want the button tappable.
-(void)textFieldPopulated:(UITextField *)sender {
    [self.myUIActivateButton setEnabled:![sender.text isEqualToString:@""]]; // And it constantly sends back a result.
}

-(void)letsDisplayTheNextLetter{   // This method uses the copy of the text field that we took to display the next letter to the user.
    if(letterOrSpaceIterater<self.theWordBeingSent.length){ // "If" I'm not reading a letter out of the range of the string, we will display it.
        NSString* thisChar = [self.theWordBeingSent substringWithRange:NSMakeRange(letterOrSpaceIterater, 1)]; // Get the letter.
        [self.bDKNHUD setText:thisChar]; // Give it to our HUD.
        [self.bDKNHUD presentWithDuration:0.5f speed:0.5f inView:self.view completion:^{ // Show it off for 0.5 seconds.
            // I got nothin for completion.
        }];
        letterOrSpaceIterater++; // Get the counter ready to display the next number.
    }
}

-(void)turnOffTheTorch{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil]; // This gets exclusive access to the camera's torch.
    [device setTorchMode:AVCaptureTorchModeOff];
    [device setFlashMode:AVCaptureFlashModeOff];
    [device unlockForConfiguration];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}
@end
