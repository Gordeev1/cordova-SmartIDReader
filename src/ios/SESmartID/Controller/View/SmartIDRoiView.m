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

#import "SmartIDRoiView.h"

@interface SmartIDRoiView()


@end

@implementation SmartIDRoiView


- (instancetype)init {
    if (self = [super init]) {
        self.offsetX = 0;
        self.offsetY = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setOffsetsX:(CGFloat)offsetX Y:(CGFloat)offsetY {
    self.offsetX = offsetX;
    self.offsetY = offsetY;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextClipToRect(context, rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.offsetX, self.offsetY);
    CGPathAddLineToPoint(path, NULL, self.offsetX, rect.size.height - self.offsetY);
    CGPathAddLineToPoint(path, NULL, rect.size.width - self.offsetX, rect.size.height - self.offsetY);
    CGPathAddLineToPoint(path, NULL, rect.size.width - self.offsetX, self.offsetY);
    CGPathAddLineToPoint(path, NULL, self.offsetX, self.offsetY);

    
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGFloat red = 100.f / 255, green = 100.f / 255, blue = 103.f / 255;
    CGFloat alpha = 0.5;
    
    CGContextSetRGBStrokeColor(context, red, green, blue, 0.0);
    CGContextStrokePath(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextAddRect(context, self.bounds);
    CGContextEOClip(context);
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextFillRect(context, self.bounds);
    CGPathRelease(path);
    CGContextRestoreGState(context);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
