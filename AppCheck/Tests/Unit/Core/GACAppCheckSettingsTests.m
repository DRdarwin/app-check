/*
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "AppCheck/Sources/Core/GACAppCheckSettings.h"

#import "FirebaseCore/Extension/FirebaseCoreInternal.h"

// TODO(andrewheard): Remove from generic App Check SDK.
// FIREBASE_APP_CHECK_ONLY_BEGIN
NSString *const kGACAppCheckTokenAutoRefreshEnabledUserDefaultsPrefix =
    @"GACAppCheckTokenAutoRefreshEnabled_";
NSString *const kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey =
    @"FirebaseAppCheckTokenAutoRefreshEnabled";
// FIREBASE_APP_CHECK_ONLY_END

@interface GACAppCheckSettingsTests : XCTestCase

@property(nonatomic) GACAppCheckSettings *settings;

@property(nonatomic) id mockApp;
@property(nonatomic) id mockUserDefaults;
@property(nonatomic) id bundleMock;

@property(nonatomic) NSString *appName;
@property(nonatomic) NSString *userDefaultKey;

@end

@implementation GACAppCheckSettingsTests

- (void)setUp {
  [super setUp];

  self.appName = @"GACAppCheckSettingsTestsAppName";
  self.userDefaultKey =
      [kGACAppCheckTokenAutoRefreshEnabledUserDefaultsPrefix stringByAppendingString:self.appName];

  self.mockApp = OCMClassMock([FIRApp class]);
  OCMStub([self.mockApp name]).andReturn(self.appName);
  self.mockUserDefaults = OCMClassMock([NSUserDefaults class]);
  self.bundleMock = OCMClassMock([NSBundle class]);

  self.settings = [[GACAppCheckSettings alloc]
                       initWithUserDefaults:self.mockUserDefaults
                                 mainBundle:self.bundleMock
      tokenAutoRefreshPolicyUserDefaultsKey:[kGACAppCheckTokenAutoRefreshEnabledUserDefaultsPrefix
                                                stringByAppendingString:self.appName]
         tokenAutoRefreshPolicyInfoPListKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey];
}

- (void)tearDown {
  self.settings = nil;
  [self.mockApp stopMocking];
  self.mockApp = nil;
  [self.mockUserDefaults stopMocking];
  self.mockUserDefaults = nil;

  [super tearDown];
}

// TODO(andrewheard): Remove section from generic App Check SDK.
#ifdef FIREBASE_APP_CHECK_ONLY

- (void)testIsTokenAutoRefreshEnabledWhenDidNotExplicitlySet {
  BOOL appDataCollectionDefaultEnabled = YES;

  // 1. Configure expectations.
  // 1.1. Expect user defaults to be checked.
  OCMExpect([self.mockUserDefaults objectForKey:self.userDefaultKey]).andReturn(nil);

  // 1.2. Expect main bundle to be checked.
  OCMExpect(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey])
      .andReturn(nil);

  // 1.3. Expect `FIRApp.dataCollectionDefaultEnabled` to be used as the value.
  [[[self.mockApp stub] andReturnValue:@(appDataCollectionDefaultEnabled)]
      isDataCollectionDefaultEnabled];

  // 2. Check the flag value.
  XCTAssertEqual(self.settings.isTokenAutoRefreshEnabled, appDataCollectionDefaultEnabled);

  // 3. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testIsTokenAutoRefreshEnabledWhenSetThisAppRun {
  BOOL newFlagValue = YES;

  // 1. Configure expectations.
  // 1.1. Don't expect user defaults to be checked.
  OCMReject([self.mockUserDefaults objectForKey:self.userDefaultKey]);

  // 1.2. Don't expect main bundle to be checked.
  OCMReject(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey]);

  // 1.3. Don't expect `FIRApp.dataCollectionDefaultEnabled` to be used as the value.
  OCMReject([self.mockApp isDataCollectionDefaultEnabled]);

  // 1.4. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:newFlagValue forKey:self.userDefaultKey]);

  // 2. Set flag value.
  self.settings.isTokenAutoRefreshEnabled = newFlagValue;

  // 3. Check the flag value.
  XCTAssertEqual(self.settings.isTokenAutoRefreshEnabled, newFlagValue);

  // 4. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testIsTokenAutoRefreshEnabledWhenSetDuringPreviousLaunch {
  BOOL userDefaultValue = YES;

  // 1. Configure expectations.
  // 1.1. Expect user defaults to be checked.
  OCMExpect([self.mockUserDefaults objectForKey:self.userDefaultKey])
      .andReturn(@(userDefaultValue));

  // 1.2. Don't expect main bundle to be checked.
  OCMReject(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey]);

  // 1.3. Don't expect `FIRApp.dataCollectionDefaultEnabled` to be used as the value.
  OCMReject([self.mockApp isDataCollectionDefaultEnabled]);

  // 2. Check the flag value.
  XCTAssertEqual(self.settings.isTokenAutoRefreshEnabled, userDefaultValue);

  // 3. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testIsTokenAutoRefreshEnabledWhenSetInInfoPlist {
  BOOL infoPlistValue = YES;

  // 1. Configure expectations.
  // 1.1. Expect user defaults to be checked.
  OCMExpect([self.mockUserDefaults objectForKey:self.userDefaultKey]).andReturn(nil);

  // 1.2. Expect main bundle to be checked.
  OCMExpect(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey])
      .andReturn(@(infoPlistValue));

  // 1.3. Don't expect `FIRApp.dataCollectionDefaultEnabled` to be used as the value.
  OCMReject([self.mockApp isDataCollectionDefaultEnabled]);

  // 2. Check the flag value.
  XCTAssertEqual(self.settings.isTokenAutoRefreshEnabled, infoPlistValue);

  // 3. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testIsTokenAutoRefreshEnabledWhenAppDeallocated {
  // 1. Create settings instance.
  // Use an actual FIRApp instance as a fake app because OCMClassMock doesn't get deallocated on
  // `self.mockApp = nil;`
  FIROptions *options =
      [[FIROptions alloc] initWithGoogleAppID:@"1:100000000000:ios:aaaaaaaaaaaaaaaaaaaaaaaa"
                                  GCMSenderID:@"sender_id"];
  id dummyAppObject = [[FIRApp alloc] initInstanceWithName:self.appName options:options];
  __weak id weakApp = dummyAppObject;

  GACAppCheckSettings *settings = [[GACAppCheckSettings alloc]
                       initWithUserDefaults:self.mockUserDefaults
                                 mainBundle:self.bundleMock
      tokenAutoRefreshPolicyUserDefaultsKey:[kGACAppCheckTokenAutoRefreshEnabledUserDefaultsPrefix
                                                stringByAppendingString:self.appName]
         tokenAutoRefreshPolicyInfoPListKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey];

  XCTAssertNotNil(weakApp);

  // 2. Release app and make sure it is deallocated.
  dummyAppObject = nil;
  XCTAssertNil(weakApp);

  // 3. Configure expectations.
  // 3.1. Expect user defaults to be checked.
  OCMExpect([self.mockUserDefaults objectForKey:self.userDefaultKey]).andReturn(nil);

  // 3.2. Expect main bundle to be checked.
  OCMExpect(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey])
      .andReturn(nil);

  // 4. Check the flag value.
  XCTAssertEqual(settings.isTokenAutoRefreshEnabled, NO);

  // 5. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testSetIsTokenAutoRefreshEnabled {
  // 1. Set first time.
  // 1.1. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:YES forKey:self.userDefaultKey]);

  // 1.2 Set.
  self.settings.isTokenAutoRefreshEnabled = YES;

  // 1.3. Check.
  XCTAssertEqual(self.settings.isTokenAutoRefreshEnabled, YES);
  OCMVerifyAll(self.mockUserDefaults);

  // 2. Set second time.
  // 2.1. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:NO forKey:self.userDefaultKey]);

  // 2.2 Set.
  self.settings.isTokenAutoRefreshEnabled = NO;

  // 2.3. Check.
  XCTAssertEqual(self.settings.isTokenAutoRefreshEnabled, NO);
  OCMVerifyAll(self.mockUserDefaults);
}

#endif  // FIREBASE_APP_CHECK_ONLY

#pragma mark - GACAppCheckSettings Tests

- (void)testGetTokenAutoRefreshPolicyWhenDidNotExplicitlySet {
  // 1. Configure expectations.
  // 1.1. Expect user defaults to be checked.
  OCMExpect([self.mockUserDefaults objectForKey:self.userDefaultKey]).andReturn(nil);

  // 1.2. Expect main bundle to be checked.
  OCMExpect(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey])
      .andReturn(nil);

  // 2. Check the flag value.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy,
                 GACAppCheckTokenAutoRefreshPolicyUnspecified);

  // 3. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testGetTokenAutoRefreshPolicyWhenSetToDefault {
  // 1. Configure expectations.
  // 1.1. Expect user defaults to be checked.
  OCMExpect([self.mockUserDefaults objectForKey:self.userDefaultKey]).andReturn(nil);

  // 1.2. Expect main bundle to be checked.
  OCMExpect(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey])
      .andReturn(nil);

  // 1.3. Expect the user defaults value to be cleared.
  OCMExpect([self.mockUserDefaults removeObjectForKey:self.userDefaultKey]);

  // 2. Set the flag value.
  self.settings.tokenAutoRefreshPolicy = GACAppCheckTokenAutoRefreshPolicyUnspecified;

  // 3. Check the flag value.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy,
                 GACAppCheckTokenAutoRefreshPolicyUnspecified);

  // 4. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testGetTokenAutoRefreshPolicyWhenEnabledThisAppRun {
  // 1. Configure expectations.
  // 1.1. Don't expect user defaults to be checked.
  OCMReject([self.mockUserDefaults objectForKey:self.userDefaultKey]);

  // 1.2. Don't expect main bundle to be checked.
  OCMReject(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey]);

  // 1.3. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:YES forKey:self.userDefaultKey]);

  // 2. Set flag value.
  self.settings.tokenAutoRefreshPolicy = GACAppCheckTokenAutoRefreshPolicyEnabled;

  // 3. Check the flag value.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy, GACAppCheckTokenAutoRefreshPolicyEnabled);

  // 4. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testGetTokenAutoRefreshPolicyWhenDisabledThisAppRun {
  // 1. Configure expectations.
  // 1.1. Don't expect user defaults to be checked.
  OCMReject([self.mockUserDefaults objectForKey:self.userDefaultKey]);

  // 1.2. Don't expect main bundle to be checked.
  OCMReject(
      [self.bundleMock objectForInfoDictionaryKey:kGACAppCheckTokenAutoRefreshEnabledInfoPlistKey]);

  // 1.3. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:NO forKey:self.userDefaultKey]);

  // 2. Set flag value.
  self.settings.tokenAutoRefreshPolicy = GACAppCheckTokenAutoRefreshPolicyDisabled;

  // 3. Check the flag value.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy, GACAppCheckTokenAutoRefreshPolicyDisabled);

  // 4. Check mocks.
  OCMVerifyAll(self.mockUserDefaults);
  OCMVerifyAll(self.mockApp);
  OCMVerifyAll(self.bundleMock);
}

- (void)testSetTokenAutoRefreshPolicyDefault {
  // 1. Set first time.
  // 1.1. Expect the user defaults value to be cleared.
  OCMExpect([self.mockUserDefaults removeObjectForKey:self.userDefaultKey]);

  // 1.2 Set.
  self.settings.tokenAutoRefreshPolicy = GACAppCheckTokenAutoRefreshPolicyUnspecified;

  // 1.3. Check.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy,
                 GACAppCheckTokenAutoRefreshPolicyUnspecified);
  OCMVerifyAll(self.mockUserDefaults);
}

- (void)testSetTokenAutoRefreshPolicyEnabled {
  // 1. Set first time.
  // 1.1. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:YES forKey:self.userDefaultKey]);

  // 1.2 Set.
  self.settings.tokenAutoRefreshPolicy = GACAppCheckTokenAutoRefreshPolicyEnabled;

  // 1.3. Check.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy, GACAppCheckTokenAutoRefreshPolicyEnabled);
  OCMVerifyAll(self.mockUserDefaults);
}

- (void)testSetTokenAutoRefreshPolicyDisabled {
  // 1. Set first time.
  // 1.1. Expect the new value to be saved to the user defaults.
  OCMExpect([self.mockUserDefaults setBool:NO forKey:self.userDefaultKey]);

  // 1.2 Set.
  self.settings.tokenAutoRefreshPolicy = GACAppCheckTokenAutoRefreshPolicyDisabled;

  // 1.3. Check.
  XCTAssertEqual(self.settings.tokenAutoRefreshPolicy, GACAppCheckTokenAutoRefreshPolicyDisabled);
  OCMVerifyAll(self.mockUserDefaults);
}

@end
