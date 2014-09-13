//
//  OrientationSolver.m
//  GyrosAndAccelerometers
//
//  Created by Luke Sorenson on 9/13/14.
//  Copyright (c) 2014 Downtyme, LLC. All rights reserved.
//

#import "OrientationSolver.h"

#define RADS_TO_DEGREES 57.2957795

@interface OrientationSolver ()

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CLLocationManager * locationManager;
@property (nonatomic) CLLocationDirection currentHeading;
@property (nonatomic) double originalOrientation;

@end

double lastX[5];
double lastY[5];
double lastZ[5];

double avgX;
double avgY;
double avgZ;

double phi_;
double theta_;
double phi_top;
double theta_top;

@implementation OrientationSolver

- (id) init {
    self = [super init];
    if (self) {
        [self initializeArrays];
        
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = .1;
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     [self calculateAccelertionData:accelerometerData.acceleration];
                                                     if(error){
                                                         
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
        
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingHeading];
        }
    }
    return self;
}

- (void) initializeArrays {
    for (int i = 0; i < 5; i++) {
        lastX[i] = 0;
        lastY[i] = 0;
        lastZ[i] = 0;
    }
}

- (void) insertAndShiftArray:(CMAcceleration)acceleration {
    for (int i = 3; i > 0; i--) {
        lastX[i+1] = lastX[i];
        lastY[i+1] = lastY[i];
        lastZ[i+1] = lastZ[i];
    }
    
    lastX[0] = -acceleration.x;
    lastY[0] = -acceleration.y;
    lastZ[0] = -acceleration.z;
}

- (void) computeRunningAverage {
    double sumX = 0;
    double sumY = 0;
    double sumZ = 0;
    for (int i = 0; i < 5; i++) {
        sumX += lastX[i];
        sumY += lastY[i];
        sumZ += lastZ[i];
    }
    avgX = sumX/5;
    avgY = sumY/5;
    avgZ = sumZ/5;
}

- (void) calculateAccelertionData:(CMAcceleration)acceleration
{
    [self insertAndShiftArray:acceleration];
    [self computeRunningAverage];
    
    // Compute phi
    double phi = atan(avgZ/pow(pow(avgX, 2.0)+pow(avgY, 2.0), 0.5))*RADS_TO_DEGREES;
    // Compute theta
    double theta = self.currentHeading - _originalOrientation;
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
    phi_ = phi;
    theta_ = theta;
}

- (void) getAccelerationDataPhi:(double*)phi andTheta:(double*)theta
    andOrientation:(double *)orientation {
    *phi = phi_;
    *theta = theta_;
    *orientation = self.currentHeading - _originalOrientation - theta_;
    NSLog(@"%@",[NSString stringWithFormat:@"Phi: %.2f",phi_]);
    NSLog(@"%@",[NSString stringWithFormat:@"Theta: %.2f",theta_]);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (!_originalOrientation) {
        if (newHeading.trueHeading == 0) {
        } else {
            
            NSLog(@"\n\n\n\n\n%f\n\n\n\n\n\n", newHeading.trueHeading);
            
            _originalOrientation = newHeading.trueHeading;
            
        }
    }
    self.currentHeading = newHeading.trueHeading;
}

@end