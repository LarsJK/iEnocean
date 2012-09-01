//
//  LJKViewController.m
//  EnoceanTest
//
//  Created by Lars-Jørgen Kristiansen on 25.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJKViewController.h"

@interface LJKViewController () {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSNumber *value;
    NSNumber *speed;
}
@end

@implementation LJKViewController
@synthesize temperatureLabel;

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"10.0.1.2", 8081, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void) closeStreams {
    NSLog(@"Closing..");
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream = nil;
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    outputStream = nil;
}

- (void) openStreams {
    [self initNetworkCommunication];
}

#pragma mark - stream delegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
            
        case NSStreamEventNone:
            NSLog(@"None");
			break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Space");
			break;
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        NSLog(@"%@", output);
                        
                        if (nil != output) {
                            NSData *data = [output dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            
                           
                            NSLog(@"%@", json);
                            
                            NSDictionary *temperatures = [json objectForKey:@"Temperatures"];
                            
                            NSLog(@"%@", temperatures);
                            
                            if (temperatures) {
                                NSNumber *temperature = [temperatures objectForKey:@"8573742"];
                                float temp = 40.0 - ((40.0 /255.0)*[temperature floatValue]);
                                temperatureLabel.text = [NSString stringWithFormat:@"%.2f°C", temp];
                            }
                           
                        }
                        
                    }
                     
                }
            }
			break;			
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"End");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    value = [NSNumber numberWithInt:0x00];
    speed = [NSNumber numberWithInt:0x00];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeStreams) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openStreams) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self initNetworkCommunication];
}

- (void)viewDidUnload
{
    [self setTemperatureLabel:nil];
    [super viewDidUnload];    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)up:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"PTM200",@"Up"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
   /* NSData *strData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [outputStream write:(uint8_t *)[strData bytes] maxLength:[strData length]];*/
}

- (IBAction)down:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"PTM200",@"Down"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
    /*
    NSString *message = @"Down\n";
    NSData *strData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [outputStream write:(uint8_t *)[strData bytes] maxLength:[strData length]];
     */
}

- (IBAction)released:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"PTM200",@"Release"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
    /*
    NSString *message = @"Released\n";    
    NSData *strData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [outputStream write:(uint8_t *)[strData bytes] maxLength:[strData length]];
     */
}

- (IBAction)blindsUp:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Blinds",@"PTM200",@"Up"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}

- (IBAction)blindsRelease:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Blinds",@"PTM200",@"Release"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}

- (IBAction)blindsDown:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Blinds",@"PTM200",@"Down"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}

- (IBAction)teach:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"Direct",@"Teach"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}

- (IBAction)dim:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"Direct",@"Dim"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}

- (IBAction)speed:(UISlider*)sender {
    int sp = sender.value;
    speed = [NSNumber numberWithInt:sp];
}

- (IBAction)off:(id)sender {
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"Direct",@"Off"] forKeys:@[@"Device",@"Sender",@"Action"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}

- (IBAction)value:(UISlider*)sender {
    int val = sender.value;
    value = [NSNumber numberWithInt:val];
    NSDictionary * json = [NSDictionary dictionaryWithObjects:@[@"Dimmer",@"Direct",@"Dim", value, speed] forKeys:@[@"Device",@"Sender",@"Action",@"Value",@"Speed"]];
    NSError *error;
    [NSJSONSerialization writeJSONObject:json toStream:outputStream options:0 error:&error];
    NSLog(@"%@", error);
}
@end
