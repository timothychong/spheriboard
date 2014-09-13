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
    
    return CGPointMake(pt.x / width * 16.9 - 8.45, pt.y / height  * 30 - 15);
}

+(CGPoint)getXYCoordinate:(CGPoint)pt
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    return CGPointMake((pt.x + 8.45) * width / 16.9 , (pt.y + 15) * height  / 30);
}

// Get db read coodinates from xy on phone
+(CGPoint) xYToDB:(CGPoint) point givenPhi:(double) phi
            theta:(double) theta andOrientation:(double) orientation {
    CGPoint pt = [conversion stCenterCoordinate:point];
    double magnitude = sqrt(pow(pt.x, 2.0) + pow(pt.y, 2.0));
    pt.x = magnitude*sin(orientation)*RADS_TO_DEGREES;
    pt.y = magnitude*cos(orientation)*RADS_TO_DEGREES;
    pt.x = pt.x + theta;
    if (pt.x > 360.0) {
        pt.x = pt.x - theta;
    }
    if (phi > 0.0) {
        pt.y += phi;
    } else {
        pt.y -= phi;
    }
    return pt;
}

// Get display xy coords from db coords
+(CGPoint) dBToXY:(CGPoint) pt givenPhi:(double) phi
            theta:(double) theta andOrientation:(double) orientation {
    pt.x = pt.x - theta;
    if (pt.x < 0.0) {
        pt.x = pt.x + theta;
    }
    if (phi > 0.0) {
        pt.y -= phi;
    } else {
        pt.y += phi;
    }
    double magnitude = sqrt(pow(pt.x, 2.0) + pow(pt.y, 2.0));
    pt.x = magnitude*sin(orientation)*RADS_TO_DEGREES;
    pt.y = magnitude*cos(orientation)*RADS_TO_DEGREES;
    return [conversion getXYCoordinate:pt];
}



@end
