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

@interface ViewController : UIViewController <ScratchPadViewDelegate, SocketIODelegate, OrientationSolverDelegate, ScratchPadLineViewDelegate>



@end

