//
//  ScratchPadView.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ScratchPadLineView.h"


@implementation ScratchPadLineView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        path_length = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGPoint) lastPathPixel {
    return path[path_length - 1];
}

- (void)drawRect:(CGRect)rect {
    
    if(path_length == 0){
        return;
    }
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(c, red);
    // Moving to the start point of drawing
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, path[0].x, path[0].y);
    for (int i = 1; i < path_length; i ++) {
        CGContextAddLineToPoint(c, path[i].x, path[i].y);
    }
    CGContextStrokePath(c);
}

-(void) addPointWithX: (float) x andY: (float) y {
    path[path_length].x = x;
    path[path_length].y = y;
    path_length ++;
    if (sizeof(path) / sizeof(path[0]) < path_length) {
        path_length = 0;
    }
    [self setNeedsDisplay];
}

-(void)setPath:(NSMutableArray *)array
{
    [array enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        CGPoint p;
        [value getValue:&p];
        path[idx] = p;
        path_length ++;
        
    }];
    path_length = array.count;
    [self setNeedsDisplay];
    
}

@end
