//
//  HRDBManger.m
//  HRManger
//
//  Created by goofygao on 9/8/16.
//  Copyright © 2016 goofyy. All rights reserved.
//

#import "HRDBManger.h"

@implementation HRDBManger

/**
 * validTime 单位秒，0表示不过期
 */
+ (void)saveObject:(id)object withKey:(NSString *)keyName expire:(NSInteger)validTime{
    
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:HR_SAVE_DB_NAME];
    [store createTableWithName:HR_SAVE_DB_TABLE_NAME];
    [store putObject:object withId:keyName intoTable:HR_SAVE_DB_TABLE_NAME];
    [store putNumber:[[NSNumber alloc]initWithInteger:validTime] withId:[NSString stringWithFormat:@"%@_validTime",keyName] intoTable:HR_SAVE_DB_TABLE_NAME];
}


+ (void)saveString:(NSString *)valueName withKey:(NSString *)keyName expire:(NSInteger)validTime{
    
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:HR_SAVE_DB_NAME];
    [store createTableWithName:HR_SAVE_DB_TABLE_NAME];
    [store putString:valueName withId:keyName intoTable:HR_SAVE_DB_TABLE_NAME];
    [store putNumber:[[NSNumber alloc]initWithInteger:validTime] withId:[NSString stringWithFormat:@"%@_validTime",keyName] intoTable:HR_SAVE_DB_TABLE_NAME];
}


+ (id)cacheObjectWithKey:(NSString *)keyName{
    
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:HR_SAVE_DB_NAME];
    [store createTableWithName:HR_SAVE_DB_TABLE_NAME];
    
    NSNumber *validTime = [store getNumberById:[NSString stringWithFormat:@"%@_validTime",keyName] fromTable:HR_SAVE_DB_TABLE_NAME];
    if ([validTime integerValue] > 0) {
        YTKKeyValueItem *item = [store getYTKKeyValueItemById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
        NSTimeInterval createTime = [item.createdTime timeIntervalSince1970];
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        
        if (nowTime - createTime > [validTime integerValue]) {
            [store deleteObjectById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
            [store deleteObjectById:[NSString stringWithFormat:@"%@_validTime",keyName] fromTable:HR_SAVE_DB_TABLE_NAME];
        }
    }
    
    id data = [store getObjectById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
    return data;
}

+ (void)deleteObjectWithKey:(NSString *)keyName {
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:HR_SAVE_DB_NAME];
    [store createTableWithName:HR_SAVE_DB_TABLE_NAME];
    [store deleteObjectById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
}

+ (NSString *)getStringWithKey:(NSString *)keyName{
    
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:HR_SAVE_DB_NAME];
    [store createTableWithName:HR_SAVE_DB_TABLE_NAME];
    
    NSNumber *validTime = [store getNumberById:[NSString stringWithFormat:@"%@_validTime",keyName] fromTable:HR_SAVE_DB_TABLE_NAME];
    if ([validTime integerValue] > 0) {
        YTKKeyValueItem *item = [store getYTKKeyValueItemById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
        NSTimeInterval createTime = [item.createdTime timeIntervalSince1970];
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        
        if (nowTime - createTime > [validTime integerValue]) {
            [store deleteObjectById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
            [store deleteObjectById:[NSString stringWithFormat:@"%@_validTime",keyName] fromTable:HR_SAVE_DB_TABLE_NAME];
        }
    }
    
    NSString *data = [store getStringById:keyName fromTable:HR_SAVE_DB_TABLE_NAME];
    return data;
}


@end
