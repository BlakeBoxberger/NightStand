// Import header for custom class
#import "NZ9NightStandView.h"

@interface SBDashBoardView : UIView
@property (nonatomic, retain) NZ9NightStandView *nightStandView;
@end

%hook SBDashBoardView
%property (nonatomic, retain) NZ9NightStandView *nightStandView; // Adds a new property to the SBDashBoardView class

- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;

	// Creating NZ9NightStandView instance and setting autoresizingMask so it will have the same frame as its superview
	NZ9NightStandView *nightStandView = [[NZ9NightStandView alloc] initWithFrame: frame];
	nightStandView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	// Adding NZ9NightStandView as a subview of the SBDashBoardView
	[self addSubview: nightStandView];

	// Set property for easy access
	self.nightStandView = nightStandView;

  return self;
}

%end

// SBDashBoardIdleTimerProvider can disable the lock screen timeout
@interface SBDashBoardIdleTimerProvider : NSObject
@property (getter=isIdleTimerEnabled,nonatomic,readonly) BOOL idleTimerEnabled;
- (void)addDisabledIdleTimerAssertionReason:(id)arg1;
- (void)removeDisabledIdleTimerAssertionReason:(id)arg1;
@end

%hook SBDashBoardIdleTimerProvider

- (instancetype)initWithDelegate:(id)arg1 {
	%orig;

	// Begins listening for NightStand on/off notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffNightStandMode) name:@"NZ9NightStandOffNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnNightStandMode) name:@"NZ9NightStandOnNotification" object:nil];

	return self;
}

// Disables the lock screen timeout
%new - (void)turnOnNightStandMode {
	[self addDisabledIdleTimerAssertionReason:@"NZ9NightStand"];
}

// Disables the lock screen timeout 
%new - (void)turnOffNightStandMode {
	[self removeDisabledIdleTimerAssertionReason:@"NZ9NightStand"];
}

%end
