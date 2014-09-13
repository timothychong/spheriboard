//
//  conversion.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "conversion.h"
#import "math.h"
#import "OrientationSolver.h"

#define RADS_TO_DEGREES 57.2957795

@implementation conversion

+(CGPoint)stCenterCoordinate:(CGPoint)pt
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    return CGPointMake(pt.x / width * 16.9 - 8.45, -(pt.y / height  * 30 - 15));
}

+(CGPoint)getXYCoordinate:(CGPoint)pt
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    return CGPointMake((pt.x + 8.45) * width / 16.9 , (-pt.y + 15) * height  / 30);
}

// Get db coodinates from xy on phone
+(CGPoint) xYToDB:(CGPoint) point givenPhi:(double) phi
            theta:(double) theta andOrientation:(double) orientation {
    CGPoint pt = [conversion stCenterCoordinate:point];
    double counterClockwise =  90.0 - orientation;
    double x = pt.x*cos(counterClockwise/RADS_TO_DEGREES) - pt.y*sin(counterClockwise/RADS_TO_DEGREES);
    pt.y = pt.x*sin(counterClockwise/RADS_TO_DEGREES) + pt.y*cos(counterClockwise/RADS_TO_DEGREES);
    pt.x = x;
    pt.y += theta;
    if (pt.y > 360.0) {
        pt.y -= 360.0;
    }
    pt.x += phi;
    pt.y *= -1;
    return pt;
}

// Get display xy coords from db coords
+(CGPoint) dBToXY:(CGPoint) pt givenPhi:(double) phi
            theta:(double) theta andOrientation:(double) orientation {
    pt.y *= -1;
    pt.y -= theta;
    pt.x -= phi;
    double counterClockwise = 270.0 + orientation;
    double x = pt.x*cos(counterClockwise/RADS_TO_DEGREES) - pt.y*sin(counterClockwise/RADS_TO_DEGREES);
    pt.y = pt.x*sin(counterClockwise/RADS_TO_DEGREES) + pt.y*cos(counterClockwise/RADS_TO_DEGREES);
    pt.x = x;
    return [conversion getXYCoordinate:pt];
}



@end
