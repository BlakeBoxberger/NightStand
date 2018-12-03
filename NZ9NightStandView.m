// Import header for custom class
#import "NZ9NightStandView.h"

// Begin implementing custom class
@implementation NZ9NightStandView

// Override initWithFrame method of UIView and set properties
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame: frame]; // Call UIView's original initWithFrame method, returns instancetype

  if(self) { // Make sure self != nil

    // Set up timeLabel
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = UIColor.greenColor;
    timeLabel.font = [UIFont systemFontOfSize: 200.0];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [timeLabel sizeToFit];
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Set up subtitleLabel
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.textColor = UIColor.greenColor;
    subtitleLabel.font = [UIFont systemFontOfSize: 40.0];
    subtitleLabel.textAlignment = NSTextAlignmentRight;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Set up backgroundView (as a UIImageView, for a custom background)
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame: frame];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = UIColor.blackColor; // Make background black in case no image is set

    // Add views to the superview
    [self addSubview: backgroundView];
    [self addSubview: timeLabel];
    [self addSubview: subtitleLabel];

    // Add constraints to layout labels
    [timeLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant: 50.0].active = YES;
    [timeLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-50.0].active = YES;
    [subtitleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-50.0].active = YES;
    [timeLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant: 50.0].active = YES;
    [subtitleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant: 50.0].active = YES;
    [subtitleLabel.topAnchor constraintEqualToAnchor:timeLabel.bottomAnchor constant: 0.0].active = YES;


    // Set properties for easy access
    self.timeLabel = timeLabel;
    self.subtitleLabel = subtitleLabel;
    self.backgroundView = backgroundView;

    // Begin listening for notifications
    [self beginListeningForNotifications];

    // Hide NZ9NightStandView
    self.alpha = 0.0;
  }

  // Return instancetype
  return self;
}

// Update labels with current time
- (void)updateLabels {
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  dateFormatter.timeStyle = NSDateFormatterShortStyle;
  dateFormatter.dateStyle = NSDateFormatterNoStyle;
  self.timeLabel.text = [dateFormatter stringFromDate: now];

  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  dateFormatter.dateStyle = NSDateFormatterMediumStyle;
  self.subtitleLabel.text = [dateFormatter stringFromDate: now];
}

// Begins listening for device orientation and battery state notifications
- (void)beginListeningForNotifications {
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[UIDevice currentDevice] setBatteryMonitoringEnabled: YES];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForModeChange) name:UIDeviceOrientationDidChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForModeChange) name:UIDeviceBatteryStateDidChangeNotification object:nil];
  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}

// When the device orientation OR the battery state changes, check for mode change
- (void)checkForModeChange {

  // Gets device data
  UIDevice *device = [UIDevice currentDevice];
  UIDeviceOrientation orientation = device.orientation;
  UIDeviceBatteryState batteryState = device.batteryState;

  // Check if orientation is landscape AND if the device is charing OR fully charged
  if (UIDeviceOrientationIsLandscape(orientation) && (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull)) {
    [self showNightStand];
  }
  else {
    [self hideNightStand];
  }

}

// Animate view in and send a notification to disable the lock screen timeout
- (void)showNightStand {
  [UIView animateWithDuration: 0.125
          delay: 0.0
          options: UIViewAnimationOptionCurveEaseIn
          animations: ^{
            self.alpha = 1.0;
          }
          completion: nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"NZ9NightStandOnNotification" object:nil];
}

// Animate view out and send a notification to enable the lock screen timeout
- (void)hideNightStand {
  [UIView animateWithDuration: 0.125
          delay: 0.0
          options: UIViewAnimationOptionCurveEaseIn
          animations: ^{
            self.alpha = 0.0;
          }
          completion: nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"NZ9NightStandOffNotification" object:nil];
}

@end
