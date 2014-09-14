//
//  ViewController.h
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScratchPadView.h"
#import <socket.IO/SocketIO.h>
#import "OrientationSolver.h"
#import "ScratchPadLineView.h"

@interface BoardViewController : UIViewController <ScratchPadViewDelegate, SocketIODelegate, OrientationSolverDelegate, ScratchPadLineViewDelegate> {
    NSTimer *timer;
}

@property (nonatomic) NSTimer    *timer;
@property (nonatomic) NSString * roomCode;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;

@end

