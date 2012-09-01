//
//  LJKViewController.h
//  EnoceanTest
//
//  Created by Lars-Jørgen Kristiansen on 25.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJKViewController : UIViewController <NSStreamDelegate>
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

- (IBAction)up:(id)sender;
- (IBAction)down:(id)sender;
- (IBAction)released:(id)sender;
- (IBAction)blindsUp:(id)sender;
- (IBAction)blindsRelease:(id)sender;
- (IBAction)blindsDown:(id)sender;
- (IBAction)teach:(id)sender;
- (IBAction)dim:(id)sender;
- (IBAction)off:(id)sender;
- (IBAction)value:(UISlider*)sender;
- (IBAction)speed:(UISlider*)sender;

@end
