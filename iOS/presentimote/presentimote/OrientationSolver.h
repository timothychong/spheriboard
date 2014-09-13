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
@class OrientationSolver;

@protocol OrientationSolverDelegate <NSObject>

-(void) OrientationSolver:(OrientationSolver *) solver didReceiveNewAccelerometerDataWithTheta:(double) theta andPhi:(double) phi andOrientation:(double) orientation;

@end

@interface OrientationSolver : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <OrientationSolverDelegate> delegate;

- (void) calculateAccelertionData:(CMAcceleration)acceleration;

//- (void) getAccelerationDataPhi:(double*)phi andTheta:(double*)theta
//                 andOrientation:(double*)orientation;

@end
