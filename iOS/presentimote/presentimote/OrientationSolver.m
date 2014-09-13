//
//  OrientationSolver.m
//  GyrosAndAccelerometers
//
//  Created by Luke Sorenson on 9/13/14.
//  Copyright (c) 2014 Downtyme, LLC. All rights reserved.
//

#import "OrientationSolver.h"

#define RADS_TO_DEGREES 57.2957795
#define K 0.96

@interface OrientationSolver ()

@property (strong, nonatomic) CMMotionManager * _motionManager;
@property (nonatomic) CLLocationManager * _locationManager;
@property (nonatomic) CLLocationDirection _currentHeading;
@property (nonatomic) double originalOrientation;
@property (nonatomic) NSTimer * headerTimer;

@end

double avgX;
double avgY;
double avgZ;

//double phi_;
//double theta_;
double phi_top;
double theta_top;


@implementation OrientationSolver

- (id) init {
    self = [super init];
    if (self) {
//        [self initializeArrays];
        
        self._motionManager = [[CMMotionManager alloc] init];
        self._motionManager.accelerometerUpdateInterval = 1.0/60.0;
        
        self._locationManager = [CLLocationManager new];
        self._locationManager.delegate = self;
        self._locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self._motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     [self calculateAccelertionData:accelerometerData.acceleration];
                                                     if(error){
                                                         NSLog(@"Error in acceleration data: %@", error);
                                                     }
                                                 }];
        
        [self._locationManager startUpdatingHeading];
    }
    return self;
}

//- (void) initializeArrays {
//    for (int i = 0; i < 5; i++) {
//        lastX[i] = 0;
//        lastY[i] = 0;
//        lastZ[i] = 0;
//    }
//}
//
//- (void) insertAndShiftArray:(CMAcceleration)acceleration {
//    for (int i = 3; i > 0; i--) {
//        lastX[i+1] = lastX[i];
//        lastY[i+1] = lastY[i];
//        lastZ[i+1] = lastZ[i];
//    }
//    
//    lastX[0] = -acceleration.x;
//    lastY[0] = -acceleration.y;
//    lastZ[0] = -acceleration.z;
//}
//
//- (void) computeRunningAverage {
//    double sumX = 0;
//    double sumY = 0;
//    double sumZ = 0;
//    for (int i = 0; i < 5; i++) {
//        sumX += lastX[i];
//        sumY += lastY[i];
//        sumZ += lastZ[i];
//    }
//    avgX = sumX/5;
//    avgY = sumY/5;
//    avgZ = sumZ/5;
//    
//}

- (void) calculateAccelertionData:(CMAcceleration)acceleration
{
//    [self insertAndShiftArray:acceleration];
//    [self computeRunningAverage];
    avgX = K * avgX + (1.0 - K) * acceleration.x;
    avgY = K * avgY + (1.0 - K) * acceleration.y;
    avgZ = K * avgZ + (1.0 - K) * acceleration.z;
    
//    avgX = acceleration.x;
//    avgY = acceleration.y;
//    avgZ = acceleration.z;
    
    // Compute phi
    double phi = atan(avgZ/pow(pow(avgX, 2.0)+pow(avgY, 2.0), 0.5))*RADS_TO_DEGREES;
    // Compute theta
    double theta = self._currentHeading - _originalOrientation;
    {
        if (phi < -45.0) {
            theta += 180.0;
        }
        if (fabs(avgX) > 0.1 || fabs(avgY) > 0.1) {
            double delta = atan(avgX/avgY)*RADS_TO_DEGREES;
            if (avgY > 0.0) {
                theta += delta;
            } else {
                if (delta < 0.0) {
                    theta += 180.0 - delta;
                } else {
                    theta += delta - 180.0;
                }
            }
        }
    }
    while (theta > 360.0) {
        theta -= 360.0;
    }
    while (theta < 0.0) {
        theta += 360.0;
    }
    if (phi > 45.0) {
        phi = 45.0;
    } else if (phi < -45.0) {
        phi = -45.0;
    }
    
    double orientation = self._currentHeading - _originalOrientation - theta;
    [self.delegate OrientationSolver:self didReceiveNewAccelerometerDataWithTheta:theta andPhi:phi andOrientation:orientation];
//    phi_ = phi;
//    theta_ = theta;
}

//- (void) getAccelerationDataPhi:(double*)phi andTheta:(double*)theta
//    andOrientation:(double *)orientation {
//    *phi = phi_;
//    *theta = theta_;
//    *orientation = self._currentHeading - _originalOrientation - theta_;
//    NSLog(@"%@",[NSString stringWithFormat:@"Phi: %.2f",phi_]);
//    NSLog(@"%@",[NSString stringWithFormat:@"Theta: %.2f",theta_]);
//}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (!_originalOrientation) {
        if (newHeading.trueHeading == 0) {
        } else {
            _originalOrientation = newHeading.trueHeading;
            
        }
    }
    self._currentHeading = newHeading.trueHeading;
}

@end
