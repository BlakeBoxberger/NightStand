#define kWidth [[UIApplication sharedApplication] keyWindow].frame.size.width
#define kHeight [[UIApplication sharedApplication] keyWindow].frame.size.height

@interface SBDashBoardView : UIView
@property (nonatomic, retain) UIStackView *nightstandView;
@property (nonatomic, retain) UILabel *nightstandTimeLabel;
@property (nonatomic, retain) UILabel *nightstandSubtitleLabel;
@property (nonatomic, retain) NSTimer *nightstandTimer;
- (void)setUpNightStandView;
- (void)setUpNotifications;
- (void)updateNightStandMode;
- (void)updateNightStandTime;
@end

%hook SBDashBoardView
%property (nonatomic, retain) UIView *nightstandView;
%property (nonatomic, retain) UILabel *nightstandTimeLabel;
%property (nonatomic, retain) UILabel *nightstandSubtitleLabel;

- (instancetype)initWithFrame:(CGRect)arg1 {
	self = %orig;
	[self setUpNightStandView];
  [self setUpNotifications];
  return self;
}

%new - (void)setUpNightStandView {
  self.nightstandView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
  self.nightstandView.axis = UILayoutConstraintAxisVertical;
  self.nightstandView.alignment = UIStackViewAlignmentCenter;
  self.nightstandView.alpha = 0.0;

  self.nightstandTimeLabel = [[UILabel alloc] init];
  self.nightstandTimeLabel.textColor = UIColor.greenColor;
  self.nightstandTimeLabel.font = [UIFont systemFontOfSize: 38.0];
  self.nightstandSubtitleLabel = [[UILabel alloc] init];
  self.nightstandSubtitleLabel.textColor = UIColor.greenColor;
  self.nightstandSubtitleLabel.font = [UIFont systemFontOfSize: 18.0];

  UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
  backgroundView.backgroundColor = UIColor.blackColor;

  [self.nightstandView addSubview: backgroundView];
  [self.nightstandView addArrangedSubview: self.nightstandTimeLabel];
  [self.nightstandView addArrangedSubview: self.nightstandSubtitleLabel];

	[self addSubview: self.nightstandView];
}

%new - (void)setUpNotifications {
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[UIDevice currentDevice] setBatteryMonitoringEnabled: YES];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNightStandMode) name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNightStandMode) name:UIDeviceBatteryStateDidChangeNotification object:nil];
  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateNightStandTime) userInfo:nil repeats:YES];
}

%new - (void)updateNightStandMode {
  UIDevice *device = [UIDevice currentDevice];
  UIDeviceOrientation orientation = device.orientation;
  UIDeviceBatteryState batteryState = device.batteryState;
  if (UIDeviceOrientationIsLandscape(orientation) && (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull)) {
    [UIView animateWithDuration: 0.125
						delay: 0.0
						options: nil
						animations: ^{
							self.nightstandView.alpha = 1.0;
						}
						completion: nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NZ9NightModeTurnedOn" object:nil];
  }
  else {
    [UIView animateWithDuration: 0.125
						delay: 0.0
						options: nil
						animations: ^{
							self.nightstandView.alpha = 0.0;
						}
						completion: nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NZ9NightModeTurnedOff" object:nil];
  }
}

%new - (void)updateNightStandTime {
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  dateFormatter.timeStyle = NSDateFormatterShortStyle;
  dateFormatter.dateStyle = NSDateFormatterNoStyle;
  self.nightstandTimeLabel.text = [dateFormatter stringFromDate: now];

  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  dateFormatter.dateStyle = NSDateFormatterMediumStyle;
  self.nightstandSubtitleLabel.text = [dateFormatter stringFromDate: now];
}

%end

// Disable idle timer
@interface SBDashBoardIdleTimerProvider : NSObject
@property (getter=isIdleTimerEnabled,nonatomic,readonly) BOOL idleTimerEnabled;
- (void)addDisabledIdleTimerAssertionReason:(id)arg1;
- (void)removeDisabledIdleTimerAssertionReason:(id)arg1;
@end

%hook SBDashBoardIdleTimerProvider

- (instancetype)initWithDelegate:(id)arg1 {
	%orig;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffNightStandMode) name:@"NZ9NightModeTurnedOff" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnNightStandMode) name:@"NZ9NightModeTurnedOn" object:nil];
	return self;
}

%new - (void)turnOnNightStandMode {
	[self addDisabledIdleTimerAssertionReason:@"NightStand"];
}

%new - (void)turnOffNightStandMode {
	[self removeDisabledIdleTimerAssertionReason:@"NightStand"];
}

%end
