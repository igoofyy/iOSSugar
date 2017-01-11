//
//  HRDBManger.h
//  HRManger
//
//  Created by goofygao on 9/8/16.
//  Copyright © 2016 goofyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YTKKeyValueStore/YTKKeyValueStore.h>

//typedef NS_ENUM(NSInteger, DBSaveType) {
//    DBSaveEaseMob,
//    DBSaveMyUserInfo,
//    DBSaveOthersUserInfo,
//    DBSaveSession,
//};
@interface HRDBManger : NSObject

//@property(nonatomic,assign) DBSaveType dbType;

+ (void)saveObject:(id)object withKey:(NSString *)keyName expire:(NSInteger)validTime;
+ (id)cacheObjectWithKey:(NSString *)keyName;
+ (void)deleteObjectWithKey:(NSString *)keyName;

+ (void)saveString:(NSString *)valueName withKey:(NSString *)keyName expire:(NSInteger)validTime;
+ (NSString *)getStringWithKey:(NSString *)keyName;

@end
