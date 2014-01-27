//
//  ReceiverViewController.h
//  MorseCode
//
//  Created by Chris Meehan on 1/22/14.
//  Copyright (c) 2014 Chris Meehan. All rights reserved.
//
// This controller interprets sequences of light flashes as morse code symbols using the devices camera, and decodes them into english letters for the user to see.
//
// It uses a class called CFMagicEvents i download off github at https://github.com/zuckerbreizh/CFMagicEventsDemo


#import <UIKit/UIKit.h>

@interface ReceiverViewController : UIViewController{
    float sensativiy; // This will be compared to the difference of this frame from the last to decide if it was a flash.
    int lastBrightness; // This keeps track of the cameras overall brightness value, that is every pixel's brightness added up.
    BOOL lightIsOn; // If we know a bright light just turned on, we will set this to yes. That way we wont keep checking for a bright light. We will then only check for a drop in light source. When that happens, we will record the time difference, and find out what symbol that was.
    NSDate *onDate; // The dates of when these changes in light intensities occur.
    NSDate *offDate;
    BOOL firstWordSpaceHasFired; // For some reason, the device always detects a "first word space" the first time it starts analysing light intensities, we dont want that, so we ignore the very first one.
    BOOL weAreRunning; // The second queue that reads the cameras pictures, check if this is set to yes, when viewDidDissapear, we set this to no to stop the 2nd queue.
}
@end
