//
//  Liulanjilu+CoreDataProperties.h
//  歌力思
//
//  Created by greenis on 16/8/24.
//  Copyright © 2016年 wen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Liulanjilu.h"

NS_ASSUME_NONNULL_BEGIN

@interface Liulanjilu (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *gongxiao;
@property (nullable, nonatomic, retain) NSString *idss;
@property (nullable, nonatomic, retain) NSString *imageliulan;
@property (nullable, nonatomic, retain) NSString *titleFirst;
@property (nullable, nonatomic, retain) NSString *titleSecond;
@property (nullable, nonatomic, retain) NSString *videoURL;
@property (nullable, nonatomic, retain) NSString *shareUrl;
@property (nullable, nonatomic, retain) NSString *step;

@end

NS_ASSUME_NONNULL_END
