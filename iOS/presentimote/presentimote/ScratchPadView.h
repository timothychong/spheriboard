//
//  ScratchPadView.h
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScratchPadView;

@protocol ScratchPadViewDelegate <NSObject>

-(void)scratchPadView:(ScratchPadView *) view touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event;
-(void)scratchPadView:(ScratchPadView *) view touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event;
-(void)scratchPadView:(ScratchPadView *) view touchesEnded:(NSSet *) touches withEvent:(UIEvent *)event;

@end


@interface ScratchPadView : UIView

@property (nonatomic, weak) id <ScratchPadViewDelegate> delegate;

@end

