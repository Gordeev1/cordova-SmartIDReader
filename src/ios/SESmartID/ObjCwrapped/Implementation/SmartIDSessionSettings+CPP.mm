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

#import "SmartIDSessionSettings+CPP.h"

@implementation SmartIDSessionSettings {
    std::unique_ptr<se::smartid::SessionSettings> settings_;
}

- (instancetype)initWithCPPInstance:(std::unique_ptr<se::smartid::SessionSettings> &&)settingsCPP {
    if (self = [super init]) {
        settings_ = std::move(settingsCPP);
    }
    return self;
}

- (se::smartid::SessionSettings &)getUnwrapped {
    return *settings_;
}

- (const std::unique_ptr<se::smartid::SessionSettings> &) getSettingsUnwrapped {
    return settings_;
}

- (NSArray<NSString *> *)getOptionNames {
    auto optionNames = settings_->GetOptionNames();
    NSMutableArray *names = [@[] mutableCopy];
    for (const auto& name : optionNames) {
        [names addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return names;
}

- (NSArray<NSString *> *)getEnabledDocumentTypes {
    NSMutableArray *docTypes = [@[] mutableCopy];
    for (const auto& type : settings_->GetEnabledDocumentTypes()) {
        [docTypes addObject:[NSString stringWithUTF8String:type.c_str()]];
    }
    return docTypes;
}

- (void) setSessionTimeout:(float)sessionTimeout {
    NSString *str = [[NSNumber numberWithFloat:sessionTimeout] stringValue];
    settings_->SetOption("common.sessionTimeout", str.UTF8String);
}

- (float) sessionTimeout {
    const std::string str = settings_->GetOption("common.sessionTimeout");
    float timeout = [[NSString stringWithUTF8String:str.c_str()] floatValue];
    return timeout;
}

- (void)addEnabledDocumentTypes:(NSString *)doctypeMask {
    settings_->AddEnabledDocumentTypes([doctypeMask UTF8String]);
}

- (void)removeEnabledDocumentTypes:(NSString *)doctypeMask {
    settings_->RemoveEnabledDocumentTypes([doctypeMask UTF8String]);
}

- (void)setEnabledDocumentTypes:(NSArray<NSString *> *)docTypes {
    std::vector<std::string> docTypesCPP;
    docTypesCPP.reserve([docTypes count]);
    for (NSString * type in docTypes) {
        docTypesCPP.push_back([type UTF8String]);
    }
    settings_->SetEnabledDocumentTypes(docTypesCPP);
}

- (NSArray<NSArray<NSString *> *> *)getSupportedDocumentTypes {
    NSMutableArray *docTypes = [@[] mutableCopy];
    for (const std::vector<std::string>& typeListCPP : settings_->GetSupportedDocumentTypes()) {
        NSMutableArray *typeList = [@[] mutableCopy];
        for (const std::string& type : typeListCPP) {
            [typeList addObject:[NSString stringWithUTF8String:type.c_str()]];
        }
        [docTypes addObject:typeList];
    }
    return docTypes;
}

- (NSDictionary<NSString *, NSString *> *)getOptions {
    const auto optionsCPP = settings_->GetOptions();
    NSMutableDictionary *options = [@{} mutableCopy];
    for (const auto& option : optionsCPP) {
        [options setValue:[NSString stringWithUTF8String:option.second.c_str()]
                   forKey:[NSString stringWithUTF8String:option.first.c_str()]];
    }
    return options;
}

- (BOOL)hasOptionWithName:(NSString *)name {
    return settings_->HasOption([name UTF8String]);
}

- (NSString *)getOptionWithName:(NSString *)name {
    return [NSString stringWithUTF8String:settings_->GetOption([name UTF8String]).c_str()];
}

- (void)setValue:(NSString *)value toOptionWithName:(NSString *)name {
    settings_->SetOption([name UTF8String], [value UTF8String]);
}

- (void)removeOptionWithName:(NSString *)name {
    settings_->RemoveOption([name UTF8String]);
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)getEnabledStringFieldNames {
    NSMutableDictionary *enalbedStringFieldNames = [@{} mutableCopy];
    const auto enabledStringFieldNamesCPP = settings_->GetEnabledStringFieldNames();
    for (const auto& fieldCPP : enabledStringFieldNamesCPP) {
        NSMutableArray *types = [@[] mutableCopy];
        for (const auto& type : fieldCPP.second) {
            [types addObject:[NSString stringWithUTF8String:type.c_str()]];
        }
        [enalbedStringFieldNames setValue:types forKey:[NSString stringWithUTF8String:fieldCPP.first.c_str()]];
    }
    return enalbedStringFieldNames;
}

- (void)enableStringFieldWithType:(NSString *)doctype andName:(NSString *)name {
    settings_->EnableStringField([doctype UTF8String], [name UTF8String]);
}

- (void)disableStringFieldWithType:(NSString *)doctype andName:(NSString *)name {
    settings_->DisableStringField([doctype UTF8String], [name UTF8String]);
}

- (void)setEnabledStringFieldsWithType:(NSString *)doctype andNames:(NSArray<NSString *> *)names {
    std::vector<std::string> namesCPP;
    namesCPP.reserve([names count]);
    for (NSString * name in names) {
        namesCPP.push_back([name UTF8String]);
    }
    settings_->SetEnabledStringFields([doctype UTF8String], namesCPP);
}

- (NSArray<NSString *> *)getSupportedFieldNamesForType:(NSString *)type {
    NSMutableArray *fieldNames = [@[] mutableCopy];
    const auto fieldNamesCPP = settings_->GetSupportedFieldNames([type UTF8String]);
    for (const auto& name : fieldNamesCPP) {
        [fieldNames addObject:[NSString stringWithUTF8String:name.c_str()]];
    }
    return fieldNames;
}


@end
