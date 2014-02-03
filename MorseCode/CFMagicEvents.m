
//  CFMagicEvents.m
//  Copyright (c) 2013 Cédric Floury
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the
//     purpose of any concept relating to diary/journal keeping.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "CFMagicEvents.h"
#import <AVFoundation/AVFoundation.h>


#define NUMBER_OF_FRAME_PER_S 5
#define BRIGHTNESS_THRESHOLD 70
#define MIN_BRIGHTNESS_THRESHOLD 10

@interface CFMagicEvents() <AVCaptureAudioDataOutputSampleBufferDelegate>{
    AVCaptureSession *_captureSession;
    int  _lastTotalBrightnessValue;
    int _brightnessThreshold;
    BOOL _started;
}
@end

@implementation CFMagicEvents

#pragma mark - init

- (id)init{
    if ((self = [super init])) { [self initMagicEvents];}
    return self;
}

- (void)initMagicEvents{
    _started = NO;
    [NSThread detachNewThreadSelector:@selector(initCapture) toTarget:self withObject:nil];
}

- (void)initCapture {
    NSError *error = nil;
    AVCaptureDevice *captureDevice = [self searchForBackCameraIfAvailable];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if ( ! videoInput){
        NSLog(@"Could not get video input: %@", error);
        return;
    }
    //  the capture session is where all of the inputs and outputs tie together. You just add inputs and outputs like you are adding objects to an array, then you just talk to the capture session. Sweet.
    _captureSession = [[AVCaptureSession alloc] init];
    //  sessionPreset governs the quality of the capture. we don't need high-resolution images,
    //  so we'll set the session preset to low quality.
    _captureSession.sessionPreset = AVCaptureSessionPresetLow;
    [_captureSession addInput:videoInput]; // Let's add the input
    //  create the thing which captures the output
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //  You will give this dict (which are just vid output settings.) to you videoDataOutput, pixel buffer format in this case.
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
                              kCVPixelBufferPixelFormatTypeKey, nil];
    videoDataOutput.videoSettings = settings;
    dispatch_queue_t queue = dispatch_queue_create("com.zuckerbreizh.cf", NULL);
    [videoDataOutput setSampleBufferDelegate:(id)self queue:queue];
    // Lets finally add an output to that AVCaptureSession.
    [_captureSession addOutput:videoDataOutput];
    // This method is used to start the flow of data from the inputs to the outputs connected to the AVCaptureSession instance that is the receiver.
    [_captureSession startRunning];
    _started = YES;
}

-(void)updateBrightnessThreshold:(int)pValue{
    _brightnessThreshold = pValue;
}

-(BOOL)startCapture{
    if(!_started){
        _lastTotalBrightnessValue = 0;
        [_captureSession startRunning];
        _started = YES;
    }
    return _started;
}

-(BOOL)stopCapture{
    if(_started){
        [_captureSession stopRunning];
        _started = NO;
    }
    return _started;
}

#pragma mark - Delegate
// This method notifies the delegate(this class) every time a sample buffer is written. (required)
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
fromConnection:(AVCaptureConnection *)connection{
    // Get the image, and put it in a Core Video image buffer reference.
    CVImageBufferRef cVIBR = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (CVPixelBufferLockBaseAddress(cVIBR, 0) == kCVReturnSuccess){ // If locking in on this pixel buffer was a success.
        // A UInt8 is an 8-bit unsigned integer (basically like a char). I think this byte holds the "red value" of the very firss pixel. It's address is the very 1st address in a long array of bytes. No seperation into rows or anything. We are on our own to sift through this.
        UInt8 *EightBitUnsignedInt = (UInt8 *)CVPixelBufferGetBaseAddress(cVIBR);
        size_t bytesPerRow      = CVPixelBufferGetBytesPerRow(cVIBR); // Which is 768 for iphone 4s.
        UInt32 totalBrightness  = 0; // Lets start with 0 brightness, and add it up as we go.
        
        // So, there are 4 bytes to each "picture square", red,green,blue,alpha. And 4*(width*height) = totalAmountOfBytesInPic, right?
        
        // Here, we loop through each "picture square" and tally up their total brightness.
        // RowStart will always point at a "red" byte, anywhere in the pic. It will be incremented by 4 as it scans the coulmns, it will get a total of like 768 incrementations (or however many bytes there are in a row) every time it moves from the beggining of one row to the next.
        // They decided just to count down the "height" variable we obtained as we loop through rows in order to know when the last row has been read. So from our point of view, we're starting with the top row, and counting downward.
        int totalRows = 144;
        int totalCount = 0;
        int rowCount = 0;
        for (UInt8 *rowStart = EightBitUnsignedInt; rowCount<totalRows; rowStart += bytesPerRow, rowCount++){// Loop through each row.
            int totalColumns = 192;// Set up how many columns the following "for" will loop through.
            // Loop through each column in this row. Once again, we start with the max columnCount, and loop down to column # 0. (Right to left).
            int columnCount = 0;
            // This is where the logic happens, not only does this scan through each pixel of the cuurent image of the camera, but we modified this nested for loop to only pay attention to the pixels in the middle of the camera lens and have the user align to the center, that we we have better accuracy.
            for (UInt8 *p = rowStart ; columnCount<totalColumns; p += 4, columnCount++){
                if((totalColumns*rowCount+columnCount)>6912 && (totalColumns*rowCount+columnCount)<20736){
                    totalCount++;
                    if(! (( 192.0f/1.333f < (totalColumns*rowCount+columnCount) % 192 ||   48 > (totalColumns*rowCount+columnCount) % 192 )) ){
                        // Add it up.
                        UInt32 value = (p[0] + p[1] + p[2]); // Here is the only time you get to look at any pixel other than a "red" (aka p[0]), if you wanted to.
                        totalBrightness += value; // This "pictue square's" brightness is now added to the grand total.
                    }
                }
            }
        }
        
        CVPixelBufferUnlockBaseAddress(cVIBR, 0); // Now unlock this pixel buffer to free it, now that we're done with this image.
        // If this is the 1st pic we've analyzed.
        if(_lastTotalBrightnessValue==0) _lastTotalBrightnessValue = totalBrightness; // Then set it to the current brightness.
    }
}


-(int)getLastBrightness{
    return _lastTotalBrightnessValue;
}

#pragma mark - Tools
- (AVCaptureDevice *)searchForBackCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}
@end
