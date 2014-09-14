
#import "ARView.h"

#import <AVFoundation/AVFoundation.h>

@interface ARView () {
	UIView *captureView;
	AVCaptureSession *captureSession;
	AVCaptureVideoPreviewLayer *captureLayer;
}

- (void)initialize;

- (void)startCameraPreview;
- (void)stopCameraPreview;

@end


#pragma mark -
#pragma mark ARView implementation

@implementation ARView

@dynamic placesOfInterest;

- (void)dealloc
{
	[self stop];
	[captureView removeFromSuperview];
}

- (void)start
{
	[self startCameraPreview];
}

- (void)stop
{
	[self stopCameraPreview];
}

- (void)initialize
{
	captureView = [[UIView alloc] initWithFrame:self.bounds];
	captureView.bounds = self.bounds;
	[self addSubview:captureView];
	[self sendSubviewToBack:captureView];
}

- (void)startCameraPreview
{	
	AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (camera == nil) {
		return;
	}
	
	captureSession = [[AVCaptureSession alloc] init];
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
	[captureSession addInput:newVideoInput];
	
	captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
	captureLayer.frame = captureView.bounds;
	[captureLayer setOrientation:AVCaptureVideoOrientationPortrait];
	[captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[captureView.layer addSublayer:captureLayer];
	
	// Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[captureSession startRunning];
	});
}

- (void)stopCameraPreview
{	
	[captureSession stopRunning];
	[captureLayer removeFromSuperlayer];
	captureSession = nil;
	captureLayer = nil;
}

@end
