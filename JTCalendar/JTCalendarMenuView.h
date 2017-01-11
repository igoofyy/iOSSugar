//
//  JTCalendarMenuView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

@class JTCalendar;

typedef void (^UpdateCurrentDate)(NSDate *);

@interface JTCalendarMenuView : UIScrollView

@property (weak, nonatomic) JTCalendar *calendarManager;

@property (strong, nonatomic) NSDate *currentDate;

@property (nonatomic,copy) UpdateCurrentDate updateDate;

- (void)loadPreviousMonth;
- (void)loadNextMonth;

- (void)reloadAppearance;



@end


