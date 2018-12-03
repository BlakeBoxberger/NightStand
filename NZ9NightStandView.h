// Interface for custom NZ9NightStandView class

@interface NZ9NightStandView : UIView
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIImageView *backgroundView;
- (void)updateLabels;
- (void)beginListeningForNotifications;
- (void)checkForModeChange;
- (void)showNightStand;
- (void)hideNightStand;
@end
