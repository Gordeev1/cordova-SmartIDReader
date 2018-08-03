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

#import "SmartIDRecognitionResult+CPP.h"

@implementation SmartIDRecognitionResult {
    std::unique_ptr<se::smartid::RecognitionResult> result_;
}

#pragma mark - C++

- (instancetype)init {
    if (self = [super init]) {
        if (result_.get() == nullptr) {
            result_.reset(new se::smartid::RecognitionResult());
        }
    }
    return self;
}

- (instancetype)initWithCPPInstance:(se::smartid::RecognitionResult &&)result {
    if (self = [super init]) {
        result_.reset(new se::smartid::RecognitionResult(std::move(result)));
    }
    return self;
}

- (se::smartid::RecognitionResult &)getUnwrapped {
    return *result_;
}


#pragma mark - utils

+ (UIImage *) wrapSmartIDImage:(const se::smartid::Image &)image {
    const bool shouldCopy = true;
    
    NSData *data = nil;
    if (shouldCopy) {
        data = [NSData dataWithBytes:image.data
                              length:image.height * image.stride];
    } else {
        data = [NSData dataWithBytesNoCopy:image.data
                                    length:image.height * image.stride
                              freeWhenDone:NO];
    }
    
    CGColorSpaceRef colorSpace;
    if (image.channels == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(image.width, // Width
                                        image.height, // Height
                                        8, // Bits per component
                                        8 * image.channels, // Bits per pixel
                                        image.stride, // Bytes per row
                                        colorSpace, // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault, // Bitmap info flags
                                        provider, // CGDataProviderRef
                                        NULL, // Decode
                                        false, // Should interpolate
                                        kCGRenderingIntentDefault); // Intent
    
    UIImage *ret = [UIImage imageWithCGImage:imageRef
                                       scale:1.0f
                                 orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

#pragma mark - wrap

- (NSArray<NSString *> *)getStringFieldNames {
    auto namesCPP = result_->GetStringFieldNames();
    NSMutableArray *namesObjC = [@[] mutableCopy];
    for (const auto& name : namesCPP) {
        [namesObjC addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return namesObjC;
}

- (BOOL)hasStringFieldWithName:(NSString *)name {
    return result_->HasStringField([name UTF8String]);
}

- (NSString *)getStringFieldWithName:(NSString *)name {
    return [NSString stringWithUTF8String:
            result_->GetStringField([name UTF8String]).GetName().c_str()];
}

- (NSDictionary<NSString *, NSString *> *)getStringFields {
    auto stringFieldsCPP = result_->GetStringFields();
    NSMutableDictionary *stringFieldsObjC = [@{} mutableCopy];
    for (const auto& field : stringFieldsCPP) {
        NSString *fieldName = [NSString stringWithUTF8String: field.first.c_str()];
        NSString *fieldValue = [NSString stringWithUTF8String:field.second.GetValue().GetUtf8String().c_str()];
        [stringFieldsObjC setObject:fieldValue forKey:fieldName];
    }
    return stringFieldsObjC;
}

- (NSArray<NSString *> *)getImageFieldNames {
    auto namesCPP = result_->GetImageFieldNames();
    NSMutableArray *namesObjC = [@[] mutableCopy];
    for (const auto& name : namesCPP) {
        [namesObjC addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return namesObjC;
}

- (BOOL)hasImageFieldWithName:(NSString *)name {
    return result_->HasImageField([name UTF8String]);
}

- (UIImage *)getImageFieldWithName:(NSString *)name {
    auto imageCPP = result_->GetImageField([name UTF8String]).GetValue();
    return [SmartIDRecognitionResult wrapSmartIDImage:imageCPP];
}

- (NSDictionary<NSString *, UIImage *> *)getImageFields {
    auto imageFieldsCPP = result_->GetImageFields();
    NSMutableDictionary *imageFieldsObjC = [@{} mutableCopy];
    for (const auto& field : imageFieldsCPP) {
        NSString *fieldName = [NSString stringWithUTF8String: field.first.c_str()];
        UIImage *fieldValue = [SmartIDRecognitionResult wrapSmartIDImage:field.second.GetValue()];
        [imageFieldsObjC setObject:fieldValue forKey:fieldName];
    }
    return imageFieldsObjC;
}

- (BOOL)isStringFieldAccepted:(NSString *)fieldname {
    return result_->GetStringField([fieldname UTF8String]).IsAccepted();
}

- (BOOL)isImageFieldAccepted:(NSString *)fieldname {
    return result_->GetImageField([fieldname UTF8String]).IsAccepted();
}

- (BOOL) isTerminal {
    return result_->IsTerminal();
}

@end
