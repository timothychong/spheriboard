//
//  ScratchPadView.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ScratchPadView.h"

@implementation ScratchPadView



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate scratchPadView:self touchesBegan:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate scratchPadView:self touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate scratchPadView:self touchesEnded:touches withEvent:event];
}


@end
