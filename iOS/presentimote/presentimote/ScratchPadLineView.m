//
//  ScratchPadView.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ScratchPadLineView.h"
#import "conversion.h"


@implementation ScratchPadLineView

@synthesize path_length = path_length;

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
    double phi, theta, orientation;
    [self.delegate scratchPadLineView:self currentPhi:&phi currentTheta:&theta currentOrientiation:&orientation];
    // Moving to the start point of drawing
    
    CGContextBeginPath(c);
    
    CGPoint start = [conversion dBToXY:CGPointMake(path[0].x, path[0].y) givenPhi:phi theta:theta andOrientation:orientation];
    
    CGContextMoveToPoint(c, start.x, start.y);
    CGPoint temp;
    for (int i = 1; i < path_length; i ++) {
        temp = [conversion dBToXY:CGPointMake(path[i].x, path[i].y) givenPhi:phi theta:theta andOrientation:orientation];
//        NSLog(@"Output Path: %@", NSStringFromCGPoint(temp));
//        NSLog(@"Output vareables %f %f %f", phi, theta, orientation);
        CGContextAddLineToPoint(c, temp.x , temp.y);
    }
    CGContextStrokePath(c);
}

-(void) addPointWithX: (float) x andY: (float) y {
    double phi, theta, orientation;
    [self.delegate scratchPadLineView:self currentPhi:&phi currentTheta:&theta currentOrientiation:&orientation];
    CGPoint temp = [conversion xYToDB:CGPointMake(x, y) givenPhi:phi theta:theta andOrientation:orientation];
    path[path_length].x = temp.x;
    path[path_length].y = temp.y;
//    NSLog(@"Input Path: %@", NSStringFromCGPoint(temp));
//    NSLog(@"Input vareables %f %f %f", phi, theta, orientation);
    path_length ++;
    if (sizeof(path) / sizeof(path[0]) == path_length) {
        path_length = 0;
    }
    [self setNeedsDisplay];
}

-(void) addPointWithDBX: (float) x andY: (float) y {
    path[path_length].x = x;
    path[path_length].y = y;
    path_length ++;
    if (sizeof(path) / sizeof(path[0]) == path_length) {
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

-(CGPoint)getPathAtIndex:(int) index
{
    return path[index];
}

@end
