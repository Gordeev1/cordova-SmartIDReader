/**
 Copyright (c) 2012-2018, Smart Engines Ltd
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of the Smart Engines Ltd nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "SmartIDViewController.h"
#import "SmartIDViewController+Protected.h"
#import "SmartIDVideoPreviewView.h"
#import "SmartIDRoiView.h"
#import "RoiHelper.h"

@interface SmartIDViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, SmartIDViewControllerProtected>

@property (nonatomic, strong) SmartIDVideoPreviewView *videoPreview;
@property (nonatomic, strong) SmartIDRoiView *roiView;
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, assign) BOOL guiInitialized;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray *> *rois;
@property (nonatomic, assign) CGRect currentRoi;

@end

@implementation SmartIDViewController
@synthesize camera, engine, quadrangleView, previewLayer;

- (instancetype) init {
    if (self = [super init]) {
        self.rois = [[NSMutableDictionary alloc] init];
        
        [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationPortrait)];
        [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationLandscapeLeft)];
        [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationLandscapeRight)];
        [[self rois] setObject:@[@0, @0] forKey:@(UIDeviceOrientationPortraitUpsideDown)];
        
        self.engine = [[smartIDVideoProcessingEngine alloc] init];
        self.camera = [[SmartIDCameraManager alloc] init];
        self.videoPreview = [[SmartIDVideoPreviewView alloc] init];
        self.quadrangleView = [[SmartIDQuadrangleView alloc] init];
        self.roiView = [[SmartIDRoiView alloc] init];
        
        [[self camera] configurePreview:[self videoPreview]];
    }
    return self;
}

- (void) makeLayout {
    self.videoPreview.translatesAutoresizingMaskIntoConstraints = NO;
    self.quadrangleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.roiView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *videoPreviewLayout = @[[NSLayoutConstraint
                                     constraintWithItem:self.videoPreview
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.videoPreview
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.videoPreview
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.videoPreview
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                     constant:0.f]
                                    ];
    
    NSArray *roiLayout = @[[NSLayoutConstraint
                                     constraintWithItem:self.roiView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.roiView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.roiView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.roiView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                     constant:0.f]
                                    ];
    
    NSArray *quadrangleViewLayout = @[[NSLayoutConstraint
                                     constraintWithItem:self.quadrangleView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.quadrangleView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.quadrangleView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:0.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.quadrangleView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1.0f
                                     constant:0.f]
                                    ];
    
    NSArray *cancelButtonLayout = @[
                                    [NSLayoutConstraint
                                     constraintWithItem:self.cancelButton
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1.0f
                                     constant:-25.f],
                                    [NSLayoutConstraint
                                     constraintWithItem:self.cancelButton
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1.0f
                                     constant:-25.f]
                                      ];
    
    NSArray *cancelButtonConstants = @[
                                       [NSLayoutConstraint
                                        constraintWithItem:self.cancelButton
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0f
                                        constant:50.f],
                                       [NSLayoutConstraint
                                        constraintWithItem:self.cancelButton
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0f
                                        constant:50.f]
                                       ];
    
    [[self view] addConstraints:videoPreviewLayout];
    [[self view] addConstraints:quadrangleViewLayout];
    [[self view] addConstraints:cancelButtonLayout];
    [[self view] addConstraints:roiLayout];
    [[self cancelButton] addConstraints:cancelButtonConstants];
}
        

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [[self camera] setSampleBufferDelegate: weakSelf];
    [[self engine] setDelegate: weakSelf];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[self view] addSubview:[self videoPreview]];
    [[self view] addSubview:[self quadrangleView]];
    [[self view] addSubview:[self roiView]];
    if (!self.shouldDisplayRoi) {
        [[self roiView] setHidden:YES];
    }
    [[self view] addSubview:[self cancelButton]];
    [self makeLayout];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusButtonTapped:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    [[self view] addGestureRecognizer:gestureRecognizer];
}

- (void) configurePreviewView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
        if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
            initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
        }
        self.videoPreview.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
    });
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rotated:nil];
    if (!UIDeviceOrientationIsPortrait(self.lastOrientation) && !UIDeviceOrientationIsLandscape(self.lastOrientation)) {
        self.lastOrientation = UIDeviceOrientationPortrait;
    }
    
    [self updateRoi];
    [self configurePreviewView];
    [self.camera startCaptureSession];
    [[self engine] startSession:[[self camera] videoSize]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self engine] endSession];
    [[self camera] stopCaptureSession];
}

#pragma mark - roi

- (void)setRoiWithOffsetX:(CGFloat)offsetX andY:(CGFloat)offsetY orientation:(UIDeviceOrientation)orientation {
    [[self rois] setObject:@[@(offsetX), @(offsetY)] forKey:@(orientation)];
}

- (void) updateRoi {
    NSArray *offsets = [[self rois] objectForKey:@(self.lastOrientation)];
    UIInterfaceOrientation currentUIIO = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(currentUIIO)) {
        self.roiView.offsetY = [[offsets objectAtIndex:0] floatValue];
        self.roiView.offsetX = [[offsets objectAtIndex:1] floatValue];
    } else {
        self.roiView.offsetX = [[offsets objectAtIndex:0] floatValue];
        self.roiView.offsetY = [[offsets objectAtIndex:1] floatValue];
    }
    [self.roiView setNeedsDisplay];
    self.currentRoi =  [RoiHelper calculateRoiWith:self.lastOrientation
                                     viewSize:self.view.frame.size
                                  orientation:currentUIIO
                                   cameraSize:[[self camera] videoSize]
                                   andOffsets:CGSizeMake([[offsets objectAtIndex:0] floatValue],
                                                         [[offsets objectAtIndex:1] floatValue])];
}

#pragma mark - video processing

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([[self engine] isSessionRunning]) {
        NSLog(@"%@", NSStringFromCGRect(self.currentRoi));
        
        [[self engine] processSampleBuffer:sampleBuffer withOrientation:self.lastOrientation andRoi:self.currentRoi];
    }
}

- (void)smartIDVideoProcessingEngineDidRecognizeResult:(SmartIDRecognitionResult *)smartIdResult {}

- (void)smartIDVideoProcessingEngineDidProcessSnapshot {}

- (void)smartIDVideoProcessingEngineDidRejectSnapshot {}

- (void)smartIDVideoProcessingEngineDidCancel {}

- (void)smartIDVideoProcessingEngineDidSegmentResult:(NSArray<SmartIDQuadrangle *> *)quads {
    if ([self displayDocumentQuadrangle]) {
        for (SmartIDQuadrangle *quad in quads) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self quadrangleView] animateQuadrangle:quad
                                                   color:[UIColor greenColor]
                                                   width:1.0
                                                   alpha:1.0
                                                 offsetX:[self currentRoi].origin.x
                                                 offsetY:[self currentRoi].origin.y];
            });
        }
    }
}

- (void)smartIDVideoProcessingEngineDidMatchResult:(NSArray<SmartIDQuadrangle *> *)quads {
    if ([self displayZonesQuadrangles]) {
        for (SmartIDQuadrangle *quad in quads) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self quadrangleView] animateQuadrangle:quad
                                                   color:[UIColor greenColor]
                                                   width:1.0
                                                   alpha:1.0
                                                 offsetX:[self currentRoi].origin.x
                                                 offsetY:[self currentRoi].origin.y];
            });
        }
    }
}

#pragma mark - cancel button

- (UIButton *) cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_cancelButton setTitle:@"X" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30.0f]];
    }
    return _cancelButton;
}

- (void) focusButtonTapped:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer * senderAsGesture = (UITapGestureRecognizer *)sender;
        CGPoint location = [senderAsGesture locationInView:[self view]];
        [[self camera] focusAtPoint:location completionHandler:nil];
    }
}

#pragma mark - session

- (void)setSessionTimeout:(float)sessionTimeout {
    NSString *str = [[NSNumber numberWithFloat:sessionTimeout] stringValue];
    [[[self engine] settings] setValue:str toOptionWithName:@"common.sessionTimeout"];
}

#pragma mark - orientation handling

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.lastOrientation = deviceOrientation;
        [self interfaceOrDeviceOrientationDidChange];
        self.videoPreview.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self interfaceOrDeviceOrientationDidChange];
}
- (void)rotated:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.lastOrientation = deviceOrientation;
        [self interfaceOrDeviceOrientationDidChange];
    }
}

- (void) interfaceOrDeviceOrientationDidChange {
    [self updateRoi];
}

@end
