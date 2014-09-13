//
//  ScratchPadView.h
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScratchPadLineView : UIView {
    CGPoint path[1000];
    int path_length;
}

-(void) addPointWithX: (float) x andY: (float) y;

@end
