//
//  OrientationSolver.h
//  GyrosAndAccelerometers
//
//  Created by Luke Sorenson on 9/13/14.
//  Copyright (c) 2014 Downtyme, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface OrientationSolver : NSObject<CLLocationManagerDelegate>

- (void) calculateAccelertionData:(CMAcceleration)acceleration;

- (void) getAccelerationDataPhi:(double*)phi andTheta:(double*)theta
                 andOrientation:(double*)orientation;

@end
