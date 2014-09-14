//
//  ScratchPadView.h
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScratchPadLineView;

@protocol ScratchPadLineViewDelegate <NSObject>

-(void) scratchPadLineView: (ScratchPadLineView *) view currentPhi:(double *)phi currentTheta:(double *) theta currentOrientiation:(double *) orientation;

@end

struct luke_point {
    double x, y;
    double last_x, last_y;
    bool not_first_time;
};

@interface ScratchPadLineView : UIView {
    struct luke_point path[500];
}
@property (nonatomic) int tim_path_length;
@property (nonatomic, weak) id <ScratchPadLineViewDelegate> delegate;

-(void) addPointWithX: (float) x andY: (float) y;
-(void) addPointWithDBX: (float) x andY: (float) y;
-(void)setPath:(NSMutableArray *)array;

-(CGPoint)getPathAtIndex:(int) index;
@end
