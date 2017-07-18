//
//  History+CoreDataProperties.h
//  歌力思
//
//  Created by greenis on 16/9/2.
//  Copyright © 2016年 wen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "History.h"

NS_ASSUME_NONNULL_BEGIN

@interface History (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *formulaID;
@property (nullable, nonatomic, retain) NSString *formulaName;
@property (nullable, nonatomic, retain) NSString *imgUrl;
@property (nullable, nonatomic, retain) NSString *gongxiao;
@property (nullable, nonatomic, retain) NSString *videoUrl;
@property (nullable, nonatomic, retain) NSString *steps;
@property (nullable, nonatomic, retain) NSString *shareurl;
@property (nullable, nonatomic, retain) NSString *cailiao;

@end

NS_ASSUME_NONNULL_END
